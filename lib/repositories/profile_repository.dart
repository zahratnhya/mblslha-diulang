import 'dart:convert';
import 'dart:io';
import '../services/profile_service.dart';

/// Repository layer untuk mengelola business logic profile
class ProfileRepository {
  final ProfileService _service = ProfileService();

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    return await _service.fetchUserProfile(userId);
  }

  /// Update user profile (with Base64 image)
  /// ✅ WORKAROUND: Selalu kirim profile_image (foto lama atau baru)
  Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String name,
    required String email,
    required String campus,
    required String major,
    required String semester,
    File? imageFile,
    bool deleteImage = false,
    String? currentProfileImage, // ✅ TAMBAHAN: foto yang sudah ada
  }) async {
    // Validasi input
    if (name.trim().isEmpty) {
      return {'success': false, 'message': 'Name is required'};
    }
    if (email.trim().isEmpty) {
      return {'success': false, 'message': 'Email is required'};
    }
    if (!_isValidEmail(email.trim())) {
      return {'success': false, 'message': 'Invalid email format'};
    }
    if (campus.trim().isEmpty) {
      return {'success': false, 'message': 'Campus is required'};
    }
    if (major.trim().isEmpty) {
      return {'success': false, 'message': 'Major is required'};
    }
    if (semester.trim().isEmpty) {
      return {'success': false, 'message': 'Semester is required'};
    }

    // Prepare data untuk API
    final data = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      'campus': campus.trim(),
      'major': major.trim(),
      'semester': semester.trim(),
    };

    // ✅ WORKAROUND: SELALU kirim profile_image
    if (deleteImage) {
      // User ingin hapus foto - kirim null
      data['profile_image'] = null;
      print('🗑️ Sending: Delete profile image (set to null)');
    } else if (imageFile != null) {
      // User upload foto baru - kirim base64
      final fileSize = await imageFile.length();
      final maxSize = 5 * 1024 * 1024; // 5MB

      if (fileSize > maxSize) {
        return {
          'success': false,
          'message': 'Image size must be less than 5MB',
        };
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      data['profile_image'] = base64Image;
      print('📸 Sending: New profile image (${(fileSize / 1024).toStringAsFixed(2)} KB)');
    } else if (currentProfileImage != null && currentProfileImage.isNotEmpty) {
      // ✅ WORKAROUND: User tidak ubah foto - kirim foto lama
      data['profile_image'] = currentProfileImage;
      print('🔄 Sending: Existing profile image (preserved)');
    } else {
      // Tidak ada foto sama sekali
      data['profile_image'] = null;
      print('ℹ️ Sending: No profile image (null)');
    }

    print('📤 Data being sent to API: ${data.keys.toList()}');

    return await _service.updateUserProfile(
      userId: userId,
      data: data,
    );
  }

  /// Delete (set null) profile image
  Future<Map<String, dynamic>> deleteProfileImage(int userId) async {
    final data = {
      'profile_image': null,
    };
    return await _service.updateUserProfile(userId: userId, data: data);
  }

  /// Email format validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// User initials
  String getUserInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Format semester
  String formatSemester(String? semester) {
    if (semester == null || semester.isEmpty) return '-';
    return 'Semester $semester';
  }

  /// Check existing profile image
  bool hasProfileImage(Map<String, dynamic> userData) {
    return userData['profile_image'] != null &&
        userData['profile_image'].toString().isNotEmpty;
  }

  /// Supported file types
  List<String> getSupportedImageExtensions() {
    return ['jpg', 'jpeg', 'png'];
  }

  /// Validate image extension
  bool isValidImageFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return getSupportedImageExtensions().contains(extension);
  }
}