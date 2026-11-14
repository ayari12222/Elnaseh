import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة النشر'),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: const Center(
        child: Text(
          'هنا ستكتب منشورك وتنشره (قريباً)',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
