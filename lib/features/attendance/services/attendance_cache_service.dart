import '../../../core/storage/local_storage_service.dart';
import '../models/attendance_event_model.dart';

class AttendanceCacheService {
  static const boxName = 'attendance_events';
  final _storage = LocalStorageService();

  // Restores the attendance event log in original action order.
  Future<List<AttendanceEventModel>> read() async {
    final box = await _storage.openBox<AttendanceEventModel>(boxName);
    final events = box.values.toList();
    events.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return List.unmodifiable(events);
  }

  // Persists a new event or delivery update under its permanent event ID.
  Future<void> save(AttendanceEventModel event) async {
    final box = await _storage.openBox<AttendanceEventModel>(boxName);
    await box.put(event.id, event);
    await box.flush();
  }
}
