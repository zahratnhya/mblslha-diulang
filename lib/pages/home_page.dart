import 'dart:convert';
import 'package:flutter/material.dart';
import '../repositories/home_repository.dart';
import 'add_task_page.dart';
import 'profile_page.dart';
import '../pages/assignments_detail_page.dart'; 
import '../utils/network_wrrapper.dart';


/// UI Layer - Home Page
class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeRepository _repository = HomeRepository();

  Map<String, dynamic> user = {};
  List<dynamic> schedule = [];
  List<dynamic> taskToday = [];
  List<dynamic> dueToday = [];

  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  /// Load semua data dari repository
  Future<void> _loadAllData() async {
    setState(() {
      loading = true;
      error = false;
    });

    final result = await _repository.getAllHomeData(widget.userId);

    if (result['success'] == true) {
      setState(() {
        user = result['user'];
        schedule = result['schedule'];
        taskToday = result['taskToday'];
        dueToday = result['dueToday'];
        loading = false;
      });
    } else {
      setState(() {
        error = true;
        loading = false;
      });
    }
  }

  /// Mark task sebagai selesai
  Future<void> _markTaskDone(int taskId, String title, dynamic time) async {
    _showSnackBar('Updating task...', Colors.grey, 500);

    final result = await _repository.markTaskAsDone(
      taskId: taskId,
      title: title,
      time: time,
    );

    if (result['success'] == true) {
      await _loadAllData();
      if (mounted) {
        _showSnackBar('✓ Task marked as done!', Colors.green, 2000);
      }
    } else {
      if (mounted) {
        _showSnackBar(
          result['message'] ?? 'Failed to update task',
          Colors.red,
          3000,
        );
      }
    }
  }

  /// ✅ Navigate ke assignment detail page
  Future<void> _navigateToAssignmentDetail(Map<String, dynamic> assignment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignmentDetailPage(assignment: assignment),
      ),
    );

    // Refresh data jika ada perubahan
    if (result == true) {
      _loadAllData();
    }
  }

  /// Show snackbar helper
  void _showSnackBar(String message, Color color, int milliseconds) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(milliseconds: milliseconds),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Navigate to add task page
  void _navigateToAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTaskPage(userId: widget.userId),
      ),
    ).then((_) => _loadAllData());
  }

  /// Navigate to profile page
  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(userId: widget.userId),
      ),
    ).then((_) => _loadAllData());
  }

  /// Check if user has profile image
  bool _hasProfileImage() {
    return user['profile_image'] != null && 
           user['profile_image'].toString().isNotEmpty;
  }

    @override
  Widget build(BuildContext context) {
    // ✅ WRAP ENTIRE PAGE WITH NetworkWrapper
    return NetworkWrapper(
      showSnackbar: true,
      showOverlay: true,
      showInitialLoading: false,
      child: _buildPage(), // Pisahkan build logic
    );
  }

  Widget _buildPage() {
    if (loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.indigo,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your schedule...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (error) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to load data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadAllData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final classesToday = _repository.getClassesToday(schedule);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          color: Colors.indigo,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ... semua content tetap sama ...
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildStatisticsCards(),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildClassesSection(classesToday),
                    const SizedBox(height: 24),
                    _buildTasksSection(),
                    const SizedBox(height: 24),
                    _buildDueTodaySection(),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  /// Header dengan avatar dan greeting
  Widget _buildHeader() {
    final hasImage = _hasProfileImage();
    final hour = DateTime.now().hour;
    String greeting = hour < 12 
        ? 'Good Morning' 
        : hour < 17 
            ? 'Good Afternoon' 
            : 'Good Evening';

    return Row(
      children: [
        GestureDetector(
          onTap: _navigateToProfile,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: hasImage
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: MemoryImage(
                      base64Decode(user['profile_image']),
                    ),
                    backgroundColor: Colors.white,
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      user['name']?[0] ?? 'U',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.indigo.shade600,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user['name'] ?? 'User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _navigateToProfile,
            icon: const Icon(Icons.settings_outlined),
            color: Colors.white,
            iconSize: 24,
          ),
        ),
      ],
    );
  }

  /// Statistics Cards
  Widget _buildStatisticsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.school_rounded,
            label: 'Classes',
            value: schedule.length.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.task_alt_rounded,
            label: 'Tasks',
            value: taskToday.length.toString(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.alarm_rounded,
            label: 'Due',
            value: dueToday.length.toString(),
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Section untuk menampilkan kelas hari ini
  Widget _buildClassesSection(List<dynamic> classesToday) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.school_rounded,
          title: "Today's Classes",
          count: classesToday.length,
        ),
        const SizedBox(height: 12),
        if (classesToday.isEmpty)
          _buildEmptyState(
            icon: Icons.event_available,
            text: "No classes scheduled today",
            subtitle: "Enjoy your free time!",
          )
        else
          Column(
            children: classesToday.map((c) => _buildClassCard(c)).toList(),
          ),
      ],
    );
  }

  /// Section Header dengan icon dan count
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.indigo, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.indigo,
            ),
          ),
        ),
      ],
    );
  }

  /// Modern Class Card
  Widget _buildClassCard(Map<String, dynamic> classData) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.indigo,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      classData['subject'] ?? 'No subject',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (classData['is_recurring'].toString() == "1")
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.indigo.shade400,
                            Colors.indigo.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.repeat, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "Recurring",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.access_time_rounded,
                classData['time'] ?? 'No time',
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_on_rounded,
                classData['location'] ?? 'No location',
                Colors.red,
              ),
              if (classData['lecturer'] != null &&
                  classData['lecturer'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.person_rounded,
                  classData['lecturer'],
                  Colors.green,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Section untuk menampilkan tasks hari ini
  Widget _buildTasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.task_alt_rounded,
          title: "Today's Tasks",
          count: taskToday.length,
        ),
        const SizedBox(height: 12),
        if (taskToday.isEmpty)
          _buildEmptyState(
            icon: Icons.check_circle_outline,
            text: "No tasks for today",
            subtitle: "You're all caught up!",
          )
        else
          Column(
            children: taskToday.map((t) => _buildTaskCard(t)).toList(),
          ),
      ],
    );
  }

  /// Modern Task Card dengan checkbox
  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            _markTaskDone(
              int.parse(task['id'].toString()),
              task['title'].toString(),
              task['time'],
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    task['title'] ?? 'No title',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section untuk menampilkan assignments yang deadline hari ini
  Widget _buildDueTodaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.alarm_rounded,
          title: "Due Today",
          count: dueToday.length,
        ),
        const SizedBox(height: 12),
        if (dueToday.isEmpty)
          _buildEmptyState(
            icon: Icons.assignment_turned_in,
            text: "No deadlines today",
            subtitle: "Keep up the good work!",
          )
        else
          Column(
            children: dueToday.map((t) => _buildDueCard(t)).toList(),
          ),
      ],
    );
  }

  /// ✅ Modern Due Card dengan onTap untuk navigate ke detail
  Widget _buildDueCard(Map<String, dynamic> assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _navigateToAssignmentDetail(assignment), // ✅ TAP HANDLER
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.alarm_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment['title'] ?? 'No title',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: Colors.red[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due Today',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.red[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Modern Floating Action Button
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _navigateToAddTask,
        backgroundColor: Colors.indigo,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
        label: const Text(
          'Add Task',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Modern Empty State
  Widget _buildEmptyState({
    required IconData icon,
    required String text,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}