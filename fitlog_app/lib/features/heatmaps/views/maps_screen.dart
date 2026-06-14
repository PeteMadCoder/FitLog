import 'package:flutter/material.dart';

/// Placeholder screen for Maps and Discovery.
class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Maps')),
      body: const Center(
        child: Text('Maps and Routes Screen', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
