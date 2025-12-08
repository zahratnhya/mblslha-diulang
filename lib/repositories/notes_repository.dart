import '../services/notes_service.dart';

//// Repository layer untuk mengelola data notes
/// Berfungsi sebagai abstraksi antara service dan UI
class NotesRepository {
  final NotesService _service = NotesService();

  /// Mendapatkan semua notes untuk user tertentu
  Future<List<dynamic>> getNotes(int userId) async {
    return await _service.fetchNotes(userId);
  }

  /// Membuat note baru
  Future<bool> addNote({
    required int userId,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final today = _formatDateForApi(now);

    return await _service.createNote(
      userId: userId,
      title: title,
      summary: content,
      date: today,
    );
  }

  /// Mengupdate note yang sudah ada
  Future<bool> editNote({
    required String noteId,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final today = _formatDateForApi(now);

    return await _service.updateNote(
      noteId: noteId,
      title: title,
      summary: content,
      date: today,
    );
  }

  /// Menghapus note
  Future<bool> removeNote(String noteId) async {
    return await _service.deleteNote(noteId);
  }

  /// Filter notes berdasarkan query pencarian
  List<dynamic> filterNotes(List<dynamic> notes, String query) {
    if (query.isEmpty) return notes;

    return notes.where((note) {
      final title = (note['title'] ?? '').toString().toLowerCase();
      final summary = (note['summary'] ?? '').toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery) || summary.contains(searchQuery);
    }).toList();
  }

  /// Format DateTime ke string untuk API (YYYY-MM-DD)
  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}