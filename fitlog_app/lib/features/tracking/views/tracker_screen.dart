import 'package:flutter/material.dart';

/// Placeholder screen for the Workout Tracker.
class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracker')),
      body: const Center(
        child: Text(
          'Workout Tracking Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
