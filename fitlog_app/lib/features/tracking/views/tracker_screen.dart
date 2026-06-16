import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitlog_app/features/tracking/providers/tracking_notifier.dart';
import 'package:fitlog_app/features/tracking/providers/tracking_state.dart';
import 'package:fitlog_app/features/tracking/models/sport_type.dart';
import 'active_workout_screen.dart';

/// Screen displayed when the Tracker tab is selected.
/// Displays the sport selection launcher when idle, and transitions to the
/// [ActiveWorkoutScreen] once tracking begins.
class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  String _selectedSport = 'running';

  Future<void> _showSportPicker() async {
    final selected = await showModalBottomSheet<SportType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _SportPickerSheet(
          initialSport: SportType.fromId(_selectedSport),
        ),
      ),
    );

    if (selected != null && mounted) {
      setState(() {
        _selectedSport = selected.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingNotifierProvider);

    // If recording or paused, redirect to the ActiveWorkoutScreen
    if (trackingState.status != TrackingStatus.idle) {
      return const ActiveWorkoutScreen();
    }

    final selectedSportType = SportType.fromId(_selectedSport);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Start Workout')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_fill,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Ready to hit the road?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your sport and start tracking your path in real time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Sport selector card
              InkWell(
                onTap: _showSportPicker,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedSportType.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          selectedSportType.icon,
                          color: selectedSportType.color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedSportType.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to change sport',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 56),

              // Start button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await ref
                        .read(trackingNotifierProvider.notifier)
                        .startTracking(_selectedSport);

                    if (context.mounted && result.isFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result.failureOrNullValue?.message ??
                                'Failed to start tracking',
                          ),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'START WORKOUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportPickerSheet extends StatefulWidget {
  final SportType initialSport;

  const _SportPickerSheet({required this.initialSport});

  @override
  State<_SportPickerSheet> createState() => _SportPickerSheetState();
}

class _SportPickerSheetState extends State<_SportPickerSheet> {
  late final TextEditingController _searchController;
  List<SportType> _filteredSports = SportType.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSports = SportType.all;
      } else {
        _filteredSports = SportType.all
            .where((s) => s.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select Sport',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search sports...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _filteredSports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No sports found',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredSports.length,
                    itemBuilder: (context, index) {
                      final sport = _filteredSports[index];
                      final isSelected = sport.id == widget.initialSport.id;
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.12)
                                : theme.colorScheme.surfaceVariant
                                    .withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            sport.icon,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          sport.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : null,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check,
                                color: theme.colorScheme.primary)
                            : null,
                        onTap: () {
                          Navigator.pop(context, sport);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}
}
