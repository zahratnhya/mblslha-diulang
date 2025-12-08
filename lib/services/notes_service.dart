import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service layer untuk mengelola semua operasi CRUD notes
class NotesService {
  static const String _baseUrl = "https://zahraapi.xyz/campus_api/index.php";

  /// Mengambil semua notes berdasarkan user_id
  Future<List<dynamic>> fetchNotes(int userId) async {
    final url = Uri.parse("$_baseUrl?path=notes&user_id=$userId");

    try {
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        return jsonData["data"] is List ? jsonData["data"] : [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching notes: $e');
      return [];
    }
  }

  /// Membuat note baru
  Future<bool> createNote({
    required int userId,
    required String title,
    required String summary,
    required String date,
  }) async {
    final url = Uri.parse("$_baseUrl?path=notes");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "title": title.isEmpty ? "Untitled" : title,
          "summary": summary,
          "date": date,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating note: $e');
      return false;
    }
  }

  /// Mengupdate note yang sudah ada
  Future<bool> updateNote({
    required String noteId,
    required String title,
    required String summary,
    required String date,
  }) async {
    final url = Uri.parse("$_baseUrl?path=notes&id=$noteId");

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title.isEmpty ? "Untitled" : title,
          "summary": summary,
          "date": date,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error updating note: $e');
      return false;
    }
  }

  /// Menghapus note
  Future<bool> deleteNote(String noteId) async {
    if (noteId.isEmpty) return false;

    final url = Uri.parse("$_baseUrl?path=notes&id=$noteId");

    try {
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }
}