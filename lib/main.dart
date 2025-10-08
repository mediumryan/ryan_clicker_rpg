import 'package:flutter/material.dart'; // Needed for WidgetsFlutterBinding
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/data/achievement_data.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart'; // Import WeaponData
import 'providers/game_provider.dart';
import 'screens/main_game_screen.dart';

import 'package:google_fonts/google_fonts.dart';

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
      title: 'Ryan Clicker RPG',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ).copyWith(
        textTheme: GoogleFonts.juaTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      builder: (context, child) {
        return Selector<GameProvider, String>(
          selector: (context, game) => game.player.graphicsQuality,
          builder: (context, quality, _) {
            final mediaQuery = MediaQuery.of(context);
            double pixelRatio = mediaQuery.devicePixelRatio;

            if (quality == 'Low') {
              pixelRatio = 1.0;
            } else if (quality == 'Medium') {
              pixelRatio = mediaQuery.devicePixelRatio * 0.75;
            }

            return MediaQuery(
              data: mediaQuery.copyWith(devicePixelRatio: pixelRatio),
              child: child!,
            );
          },
        );
      },
      home: const MainGameScreen(),
    );
  }
}
