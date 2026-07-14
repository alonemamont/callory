import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callory/providers/providers.dart';
import 'package:callory/data/settings_service.dart';
import 'package:callory/ui/day/day_screen.dart';
import 'package:callory/ui/add_food/add_food_screen.dart';
import 'package:callory/ui/goals/goals_screen.dart';
import 'package:callory/ui/settings/settings_screen.dart';

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

class CalloryApp extends StatelessWidget {
  const CalloryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Callory',
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
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Day'),
          NavigationDestination(icon: Icon(Icons.add), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.flag), label: 'Goals'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
