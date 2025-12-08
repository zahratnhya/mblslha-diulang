import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String _baseUrl = "https://zahraapi.xyz/campus_api/index.php";

  /// ==========================================================
  /// GET USER PROFILE
  /// ==========================================================
  Future<Map<String, dynamic>> fetchUserProfile(int userId) async {
    final url = Uri.parse("$_baseUrl?path=users&id=$userId");

    try {
      print("===== FETCH USER PROFILE =====");
      print("URL: $url");

      final response = await http.get(url);

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      print("===============================");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded["success"] == true && decoded["data"] != null) {
          return {
            "success": true,
            "data": decoded["data"],
          };
        }
      }

      return {"success": false, "message": "Failed to fetch profile"};
    } catch (e) {
      print("Error fetching profile: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// ==========================================================
  /// UPDATE USER PROFILE (Base64 Image)
  /// ==========================================================
  Future<Map<String, dynamic>> updateUserProfile({
    required int userId,
    required Map<String, dynamic> data,
  }) async {
    final url = Uri.parse("$_baseUrl?path=users&id=$userId");

    try {
      print("===== UPDATE USER PROFILE =====");
      print("URL: $url");

      final body = jsonEncode(data);
      print("Sending Body: $body");

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("===============================");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        return {
          "success": decoded["success"] ?? false,
          "message": decoded["message"] ?? "Unknown response",
        };
      }

      return {
        "success": false,
        "message": "HTTP Error ${response.statusCode}",
      };
    } catch (e) {
      print("Error updating profile: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  /// ==========================================================
  /// DELETE PROFILE IMAGE (Set NULL)
  /// ==========================================================
  Future<Map<String, dynamic>> deleteProfileImage(int userId) async {
    final url = Uri.parse("$_baseUrl?path=users&id=$userId");

    try {
      print("===== DELETE PROFILE IMAGE =====");
      print("URL: $url");

      final body = jsonEncode({"profile_image": null});

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("Status: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("===============================");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        return {
          "success": decoded["success"] ?? false,
          "message": decoded["message"] ?? "Unknown response",
        };
      }

      return {
        "success": false,
        "message": "HTTP Error ${response.statusCode}",
      };
    } catch (e) {
      print("Error deleting image: $e");
      return {"success": false, "message": e.toString()};
    }
  }
}
