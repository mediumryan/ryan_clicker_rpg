import 'package:flutter/material.dart'; // Needed for WidgetsFlutterBinding
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/data/achievement_data.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart'; // Import WeaponData
import 'package:ryan_clicker_rpg/screens/special_boss_screen.dart';
import 'providers/game_provider.dart';
import 'screens/main_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized
  await WeaponData.initialize(); // Initialize WeaponData
  await AchievementData.initialize(); // Initialize AchievementData

  // Create GameProvider instance
  final gameProvider = GameProvider();

  // Initialize GameProvider after WeaponData is ready
  await gameProvider.initializeGame();

  runApp(
    ChangeNotifierProvider<GameProvider>.value(
      // Use .value constructor
      value: gameProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // No ChangeNotifierProvider here anymore
      title: 'Ryan Clicker RPG',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<GameProvider>(
        builder: (context, game, child) {
          return game.inSpecialBossZone
              ? const SpecialBossScreen()
              : const MainGameScreen();
        },
      ),
    );
  }
}
