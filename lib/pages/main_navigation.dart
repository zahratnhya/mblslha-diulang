import 'package:flutter/material.dart';
import 'home_page.dart';
import 'schedule_page.dart';
import 'assignments_page.dart';
import 'notes_page.dart';

class MainNavigation extends StatefulWidget {
  final int userId;

  const MainNavigation({super.key, required this.userId});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // Handler bottom nav
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Semua halaman utama
    final List<Widget> pages = [
      HomePage(userId: widget.userId),
      SchedulePage(userId: widget.userId),
      AssignmentsPage(userId: widget.userId),
      NotesPage(userId: widget.userId),
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[_selectedIndex],
      ),

      // ------------------------------
      //  BOTTOM NAVIGATION WITH GRADIENT
      // ------------------------------
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F7FFA), // biru muda
              Color(0xFF001C71), // biru gelap
            ],
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // wajib agar gradient terlihat
          elevation: 0,
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt),
              label: 'Assignments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.note),
              label: 'Notes',
            ),
          ],
        ),
      ),
    );
  }
}
