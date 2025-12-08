import 'package:flutter/material.dart';
import '../repositories/schedule_repository.dart';

/// UI Layer - Schedule Detail Page
class ScheduleDetailPage extends StatefulWidget {
  final Map<String, dynamic> schedule;

  const ScheduleDetailPage({Key? key, required this.schedule}) : super(key: key);

  @override
  State<ScheduleDetailPage> createState() => _ScheduleDetailPageState();
}

class _ScheduleDetailPageState extends State<ScheduleDetailPage> {
  final ScheduleRepository _repository = ScheduleRepository();
  
  late Map<String, dynamic> schedule;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    schedule = widget.schedule;
  }

  /// Menghapus schedule
  Future<void> _deleteSchedule() async {
    final confirm = await _showDeleteConfirmation();
    if (confirm != true) return;

    setState(() => isDeleting = true);

    final result = await _repository.removeSchedule(schedule['id'].toString());

    if (result['success'] == true && mounted) {
      _showSnackBar('✅ Schedule deleted successfully!', Colors.green);
      Navigator.pop(context, true);
    } else if (mounted) {
      setState(() => isDeleting = false);
      _showSnackBar('❌ Error: ${result['message']}', Colors.red);
    }
  }

  /// Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Show update modal
  void _showUpdateModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateScheduleModal(
        schedule: schedule,
        repository: _repository,
        onUpdated: (updatedSchedule) {
          setState(() => schedule = updatedSchedule);
          _showSnackBar('✅ Schedule updated successfully!', Colors.green);
        },
      ),
    );
  }

  /// Show snackbar helper
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _repository.getTypeColor(schedule['type']);
    final typeIcon = _repository.getTypeIcon(schedule['type']);
    final isRecurring = _repository.isRecurring(schedule);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          schedule['subject'] ?? 'Schedule Detail',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: typeColor,
        foregroundColor: Colors.white,
        elevation: 3,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: isDeleting ? null : _deleteSchedule,
            tooltip: 'Delete Schedule',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(typeColor, typeIcon, isRecurring),
            const SizedBox(height: 26),
            _buildInfoSection(isRecurring),
            const SizedBox(height: 26),
            _buildDescriptionSection(),
            const SizedBox(height: 30),
            _buildActionButtons(typeColor),
          ],
        ),
      ),
    );
  }

  /// Build header section
  Widget _buildHeader(Color typeColor, IconData typeIcon, bool isRecurring) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [typeColor.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: typeColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: typeColor.withOpacity(0.15),
            child: Icon(typeIcon, color: typeColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule['subject'] ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      schedule['type']?.toString().toUpperCase() ?? '',
                      style: TextStyle(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    if (isRecurring) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.repeat, size: 12, color: typeColor),
                            const SizedBox(width: 4),
                            Text(
                              'Recurring',
                              style: TextStyle(
                                fontSize: 10,
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build info section
  Widget _buildInfoSection(bool isRecurring) {
    return _buildInfoCard([
      _buildInfoRow(Icons.access_time_rounded, "Time", schedule['time']),
      _buildInfoRow(Icons.calendar_today_rounded, "Date", schedule['date']),
      if (isRecurring) ...[
        _buildInfoRow(
          Icons.event_repeat,
          "Repeats",
          _repository.formatRecurringDay(schedule['recurring_day']),
        ),
        if (schedule['recurring_until'] != null)
          _buildInfoRow(
            Icons.event_busy,
            "Until",
            schedule['recurring_until'],
          ),
      ],
      _buildInfoRow(Icons.location_on_rounded, "Location", schedule['location']),
      _buildInfoRow(Icons.person_rounded, "Lecturer", schedule['lecturer'] ?? "-"),
    ]);
  }

  /// Build description section
  Widget _buildDescriptionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📝 Description",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            schedule['description'] ??
                'No description available for this schedule.',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(Color typeColor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showUpdateModal,
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Update',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: typeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: typeColor),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'Back',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: typeColor,
                ),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: typeColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build info card container
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// Build info row
  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 22),
          const SizedBox(width: 12),
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value ?? "-",
              style: const TextStyle(fontSize: 15, color: Colors.black54),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// ================================
/// Update Schedule Modal Widget
/// ================================
class UpdateScheduleModal extends StatefulWidget {
  final Map<String, dynamic> schedule;
  final ScheduleRepository repository;
  final Function(Map<String, dynamic>) onUpdated;

  const UpdateScheduleModal({
    Key? key,
    required this.schedule,
    required this.repository,
    required this.onUpdated,
  }) : super(key: key);

  @override
  State<UpdateScheduleModal> createState() => _UpdateScheduleModalState();
}

class _UpdateScheduleModalState extends State<UpdateScheduleModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _subjectController;
  late TextEditingController _timeController;
  late TextEditingController _locationController;
  late TextEditingController _lecturerController;
  late TextEditingController _descriptionController;

  late String _selectedType;
  late DateTime _selectedDate;
  late bool _isRecurring;
  String? _selectedRecurringDay;
  DateTime? _recurringUntil;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _subjectController = TextEditingController(text: widget.schedule['subject']);
    _timeController = TextEditingController(text: widget.schedule['time']);
    _locationController = TextEditingController(text: widget.schedule['location'] ?? '');
    _lecturerController = TextEditingController(text: widget.schedule['lecturer'] ?? '');
    _descriptionController = TextEditingController(text: widget.schedule['description'] ?? '');

    _selectedType = widget.schedule['type'] ?? 'class';
    _selectedDate = DateTime.parse(widget.schedule['date']);
    _isRecurring = widget.repository.isRecurring(widget.schedule);
    _selectedRecurringDay = widget.schedule['recurring_day'];

    if (widget.schedule['recurring_until'] != null) {
      _recurringUntil = DateTime.parse(widget.schedule['recurring_until']);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _lecturerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Update schedule
  Future<void> _updateSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final result = await widget.repository.editSchedule(
      scheduleId: widget.schedule['id'].toString(),
      subject: _subjectController.text,
      type: _selectedType,
      date: _selectedDate,
      time: _timeController.text,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      lecturer: _lecturerController.text.isEmpty ? null : _lecturerController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      isRecurring: _isRecurring,
      recurringDay: _selectedRecurringDay,
      recurringUntil: _recurringUntil,
    );

    setState(() => _isSubmitting = false);

    if (result['success'] == true && mounted) {
      // Build updated schedule map
      final updatedSchedule = widget.repository.buildUpdatedSchedule(
        originalSchedule: widget.schedule,
        subject: _subjectController.text,
        type: _selectedType,
        date: _selectedDate,
        time: _timeController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        lecturer: _lecturerController.text.isEmpty ? null : _lecturerController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        isRecurring: _isRecurring,
        recurringDay: _selectedRecurringDay,
        recurringUntil: _recurringUntil,
      );

      widget.onUpdated(updatedSchedule);
      Navigator.pop(context);
    } else if (mounted) {
      _showSnackBar('❌ Error: ${result['message']}', Colors.red);
    }
  }

  /// Show snackbar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  /// Select date picker
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// Select recurring until date
  Future<void> _selectRecurringUntil() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurringUntil ?? _selectedDate.add(const Duration(days: 90)),
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _recurringUntil = picked);
    }
  }

  /// Select time picker
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final endTime = await showDialog<TimeOfDay>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('End Time (Optional)'),
          content: const Text('Select end time or skip for single time'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip'),
            ),
            TextButton(
              onPressed: () async {
                final end = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                      hour: picked.hour + 2, minute: picked.minute),
                );
                if (context.mounted) Navigator.pop(context, end);
              },
              child: const Text('Select'),
            ),
          ],
        ),
      );

      String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      if (endTime != null) {
        formattedTime +=
            ' - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      }

      _timeController.text = formattedTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          _buildHandleBar(),
          _buildHeader(),
          const Divider(height: 1),
          _buildForm(),
        ],
      ),
    );
  }

  /// Build handle bar
  Widget _buildHandleBar() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  /// Build header
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Update Schedule',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  /// Build form
  Widget _buildForm() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubjectField(),
              const SizedBox(height: 16),
              _buildTypeDropdown(),
              const SizedBox(height: 16),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildTimeField(),
              const SizedBox(height: 16),
              _buildLocationField(),
              const SizedBox(height: 16),
              _buildLecturerField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 20),
              _buildRecurringToggle(),
              if (_isRecurring) ...[
                const SizedBox(height: 10),
                _buildRecurringDayDropdown(),
                const SizedBox(height: 16),
                _buildRecurringUntilField(),
              ],
              const SizedBox(height: 30),
              _buildUpdateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: _subjectController,
      decoration: const InputDecoration(
        labelText: 'Subject / Title',
        prefixIcon: Icon(Icons.title),
        border: OutlineInputBorder(),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Subject is required' : null,
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Type',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'class', child: Text('📚 Class')),
        DropdownMenuItem(value: 'event', child: Text('🎉 Event')),
        DropdownMenuItem(value: 'meeting', child: Text('👥 Meeting')),
        DropdownMenuItem(value: 'organization', child: Text('🏛️ Organization')),
        DropdownMenuItem(value: 'guidance', child: Text('🎓 Guidance')),
      ],

      onChanged: (val) => setState(() => _selectedType = val!),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(widget.repository.formatDisplayDate(_selectedDate)),
      ),
    );
  }

  Widget _buildTimeField() {
    return TextFormField(
      controller: _timeController,
      decoration: const InputDecoration(
        labelText: 'Time',
        prefixIcon: Icon(Icons.access_time),
        border: OutlineInputBorder(),
        hintText: 'e.g. 08:00 - 10:00',
      ),
      readOnly: true,
      onTap: _selectTime,
      validator: (val) => val == null || val.isEmpty ? 'Time is required' : null,
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location (optional)',
        prefixIcon: Icon(Icons.location_on),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildLecturerField() {
    return TextFormField(
      controller: _lecturerController,
      decoration: const InputDecoration(
        labelText: 'Lecturer / PIC (optional)',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (optional)',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildRecurringToggle() {
    return SwitchListTile(
      title: const Text(
        '🔁 Recurring Schedule',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text('Repeat every week on a specific day'),
      value: _isRecurring,
      onChanged: (val) => setState(() {
        _isRecurring = val;
        if (!val) {
          _selectedRecurringDay = null;
          _recurringUntil = null;
        }
      }),
      activeColor: Colors.indigo,
    );
  }

  Widget _buildRecurringDayDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRecurringDay,
      decoration: const InputDecoration(
        labelText: 'Recurring Day',
        prefixIcon: Icon(Icons.event_repeat),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'monday', child: Text('Monday')),
        DropdownMenuItem(value: 'tuesday', child: Text('Tuesday')),
        DropdownMenuItem(value: 'wednesday', child: Text('Wednesday')),
        DropdownMenuItem(value: 'thursday', child: Text('Thursday')),
        DropdownMenuItem(value: 'friday', child: Text('Friday')),
        DropdownMenuItem(value: 'saturday', child: Text('Saturday')),
        DropdownMenuItem(value: 'sunday', child: Text('Sunday')),
      ],
      onChanged: (val) => setState(() => _selectedRecurringDay = val),
      validator: (val) =>
          _isRecurring && val == null ? 'Please select a day' : null,
    );
  }

  Widget _buildRecurringUntilField() {
    return InkWell(
      onTap: _selectRecurringUntil,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Repeat Until (Optional)',
          prefixIcon: Icon(Icons.event),
          border: OutlineInputBorder(),
        ),
        child: Text(
          _recurringUntil != null
              ? widget.repository.formatDisplayDate(_recurringUntil!)
              : 'No end date',
          style: TextStyle(
            color: _recurringUntil != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _updateSchedule,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Update Schedule',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}