import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  String? _gender;
  bool _initialized = false;
  bool _isSaving = false;
  bool _isProcessingBackup = false;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    try {
      await ref.read(settingsStateProvider.notifier).updateSettings(
            gender: _gender,
            height: height,
            weight: weight,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _exportJson() async {
    setState(() {
      _isProcessingBackup = true;
    });

    try {
      final jsonString = await ref.read(backupServiceProvider).exportToJson();
      final bytes = Uint8List.fromList(utf8.encode(jsonString));
      final path = await FilePicker.saveFile(
        dialogTitle: 'Save JSON Backup',
        fileName: 'fitlog_backup.json',
        allowedExtensions: ['json'],
        type: FileType.custom,
        bytes: bytes,
      );

      if (path != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup exported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessingBackup = false;
      });
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _importJson() async {
    final confirm = await _showConfirmationDialog(
      title: 'Import JSON Backup',
      content: 'This will overwrite your profile settings and append new workout entries. Do you want to proceed?',
      confirmText: 'Import',
    );
    if (!confirm) return;

    setState(() {
      _isProcessingBackup = true;
    });

    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select JSON Backup File',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        await ref.read(backupServiceProvider).importFromJson(content);
        
        // Reset initialization so the profile form re-reads settings from provider
        setState(() {
          _initialized = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backup imported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessingBackup = false;
      });
    }
  }

  Future<void> _exportIsarDb() async {
    setState(() {
      _isProcessingBackup = true;
    });

    try {
      final dbBytes = await ref.read(backupServiceProvider).getDatabaseBytes();
      final path = await FilePicker.saveFile(
        dialogTitle: 'Save Database Backup',
        fileName: 'default.isar',
        allowedExtensions: ['isar'],
        type: FileType.custom,
        bytes: dbBytes,
      );

      if (path != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Full database exported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessingBackup = false;
      });
    }
  }

  Future<void> _importIsarDb() async {
    final confirm = await _showConfirmationDialog(
      title: 'Full Database Import',
      content: 'WARNING: This will completely overwrite your current database. All current workouts and settings will be permanently replaced. Do you want to proceed?',
      confirmText: 'Overwrite',
    );
    if (!confirm) return;

    setState(() {
      _isProcessingBackup = true;
    });

    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select Database Backup File',
        type: FileType.custom,
        allowedExtensions: ['isar'],
      );

      if (result != null && result.files.single.path != null) {
        await ref.read(backupServiceProvider).importDatabase(result.files.single.path!);
        
        // Reset initialization so any local settings form is correctly aligned
        setState(() {
          _initialized = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Database imported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessingBackup = false;
      });
    }
  }

  Future<void> _importGpxTcx() async {
    setState(() {
      _isProcessingBackup = true;
    });

    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: 'Select GPX or TCX file to import',
        type: FileType.custom,
        allowedExtensions: ['gpx', 'tcx', 'xml'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final content = await file.readAsString();

        final isTcx = filePath.toLowerCase().endsWith('.tcx') || content.contains('<TrainingCenterDatabase');
        
        final backupService = ref.read(backupServiceProvider);
        final parsedWorkout = isTcx 
            ? backupService.parseTcx(content) 
            : backupService.parseGpx(content);

        await backupService.saveWorkout(parsedWorkout);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Imported "${parsedWorkout.workout.name}" successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import workout file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessingBackup = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          settingsAsync.when(
            data: (settings) {
              if (!_initialized) {
                _gender = settings.gender;
                _heightController.text = settings.height?.toString() ?? '';
                _weightController.text = settings.weight?.toString() ?? '';
                _initialized = true;
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(theme),
                    const SizedBox(height: 24),
                    _buildBackupRestoreCard(theme),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Text(
                'Error loading settings: $err',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ),
          if (_isProcessingBackup)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing, please wait...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'User Profile',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                  DropdownMenuItem(value: 'Not Specified', child: Text('Not Specified')),
                ],
                onChanged: (val) {
                  setState(() {
                    _gender = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Height Field
              TextFormField(
                controller: _heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final val = double.tryParse(value);
                  if (val == null || val <= 0) {
                    return 'Please enter a valid height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Weight Field
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final val = double.tryParse(value);
                  if (val == null || val <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving 
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Save Profile'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupRestoreCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.backup_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Data Management & Backup',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Export JSON
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Export Data to JSON'),
              subtitle: const Text('Save all settings and workout data to a single JSON file.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _exportJson,
            ),
            const Divider(height: 8),

            // Import JSON
            ListTile(
              leading: const Icon(Icons.download_done_outlined),
              title: const Text('Import Data from JSON'),
              subtitle: const Text('Import and restore data/settings from a JSON backup file.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _importJson,
            ),
            const Divider(height: 8),

            // Full DB Copy
            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Full Database Export'),
              subtitle: const Text('Export raw database file (default.isar) for manual backup.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _exportIsarDb,
            ),
            const Divider(height: 8),

            // Full DB Import
            ListTile(
              leading: const Icon(Icons.settings_backup_restore_outlined),
              title: const Text('Full Database Import'),
              subtitle: const Text('Import raw database file (default.isar) to restore from manual backup.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _importIsarDb,
            ),
            const Divider(height: 8),

            // Import GPX/TCX
            ListTile(
              leading: const Icon(Icons.directions_run),
              title: const Text('Import Workout (GPX / TCX)'),
              subtitle: const Text('Parse and import a single workout file from other apps.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _importGpxTcx,
            ),
          ],
        ),
      ),
    );
  }
}
