import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:callory/l10n/app_localizations.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/ui/goals/goals_screen.dart';

enum _LanguageChoice { system, english, russian }

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
    final loc = AppLocalizations.of(context)!;
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
        title: Text(loc.settingsImportConfirmTitle),
        content: Text(loc.settingsImportConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.settingsCancelButton)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.settingsReplaceButton)),
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
          SnackBar(content: Text(loc.settingsImportSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.settingsImportFailure(e.toString()))),
        );
      }
    }
  }

  Future<void> _pickLanguage() async {
    final choice = await showDialog<_LanguageChoice>(
      context: context,
      builder: (context) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, _LanguageChoice.system),
            child: const Text('System'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, _LanguageChoice.english),
            child: const Text('English'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, _LanguageChoice.russian),
            child: const Text('Русский'),
          ),
        ],
      ),
    );
    if (choice == null) return;
    final locale = switch (choice) {
      _LanguageChoice.system => null,
      _LanguageChoice.english => const Locale('en'),
      _LanguageChoice.russian => const Locale('ru'),
    };
    await ref.read(localeProvider.notifier).setLocale(locale);
  }

  String _languageSubtitle(Locale? locale) {
    switch (locale?.languageCode) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      default:
        return 'System';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(loc.settingsGapWindowLabel(_gapMinutes)),
          Slider(
            value: _gapMinutes.toDouble(),
            min: 15,
            max: 240,
            divisions: 15,
            label: loc.settingsGapWindowSliderLabel(_gapMinutes),
            onChanged: (value) => setState(() => _gapMinutes = value.round()),
            onChangeEnd: (value) =>
                ref.read(settingsServiceProvider).setGapWindowMinutes(value.round()),
          ),
          const Divider(height: 32),
          ListTile(
            title: Text(loc.settingsLanguageLabel),
            subtitle: Text(_languageSubtitle(ref.watch(localeProvider))),
            onTap: _pickLanguage,
          ),
          const Divider(height: 32),
          ListTile(
            title: Text(loc.settingsSetGoalsLabel),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GoalsScreen()),
            ),
          ),
          const Divider(height: 32),
          ElevatedButton(onPressed: _exportData, child: Text(loc.settingsExportButton)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _importData, child: Text(loc.settingsImportButton)),
        ],
      ),
    );
  }
}
