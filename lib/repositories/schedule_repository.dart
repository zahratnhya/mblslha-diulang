import 'package:flutter/material.dart';
import '../services/schedule_service.dart';

/// Repository layer untuk mengelola business logic schedule
class ScheduleRepository {
  final ScheduleService _service = ScheduleService();

  /// Menghapus schedule
  Future<Map<String, dynamic>> removeSchedule(String scheduleId) async {
    return await _service.deleteSchedule(scheduleId);
  }

  /// Mengupdate schedule
  Future<Map<String, dynamic>> editSchedule({
    required String scheduleId,
    required String subject,
    required String type,
    required DateTime date,
    required String time,
    String? location,
    String? lecturer,
    String? description,
    required bool isRecurring,
    String? recurringDay,
    DateTime? recurringUntil,
  }) async {
    // Validasi input
    if (subject.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Subject is required',
      };
    }

    if (time.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Time is required',
      };
    }

    if (isRecurring && recurringDay == null) {
      return {
        'success': false,
        'message': 'Recurring day is required for recurring schedule',
      };
    }

    // Prepare data
    final data = {
      'subject': subject.trim(),
      'type': type,
      'date': _formatDateForApi(date),
      'time': time.trim(),
      'location': location?.trim(),
      'lecturer': lecturer?.trim(),
      'description': description?.trim(),
      'is_recurring': isRecurring ? 1 : 0,
      'recurring_day': isRecurring ? recurringDay : null,
      'recurring_until': isRecurring && recurringUntil != null
          ? _formatDateForApi(recurringUntil)
          : null,
    };

    return await _service.updateSchedule(
      scheduleId: scheduleId,
      data: data,
    );
  }

  /// Format DateTime ke string untuk API (YYYY-MM-DD)
  String _formatDateForApi(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  /// Format display date (DD/MM/YYYY)
  String formatDisplayDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  /// Format recurring day untuk display
  String formatRecurringDay(String? day) {
    if (day == null) return '-';
    return day[0].toUpperCase() + day.substring(1);
  }

  /// Get icon berdasarkan type
  IconData getTypeIcon(String? type) {
    switch (type) {
      case 'class':
        return Icons.school_rounded;
      case 'event':
        return Icons.event_rounded;
      case 'meeting':
        return Icons.groups_rounded;
      case 'organization':
        return Icons.people_alt_rounded;
      case 'guidance':
        return Icons.person_pin_circle_rounded;
      default:
        return Icons.calendar_today_rounded;
    }
  }

  /// Get color berdasarkan type
  Color getTypeColor(String? type) {
    switch (type) {
      case 'class':
        return Colors.indigo;
      case 'event':
        return Colors.pink;
      case 'meeting':
        return Colors.orange;
      case 'organization':
        return Colors.green;
      case 'task':
        return Colors.red;
      case 'guidance':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Check apakah schedule recurring
  bool isRecurring(Map<String, dynamic> schedule) {
    return schedule['is_recurring'].toString() == "1";
  }

  /// Build updated schedule map
  Map<String, dynamic> buildUpdatedSchedule({
    required Map<String, dynamic> originalSchedule,
    required String subject,
    required String type,
    required DateTime date,
    required String time,
    String? location,
    String? lecturer,
    String? description,
    required bool isRecurring,
    String? recurringDay,
    DateTime? recurringUntil,
  }) {
    final updated = Map<String, dynamic>.from(originalSchedule);
    
    updated['subject'] = subject.trim();
    updated['type'] = type;
    updated['date'] = _formatDateForApi(date);
    updated['time'] = time.trim();
    updated['location'] = location?.trim();
    updated['lecturer'] = lecturer?.trim();
    updated['description'] = description?.trim();
    updated['is_recurring'] = isRecurring ? 1 : 0;
    updated['recurring_day'] = isRecurring ? recurringDay : null;
    updated['recurring_until'] = isRecurring && recurringUntil != null
        ? _formatDateForApi(recurringUntil)
        : null;
    
    return updated;
  }

  /// Get schedules untuk tanggal tertentu
  Future<List<dynamic>> getSchedulesForDate({
    required int userId,
    required int year,
    required int month,
    required int day,
  }) async {
    final date = DateTime(year, month, day);
    final dateStr = _formatDateForApi(date);
    
    return await _service.fetchSchedules(userId, dateStr);
  }

  /// Filter schedules berdasarkan type
  Map<String, List<Map<String, dynamic>>> groupSchedulesByType(List<dynamic> schedules) {
    final classes = <Map<String, dynamic>>[];
    final others = <Map<String, dynamic>>[];

    for (var schedule in schedules) {
      final map = Map<String, dynamic>.from(schedule);
      if (map['type'] == 'class') {
        classes.add(map);
      } else {
        others.add(map);
      }
    }

    return {
      'classes': classes,
      'others': others,
    };
  }

  /// Get month name
  String getMonthName(int month) {
    const names = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return names[month - 1];
  }

  /// Navigate month (previous/next)
  Map<String, int> navigateMonth({
    required int currentMonth,
    required int currentYear,
    required bool isNext,
  }) {
    int newMonth = currentMonth;
    int newYear = currentYear;

    if (isNext) {
      if (currentMonth == 12) {
        newMonth = 1;
        newYear++;
      } else {
        newMonth++;
      }
    } else {
      if (currentMonth == 1) {
        newMonth = 12;
        newYear--;
      } else {
        newMonth--;
      }
    }

    return {'month': newMonth, 'year': newYear};
  }

  /// Membuat schedule baru
  Future<Map<String, dynamic>> createSchedule({
    required int userId,
    required String subject,
    required String type,
    required DateTime date,
    required String time,
    String? location,
    String? lecturer,
    String? description,
    required bool isRecurring,
    String? recurringDay,
    DateTime? recurringUntil,
  }) async {
    // Validasi input
    if (subject.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Subject is required',
      };
    }

    if (time.trim().isEmpty) {
      return {
        'success': false,
        'message': 'Time is required',
      };
    }

    if (isRecurring && recurringDay == null) {
      return {
        'success': false,
        'message': 'Recurring day is required for recurring schedule',
      };
    }

    // Prepare data
    final data = {
      'user_id': userId,
      'subject': subject.trim(),
      'type': type,
      'date': _formatDateForApi(date),
      'time': time.trim(),
      'location': location?.trim(),
      'lecturer': lecturer?.trim(),
      'description': description?.trim(),
      'is_recurring': isRecurring ? 1 : 0,
      'recurring_day': isRecurring ? recurringDay : null,
      'recurring_until': isRecurring && recurringUntil != null
          ? _formatDateForApi(recurringUntil)
          : null,
    };

    return await _service.createSchedule(data: data);
  }

  /// Format time dari TimeOfDay
  String formatTimeFromPicker(TimeOfDay startTime, TimeOfDay? endTime) {
    String formattedTime =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

    if (endTime != null) {
      formattedTime +=
          ' - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    }

    return formattedTime;
  }

  /// Get recurring info text
  String getRecurringInfoText(String? recurringDay, DateTime? recurringUntil) {
    if (recurringDay == null) return 'Please select a recurring day';

    String text = 'This schedule will repeat every $recurringDay';

    if (recurringUntil != null) {
      text += ' until ${formatDisplayDate(recurringUntil)}';
    } else {
      text += ' indefinitely';
    }

    return text;
  }

  /// Validasi recurring schedule
  bool validateRecurringSchedule(bool isRecurring, String? recurringDay) {
    if (isRecurring && recurringDay == null) {
      return false;
    }
    return true;
  }
}