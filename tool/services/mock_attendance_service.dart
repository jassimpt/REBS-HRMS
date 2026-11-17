import 'dart:convert';
import 'dart:io';

import 'package:rebs_hrms/core/helpers/company_clock.dart';
import 'package:rebs_hrms/core/helpers/location_helper.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_action.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_event_model.dart';
import 'package:rebs_hrms/features/attendance/models/attendance_record_model.dart';

class MockAttendanceException implements Exception {
  const MockAttendanceException(this.code, {this.status = 409});
  final String code;
  final int status;
}

class MockAttendanceService {
  MockAttendanceService({this.storagePath});

  final String? storagePath;
  Map<String, Map<String, dynamic>> _accepted = {};
  Future<void> _submission = Future.value();

  // Restores accepted event identities independently of the mobile app cache.
  Future<void> initialize() async {
    if (storagePath == null) return;
    final file = File(storagePath!);
    if (!await file.exists()) return;
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    _accepted = data.map(
      (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
    );
  }

  // Merges accepted sessions with the configured demonstration fixtures.
  List<Map<String, dynamic>> records(List<Map<String, dynamic>> fixtures) {
    final sessions = {
      for (final record in fixtures) record['date'] as String: record,
    };
    for (final entry in _accepted.values) {
      final record = Map<String, dynamic>.from(entry['record'] as Map);
      sessions[record['date'] as String] = record;
    }
    return sessions.values.toList()
      ..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
  }

  // Serializes submissions so concurrent requests cannot create duplicate sessions.
  Future<Map<String, dynamic>> submit(
    AttendanceEventModel event,
    List<Map<String, dynamic>> fixtures, {
    required String timezone,
    required double officeLatitude,
    required double officeLongitude,
    bool forceConflict = false,
  }) {
    final result = _submission.then(
      (_) => _accept(
        event,
        fixtures,
        timezone: timezone,
        officeLatitude: officeLatitude,
        officeLongitude: officeLongitude,
        forceConflict: forceConflict,
      ),
    );
    _submission = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  // Repeats server rules and returns the original result for an identical retry.
  Future<Map<String, dynamic>> _accept(
    AttendanceEventModel event,
    List<Map<String, dynamic>> fixtures, {
    required String timezone,
    required double officeLatitude,
    required double officeLongitude,
    required bool forceConflict,
  }) async {
    final existing = _accepted[event.id];
    if (existing != null) {
      if (jsonEncode(existing['payload']) != jsonEncode(event.toJson())) {
        throw const MockAttendanceException('idempotency_mismatch');
      }
      return {'event_id': event.id, 'record': existing['record']};
    }
    if (forceConflict) throw const MockAttendanceException('attendance_exists');
    final now = DateTime.now().toUtc();
    if (event.employeeId != 'REBS-1042' ||
        event.id.isEmpty ||
        event.sessionId.isEmpty ||
        event.companyDate != CompanyClock.dateKey(event.occurredAt, timezone) ||
        event.occurredAt.isAfter(now.add(const Duration(minutes: 5)))) {
      throw const MockAttendanceException('invalid_event', status: 422);
    }
    final location = event.location;
    if (!location.latitude.isFinite ||
        location.latitude.abs() > 90 ||
        !location.longitude.isFinite ||
        location.longitude.abs() > 180 ||
        !location.accuracy.isFinite ||
        location.accuracy < 0 ||
        event.occurredAt.difference(location.capturedAt).inSeconds.abs() >
            120 ||
        LocationHelper.distance(
              location.latitude,
              location.longitude,
              officeLatitude,
              officeLongitude,
            ) >
            200) {
      throw const MockAttendanceException('invalid_location', status: 422);
    }
    final sessions = records(fixtures);
    final sameDay = sessions
        .where((record) => record['date'] == event.companyDate)
        .firstOrNull;
    late AttendanceRecordModel record;
    if (event.action == AttendanceAction.checkIn) {
      if (sameDay != null) {
        throw const MockAttendanceException('attendance_exists');
      }
      if (event.sessionId != event.id) {
        throw const MockAttendanceException('invalid_event', status: 422);
      }
      record = AttendanceRecordModel(
        id: event.sessionId,
        date: event.companyDate,
        checkIn: event.occurredAt,
      );
    } else {
      if (sameDay == null) {
        throw const MockAttendanceException('check_in_required');
      }
      final original = AttendanceRecordModel.fromJson(sameDay);
      if (original.id != event.sessionId || original.checkOut != null) {
        throw const MockAttendanceException('attendance_exists');
      }
      if (event.occurredAt.isBefore(original.checkIn)) {
        throw const MockAttendanceException('invalid_event', status: 422);
      }
      record = AttendanceRecordModel(
        id: original.id,
        date: original.date,
        checkIn: original.checkIn,
        checkOut: event.occurredAt,
      );
    }
    final next = {
      ..._accepted,
      event.id: {'payload': event.toJson(), 'record': record.toJson()},
    };
    if (storagePath != null) {
      final file = File(storagePath!);
      await file.parent.create(recursive: true);
      final temporary = File('$storagePath.tmp');
      await temporary.writeAsString(jsonEncode(next), flush: true);
      await temporary.rename(file.path);
    }
    _accepted = next;
    return {'event_id': event.id, 'record': record.toJson()};
  }
}
