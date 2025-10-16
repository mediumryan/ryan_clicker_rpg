import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/widgets/quick_access_buttons.dart';
import 'package:ryan_clicker_rpg/widgets/stage_zone_widget.dart';
import 'package:ryan_clicker_rpg/widgets/weapon_info_widget.dart';
import 'package:ryan_clicker_rpg/widgets/app_drawer.dart';
import 'package:ryan_clicker_rpg/widgets/player_resources_widget.dart'; // New import

// Data class for the player stats selector
class _PlayerStatsData {
  final double finalDamage;
  final double finalAttackSpeed;
  final double finalCritChance;
  final double finalCritDamage;
  final double finalAccuracy;
  final double finalDoubleAttackChance;
  final double finalDefensePenetration;

  _PlayerStatsData({
    required this.finalDamage,
    required this.finalAttackSpeed,
    required this.finalCritChance,
    required this.finalCritDamage,
    required this.finalAccuracy,
    required this.finalDoubleAttackChance,
    required this.finalDefensePenetration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PlayerStatsData &&
          runtimeType == other.runtimeType &&
          finalDamage == other.finalDamage &&
          finalAttackSpeed == other.finalAttackSpeed &&
          finalCritChance == other.finalCritChance &&
          finalCritDamage == other.finalCritDamage &&
          finalAccuracy == other.finalAccuracy &&
          finalDoubleAttackChance == other.finalDoubleAttackChance &&
          finalDefensePenetration == other.finalDefensePenetration;

  @override
  int get hashCode =>
      finalDamage.hashCode ^
      finalAttackSpeed.hashCode ^
      finalCritChance.hashCode ^
      finalCritDamage.hashCode ^
      finalAccuracy.hashCode ^
      finalDoubleAttackChance.hashCode ^
      finalDefensePenetration.hashCode;
}

class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GameProvider>(
        context,
        listen: false,
      ).setShowHeroLevelUpDialogCallback(_showHeroLevelUpDialog);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Provider.of<GameProvider>(
      context,
      listen: false,
    ).setShowHeroLevelUpDialogCallback(null);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Save the game when the app is paused/backgrounded
      context.read<GameProvider>().saveGame();
    }
  }

  void _showHeroLevelUpDialog(int newLevel, int skillPointsGained) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('레벨 업!', style: TextStyle(color: Colors.white)),
          content: Text(
            '축하합니다! 레벨이 $newLevel이 되었습니다.\n\n스킬 포인트를 $skillPointsGained 획득했습니다.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text('확인', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const PlayerResourcesWidget(), // This widget is already optimized
            // Top 20% of the screen
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Selector<GameProvider, Weapon>(
                      selector: (context, game) => game.player.equippedWeapon,
                      builder: (context, weapon, child) {
                        return WeaponInfoWidget(
                          weapon: weapon,
                        );
                      },
                    ),
                  ),
                  const Expanded(flex: 7, child: QuickAccessButtons()),
                ],
              ),
            ),
            // This selector for stats is efficient and remains unchanged
            Selector<GameProvider, _PlayerStatsData>(
              selector: (context, game) => _PlayerStatsData(
                finalDamage: game.player.finalDamage,
                finalAttackSpeed: game.player.finalAttackSpeed,
                finalCritChance: game.player.finalCritChance,
                finalCritDamage: game.player.finalCritDamage,
                finalAccuracy: game.player.finalAccuracy,
                finalDoubleAttackChance: game.player.finalDoubleAttackChance,
                finalDefensePenetration: game.player.finalDefensePenetration,
              ),
              builder: (context, statsData, child) {
                return _buildPlayerStats(statsData);
              },
            ),
            // Bottom 80% of the screen
            const Expanded(
              flex: 8,
              child: StageZoneWidget(), // This widget is already optimized
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerStats(_PlayerStatsData stats) {
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
                    'assets/images/stats/damage.png',
                    stats.finalDamage.toStringAsFixed(0),
                    '공격력: 몬스터에게 입히는 기본 데미지입니다. 몬스터의 방어력에 따라 최종 데미지가 달라질 수 있습니다.',
                  ),
                  _buildStat(
                    'assets/images/stats/speed.png',
                    stats.finalAttackSpeed.toStringAsFixed(2),
                    '공격속도: 1초당 공격하는 횟수입니다. 수치가 높을수록 더 빠르게 공격합니다.',
                  ),
                  _buildStat(
                    'assets/images/stats/critical_chance.png',
                    '${(stats.finalCritChance * 100).toStringAsFixed(1)}%',
                    '치명타 확률: 공격 시 치명타가 발생할 확률입니다.',
                  ),
                  _buildStat(
                    'assets/images/stats/critical_damage.png',
                    'x${stats.finalCritDamage.toStringAsFixed(2)}',
                    '치명타 배율: 치명타 공격 시 적용되는 데미지 배율입니다.',
                  ),
                  _buildStat(
                    'assets/images/stats/accuracy.png',
                    '${(stats.finalAccuracy * 100).toStringAsFixed(0)}%',
                    '적중률: 공격이 몬스터에게 적중할 확률입니다.',
                  ),
                  _buildStat(
                    'assets/images/stats/double_attack_chance.png',
                    '${(stats.finalDoubleAttackChance * 100).toStringAsFixed(1)}%',
                    '더블 어택 확률: 공격 시 한 번 더 공격할 확률입니다.',
                  ),
                  _buildStat(
                    'assets/images/stats/defense_penetration.png',
                    stats.finalDefensePenetration.toStringAsFixed(0),
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
