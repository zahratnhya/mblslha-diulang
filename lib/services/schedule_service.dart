import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service layer untuk mengelola operasi schedule
class ScheduleService {
  static const String _baseUrl = "https://zahraapi.xyz/campus_api/index.php";

  /// Menghapus schedule berdasarkan id
  Future<Map<String, dynamic>> deleteSchedule(String scheduleId) async {
    final url = Uri.parse("$_baseUrl?path=schedule&id=$scheduleId");

    try {
      print('===== DELETE SCHEDULE =====');
      print('URL: $url');

      final response = await http.delete(url);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('===========================');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {
          'success': decoded['success'] ?? false,
          'message': decoded['message'] ?? 'Unknown error',
        };
      }

      return {
        'success': false,
        'message': 'HTTP Error ${response.statusCode}',
      };
    } catch (e) {
      print('Error deleting schedule: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Mengupdate schedule
  Future<Map<String, dynamic>> updateSchedule({
    required String scheduleId,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse("$_baseUrl?path=schedule&id=$scheduleId");

    try {
      final body = jsonEncode(data);

      print('===== UPDATE SCHEDULE =====');
      print('URL: $url');
      print('Body: $body');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('===========================');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {
          'success': decoded['success'] ?? false,
          'message': decoded['message'] ?? 'Unknown error',
          'data': decoded['data'],
        };
      }

      return {
        'success': false,
        'message': 'HTTP Error ${response.statusCode}',
      };
    } catch (e) {
      print('Error updating schedule: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Mengambil semua schedule berdasarkan user_id dan tanggal
  Future<List<dynamic>> fetchSchedules(int userId, String date) async {
    final url = Uri.parse("$_baseUrl?path=schedule&user_id=$userId&date=$date");

    try {
      print('===== FETCH SCHEDULES =====');
      print('URL: $url');

      final response = await http.get(url);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('===========================');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        if (decoded["success"] == true) {
          return decoded["data"] is List ? decoded["data"] : [];
        }
      }

      return [];
    } catch (e) {
      print('Error fetching schedules: $e');
      return [];
    }
  }

  /// Membuat schedule baru
  Future<Map<String, dynamic>> createSchedule({
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse("$_baseUrl?path=schedule");

    try {
      final body = jsonEncode(data);

      print('===== CREATE SCHEDULE =====');
      print('URL: $url');
      print('Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('===========================');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {
          'success': decoded['success'] ?? false,
          'message': decoded['message'] ?? 'Unknown error',
        };
      }

      return {
        'success': false,
        'message': 'HTTP Error ${response.statusCode}',
      };
    } catch (e) {
      print('Error creating schedule: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}