import 'package:flutter/material.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const CampusPlanner());
}

class CampusPlanner extends StatelessWidget {
  const CampusPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Campus Planner",
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
