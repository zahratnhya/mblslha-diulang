import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service layer untuk mengelola semua operasi data home page
class HomeService {
  static const String _baseUrl = "https://zahraapi.xyz/campus_api/index.php";

  /// Mengambil data user berdasarkan user_id
  Future<Map<String, dynamic>> fetchUser(int userId) async {
    final url = Uri.parse("$_baseUrl?path=users&id=$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'] ?? {};
      }
      return {};
    } catch (e) {
      print('Error fetching user: $e');
      return {};
    }
  }

  /// Mengambil schedule berdasarkan user_id dan tanggal
  Future<List<dynamic>> fetchSchedule(int userId, String date) async {
    final url = Uri.parse("$_baseUrl?path=schedule&user_id=$userId&date=$date");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'] is List ? jsonData['data'] : [];
      }
      return [];
    } catch (e) {
      print('Error fetching schedule: $e');
      return [];
    }
  }

  /// Mengambil task today berdasarkan user_id
  Future<List<dynamic>> fetchTaskToday(int userId) async {
    final url = Uri.parse("$_baseUrl?path=tasktoday&user_id=$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'] is List ? jsonData['data'] : [];
      }
      return [];
    } catch (e) {
      print('Error fetching task today: $e');
      return [];
    }
  }

  /// Mengambil semua tasks berdasarkan user_id
  Future<List<dynamic>> fetchAllTasks(int userId) async {
    final url = Uri.parse("$_baseUrl?path=tasks&user_id=$userId");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData['data'] is List ? jsonData['data'] : [];
      }
      return [];
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  /// Update status task menjadi done (status = 1)
  Future<Map<String, dynamic>> updateTaskStatus({
    required int taskId,
    required String title,
    required String time,
  }) async {
    final url = Uri.parse("$_baseUrl?path=tasktoday&id=$taskId");

    try {
      // Format time dengan benar (HH:mm:ss)
      String formattedTime = time;
      if (!formattedTime.contains(':')) {
        formattedTime = "00:00:00";
      } else if (formattedTime.split(':').length == 2) {
        formattedTime = "$formattedTime:00";
      }

      final requestBody = {
        "title": title,
        "time": formattedTime,
        "status": 1,
      };

      print('===== UPDATE TASK =====');
      print('URL: $url');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=======================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'] ?? 'Unknown error',
        };
      }

      return {
        'success': false,
        'message': 'HTTP Error: ${response.statusCode}',
      };
    } catch (e) {
      print('Error updating task: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}