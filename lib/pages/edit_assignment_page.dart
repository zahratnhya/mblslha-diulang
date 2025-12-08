import 'package:flutter/material.dart';
import '../repositories/assigment_repository.dart';

/// UI Layer - Edit Assignment Page
class EditAssignmentPage extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> assignment;

  const EditAssignmentPage({
    Key? key,
    required this.userId,
    required this.assignment,
  }) : super(key: key);

  @override
  State<EditAssignmentPage> createState() => _EditAssignmentPageState();
}

class _EditAssignmentPageState extends State<EditAssignmentPage> {
  final AssignmentRepository _repository = AssignmentRepository();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _timeController;
  late DateTime _selectedDeadline;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data
    _titleController = TextEditingController(
      text: widget.assignment['title']?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.assignment['description']?.toString() ?? '',
    );
    _timeController = TextEditingController(
      text: widget.assignment['time']?.toString() ?? '',
    );

    // Parse deadline
    try {
      _selectedDeadline = DateTime.parse(widget.assignment['deadline'] ?? '');
    } catch (e) {
      _selectedDeadline = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  /// Pick deadline date
  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // ✅ FIX: Jika deadline sudah lewat, gunakan deadline lama sebagai firstDate
    // Jika belum lewat, gunakan hari ini sebagai firstDate
    final firstDate = _selectedDeadline.isBefore(today) 
        ? _selectedDeadline 
        : today;
    
    // ✅ Pastikan initialDate tidak lebih kecil dari firstDate
    final initialDate = _selectedDeadline.isBefore(firstDate)
        ? firstDate
        : _selectedDeadline;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade600,
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
      setState(() => _selectedDeadline = picked);
    }
  }

  /// Pick time
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade600,
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
      final now = DateTime.now();
      final timeString = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      ).toString();

      setState(() {
        _timeController.text = timeString;
      });
    }
  }

  /// Save assignment - ✅ FIXED VERSION with timeout
  /// Save assignment - ✅ FIXED VERSION with type conversion
  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Validasi time tidak boleh kosong
    if (_timeController.text.trim().isEmpty) {
      _showSnackBar('Please select a time', Colors.red.shade600);
      return;
    }

    setState(() => isSaving = true);

    try {
      // ✅ FIX: Convert status to int properly
      final statusValue = widget.assignment['status'];
      final int status;
      
      if (statusValue is int) {
        status = statusValue;
      } else if (statusValue is String) {
        status = int.tryParse(statusValue) ?? 0;
      } else {
        status = 0;
      }

      // ✅ Tambahkan timeout 15 detik
      final result = await _repository.updateAssignment(
        assignmentId: widget.assignment['id'].toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        time: _timeController.text.trim(),
        deadline: _selectedDeadline.toString().split(' ')[0],
        status: status, // ✅ Now properly converted to int
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          return {
            'success': false,
            'message': 'Request timeout. Please check your internet connection.',
          };
        },
      );

      // ✅ PASTIKAN setState dipanggil sebelum Navigator.pop
      if (mounted) {
        setState(() => isSaving = false);
      }

      if (result['success'] == true && mounted) {
        _showSnackBar('Assignment updated successfully!', Colors.green.shade600);
        // Tunggu sebentar agar snackbar terlihat
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (mounted) {
        _showSnackBar(
          result['message'] ?? 'Failed to update assignment',
          Colors.red.shade600,
        );
      }
    } catch (e) {
      // ✅ Tangkap semua error
      if (mounted) {
        setState(() => isSaving = false);
        _showSnackBar(
          'Error: ${e.toString()}',
          Colors.red.shade600,
        );
      }
      print('Error in _saveAssignment: $e');
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Edit Assignment',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ✅ Tombol Cancel untuk debugging
          if (isSaving)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  setState(() => isSaving = false);
                  _showSnackBar('Cancelled', Colors.orange.shade600);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : _saveAssignment,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check_rounded, size: 20),
              label: Text(
                isSaving ? 'Saving...' : 'Save',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo.shade600,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Assignment Details', Icons.assignment_rounded),
              const SizedBox(height: 16),
              _buildTitleField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 24),
              _buildSectionTitle('Schedule', Icons.schedule_rounded),
              const SizedBox(height: 16),
              _buildDeadlineField(),
              const SizedBox(height: 16),
              _buildTimeField(),
              const SizedBox(height: 32),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade600,
                Colors.indigo.shade400,
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F36),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _titleController,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1F36),
        ),
        decoration: InputDecoration(
          labelText: 'Title',
          labelStyle: TextStyle(
            color: Colors.indigo.shade600,
            fontWeight: FontWeight.w600,
          ),
          hintText: 'Enter assignment title',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.title_rounded, color: Colors.indigo.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a title';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 6,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1A1F36),
          height: 1.5,
        ),
        decoration: InputDecoration(
          labelText: 'Description',
          labelStyle: TextStyle(
            color: Colors.indigo.shade600,
            fontWeight: FontWeight.w600,
          ),
          hintText: 'Enter assignment description',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a description';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDeadlineField() {
    return GestureDetector(
      onTap: _pickDeadline,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.indigo.shade200,
            width: 1.5,
          ),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: Colors.indigo.shade600,
                size: 24,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedDeadline.toString().split(' ')[0],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: _pickTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.indigo.shade200,
            width: 1.5,
          ),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.access_time_rounded,
                color: Colors.indigo.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _timeController.text.isEmpty
                        ? 'Select time'
                        : _repository.formatTime(_timeController.text),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _timeController.text.isEmpty
                          ? Colors.grey.shade400
                          : const Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.blue.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Make sure all information is correct before saving',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}