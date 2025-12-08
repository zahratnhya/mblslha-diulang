import '../services/auth_service.dart';

/// Repository layer untuk mengelola business logic authentication
class AuthRepository {
  final AuthService _service = AuthService();

  /// Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    // Validasi input
    if (email.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Email is required',
        'userId': null,
      };
    }

    if (password.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Password is required',
        'userId': null,
      };
    }

    // Validasi format email
    if (!_isValidEmail(email.trim())) {
      return {
        'success': false,
        'message': 'Invalid email format',
        'userId': null,
      };
    }

    // Call service
    final result = await _service.login(
      email: email.trim(),
      password: password.trim(),
    );

    // Process result
    if (result['success'] == true && result['user'] != null) {
      final userId = int.parse(result['user']['id'].toString());
      return {
        'success': true,
        'message': 'Login successful',
        'userId': userId,
      };
    }

    return {
      'success': false,
      'message': result['message'] ?? 'Login failed',
      'userId': null,
    };
  }

  /// Validasi format email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}