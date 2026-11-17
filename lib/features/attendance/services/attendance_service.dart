import '../../../core/network/api_service.dart';
import '../models/attendance_record_model.dart';
import '../models/attendance_event_model.dart';
import '../../../core/network/api_exception.dart';

class AttendanceService {
  AttendanceService({String? baseUrl}) : _api = ApiService(baseUrl: baseUrl);

  final ApiService _api;

  // Submits the original event ID and verifies the server acknowledgement.
  Future<void> submit(AttendanceEventModel event) async {
    final response = await _api.post('/attendance/events', event.toJson());
    if (response['event_id'] != event.id) {
      throw const ApiException(ApiFailure.invalidResponse);
    }
  }

  // Loads the latest five sessions across month boundaries.
  Future<List<AttendanceRecordModel>> fetchRecent() async {
    final response = await _api.get('/attendance', query: {'limit': '5'});
    final records = (response['records'] as List)
        .map(
          (item) =>
              AttendanceRecordModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
    records.sort((a, b) => b.checkIn.compareTo(a.checkIn));
    return List.unmodifiable(records.take(5));
  }
}
