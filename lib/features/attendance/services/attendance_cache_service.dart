import 'dart:async';

import '../../../core/storage/local_storage_service.dart';
import '../models/attendance_event_model.dart';

class AttendanceCacheService {
  static const boxName = 'attendance_events';
  final _storage = LocalStorageService();
  static final _changes = StreamController<void>.broadcast();
  static Future<void> _operation = Future.value();

  Stream<void> get changes => _changes.stream;

  // Serializes access so readers cannot observe an event before its save finishes.
  Future<T> _serialize<T>(Future<T> Function() operation) {
    final result = _operation.then((_) => operation());
    _operation = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );
    return result;
  }

  // Restores the attendance event log after earlier writes are durable.
  Future<List<AttendanceEventModel>> read() => _serialize(() async {
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
    return List<AttendanceEventModel>.unmodifiable(events);
  });

  // Persists a new event or delivery update under its permanent event ID.
  Future<void> save(AttendanceEventModel event) => _serialize(() async {
    final box = await _storage.openBox<AttendanceEventModel>(boxName);
    await box.put(event.id, event);
    await box.flush();
    _changes.add(null);
  });
}
