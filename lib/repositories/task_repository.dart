import '../services/task_service.dart';

/// Repository layer untuk mengelola business logic task
class TaskRepository {
  final TaskService _service = TaskService();

  /// Menambahkan task baru
  Future<bool> addTask({
    required int userId,
    required String title,
    required String time,
    required bool status,
  }) async {
    // Validasi input
    if (title.trim().isEmpty) {
      return false;
    }

    if (time.trim().isEmpty) {
      return false;
    }

    // Validasi format waktu (HH:mm atau HH:mm:ss)
    if (!_isValidTimeFormat(time)) {
      return false;
    }

    // Format waktu ke HH:mm:ss jika perlu
    final formattedTime = _formatTime(time);

    return await _service.createTask(
      userId: userId,
      title: title.trim(),
      time: formattedTime,
      status: status ? 1 : 0,
    );
  }

  /// Mengupdate task yang sudah ada
  Future<bool> editTask({
    required int taskId,
    required String title,
    required String time,
    required bool status,
  }) async {
    // Validasi input
    if (title.trim().isEmpty) {
      return false;
    }

    if (time.trim().isEmpty) {
      return false;
    }

    // Format waktu
    final formattedTime = _formatTime(time);

    return await _service.updateTask(
      taskId: taskId,
      title: title.trim(),
      time: formattedTime,
      status: status ? 1 : 0,
    );
  }

  /// Menghapus task
  Future<bool> removeTask(int taskId) async {
    return await _service.deleteTask(taskId);
  }

  /// Validasi format waktu (HH:mm atau HH:mm:ss)
  bool _isValidTimeFormat(String time) {
    // Regex untuk validasi HH:mm atau HH:mm:ss
    final timePattern = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])(:([0-5][0-9]))?$');
    return timePattern.hasMatch(time);
  }

  /// Format waktu ke HH:mm:ss
  String _formatTime(String time) {
    time = time.trim();
    
    // Jika sudah format HH:mm:ss
    if (time.split(':').length == 3) {
      return time;
    }
    
    // Jika format HH:mm, tambahkan :00
    if (time.split(':').length == 2) {
      return "$time:00";
    }
    
    // Default
    return "00:00:00";
  }

  /// Validasi input task
  Map<String, String?> validateTaskInput({
    required String title,
    required String time,
  }) {
    Map<String, String?> errors = {};

    if (title.trim().isEmpty) {
      errors['title'] = 'Please enter task title';
    }

    if (time.trim().isEmpty) {
      errors['time'] = 'Please enter time';
    } else if (!_isValidTimeFormat(time)) {
      errors['time'] = 'Invalid time format (use HH:mm)';
    }

    return errors;
  }
}