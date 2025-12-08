import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service layer untuk mengelola operasi task
class TaskService {
  static const String _baseUrl = "https://zahraapi.xyz/campus_api/index.php";

  /// Membuat task baru
  Future<bool> createTask({
    required int userId,
    required String title,
    required String time,
    required int status,
  }) async {
    final url = Uri.parse("$_baseUrl?path=tasktoday");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "title": title,
          "time": time,
          "status": status,
        }),
      );

      print('===== CREATE TASK =====');
      print('URL: $url');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=======================');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating task: $e');
      return false;
    }
  }

  /// Mengupdate task yang sudah ada
  Future<bool> updateTask({
    required int taskId,
    required String title,
    required String time,
    required int status,
  }) async {
    final url = Uri.parse("$_baseUrl?path=tasktoday&id=$taskId");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "time": time,
          "status": status,
        }),
      );

      print('===== UPDATE TASK =====');
      print('URL: $url');
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=======================');

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  /// Menghapus task
  Future<bool> deleteTask(int taskId) async {
    final url = Uri.parse("$_baseUrl?path=tasktoday&id=$taskId");

    try {
      final response = await http.delete(url);

      print('===== DELETE TASK =====');
      print('URL: $url');
      print('Response Status: ${response.statusCode}');
      print('=======================');

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }
}