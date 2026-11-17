import '../../../core/network/api_service.dart';
import '../models/attendance_record_model.dart';

class AttendanceService {
  final _api = ApiService();

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
