import 'package:flutter/material.dart';
import '../repositories/assigment_repository.dart';
import 'edit_assignment_page.dart';

/// UI Layer - Assignment Detail Page
class AssignmentDetailPage extends StatefulWidget {
  final Map<String, dynamic> assignment;

  const AssignmentDetailPage({Key? key, required this.assignment})
      : super(key: key);

  @override
  State<AssignmentDetailPage> createState() => _AssignmentDetailPageState();
}

class _AssignmentDetailPageState extends State<AssignmentDetailPage> {
  final AssignmentRepository _repository = AssignmentRepository();

  late bool isCompleted;
  late double progress;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    progress = _repository.getInitialProgress(widget.assignment);
    isCompleted = _repository.isCompleted(progress);
  }

  /// Mark assignment as completed
  Future<void> _markCompleted() async {
    setState(() => isLoading = true);

    final result = await _repository.markCompleted(widget.assignment);

    if (result['success'] == true) {
      setState(() {
        isCompleted = true;
        progress = 1.0;
        widget.assignment['status'] = 1;
        isLoading = false;
      });

      if (mounted) {
        Navigator.pop(context, true);
        _showSnackBar("Task marked as completed ✅", Colors.green.shade600);
      }
    } else {
      setState(() => isLoading = false);
      if (mounted) {
        _showSnackBar("Failed: ${result['message']}", Colors.red.shade600);
      }
    }
  }

  /// Mark assignment as incomplete
  Future<void> _markIncomplete() async {
    setState(() => isLoading = true);

    final result = await _repository.markIncomplete(widget.assignment);

    if (result['success'] == true) {
      setState(() {
        isCompleted = false;
        progress = 0.0;
        widget.assignment['status'] = 0;
        isLoading = false;
      });

      if (mounted) {
        _showSnackBar("Task marked as incomplete", Colors.orange.shade600);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  /// Navigate to edit page
  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAssignmentPage(
          userId: 1, // Ganti dengan userId yang sesuai
          assignment: widget.assignment,
        ),
      ),
    );

    // Refresh jika ada perubahan
    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  /// Delete assignment with confirmation
  Future<void> _deleteAssignment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Colors.red.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Assignment?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this assignment? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoading = true);

      final result = await _repository.removeAssignment(widget.assignment['id']);

      if (result['success'] == true) {
        if (mounted) {
          _showSnackBar("Assignment deleted successfully 🗑️", Colors.red.shade600);
          Navigator.pop(context, true);
        }
      } else {
        setState(() => isLoading = false);
        if (mounted) {
          _showSnackBar("Failed to delete: ${result['message']}", Colors.red.shade600);
        }
      }
    }
  }

  /// Show confirmation dialog
  Future<void> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.indigo.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Mark as Completed?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to mark this assignment as completed?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      _markCompleted();
    }
  }

  /// Show snackbar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.assignment;
    final overdue = _repository.isOverdue(a['deadline'], isCompleted);
    final hasDescription = a['description'] != null && 
                          a['description'].toString().trim().isNotEmpty;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, isCompleted);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          title: Text(
            a['title'] ?? 'Assignment Detail',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.indigo.shade600,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            // ✨ TOMBOL EDIT
            IconButton(
              onPressed: _navigateToEdit,
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'Edit',
            ),
            // ✨ TOMBOL DELETE
            IconButton(
              onPressed: isLoading ? null : _deleteAssignment,
              icon: const Icon(Icons.delete_rounded),
              tooltip: 'Delete',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(a, overdue),
              const SizedBox(height: 20),
              _buildDeadlineCard(a, overdue),
              const SizedBox(height: 20),
              _buildProgressCard(),
              
              if (hasDescription) ...[
                const SizedBox(height: 20),
                _buildDescriptionSection(a),
              ],
              
              const SizedBox(height: 32),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> assignment, bool overdue) {
    final badgeData = _repository.getStatusBadgeData(isCompleted, overdue);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade600,
            Colors.indigo.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assignment['title'] ?? 'Assignment',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badgeData['icon'],
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeData['text'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineCard(Map<String, dynamic> assignment, bool overdue) {
    final colors = _repository.getDeadlineCardColors(isCompleted, overdue);
    final remainingDays = _repository.getRemainingDays(assignment['deadline']);
    final formattedTime = _repository.formatTime(assignment['time']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors['borderColor'], width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (colors['iconColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.event_rounded,
              color: colors['iconColor'],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deadline',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  assignment['deadline'] ?? '-',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors['textColor'],
                  ),
                ),
                if (!isCompleted && remainingDays.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: overdue 
                          ? Colors.red.shade50 
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      remainingDays,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: overdue 
                            ? Colors.red.shade700 
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (assignment['time'] != null &&
              assignment['time'].toString().isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.indigo.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Colors.indigo.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final percentage = _repository.getProgressPercentage(progress);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: Colors.indigo.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Progress",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1A1F36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 14,
              backgroundColor: Colors.grey.shade200,
              color: isCompleted ? Colors.green.shade600 : Colors.indigo.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentage% completed',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isCompleted
                      ? Colors.green.shade700
                      : Colors.indigo.shade700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? Colors.green.shade50 
                      : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCompleted ? 'Complete' : 'In Progress',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isCompleted 
                        ? Colors.green.shade700 
                        : Colors.indigo.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> assignment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.indigo.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF1A1F36),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.indigo.shade100),
            ),
            child: Text(
              assignment['description'],
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Color(0xFF1A1F36),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: isCompleted
            ? Column(
                key: const ValueKey('done'),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green.shade600,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Assignment Completed! 🎉',
                    style: TextStyle(
                      color: Color(0xFF1A1F36),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Great job on finishing this task!',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: isLoading ? null : _markIncomplete,
                    icon: const Icon(Icons.undo_rounded, size: 20),
                    label: const Text(
                      'Mark as Incomplete',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                key: const ValueKey('mark_btn'),
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _showConfirmDialog,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 24,
                        ),
                  label: Text(
                    isLoading ? 'Saving...' : 'Mark as Completed',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.indigo.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}