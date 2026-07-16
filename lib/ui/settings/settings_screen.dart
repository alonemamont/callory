import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:callory/providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late int _gapMinutes;

  @override
  void initState() {
    super.initState();
    _gapMinutes = ref.read(settingsServiceProvider).gapWindow.inMinutes;
  }

  Future<void> _exportData() async {
    final json = await ref.read(exportImportServiceProvider).exportToJson();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/callory_export.json');
    await file.writeAsString(jsonEncode(json));
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _importData() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace current data?'),
        content: const Text('Importing will overwrite all current data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Replace')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final content = await File(path).readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      await ref.read(exportImportServiceProvider).importFromJson(json);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Meal grouping gap: $_gapMinutes minutes'),
          Slider(
            value: _gapMinutes.toDouble(),
            min: 15,
            max: 240,
            divisions: 15,
            label: '$_gapMinutes min',
            onChanged: (value) => setState(() => _gapMinutes = value.round()),
            onChangeEnd: (value) =>
                ref.read(settingsServiceProvider).setGapWindowMinutes(value.round()),
          ),
          const Divider(height: 32),
          ElevatedButton(onPressed: _exportData, child: const Text('Export data (JSON)')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _importData, child: const Text('Import data (JSON)')),
        ],
      ),
    );
  }
}
