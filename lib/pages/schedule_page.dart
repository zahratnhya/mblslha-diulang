import 'package:flutter/material.dart';
import '../repositories/schedule_repository.dart';
import '../pages/schedule_detail_page.dart';
import '../pages/add_schedule_page.dart';

/// UI Layer - Schedule Page
class SchedulePage extends StatefulWidget {
  final int userId;

  const SchedulePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleRepository _repository = ScheduleRepository();

  List schedules = [];
  bool isLoading = true;

  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  // Filter state
  String? selectedTypeFilter;
  final List<Map<String, dynamic>> typeFilters = [
    {'value': null, 'label': 'All', 'icon': Icons.apps},
    {'value': 'class', 'label': 'Class', 'icon': Icons.school_rounded},
    {'value': 'event', 'label': 'Event', 'icon': Icons.event_rounded},
    {'value': 'meeting', 'label': 'Meeting', 'icon': Icons.groups_rounded},
    {'value': 'organization', 'label': 'Organization', 'icon': Icons.people_alt_rounded},
    {'value': 'guidance', 'label': 'Guidance', 'icon': Icons.person_pin_circle_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  /// Load schedules dari repository
  Future<void> _loadSchedules() async {
    setState(() => isLoading = true);

    final fetchedSchedules = await _repository.getSchedulesForDate(
      userId: widget.userId,
      year: selectedYear,
      month: selectedMonth,
      day: selectedDay,
    );

    setState(() {
      schedules = fetchedSchedules;
      isLoading = false;
    });
  }

  /// Navigate ke bulan sebelumnya
  void _previousMonth() {
    final result = _repository.navigateMonth(
      currentMonth: selectedMonth,
      currentYear: selectedYear,
      isNext: false,
    );

    setState(() {
      selectedMonth = result['month']!;
      selectedYear = result['year']!;
      selectedDay = 1;
    });

    _loadSchedules();
  }

  /// Navigate ke bulan selanjutnya
  void _nextMonth() {
    final result = _repository.navigateMonth(
      currentMonth: selectedMonth,
      currentYear: selectedYear,
      isNext: true,
    );

    setState(() {
      selectedMonth = result['month']!;
      selectedYear = result['year']!;
      selectedDay = 1;
    });

    _loadSchedules();
  }

  /// Select day
  void _selectDay(int day) {
    setState(() => selectedDay = day);
    _loadSchedules();
  }

  /// Navigate to add schedule
  void _navigateToAddSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddSchedulePage(userId: widget.userId),
      ),
    );

    if (result == true) {
      _loadSchedules();
    }
  }

  /// Navigate to schedule detail
  void _navigateToDetail(Map<String, dynamic> schedule) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleDetailPage(schedule: schedule),
      ),
    );

    if (result == true) {
      _loadSchedules();
    }
  }

  /// Filter schedules berdasarkan type yang dipilih
  List<Map<String, dynamic>> _getFilteredSchedules() {
    if (selectedTypeFilter == null) {
      return schedules.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    
    return schedules
        .where((s) => s['type'] == selectedTypeFilter)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.indigo),
        ),
      );
    }

    // Filter schedules
    final filteredSchedules = _getFilteredSchedules();
    
    // Group schedules by type
    final grouped = _repository.groupSchedulesByType(filteredSchedules);
    final classEvents = grouped['classes']!;
    final otherEvents = grouped['others']!;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 16),
            _buildCalendar(),
            const SizedBox(height: 20),
            _buildTypeFilter(),
            const SizedBox(height: 16),
            _buildScheduleHeader(),
            const SizedBox(height: 10),
            _buildScheduleList(classEvents, otherEvents),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddSchedule,
        backgroundColor: const Color.fromARGB(255, 26, 41, 124),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Build title
  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.calendar_today,
            color: Colors.indigo,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          "Schedule",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.indigo,
          ),
        ),
      ],
    );
  }

  /// Build type filter
  Widget _buildTypeFilter() {
    final selectedFilter = typeFilters.firstWhere(
      (f) => f['value'] == selectedTypeFilter,
      orElse: () => typeFilters[0],
    );
    
    final color = selectedTypeFilter == null 
        ? Colors.indigo 
        : _repository.getTypeColor(selectedTypeFilter);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedTypeFilter,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: color),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: Colors.white,
          items: typeFilters.map((filter) {
            final filterColor = filter['value'] == null 
                ? Colors.grey 
                : _repository.getTypeColor(filter['value']);
            
            return DropdownMenuItem<String?>(
              value: filter['value'],
              child: Row(
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 20,
                    color: filterColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: filter['value'] == selectedTypeFilter 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedTypeFilter = value;
            });
          },
          hint: Row(
            children: [
              Icon(selectedFilter['icon'] as IconData, size: 20, color: color),
              const SizedBox(width: 12),
              Text(
                'Filter: ${selectedFilter['label']}',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build calendar widget
  Widget _buildCalendar() {
    return _CalendarWidget(
      selectedDay: selectedDay,
      selectedMonth: selectedMonth,
      selectedYear: selectedYear,
      repository: _repository,
      onDaySelected: _selectDay,
      onPreviousMonth: _previousMonth,
      onNextMonth: _nextMonth,
    );
  }

  /// Build schedule header
  Widget _buildScheduleHeader() {
    final filteredCount = _getFilteredSchedules().length;
    final totalCount = schedules.length;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Schedule for $selectedDay ${_repository.getMonthName(selectedMonth)}",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            if (selectedTypeFilter != null)
              Text(
                "Showing $filteredCount of $totalCount events",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh, size: 20),
          onPressed: _loadSchedules,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  /// Build schedule list
  Widget _buildScheduleList(
    List<Map<String, dynamic>> classEvents,
    List<Map<String, dynamic>> otherEvents,
  ) {
    // Empty state
    if (classEvents.isEmpty && otherEvents.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (classEvents.isNotEmpty) ...[
          const Text(
            "📚 Classes",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Column(
            children: classEvents
                .map((s) => _buildEventTile(s, Colors.indigo.shade50))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
        if (otherEvents.isNotEmpty) ...[
          const Text(
            "🗓 Activities",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Column(
            children: otherEvents
                .map((s) => _buildEventTile(s, Colors.pink.shade50))
                .toList(),
          ),
        ],
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(Icons.event_busy, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            selectedTypeFilter == null
                ? "No events scheduled today 📅"
                : "No ${typeFilters.firstWhere((f) => f['value'] == selectedTypeFilter)['label']} events today",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Build event tile
  Widget _buildEventTile(Map<String, dynamic> schedule, Color bgColor) {
    final isRecurring = _repository.isRecurring(schedule);

    return GestureDetector(
      onTap: () => _navigateToDetail(schedule),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          schedule['subject'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (isRecurring) _buildRecurringBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildTimeRow(schedule['time']),
                  if (schedule['location'] != null &&
                      schedule['location'].toString().isNotEmpty)
                    _buildLocationRow(schedule['location']),
                  if (schedule['lecturer'] != null &&
                      schedule['lecturer'].toString().isNotEmpty)
                    _buildLecturerRow(schedule['lecturer']),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  /// Build recurring badge
  Widget _buildRecurringBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.indigo.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.repeat, size: 10, color: Colors.indigo.shade700),
          const SizedBox(width: 2),
          Text(
            'Recurring',
            style: TextStyle(
              fontSize: 9,
              color: Colors.indigo.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build time row
  Widget _buildTimeRow(String? time) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 4),
        Text(
          time ?? '',
          style: TextStyle(color: Colors.grey[700], fontSize: 13),
        ),
      ],
    );
  }

  /// Build location row
  Widget _buildLocationRow(String location) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              location,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build lecturer row
  Widget _buildLecturerRow(String lecturer) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(Icons.person, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            lecturer,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// ================================
/// Calendar Widget (Separated Component)
/// ================================
class _CalendarWidget extends StatelessWidget {
  final int selectedDay;
  final int selectedMonth;
  final int selectedYear;
  final ScheduleRepository repository;
  final Function(int) onDaySelected;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _CalendarWidget({
    required this.selectedDay,
    required this.selectedMonth,
    required this.selectedYear,
    required this.repository,
    required this.onDaySelected,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMonthHeader(),
        const SizedBox(height: 12),
        _buildWeeklyCalendar(),
      ],
    );
  }

  /// Build month header with navigation
  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPreviousMonth,
        ),
        Text(
          "${repository.getMonthName(selectedMonth)} $selectedYear",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNextMonth,
        ),
      ],
    );
  }

  /// Build weekly calendar dengan format 7 kolom
  Widget _buildWeeklyCalendar() {
    final daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
    final firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday % 7; // 0 = Sunday
    
    // Day labels
    final dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Column(
      children: [
        // Header hari
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: dayLabels.map((day) {
            final isSunday = day == 'Sun';
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    color: isSunday ? Colors.red : Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        
        // Grid tanggal
        _buildDateGrid(daysInMonth, weekdayOfFirstDay),
      ],
    );
  }

  /// Build grid tanggal dengan 7 kolom per baris
  Widget _buildDateGrid(int daysInMonth, int firstWeekday) {
    final List<Widget> weeks = [];
    final List<Widget> currentWeek = [];
    
    // Tambahkan sel kosong untuk hari sebelum tanggal 1
    for (int i = 0; i < firstWeekday; i++) {
      currentWeek.add(_buildEmptyCell());
    }
    
    // Tambahkan tanggal
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedYear, selectedMonth, day);
      final weekday = date.weekday % 7; // 0 = Sunday
      final isSelected = day == selectedDay;
      final isSunday = weekday == 0;
      
      currentWeek.add(_buildDateCell(day, isSelected, isSunday));
      
      // Jika sudah Sabtu (weekday 6) atau hari terakhir, mulai baris baru
      if (weekday == 6 || day == daysInMonth) {
        // Lengkapi baris dengan sel kosong jika perlu
        while (currentWeek.length < 7) {
          currentWeek.add(_buildEmptyCell());
        }
        
        weeks.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.from(currentWeek),
            ),
          ),
        );
        
        currentWeek.clear();
      }
    }
    
    return Column(children: weeks);
  }

  /// Build sel tanggal
  Widget _buildDateCell(int day, bool isSelected, bool isSunday) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onDaySelected(day),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.indigo : Colors.grey.shade300,
            ),
          ),
          child: Text(
            "$day",
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : (isSunday ? Colors.red : Colors.black),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  /// Build sel kosong
  Widget _buildEmptyCell() {
    return Expanded(
      child: Container(
        height: 40,
        alignment: Alignment.center,
      ),
    );
  }
}