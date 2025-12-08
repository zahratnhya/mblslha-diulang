import '../services/assignment_service.dart';
import 'package:flutter/material.dart';

/// Repository layer untuk mengelola business logic assignments
class AssignmentRepository {
  final AssignmentService _service = AssignmentService();

  /// Mendapatkan semua assignments
  Future<List<dynamic>> getAssignments(int userId) async {
    return await _service.fetchAssignments(userId);
  }

  /// Mengupdate assignment - ✅ FIXED: Tambah parameter time
  Future<Map<String, dynamic>> updateAssignment({
    required String assignmentId,
    required String title,
    required String description,
    required String time,          // ✅ DITAMBAHKAN
    required String deadline,
    required int status,
  }) async {
    final data = {
      'title': title.trim(),
      'description': description.trim(),
      'time': time.trim(),         // ✅ DITAMBAHKAN
      'deadline': deadline,
      'status': status,
    };

    return await _service.updateAssignment(
      assignmentId: assignmentId,
      data: data,
    );
  }

  /// Menghapus assignment
  Future<Map<String, dynamic>> removeAssignment(String assignmentId) async {
    return await _service.deleteAssignment(assignmentId);
  }

  /// Convert assignments dengan progress
  List<Map<String, dynamic>> processAssignmentsWithProgress(List<dynamic> assignments) {
    return assignments.map((a) {
      final map = Map<String, dynamic>.from(a);
      // Convert status ke progress (0 atau 1)
      final status = map['status'].toString();
      map['progress'] = status == "1" ? 1.0 : 0.0;
      return map;
    }).toList();
  }

  /// Filter assignments berdasarkan status
  List<Map<String, dynamic>> filterAssignments(
    List<Map<String, dynamic>> assignments,
    String filter,
  ) {
    if (filter == "Ongoing") {
      return assignments.where((a) => a["progress"] < 1).toList();
    } else if (filter == "Completed") {
      return assignments.where((a) => a["progress"] == 1).toList();
    } else {
      return assignments;
    }
  }

  /// Calculate overall progress
  double calculateOverallProgress(List<Map<String, dynamic>> assignments) {
    if (assignments.isEmpty) return 0.0;

    final totalProgress = assignments
        .map((a) => a["progress"] as double)
        .reduce((a, b) => a + b);

    return totalProgress / assignments.length;
  }

  /// Check if assignment is done
  bool isAssignmentDone(Map<String, dynamic> assignment) {
    return (assignment['progress'] as double) == 1.0;
  }

  /// Get assignment progress percentage
  int getProgressPercentage(double progress) {
    return (progress * 100).round();
  }

  /// Format deadline date
  String formatDeadline(String deadline) {
    try {
      final date = DateTime.parse(deadline);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference < 0) {
        return '$deadline (Overdue)';
      } else if (difference == 0) {
        return '$deadline (Today)';
      } else if (difference == 1) {
        return '$deadline (Tomorrow)';
      }

      return deadline;
    } catch (e) {
      return deadline;
    }
  }

  /// Get filter colors
  Map<String, dynamic> getFilterColor(String filter) {
    switch (filter) {
      case 'All':
        return {'color': const Color(0xFF3F51B5), 'name': 'All'};
      case 'Ongoing':
        return {'color': const Color(0xFFFF9800), 'name': 'Ongoing'};
      case 'Completed':
        return {'color': const Color(0xFF4CAF50), 'name': 'Completed'};
      default:
        return {'color': const Color(0xFF3F51B5), 'name': 'All'};
    }
  }

  /// Mark assignment sebagai completed
  Future<Map<String, dynamic>> markCompleted(Map<String, dynamic> assignment) async {
    return await _service.markAsCompleted(
      assignmentId: assignment['id'].toString(),
      title: assignment['title'] ?? '',
      time: assignment['time'] ?? '',
      deadline: assignment['deadline'] ?? '',
      description: assignment['description'] ?? '',  // ✅ DITAMBAHKAN
    );
  }

  /// Mark assignment sebagai incomplete
  Future<Map<String, dynamic>> markIncomplete(Map<String, dynamic> assignment) async {
    return await _service.markAsIncomplete(
      assignmentId: assignment['id'].toString(),
      title: assignment['title'] ?? '',
      time: assignment['time'] ?? '',
      deadline: assignment['deadline'] ?? '',
      description: assignment['description'] ?? '',  // ✅ DITAMBAHKAN
    );
  }

  /// Get initial progress from assignment
  double getInitialProgress(Map<String, dynamic> assignment) {
    return assignment['status'].toString() == "1" ? 1.0 : 0.0;
  }

  /// Check if assignment is completed
  bool isCompleted(double progress) {
    return progress >= 1.0;
  }

  /// Format time untuk display
  String formatTime(String? time) {
    if (time == null || time.isEmpty) return "-";
    try {
      final dateTime = DateTime.parse(time);
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (e) {
      return time;
    }
  }

  /// Check if assignment is overdue
  bool isOverdue(String? deadline, bool isCompleted) {
    try {
      if (deadline == null || deadline.isEmpty) return false;
      
      final deadlineDate = DateTime.parse(deadline);
      final now = DateTime.now();
      
      return !isCompleted && now.isAfter(deadlineDate);
    } catch (e) {
      return false;
    }
  }

  /// Get remaining days text
  String getRemainingDays(String? deadline) {
    try {
      if (deadline == null || deadline.isEmpty) return "";
      
      final deadlineDate = DateTime.parse(deadline);
      final now = DateTime.now();
      final difference = deadlineDate.difference(now).inDays;
      
      if (difference < 0) return "Overdue by ${-difference} days";
      if (difference == 0) return "Due today!";
      if (difference == 1) return "Due tomorrow";
      return "$difference days left";
    } catch (e) {
      return "";
    }
  }

  /// Get status badge data
  Map<String, dynamic> getStatusBadgeData(bool isCompleted, bool isOverdue) {
    if (isCompleted) {
      return {
        'text': 'Done',
        'icon': Icons.check_circle,
        'color': Colors.green.shade700,
        'bgColor': Colors.green.shade100,
      };
    } else if (isOverdue) {
      return {
        'text': 'Overdue',
        'icon': Icons.warning_rounded,
        'color': Colors.red.shade700,
        'bgColor': Colors.red.shade100,
      };
    } else {
      return {
        'text': 'Pending',
        'icon': Icons.pending_rounded,
        'color': Colors.orange.shade700,
        'bgColor': Colors.orange.shade100,
      };
    }
  }

  /// Get deadline card colors
  Map<String, dynamic> getDeadlineCardColors(bool isCompleted, bool isOverdue) {
    if (isOverdue) {
      return {
        'gradientColors': [Colors.red.shade50, Colors.red.shade100],
        'borderColor': Colors.red.shade300,
        'iconColor': Colors.red.shade700,
        'textColor': Colors.red.shade900,
      };
    } else if (isCompleted) {
      return {
        'gradientColors': [Colors.green.shade50, Colors.green.shade100],
        'borderColor': Colors.green.shade300,
        'iconColor': Colors.green.shade700,
        'textColor': Colors.green.shade900,
      };
    } else {
      return {
        'gradientColors': [Colors.indigo.shade50, Colors.indigo.shade100],
        'borderColor': Colors.indigo.shade300,
        'iconColor': Colors.indigo.shade700,
        'textColor': Colors.indigo.shade900,
      };
    }
  }

  /// Membuat assignment baru
  Future<Map<String, dynamic>> createAssignment({
    required int userId,
    required String title,
    required String description,
    required String time,
    required String deadline,
  }) async {
    // Validasi input
    if (title.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Title is required',
      };
    }

    if (description.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Description is required',
      };
    }

    if (time.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Time is required',
      };
    }

    // Prepare data
    final data = {
      'user_id': userId,
      'title': title.trim(),
      'description': description.trim(),
      'time': time.trim(),
      'deadline': deadline,
      'status': 0, // Default: incomplete
    };

    return await _service.createAssignment(data: data);
  }
}