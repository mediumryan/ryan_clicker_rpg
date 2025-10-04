import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/widgets/quick_access_buttons.dart';
import 'package:ryan_clicker_rpg/widgets/stage_zone_widget.dart';
import 'package:ryan_clicker_rpg/widgets/weapon_info_widget.dart';
import 'package:ryan_clicker_rpg/widgets/app_drawer.dart';
import 'package:ryan_clicker_rpg/widgets/player_resources_widget.dart'; // New import

class MainGameScreen extends StatelessWidget {
  const MainGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
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
                      Expanded(
                        flex: 3,
                        child: WeaponInfoWidget(
                          weapon: game.player.equippedWeapon,
                        ),
                      ),
                      const Expanded(flex: 7, child: QuickAccessButtons()),
                    ],
                  ),
                ),
                _buildPlayerStats(game),
                // Bottom 80% of the screen
                Expanded(
                  flex: 8,
                  child: StageZoneWidget(
                    player: game.player,
                    monster: game.monster,
                    onAttack: (Map<String, dynamic> _) {
                      // Accept the empty map, but don't use it
                      return game.attackMonster();
                    },
                    onGoToNextStage: game.goToNextStage,
                    onGoToPreviousStage: game.goToPreviousStage,
                    isMonsterDefeated: game.isMonsterDefeated,
                    stageName: game.currentStageName, // Pass stage name
                    monsterEffectiveDefense: game
                        .currentMonsterEffectiveDefense, // New: Pass effective defense
                    autoAttackDelay:
                        game.autoAttackDelay, // New: Pass auto attack delay
                    lastGoldReward: game.lastGoldReward, // New
                    lastDroppedBox: game.lastDroppedBox, // New
                    lastEnhancementStonesReward:
                        game.lastEnhancementStonesReward, // New
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerStats(GameProvider game) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.black.withAlpha(128),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat(
                    'images/stats/damage.png',
                    game.player.finalDamage.toStringAsFixed(0),
                    '공격력: 몬스터에게 입히는 기본 데미지입니다. 몬스터의 방어력에 따라 최종 데미지가 달라질 수 있습니다.',
                  ),
                  _buildStat(
                    'images/stats/speed.png',
                    game.player.finalAttackSpeed.toStringAsFixed(2),
                    '공격속도: 1초당 공격하는 횟수입니다. 수치가 높을수록 더 빠르게 공격합니다.',
                  ),
                  _buildStat(
                    'images/stats/critical_chance.png',
                    '${(game.player.finalCritChance * 100).toStringAsFixed(1)}%',
                    '치명타 확률: 공격 시 치명타가 발생할 확률입니다.',
                  ),
                  _buildStat(
                    'images/stats/critical_damage.png',
                    'x${game.player.finalCritDamage.toStringAsFixed(2)}',
                    '치명타 배율: 치명타 공격 시 적용되는 데미지 배율입니다.',
                  ),
                  _buildStat(
                    'images/stats/accuracy.png',
                    '${(game.player.finalAccuracy * 100).toStringAsFixed(0)}%',
                    '적중률: 공격이 몬스터에게 적중할 확률입니다.',
                  ),
                  _buildStat(
                    'images/stats/double_attack_chance.png',
                    '${(game.player.finalDoubleAttackChance * 100).toStringAsFixed(1)}%',
                    '더블 어택 확률: 공격 시 한 번 더 공격할 확률입니다.',
                  ),
                  _buildStat(
                    'images/stats/defense_penetration.png',
                    game.player.finalDefensePenetration.toStringAsFixed(0),
                    '방어력 관통: 몬스터의 방어력을 무시하는 수치입니다.',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String imagePath, String value, String tooltipMessage) {
    return SizedBox(
      width: 70,
      child: Tooltip(
        message: tooltipMessage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 24, height: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
