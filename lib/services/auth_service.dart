import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service layer untuk mengelola operasi authentication
class AuthService {
  static const String _baseUrl = "https://zahraapi.xyz/campus_api/index.php";

  /// Login user dengan email dan password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl?path=users&action=login");

    try {
      print('===== LOGIN REQUEST =====');
      print('URL: $url');
      print('Email: $email');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('========================');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {
          'success': decoded['success'] ?? false,
          'message': decoded['message'] ?? 'Unknown error',
          'user': decoded['user'],
        };
      }

      return {
        'success': false,
        'message': 'HTTP Error ${response.statusCode}',
        'user': null,
      };
    } catch (e) {
      print('Error during login: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
        'user': null,
      };
    }
  }
}