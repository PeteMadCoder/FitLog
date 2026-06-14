import 'package:flutter/material.dart';

/// Placeholder screen for the Workout Diary.
class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diary')),
      body: const Center(
        child: Text(
          'Workout Diary & Calendar Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
