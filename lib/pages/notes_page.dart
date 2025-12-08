import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/notes_repository.dart';

/// UI Layer - Notes List Page
class NotesPage extends StatefulWidget {
  final int userId;
  const NotesPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NotesRepository _repository = NotesRepository();
  
  List notes = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => isLoading = true);
    final fetchedNotes = await _repository.getNotes(widget.userId);
    setState(() {
      notes = fetchedNotes;
      isLoading = false;
    });
  }

  void _navigateToAddNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditNotePage(userId: widget.userId),
      ),
    );
    if (result == true) _loadNotes();
  }

  void _navigateToDetail(Map<String, dynamic> note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteDetailPage(
          note: note,
          userId: widget.userId,
        ),
      ),
    );
    if (result == true) _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
          ),
        ),
      );
    }

    final filteredNotes = _repository.filterNotes(notes, searchQuery);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: filteredNotes.isEmpty
                  ? _buildEmptyState()
                  : _buildNotesList(filteredNotes),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddNote,
        backgroundColor: Colors.indigo.shade600,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, color: Colors.white,size: 24),
        label: const Text(
          'New Note',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 20,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade600,
                      Colors.indigo.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Notes",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1F36),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Organize your thoughts",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8F95B2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade50,
                      Colors.indigo.shade100.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.indigo.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.library_books_rounded,
                      size: 16,
                      color: Colors.indigo.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "${notes.length}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.indigo.shade100,
                width: 1.5,
              ),
            ),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1A1F36),
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: "Search your notes...",
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.indigo.shade400,
                  size: 22,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () => setState(() => searchQuery = ''),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(List filteredNotes) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return _buildNoteCard(note, index);
      },
    );
  }

  Widget _buildNoteCard(Map<String, dynamic> note, int index) {
    final cardColors = [
      {
        'bg': const Color(0xFFEEF2FF),
        'border': const Color(0xFFC7D2FE),
        'accent': Colors.indigo.shade600,
      },
      {
        'bg': const Color(0xFFF0FDF4),
        'border': const Color(0xFFBBF7D0),
        'accent': Colors.green.shade600,
      },
      {
        'bg': const Color(0xFFFFF7ED),
        'border': const Color(0xFFFED7AA),
        'accent': Colors.orange.shade600,
      },
      {
        'bg': const Color(0xFFFDF2F8),
        'border': const Color(0xFFFBCFE8),
        'accent': Colors.pink.shade600,
      },
      {
        'bg': const Color(0xFFFAF5FF),
        'border': const Color(0xFFE9D5FF),
        'accent': Colors.purple.shade600,
      },
    ];

    final noteId = note['id'] != null 
        ? (int.tryParse(note['id'].toString()) ?? 0) 
        : 0;
    final colorScheme = cardColors[noteId % cardColors.length];

    return GestureDetector(
      onTap: () => _navigateToDetail(note),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme['border'] as Color,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (colorScheme['accent'] as Color).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme['bg'] as Color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (colorScheme['accent'] as Color).withOpacity(0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.description_rounded,
                      size: 20,
                      color: colorScheme['accent'] as Color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      note['title']?.toString() ?? 'Untitled',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: colorScheme['accent'] as Color,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: (colorScheme['accent'] as Color).withOpacity(0.5),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note['summary']?.toString() ?? 'No content',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.indigo.shade100,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Colors.indigo.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(note['date']?.toString() ?? ''),
                          style: TextStyle(
                            color: Colors.indigo.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.indigo.shade50,
                  Colors.indigo.shade100.withOpacity(0.3),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              searchQuery.isEmpty 
                  ? Icons.note_add_rounded 
                  : Icons.search_off_rounded,
              size: 64,
              color: Colors.indigo.shade300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery.isEmpty 
                ? 'No notes yet'
                : 'No notes found',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F36),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              searchQuery.isEmpty
                  ? 'Start capturing your ideas and thoughts.\nTap the button below to create your first note.'
                  : 'Try using different keywords or\ncheck your spelling.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8F95B2),
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return 'No date';
    
    try {
      final dateTime = DateTime.parse(date);
      final now = DateTime.now();
      final diff = now.difference(dateTime).inDays;

      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      if (diff < 7) return '$diff days ago';
      
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return date;
    }
  }
}

/// ============================================================
/// UI Layer - Note Detail Page
/// ============================================================
class NoteDetailPage extends StatefulWidget {
  final Map<String, dynamic> note;
  final int userId;

  const NoteDetailPage({
    Key? key,
    required this.note,
    required this.userId,
  }) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final NotesRepository _repository = NotesRepository();
  bool isDeleting = false;

  Future<void> _deleteNote() async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed != true) return;

    setState(() => isDeleting = true);

    final noteId = widget.note['id']?.toString() ?? '';
    if (noteId.isEmpty) {
      setState(() => isDeleting = false);
      return;
    }

    final success = await _repository.removeNote(noteId);

    if (success && mounted) {
      Navigator.pop(context, true);
      _showSnackBar('Note deleted successfully', Colors.red.shade600);
    } else if (mounted) {
      setState(() => isDeleting = false);
      _showSnackBar('Failed to delete note', Colors.red.shade600);
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
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
              'Delete Note?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: const Text(
          'This action cannot be undone. Your note will be permanently deleted.',
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
  }

  Future<void> _editNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditNotePage(
          userId: widget.userId,
          note: widget.note,
        ),
      ),
    );

    if (result == true) {
      Navigator.pop(context, true);
    }
  }

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
    final note = widget.note;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text(
          'Note Detail',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: isDeleting ? null : _editNote,
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: isDeleting ? null : _deleteNote,
            icon: isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.delete_rounded),
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
            Container(
              width: double.infinity,
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
                  Text(
                    note['title']?.toString() ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          note['date']?.toString() ?? 'No date',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
              child: Text(
                note['summary']?.toString() ?? 'No content',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: Color(0xFF1A1F36),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// UI Layer - Add/Edit Note Page
/// ============================================================
class AddEditNotePage extends StatefulWidget {
  final int userId;
  final Map<String, dynamic>? note;

  const AddEditNotePage({
    Key? key,
    required this.userId,
    this.note,
  }) : super(key: key);

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final NotesRepository _repository = NotesRepository();
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleCtrl.text = widget.note!['title']?.toString() ?? '';
      _bodyCtrl.text = widget.note!['summary']?.toString() ?? '';
    }
  }

  Future<void> _saveNote() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty && body.isEmpty) {
      _showSnackBar('Please enter title or content', Colors.orange.shade600);
      return;
    }

    setState(() => isSaving = true);

    bool success;
    
    if (widget.note == null) {
      success = await _repository.addNote(
        userId: widget.userId,
        title: title,
        content: body,
      );
    } else {
      final noteId = widget.note!['id']?.toString() ?? '';
      success = await _repository.editNote(
        noteId: noteId,
        title: title,
        content: body,
      );
    }

    if (success && mounted) {
      Navigator.pop(context, true);
      _showSnackBar(
        widget.note == null
            ? 'Note created successfully!'
            : 'Note updated successfully!',
        Colors.green.shade600,
      );
    } else if (mounted) {
      setState(() => isSaving = false);
      _showSnackBar('Failed to save note', Colors.red.shade600);
    }
  }

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
        title: Text(
          widget.note == null ? 'New Note' : 'Edit Note',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : _saveNote,
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
        child: Column(
          children: [
            Container(
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
                children: [
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1F36),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Note title',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.title_rounded,
                        color: Colors.indigo.shade400,
                      ),
                    ),
                  ),
                  Divider(height: 32, color: Colors.indigo.shade100),
                  TextField(
                    controller: _bodyCtrl,
                    maxLines: null,
                    minLines: 15,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Color(0xFF1A1F36),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing your note...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }
}