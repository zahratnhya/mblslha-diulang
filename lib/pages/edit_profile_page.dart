import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/profile_repository.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> currentData;

  const EditProfilePage({
    Key? key,
    required this.userId,
    required this.currentData,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileRepository _repository = ProfileRepository();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _campusController;
  late TextEditingController _majorController;
  late TextEditingController _semesterController;

  File? _selectedImage;
  bool _isSubmitting = false;
  bool _deleteImage = false;
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentData['name']);
    _emailController = TextEditingController(text: widget.currentData['email']);
    _campusController = TextEditingController(text: widget.currentData['campus']);
    _majorController = TextEditingController(text: widget.currentData['major']);
    _semesterController = TextEditingController(text: widget.currentData['semester']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _campusController.dispose();
    _majorController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _processSelectedImage(image);
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackBar('Failed to pick image: $e', Colors.red);
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _processSelectedImage(image);
      }
    } catch (e) {
      print('Error capturing photo: $e');
      _showSnackBar('Failed to capture photo: $e', Colors.red);
    }
  }

  Future<void> _processSelectedImage(XFile image) async {
    try {
      final file = File(image.path);
      
      final fileSize = await file.length();
      final fileSizeMB = fileSize / (1024 * 1024);
      
      const maxSizeMB = 5;
      if (fileSizeMB > maxSizeMB) {
        _showSnackBar(
          'Image too large (${fileSizeMB.toStringAsFixed(1)}MB). Max size is ${maxSizeMB}MB',
          Colors.orange,
        );
        return;
      }

      setState(() {
        _selectedImage = file;
        _deleteImage = false;
        _imageChanged = true;
      });
      _showSnackBar('✓ Image selected (${fileSizeMB.toStringAsFixed(2)}MB)', Colors.green);
    } catch (e) {
      print('Error processing image: $e');
      _showSnackBar('Failed to process image: $e', Colors.red);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Select Photo Source',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Gallery',
                  subtitle: 'Choose from gallery',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                const SizedBox(height: 12),
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Camera',
                  subtitle: 'Take a new photo',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                if (_selectedImage != null || _repository.hasProfileImage(widget.currentData)) ...[
                  const SizedBox(height: 12),
                  _buildImageSourceOption(
                    icon: Icons.delete_rounded,
                    title: 'Remove Photo',
                    subtitle: 'Delete current photo',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _deleteImage = true;
                        _imageChanged = true;
                      });
                      _showSnackBar('Photo will be removed', Colors.orange);
                    },
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitUpdate() async {
    print('🔥 UPDATE PROFILE CLICKED');

    if (!_formKey.currentState!.validate()) {
      print('❌ FORM VALIDATION FAILED');
      _showSnackBar('⚠️ Please fill all required fields', Colors.orange);
      return;
    }

    print('✅ Form validation passed');

    setState(() => _isSubmitting = true);
    
    // ✅ WORKAROUND: Ambil foto lama jika user tidak ubah foto
    String? currentImage;
    if (!_imageChanged && _repository.hasProfileImage(widget.currentData)) {
      currentImage = widget.currentData['profile_image'];
      print('🔄 Will send existing profile image to preserve it');
    }

    print('📤 Submitting to API...');
    print('🖼️ Selected Image: ${_selectedImage?.path ?? "none"}');
    print('🗑️ Delete Image: $_deleteImage');
    print('🔄 Image Changed: $_imageChanged');
    print('💾 Current Image exists: ${currentImage != null}');

    try {
      final result = await _repository.updateProfile(
        userId: widget.userId,
        name: _nameController.text,
        email: _emailController.text,
        campus: _campusController.text,
        major: _majorController.text,
        semester: _semesterController.text,
        imageFile: _imageChanged ? _selectedImage : null,
        deleteImage: _imageChanged && _deleteImage,
        currentProfileImage: currentImage, // ✅ KIRIM FOTO LAMA
      );

      print('📡 API Result: $result');

      if (mounted) {
        setState(() => _isSubmitting = false);
      }

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackBar('✅ Profile updated successfully!', Colors.green);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showSnackBar('❌ Error: ${result['message']}', Colors.red);
      }
    } catch (e) {
      print('💥 EXCEPTION: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnackBar('❌ Error: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCurrentImage = _repository.hasProfileImage(widget.currentData);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.indigo.shade600,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white
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
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                _buildImageSection(hasCurrentImage),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildPersonalInfoCard(),
                      const SizedBox(height: 16),
                      _buildAcademicInfoCard(),
                      const SizedBox(height: 32),
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

  Widget _buildImageSection(bool hasCurrentImage) {
    final shouldShowImage = _selectedImage != null || 
                            (hasCurrentImage && !_deleteImage);
    
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.indigo, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.indigo.shade50,
                  backgroundImage: shouldShowImage
                      ? (_selectedImage != null
                          ? FileImage(_selectedImage!)
                          : MemoryImage(
                              base64Decode(widget.currentData['profile_image']),
                            ) as ImageProvider)
                      : null,
                  child: !shouldShowImage
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 50,
                              color: Colors.indigo.shade300,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No Photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.indigo.shade300,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'New photo selected',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_deleteImage && _selectedImage == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.orange, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Photo will be removed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return _buildCard(
      title: 'Personal Information',
      icon: Icons.person_rounded,
      children: [
        _buildModernTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.badge_rounded,
          hint: 'Enter your full name',
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email_rounded,
          hint: 'your.email@example.com',
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
              return 'Invalid email format';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAcademicInfoCard() {
    return _buildCard(
      title: 'Academic Information',
      icon: Icons.school_rounded,
      children: [
        _buildModernTextField(
          controller: _campusController,
          label: 'Campus',
          icon: Icons.apartment_rounded,
          hint: 'e.g., Universitas Islam Negeri Malang',
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Campus is required' : null,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _majorController,
          label: 'Major',
          icon: Icons.book_rounded,
          hint: 'e.g., Teknik Informatika',
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Major is required' : null,
        ),
        const SizedBox(height: 16),
        _buildModernTextField(
          controller: _semesterController,
          label: 'Semester',
          icon: Icons.calendar_today_rounded,
          hint: 'e.g., 5',
          keyboardType: TextInputType.number,
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Semester is required' : null,
        ),
      ],
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(fontSize: 15),
          validator: validator,
        ),
      ],
    );
  }

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
        onPressed: _isSubmitting ? null : _submitUpdate,
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
                    'Saving Changes...',
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
                    Icons.save_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Save Changes',
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