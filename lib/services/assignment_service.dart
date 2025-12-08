import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service layer untuk mengelola operasi assignments/tasks
class AssignmentService {
  static const String _baseUrl = "https://zahraapi.xyz/campus_api/index.php";

  /// Mengambil semua assignments berdasarkan user_id
  Future<List<dynamic>> fetchAssignments(int userId) async {
    final url = Uri.parse("$_baseUrl?path=tasks&user_id=$userId");

    try {
      print('===== FETCH ASSIGNMENTS =====');
      print('URL: $url');

      final response = await http.get(url);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==============================');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['data'] is List ? decoded['data'] : [];
      }

      return [];
    } catch (e) {
      print('Error fetching assignments: $e');
      return [];
    }
  }

  /// Mengupdate assignment
  Future<Map<String, dynamic>> updateAssignment({
    required String assignmentId,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse("$_baseUrl?path=tasks&id=$assignmentId");

    try {
      final body = jsonEncode(data);

      print('===== UPDATE ASSIGNMENT =====');
      print('URL: $url');
      print('Body: $body');

      // ✅ Tambahkan timeout 10 detik
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==============================');

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
      print('Error updating assignment: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Menghapus assignment
  Future<Map<String, dynamic>> deleteAssignment(String assignmentId) async {
    final url = Uri.parse("$_baseUrl?path=tasks&id=$assignmentId");

    try {
      print('===== DELETE ASSIGNMENT =====');
      print('URL: $url');

      final response = await http.delete(url);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==============================');

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
      print('Error deleting assignment: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Mark assignment sebagai completed - ✅ FIXED: Tambah description
  Future<Map<String, dynamic>> markAsCompleted({
    required String assignmentId,
    required String title,
    required String time,
    required String deadline,
    required String description,  // ✅ DITAMBAHKAN
  }) async {
    final url = Uri.parse("$_baseUrl?path=tasks&id=$assignmentId");

    try {
      final body = jsonEncode({
        "title": title,
        "time": time,
        "deadline": deadline,
        "description": description,  // ✅ DITAMBAHKAN
        "status": 1,
      });

      print('===== MARK AS COMPLETED =====');
      print('URL: $url');
      print('Body: $body');

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==============================');

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
      print('Error marking as completed: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Mark assignment sebagai incomplete - ✅ FIXED: Tambah description
  Future<Map<String, dynamic>> markAsIncomplete({
    required String assignmentId,
    required String title,
    required String time,
    required String deadline,
    required String description,  // ✅ DITAMBAHKAN
  }) async {
    final url = Uri.parse("$_baseUrl?path=tasks&id=$assignmentId");

    try {
      final body = jsonEncode({
        "title": title,
        "time": time,
        "deadline": deadline,
        "description": description,  // ✅ DITAMBAHKAN
        "status": 0,
      });

      print('===== MARK AS INCOMPLETE =====');
      print('URL: $url');
      print('Body: $body');

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==============================');

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
      print('Error marking as incomplete: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  /// Membuat assignment baru
  Future<Map<String, dynamic>> createAssignment({
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse("$_baseUrl?path=tasks");

    try {
      final body = jsonEncode(data);

      print('===== CREATE ASSIGNMENT =====');
      print('URL: $url');
      print('Body: $body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==============================');

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
      print('Error creating assignment: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}