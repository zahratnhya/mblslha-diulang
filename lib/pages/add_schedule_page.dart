import 'package:flutter/material.dart';
import '../repositories/schedule_repository.dart';

/// UI Layer - Add Schedule Page
class AddSchedulePage extends StatefulWidget {
  final int userId;

  const AddSchedulePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final ScheduleRepository _repository = ScheduleRepository();
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _lecturerController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'class';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String? _selectedRecurringDay;
  DateTime? _recurringUntil;

  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _lecturerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Submit schedule
  Future<void> _submitSchedule() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi recurring
    if (!_repository.validateRecurringSchedule(_isRecurring, _selectedRecurringDay)) {
      _showSnackBar('⚠️ Please select a day for recurring schedule', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _repository.createSchedule(
        userId: widget.userId,
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

      if (mounted) {
        setState(() => _isSubmitting = false);
      }

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackBar('✅ Schedule added successfully!', Colors.green);
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showSnackBar('❌ Error: ${result['message']}', Colors.red);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnackBar('❌ Error: $e', Colors.red);
      }
    }
  }

  /// Show snackbar
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Select date
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _recurringUntil = picked);
    }
  }

  /// Select time
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final endTime = await _showEndTimeDialog(picked);
      final formattedTime = _repository.formatTimeFromPicker(picked, endTime);
      _timeController.text = formattedTime;
    }
  }

  /// Show end time dialog
  Future<TimeOfDay?> _showEndTimeDialog(TimeOfDay startTime) async {
    return await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: const [
            Icon(Icons.schedule_rounded, color: Colors.indigo),
            SizedBox(width: 10),
            Text('End Time'),
          ],
        ),
        content: const Text('Select end time or skip for single time'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              final end = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: startTime.hour + 2,
                  minute: startTime.minute,
                ),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.indigo,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (context.mounted) Navigator.pop(context, end);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar dengan gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.indigo.shade600,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'ADD SCHEDULE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color:Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade600,
                      Colors.indigo.shade400,
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeaderInfo(),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildBasicInfoCard(),
                      const SizedBox(height: 16),
                      _buildDateTimeCard(),
                      const SizedBox(height: 16),
                      _buildOptionalDetailsCard(),
                      const SizedBox(height: 16),
                      _buildRecurringCard(),
                      const SizedBox(height: 24),
                      _buildSubmitButton(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Build header info
  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.indigo.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Colors.indigo,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in the details below',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Basic Info Card
  Widget _buildBasicInfoCard() {
    return _buildCard(
      title: 'Basic Information',
      icon: Icons.info_outline_rounded,
      children: [
        _buildModernTextField(
          controller: _subjectController,
          label: 'Subject / Title',
          icon: Icons.title_rounded,
          hint: 'e.g., Data Structures',
          validator: (val) =>
              val == null || val.isEmpty ? 'Subject is required' : null,
        ),
        const SizedBox(height: 16),
        _buildTypeDropdown(),
      ],
    );
  }

  /// Build Date Time Card
  Widget _buildDateTimeCard() {
    return _buildCard(
      title: 'Date & Time',
      icon: Icons.calendar_month_rounded,
      children: [
        _buildDateField(),
        const SizedBox(height: 16),
        _buildTimeField(),
      ],
    );
  }

  /// Build Optional Details Card
  Widget _buildOptionalDetailsCard() {
    return _buildCard(
      title: 'Additional Details',
      icon: Icons.more_horiz_rounded,
      children: [
        _buildModernTextField(
          controller: _locationController,
          label: 'Location',
          icon: Icons.location_on_rounded,
          hint: 'e.g., Building B - Room 204',
          required: false,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _lecturerController,
          label: 'Lecturer / PIC',
          icon: Icons.person_rounded,
          hint: 'e.g., Dr. John Doe',
          required: false,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _descriptionController,
          label: 'Description',
          icon: Icons.description_rounded,
          hint: 'Add notes or description...',
          required: false,
          maxLines: 3,
        ),
      ],
    );
  }

  /// Build Recurring Card
  Widget _buildRecurringCard() {
    return _buildCard(
      title: 'Recurring Options',
      icon: Icons.repeat_rounded,
      children: [
        _buildRecurringToggle(),
        if (_isRecurring) ...[
          const SizedBox(height: 16),
          _buildRecurringDayDropdown(),
          const SizedBox(height: 16),
          _buildRecurringUntilField(),
          const SizedBox(height: 12),
          _buildRecurringInfoBox(),
        ],
      ],
    );
  }

  /// Build card wrapper
  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.indigo, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  /// Build modern text field
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    bool required = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            if (!required) ...[
              const SizedBox(width: 6),
              Text(
                '(Optional)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.indigo, size: 20),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.indigo, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  /// Build type dropdown
  Widget _buildTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _repository.getTypeColor(_selectedType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _repository.getTypeIcon(_selectedType),
                  color: _repository.getTypeColor(_selectedType),
                  size: 20,
                ),
              ),
              border: InputBorder.none,
            ),
            items: const [
              DropdownMenuItem(value: 'class', child: Text('📚 Class')),
              DropdownMenuItem(value: 'event', child: Text('🎉 Event')),
              DropdownMenuItem(value: 'meeting', child: Text('👥 Meeting')),
              DropdownMenuItem(value: 'organization', child: Text('🏛️ Organization')),
              DropdownMenuItem(value: 'guidance', child: Text('🎓 Guidance')),
            ],
            onChanged: (val) => setState(() => _selectedType = val!),
          ),
        ),
      ],
    );
  }

  /// Build date field
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _repository.formatDisplayDate(_selectedDate),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build time field
  Widget _buildTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _timeController,
          readOnly: true,
          onTap: _selectTime,
          decoration: InputDecoration(
            hintText: 'e.g. 08:00 - 10:00',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: Colors.orange,
                size: 20,
              ),
            ),
            suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          validator: (val) =>
              val == null || val.isEmpty ? 'Time is required' : null,
        ),
      ],
    );
  }

  /// Build recurring toggle
  Widget _buildRecurringToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _isRecurring ? Colors.indigo.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isRecurring ? Colors.indigo.shade200 : Colors.grey.shade200,
        ),
      ),
      child: SwitchListTile(
        title: const Text(
          'Repeat Weekly',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text('Schedule repeats every week'),
        value: _isRecurring,
        onChanged: (val) => setState(() {
          _isRecurring = val;
          if (!val) {
            _selectedRecurringDay = null;
            _recurringUntil = null;
          }
        }),
        activeColor: Colors.indigo,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  /// Build recurring day dropdown
  Widget _buildRecurringDayDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat On',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedRecurringDay,
            decoration: InputDecoration(
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event_repeat_rounded,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              hintText: 'Select a day',
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
          ),
        ),
      ],
    );
  }

  /// Build recurring until field
  Widget _buildRecurringUntilField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Repeat Until',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(Optional)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectRecurringUntil,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _recurringUntil != null
                      ? _repository.formatDisplayDate(_recurringUntil!)
                      : 'No end date',
                  style: TextStyle(
                    fontSize: 15,
                    color: _recurringUntil != null
                        ? Colors.black87
                        : Colors.grey[500],
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build recurring info box
  Widget _buildRecurringInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.indigo.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.indigo.shade700, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _repository.getRecurringInfoText(_selectedRecurringDay, _recurringUntil),
              style: TextStyle(
                fontSize: 13,
                color: Colors.indigo.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build submit button
  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isSubmitting
            ? []
            : [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitSchedule,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Adding Schedule...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Add Schedule',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}