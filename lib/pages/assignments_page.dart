import 'package:flutter/material.dart';
import '../repositories/assigment_repository.dart';
import '../pages/assignments_detail_page.dart';
import '../pages/add_assignment_page.dart';

/// UI Layer - Assignments Page
class AssignmentsPage extends StatefulWidget {
  final int userId;

  const AssignmentsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage> {
  final AssignmentRepository _repository = AssignmentRepository();

  List<Map<String, dynamic>> assignments = [];
  bool loading = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  /// Load assignments dari repository
  Future<void> _loadAssignments() async {
    setState(() => loading = true);

    final fetchedAssignments = await _repository.getAssignments(widget.userId);
    final processedAssignments =
        _repository.processAssignmentsWithProgress(fetchedAssignments);

    setState(() {
      assignments = processedAssignments;
      loading = false;
    });
  }

  /// Navigate to assignment detail
  void _navigateToDetail(Map<String, dynamic> assignment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentDetailPage(assignment: assignment),
      ),
    );

    // Refresh if there's any change
    if (result == true) {
      _loadAssignments();
    }
  }

  /// Navigate to add assignment page
  void _navigateToAddAssignment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAssignmentPage(userId: widget.userId),
      ),
    );

    // Refresh if assignment was added
    if (result == true) {
      _loadAssignments();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F7FB),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.indigo,
          ),
        ),
      );
    }

    // Filter assignments
    final filteredAssignments =
        _repository.filterAssignments(assignments, selectedFilter);

    // Calculate overall progress
    final overallProgress =
        _repository.calculateOverallProgress(assignments);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAssignments,
          color: Colors.indigo,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildOverallProgress(overallProgress),
                const SizedBox(height: 30),
                _buildFilterChips(),
                const SizedBox(height: 20),
                _buildAssignmentsList(filteredAssignments),
                const SizedBox(height: 80), // Extra space for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddAssignment,
        backgroundColor: const Color.fromARGB(255, 26, 41, 124),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Assignment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Build header with refresh button
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.assignment_rounded,
            color: Colors.indigo,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "Assignments",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.indigo,
            ),
          ),
        ),
        // ✨ REFRESH BUTTON
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _loadAssignments,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.indigo,
                size: 26,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build overall progress circle
  Widget _buildOverallProgress(double overallProgress) {
    final percentage = _repository.getProgressPercentage(overallProgress);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: overallProgress,
              strokeWidth: 12,
              color: const Color.from(alpha: 1, red: 0.247, green: 0.318, blue: 0.71),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          Column(
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Overall Progress',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip("All", Colors.indigo),
          _buildFilterChip("Ongoing", Colors.orange),
          _buildFilterChip("Completed", Colors.green),
        ],
      ),
    );
  }

  /// Build single filter chip
  Widget _buildFilterChip(String label, Color color) {
    final selected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: selected,
        onSelected: (_) => setState(() => selectedFilter = label),
        selectedColor: color,
        backgroundColor: Colors.grey.shade200,
        labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      ),
    );
  }

  /// Build assignments list
  Widget _buildAssignmentsList(List<Map<String, dynamic>> filteredAssignments) {
    if (filteredAssignments.isEmpty) {
      return _buildEmptyState("No assignments found 🎓");
    }

    return Column(
      children: filteredAssignments.map((assignment) {
        final progress = assignment["progress"] as double;
        final isDone = _repository.isAssignmentDone(assignment);

        return GestureDetector(
          onTap: () => _navigateToDetail(assignment),
          child: _buildAssignmentTile(assignment, progress, isDone),
        );
      }).toList(),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 15),
        ),
      ),
    );
  }

  /// Build assignment tile
  Widget _buildAssignmentTile(
    Map<String, dynamic> assignment,
    double progress,
    bool isDone,
  ) {
    final percentage = _repository.getProgressPercentage(progress);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildIconCircle(isDone),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment["title"] ?? 'No title',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Deadline: ${assignment["deadline"] ?? 'No deadline'}",
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                _buildProgressBar(progress, isDone),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDone ? Colors.green.shade700 : Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build icon circle
  Widget _buildIconCircle(bool isDone) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade100 : Colors.indigo.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isDone ? Icons.check_circle_rounded : Icons.edit_note_rounded,
        color: isDone ? Colors.green.shade700 : Colors.indigo,
        size: 26,
      ),
    );
  }

  /// Build progress bar
  Widget _buildProgressBar(double progress, bool isDone) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        backgroundColor: Colors.grey.shade200,
        color: isDone ? Colors.green : Colors.indigo,
      ),
    );
  }
}