import 'dart:async';

import '../../../core/storage/local_storage_service.dart';
import '../models/attendance_event_model.dart';

class AttendanceCacheService {
  static const boxName = 'attendance_events';
  final _storage = LocalStorageService();
  static final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  // Restores the attendance event log in original action order.
  Future<List<AttendanceEventModel>> read() async {
    final box = await _storage.openBox<AttendanceEventModel>(boxName);
    final events = box.values.toList();
    events.sort((a, b) {
      final date = a.companyDate.compareTo(b.companyDate);
      if (date != 0) return date;
      final action = a.action.index.compareTo(b.action.index);
      if (action != 0) return action;
      final time = a.occurredAt.compareTo(b.occurredAt);
      return time != 0 ? time : a.id.compareTo(b.id);
    });
    return List.unmodifiable(events);
  }

  // Persists a new event or delivery update under its permanent event ID.
  Future<void> save(AttendanceEventModel event) async {
    final box = await _storage.openBox<AttendanceEventModel>(boxName);
    await box.put(event.id, event);
    await box.flush();
    _changes.add(null);
  }
}
