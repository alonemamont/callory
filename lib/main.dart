import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/l10n/app_localizations.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/ui/day/day_screen.dart';
import 'package:callory/ui/add_food/add_food_screen.dart';
import 'package:callory/ui/goals/goals_screen.dart';
import 'package:callory/ui/settings/settings_screen.dart';
import 'package:callory/ui/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
    ],
    child: const CalloryApp(),
  ));
}

class CalloryApp extends ConsumerWidget {
  const CalloryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Callory',
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _HomeShell(),
    );
  }
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _index = 0;

  static const _screens = [
    DayScreen(),
    AddFoodScreen(),
    GoalsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.today), label: loc.navDay),
          NavigationDestination(icon: const Icon(Icons.add), label: loc.navAdd),
          NavigationDestination(icon: const Icon(Icons.flag), label: loc.navGoals),
          NavigationDestination(icon: const Icon(Icons.settings), label: loc.navSettings),
        ],
      ),
    );
  }
}
