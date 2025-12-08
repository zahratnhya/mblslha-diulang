import '../services/home_service.dart';

/// Repository layer untuk mengelola business logic home page
class HomeRepository {
  final HomeService _service = HomeService();

  /// Mendapatkan semua data yang diperlukan untuk home page
  Future<Map<String, dynamic>> getAllHomeData(int userId) async {
    try {
      final today = DateTime.now();
      final todayStr = _formatDateForApi(today);

      // Fetch semua data secara parallel
      final results = await Future.wait([
        _service.fetchUser(userId),
        _service.fetchSchedule(userId, todayStr),
        _service.fetchTaskToday(userId),
        _service.fetchAllTasks(userId),
      ]);

      final user = results[0] as Map<String, dynamic>;
      final schedule = results[1] as List<dynamic>;
      final taskToday = results[2] as List<dynamic>;
      final allTasks = results[3] as List<dynamic>;

      // Filter task today (status=0 dan created_at hari ini)
      final filteredTaskToday = _filterTaskToday(taskToday, todayStr);

      // Filter tasks yang deadline hari ini
      final dueToday = _filterDueToday(allTasks, todayStr);

      return {
        'success': true,
        'user': user,
        'schedule': schedule,
        'taskToday': filteredTaskToday,
        'dueToday': dueToday,
      };
    } catch (e) {
      print('Error in getAllHomeData: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Filter classes dari schedule
  List<dynamic> getClassesToday(List<dynamic> schedule) {
    return schedule.where((x) => x['type'] == 'class').toList();
  }

  /// Mark task as done
  Future<Map<String, dynamic>> markTaskAsDone({
    required int taskId,
    required String title,
    required dynamic time,
  }) async {
    final timeStr = time?.toString() ?? "00:00:00";
    
    return await _service.updateTaskStatus(
      taskId: taskId,
      title: title,
      time: timeStr,
    );
  }

  /// Filter task today berdasarkan status dan created_at
  List<dynamic> _filterTaskToday(List<dynamic> tasks, String todayStr) {
    return tasks.where((t) {
      return t['status'].toString() == "0" &&
             t['created_at'].toString().startsWith(todayStr);
    }).toList();
  }

  /// Filter tasks yang deadline hari ini
  List<dynamic> _filterDueToday(List<dynamic> tasks, String todayStr) {
    return tasks.where((t) => t['deadline'] == todayStr).toList();
  }

  /// Format DateTime ke string untuk API (YYYY-MM-DD)
  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}