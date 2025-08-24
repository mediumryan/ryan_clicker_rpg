
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/widgets/nav_buttons_widget.dart';
import 'package:ryan_clicker_rpg/widgets/stage_zone_widget.dart';
import 'package:ryan_clicker_rpg/widgets/weapon_info_widget.dart';
import 'package:ryan_clicker_rpg/widgets/player_resources_widget.dart'; // New import

class MainGameScreen extends StatelessWidget {
  const MainGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, game, child) {
            return Column(
              children: [
                const PlayerResourcesWidget(), // Display player resources
                // Top 20% of the screen
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      // Left 60% of the top section
                      Expanded(
                        flex: 3, // Adjusted flex for WeaponInfoWidget
                        child: WeaponInfoWidget(weapon: game.player.equippedWeapon),
                      ),
                      // Right 40% of the top section
                      const Expanded(
                        flex: 7, // Adjusted flex for NavButtonsWidget
                        child: NavButtonsWidget(),
                      ),
                    ],
                  ),
                ),
                // Bottom 80% of the screen
                Expanded(
                  flex: 8,
                  child: StageZoneWidget(
                    player: game.player,
                    monster: game.monster,
                    onAttack: (Map<String, dynamic> _) { // Accept the empty map, but don't use it
                      return game.attackMonster();
                    },
                    onGoToNextStage: game.goToNextStage,
                    onGoToPreviousStage: game.goToPreviousStage,
                    isMonsterDefeated: game.isMonsterDefeated,
                    stageName: game.currentStageName, // Pass stage name
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
