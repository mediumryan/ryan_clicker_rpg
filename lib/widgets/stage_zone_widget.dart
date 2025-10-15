import 'package:ryan_clicker_rpg/models/difficulty.dart';
import 'package:ryan_clicker_rpg/data/difficulty_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ryan_clicker_rpg/models/status_effect.dart';

import 'package:ryan_clicker_rpg/models/gacha_box.dart'; // New import
import 'dart:async'; // Import for Timer
import 'package:provider/provider.dart'; // New import
import 'package:ryan_clicker_rpg/providers/game_provider.dart'; // New import
import 'package:intl/intl.dart';

class _HeroExpData {
  final int heroLevel;
  final double heroExp;
  final double requiredExp;

  _HeroExpData({
    required this.heroLevel,
    required this.heroExp,
    required this.requiredExp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _HeroExpData &&
          runtimeType == other.runtimeType &&
          heroLevel == other.heroLevel &&
          heroExp == other.heroExp &&
          requiredExp == other.requiredExp;

  @override
  int get hashCode =>
      heroLevel.hashCode ^ heroExp.hashCode ^ requiredExp.hashCode;
}

enum DamageType {
  normal,
  doubleAttack,
  bleed,
  shatter,
  shock,
  poison,
  fixed,
  maxHp,
  instantKill,
}

// Class to hold damage text information
class DamageText {
  final int damage;
  final bool isCritical;
  final bool isMiss; // New
  final bool isSkillDamage;
  final DamageType damageType;
  final Key key;

  DamageText({
    required this.damage,
    required this.isCritical,
    required this.isMiss,
    this.isSkillDamage = false,
    this.damageType = DamageType.normal,
  }) // Modified
  : key = UniqueKey();
}


class StageZoneWidget extends StatefulWidget {
  const StageZoneWidget({super.key});

  @override
  State<StageZoneWidget> createState() => _StageZoneWidgetState();
}

class _StageZoneWidgetState extends State<StageZoneWidget> {
  Timer? _defeatTimer;
  final List<DamageText> _damageTexts = []; // List to hold active damage texts

  // Helper map to get icon and color for each status effect
  final Map<StatusEffectType, String> _statusEffectImagePaths = {
    StatusEffectType.poison: 'assets/images/status/poison.png',
    StatusEffectType.bleed: 'assets/images/status/bleed.png',
    StatusEffectType.stun: 'assets/images/status/stun.png',
    StatusEffectType.confusion: 'assets/images/status/confusion.png',
    StatusEffectType.sleep: 'assets/images/status/sleep.png',
    StatusEffectType.disarm: 'assets/images/status/disarm.png',
    StatusEffectType.charm: 'assets/images/status/charm.png',
    StatusEffectType.weakness: 'assets/images/status/weakness.png',
    StatusEffectType.freeze: 'assets/images/status/freeze.png',
    StatusEffectType.burn: 'assets/images/status/burn.png',
    StatusEffectType.shock: 'assets/images/status/shock.png',
  };

  @override
  void initState() {
    super.initState();
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.setShowFloatingDamageTextCallback(_showDamageText);
    gameProvider.setShowDifficultyClearDialogCallback(
      _showDifficultyClearDialog,
    );
  }

  @override
  void dispose() {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    gameProvider.setShowFloatingDamageTextCallback(null);
    gameProvider.setShowDifficultyClearDialogCallback(null);
    _defeatTimer?.cancel();
    super.dispose();
  }

  void _showDifficultyClearDialog(int xpReward, Difficulty? nextDifficulty) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('축하합니다!', style: TextStyle(color: Colors.white)),
          content: Text(
            '${DifficultyData.getDifficultyName(gameProvider.player.currentDifficulty)} 난이도를 클리어 하셨습니다.\n\n클리어 보상: 영웅 경험치 $xpReward',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('난이도 재도전'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                gameProvider.restartCurrentDifficulty();
              },
            ),
            if (nextDifficulty != null)
              TextButton(
                child: const Text('다음 난이도 도전'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  gameProvider.startNextDifficulty();
                },
              ),
          ],
        );
      },
    );
  }

  // Method to add and manage damage text
  void _showDamageText(
    int damage,
    bool isCritical,
    bool isMiss, {
    bool isSkillDamage = false,
    DamageType damageType = DamageType.normal,
  }) {
    final newDamageText = DamageText(
      damage: damage,
      isCritical: isCritical,
      isMiss: isMiss,
      isSkillDamage: isSkillDamage,
      damageType: damageType,
    );
    if (!mounted) return;
    setState(() {
      _damageTexts.add(newDamageText);
    });

    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    // Remove the damage text after a delay (e.g., 1.5 seconds for animation)
    Timer(
      Duration(
        milliseconds:
            (gameProvider.autoAttackDelay.inMilliseconds * 0.75).round(),
      ),
      () {
        if (!mounted) return;
        setState(() {
          _damageTexts.remove(newDamageText);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The main GestureDetector needs to know if it should be tappable.
    return Selector<GameProvider, (bool, bool)>(
      selector: (context, game) =>
          (game.isMonsterDefeated, game.player.canManualAttack),
      builder: (context, data, child) {
        final isMonsterDefeated = data.$1;
        final canManualAttack = data.$2;

        return GestureDetector(
          onTap: isMonsterDefeated || !canManualAttack
              ? null
              : () => Provider.of<GameProvider>(context, listen: false)
                  .handleManualClick(),
          child: Container(
            color: Colors.grey[900],
            width: double.infinity,
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLeftNavigation(),
                    _buildCenterContent(),
                    _buildRightNavigation(),
                  ],
                ),
                _buildDamageTexts(),
                _buildRewardDisplay(),
                _buildTopBar(),
                _buildHeroExpBar(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeftNavigation() {
    return Selector<GameProvider, (int, bool)>(
      selector: (context, game) =>
          (game.player.currentStage, game.isMonsterDefeated),
      builder: (context, data, child) {
        final currentStage = data.$1;
        final isMonsterDefeated = data.$2;
        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.first_page, color: Colors.white),
              onPressed: currentStage > 1 && !isMonsterDefeated
                  ? () =>
                      Provider.of<GameProvider>(context, listen: false).warpToStage(1)
                  : null,
            ),
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: currentStage > 1 && !isMonsterDefeated
                  ? () => Provider.of<GameProvider>(context, listen: false)
                      .goToPreviousStage()
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRightNavigation() {
    return Selector<GameProvider, (int, int)>(
      selector: (context, game) => (
        game.player.currentStage,
        game.player.highestStageCleared,
      ),
      builder: (context, data, child) {
        final currentStage = data.$1;
        final highestStageCleared = data.$2;
        return Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
              onPressed: currentStage < highestStageCleared + 1
                  ? () => Provider.of<GameProvider>(context, listen: false)
                      .goToNextStage()
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.last_page, color: Colors.white),
              onPressed: currentStage < highestStageCleared + 1
                  ? () => Provider.of<GameProvider>(context, listen: false)
                      .warpToStage(highestStageCleared + 1)
                  : null,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCenterContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStageText(),
        const SizedBox(height: 16),
        _buildMonsterName(),
        const SizedBox(height: 16),
        _buildMonsterImageAndInfo(),
        const SizedBox(height: 16),
        _buildMonsterHpBar(),
      ],
    );
  }

  Widget _buildStageText() {
    return Selector<GameProvider, (int, Difficulty, String)>(
      selector: (context, game) => (
        game.monster.stage,
        game.player.currentDifficulty,
        game.currentStageName
      ),
      builder: (context, data, child) {
        return Column(
          children: [
            Text(
              'Stage ${data.$1} / ${DifficultyData.getDifficultyGoal(data.$2)}',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              data.$3, // Display stage name
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonsterName() {
    return Selector<GameProvider, (String, bool)>(
      selector: (context, game) => (game.monster.name, game.monster.isBoss),
      builder: (context, data, child) {
        final name = data.$1;
        final isBoss = data.$2;
        return Text(
          isBoss ? '$name (BOSS)' : name,
          style: TextStyle(
            color: isBoss ? Colors.red : Colors.white,
            fontSize: 20,
          ),
        );
      },
    );
  }

  Widget _buildMonsterImageAndInfo() {
    return Selector<GameProvider,
        (bool, String, List<StatusEffect>, double)>(
      selector: (context, game) => (
        game.isMonsterDefeated,
        game.monster.imageName,
        game.monster.statusEffects,
        game.currentMonsterEffectiveDefense
      ),
      shouldRebuild: (previous, next) {
        // Rebuild only if these specific values change
        return previous.$1 != next.$1 ||
            previous.$2 != next.$2 ||
            !listEquals(previous.$3, next.$3) ||
            previous.$4 != next.$4;
      },
      builder: (context, data, child) {
        final isMonsterDefeated = data.$1;
        final imageName = data.$2;
        final statusEffects = data.$3;
        final effectiveDefense = data.$4;

        return ColorFiltered(
          colorFilter: isMonsterDefeated
              ? const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ])
              : const ColorFilter.mode(
                  Colors.transparent,
                  BlendMode.multiply,
                ),
          child: Stack(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: Image.asset(
                  'assets/images/monsters/$imageName',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.blue,
                    child: const Center(
                      child: Text('Monster Img',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              if (statusEffects.isNotEmpty)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Row(
                    children: statusEffects
                        .map((e) => e.type)
                        .toSet()
                        .map((uniqueType) {
                      final imagePath = _statusEffectImagePaths[uniqueType];
                      if (imagePath != null) {
                        final effect =
                            statusEffects.firstWhere((e) => e.type == uniqueType);
                        return Tooltip(
                          message:
                              '${effect.type.toString().split('.').last} (${effect.duration}s)',
                          child: Image.asset(
                            imagePath,
                            width: 30,
                            height: 30,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.grey[900],
                          titleTextStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          contentTextStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          title: const Text('방어력 정보'),
                          content: const Text(
                            '몬스터의 방어력 수치를 나타냅니다.\n\n'
                            '몬스터의 방어력 1당 0.5%의 데미지가 경감됩니다.\n\n'
                            '반대로 몬스터의 방어력이 0보다 낮을 경우에는 1당 2.5%의 추가 데미지를 받습니다.',
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('닫기'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.shield,
                        color: Colors.grey[800],
                        size: 30,
                      ),
                      Text(
                        effectiveDefense.toStringAsFixed(0),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonsterHpBar() {
    return Selector<GameProvider, (double, double)>(
      selector: (context, game) => (game.monster.hp, game.monster.maxHp),
      builder: (context, data, child) {
        final hp = data.$1;
        final maxHp = data.$2;
        final hpPercentage = maxHp > 0 ? hp / maxHp : 0.0;

        return SizedBox(
          width: 160,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: hpPercentage,
                minHeight: 20,
                backgroundColor: Colors.grey,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${NumberFormat('#,###').format(hp.truncate())} / ${NumberFormat('#,###').format(maxHp.truncate())}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDamageTexts() {
    return Selector<GameProvider, Duration>(
      selector: (context, game) => game.autoAttackDelay,
      builder: (context, autoAttackDelay, child) {
        return Stack(
          children: _damageTexts
              .map(
                (dt) => _DamageTextWidget(
                  key: dt.key,
                  damageText: dt,
                  animationDuration: autoAttackDelay,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildRewardDisplay() {
    return Selector<GameProvider, (bool, double, GachaBox?, double)>(
      selector: (context, game) => (
        game.isMonsterDefeated,
        game.lastGoldReward,
        game.lastDroppedBox,
        game.lastEnhancementStonesReward
      ),
      builder: (context, data, child) {
        final isMonsterDefeated = data.$1;
        final lastGoldReward = data.$2;
        final lastDroppedBox = data.$3;
        final lastEnhancementStonesReward = data.$4;

        if (!isMonsterDefeated) {
          return const SizedBox.shrink();
        }

        return Positioned(
          bottom: 60, // Moved down slightly
          left: 0,
          right: 0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gold reward
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: Image.asset(
                      'assets/images/others/gold.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${NumberFormat('#,###').format(lastGoldReward)}G',
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Dropped box
                  if (lastDroppedBox != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          lastDroppedBox.imagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  // Enhancement stones reward
                  if (lastEnhancementStonesReward > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: Image.asset(
                              'assets/images/others/enhancement_stone.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${NumberFormat('#,###').format(lastEnhancementStonesReward)}개',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Selector<GameProvider, (Difficulty, bool)>(
        selector: (context, game) =>
            (game.player.currentDifficulty, game.isAutoAttackActive),
        builder: (context, data, child) {
          final currentDifficulty = data.$1;
          final isAutoAttackActive = data.$2;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DifficultyData.getDifficultyName(
                  currentDifficulty,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Column(
                children: [
                  Switch(
                    value: isAutoAttackActive,
                    onChanged: (value) {
                      Provider.of<GameProvider>(
                        context,
                        listen: false,
                      ).toggleAutoAttack();
                    },
                    activeTrackColor: Colors.green,
                    inactiveTrackColor: Colors.grey,
                  ),
                  Text(
                    'Auto-Attack',
                    style: TextStyle(
                      color: isAutoAttackActive
                          ? Colors.greenAccent
                          : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroExpBar() {
    return Selector<GameProvider, _HeroExpData>(
      selector: (context, game) => _HeroExpData(
        heroLevel: game.player.heroLevel,
        heroExp: game.player.heroExp,
        requiredExp: game.requiredExpForLevelUp,
      ),
      builder: (context, data, child) {
        final expPercentage =
            data.requiredExp > 0 ? data.heroExp / data.requiredExp : 0.0;

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 22, // Give a fixed height to the bar
                  child: LinearProgressIndicator(
                    value: expPercentage,
                    backgroundColor: Colors.grey[700],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.lightBlueAccent,
                    ),
                  ),
                ),
                Text(
                  '레벨: ${data.heroLevel} (${data.heroExp.toStringAsFixed(0)} / ${data.requiredExp.toStringAsFixed(0)})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      // Add shadow for better readability
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Widget for displaying individual damage text with animation
class _DamageTextWidget extends StatefulWidget {
  final DamageText damageText;
  final Duration animationDuration;

  const _DamageTextWidget({
    super.key,
    required this.damageText,
    required this.animationDuration,
  });

  @override
  State<_DamageTextWidget> createState() => _DamageTextWidgetState();
}

class _DamageTextWidgetState extends State<_DamageTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration, // Use dynamic duration
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0), // Start at current position
      end: const Offset(0.0, -1.0), // Move upwards
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      switch (widget.damageText.damageType) {
        case DamageType.doubleAttack:
          return Colors.orange;
        case DamageType.bleed:
          return Colors.red;
        case DamageType.shatter:
          return Colors.blue;
        case DamageType.shock:
          return Colors.yellow;
        case DamageType.poison:
          return Colors.purple;
        case DamageType.fixed:
        case DamageType.maxHp:
          return Colors.orange;
        case DamageType.instantKill:
          return Colors.redAccent;
        case DamageType.normal:
          if (widget.damageText.isMiss) return Colors.yellow;
          if (widget.damageText.isCritical) return Colors.red;
          return Colors.white;
      }
    }

    double getFontSize() {
      double baseSize = widget.damageText.isMiss
          ? 32
          : (widget.damageText.isCritical ? 28 : 20);
      if (widget.damageText.isSkillDamage) {
        return baseSize * 1.5;
      }
      return baseSize;
    }

    return Positioned.fill(
      child: Align(
        alignment: () {
          if (widget.damageText.damageType == DamageType.doubleAttack) {
            return const Alignment(
              0.0,
              0.2, // Slightly lower for double attack damage
            );
          } else if (widget.damageText.damageType == DamageType.shock) {
            return const Alignment(
              0.0,
              -0.15, // Slightly higher for shock damage
            );
          } else if (widget.damageText.isSkillDamage) {
            return const Alignment(
              0.3,
              0.0, // To the right for other skill damage
            );
          } else if (widget.damageText.isMiss) {
            return const Alignment(
              0.0,
              -0.5, // Slightly above center for MISS!
            );
          }
          return Alignment.center; // Normal damage at the center
        }(),
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              widget.damageText.damageType == DamageType.instantKill
                  ? 'Kill!'
                  : (widget.damageText.isMiss
                      ? 'MISS!'
                      : widget.damageText.damage.toString()),
              style: TextStyle(
                color: getColor(),
                fontSize: getFontSize(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
