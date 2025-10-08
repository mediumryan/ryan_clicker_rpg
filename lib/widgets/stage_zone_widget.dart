import 'package:ryan_clicker_rpg/models/difficulty.dart';
import 'package:ryan_clicker_rpg/data/difficulty_data.dart';
import 'package:flutter/material.dart';
import 'package:ryan_clicker_rpg/models/monster.dart';
import 'package:ryan_clicker_rpg/models/status_effect.dart';
import 'package:ryan_clicker_rpg/models/player.dart';
import 'package:ryan_clicker_rpg/models/gacha_box.dart'; // New import
import 'dart:async'; // Import for Timer
import 'package:provider/provider.dart'; // New import
import 'package:ryan_clicker_rpg/providers/game_provider.dart'; // New import
import 'package:intl/intl.dart';

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
  final Player player;
  final Monster monster;
  final Function(Map<String, dynamic>)
  onAttack; // Updated to accept damage info
  final VoidCallback onGoToNextStage;
  final VoidCallback onGoToPreviousStage;
  final bool isMonsterDefeated;
  final String stageName; // New: Stage name
  final double monsterEffectiveDefense; // New field
  final double lastGoldReward; // New
  final GachaBox? lastDroppedBox; // New
  final Duration autoAttackDelay; // New
  final double lastEnhancementStonesReward; // New

  const StageZoneWidget({
    super.key,
    required this.player,
    required this.monster,
    required this.onAttack,
    required this.onGoToNextStage,
    required this.onGoToPreviousStage,
    required this.isMonsterDefeated,
    required this.stageName, // New: Required in constructor
    required this.monsterEffectiveDefense, // New required field
    required this.lastGoldReward, // New
    required this.lastDroppedBox, // New
    required this.autoAttackDelay, // New
    required this.lastEnhancementStonesReward, // New
  });

  @override
  State<StageZoneWidget> createState() => _StageZoneWidgetState();
}

class _StageZoneWidgetState extends State<StageZoneWidget> {
  Timer? _defeatTimer;
  final List<DamageText> _damageTexts = []; // List to hold active damage texts

  // Helper map to get icon and color for each status effect
  final Map<StatusEffectType, String> _statusEffectImagePaths = {
    StatusEffectType.poison: 'images/status/poison.png',
    StatusEffectType.bleed: 'images/status/bleed.png',
    StatusEffectType.stun: 'images/status/stun.png',
    StatusEffectType.confusion: 'images/status/confusion.png',
    StatusEffectType.sleep: 'images/status/sleep.png',
    StatusEffectType.disarm: 'images/status/disarm.png',
    StatusEffectType.charm: 'images/status/charm.png',
    StatusEffectType.weakness: 'images/status/weakness.png',
    StatusEffectType.freeze: 'images/status/freeze.png',
    StatusEffectType.burn: 'images/status/burn.png',
    StatusEffectType.shock: 'images/status/shock.png',
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
    setState(() {
      _damageTexts.add(newDamageText);
    });

    // Remove the damage text after a delay (e.g., 1.5 seconds for animation)
    Timer(
      Duration(
        milliseconds: (widget.autoAttackDelay.inMilliseconds * 0.75).round(),
      ),
      () {
        setState(() {
          _damageTexts.remove(newDamageText);
        });
      },
    );
  }

  Widget _buildWarpDropdown() {
    final List<int> warpStages = [];
    final int highestClearedTwentyFiveStage =
        (widget.player.highestStageCleared ~/ 25) * 25;

    // Start from 25, go up to highestClearedTwentyFiveStage
    for (int stage = 25; stage <= highestClearedTwentyFiveStage; stage += 25) {
      warpStages.add(stage);
    }

    if (warpStages.isEmpty) {
      return const SizedBox.shrink(); // No stages to warp to
    }

    return DropdownButton<int>(
      hint: Text('Warp to Stage', style: TextStyle(color: Colors.white70)),
      value: null, // No initial selection
      dropdownColor: Colors.grey[800],
      style: const TextStyle(color: Colors.white, fontSize: 16),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      onChanged: (int? newStage) {
        if (newStage != null) {
          Provider.of<GameProvider>(
            context,
            listen: false,
          ).warpToStage(newStage);
        }
      },
      items: warpStages.map<DropdownMenuItem<int>>((int stage) {
        return DropdownMenuItem<int>(value: stage, child: Text('Stage $stage'));
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    double hpPercentage = widget.monster.maxHp > 0
        ? widget.monster.hp / widget.monster.maxHp
        : 0;

    return GestureDetector(
      onTap: widget.isMonsterDefeated || !widget.player.canManualAttack
          ? null
          : () {
              Provider.of<GameProvider>(
                context,
                listen: false,
              ).handleManualClick(); // New: Handle manual click
            },
      child: Container(
        color: Colors.grey[900],
        width: double.infinity,
        child: Stack(
          // Use Stack to overlay damage numbers
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Previous Stage Button
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed:
                      widget.player.currentStage > 1 &&
                          !widget.isMonsterDefeated
                      ? widget.onGoToPreviousStage
                      : null,
                ),
                // Center Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Stage ${widget.monster.stage}',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text(
                      widget.stageName, // Display stage name
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.monster.isBoss
                          ? '${widget.monster.name} (BOSS)'
                          : widget.monster.name,
                      style: TextStyle(
                        color: widget.monster.isBoss
                            ? Colors.red
                            : Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ColorFiltered(
                      colorFilter: widget.isMonsterDefeated
                          ? const ColorFilter.matrix(<double>[
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ])
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            ),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Image.asset(
                              'images/monsters/${widget.monster.imageName}',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.blue,
                                    child: const Center(
                                      child: Text(
                                        'Monster Img',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          if (widget.monster.statusEffects.isNotEmpty)
                            Positioned(
                              top: 0,
                              left: 0,
                              child: Row(
                                children: widget.monster.statusEffects
                                    .map(
                                      (effect) => effect.type,
                                    ) // Get only the type
                                    .toSet() // Get unique types
                                    .map((uniqueType) {
                                      // Map unique types to icons
                                      final imagePath =
                                          _statusEffectImagePaths[uniqueType];
                                      if (imagePath != null) {
                                        // Find the first effect of this type to get its duration for the tooltip
                                        final effect = widget
                                            .monster
                                            .statusEffects
                                            .firstWhere(
                                              (e) => e.type == uniqueType,
                                            );
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
                                    })
                                    .toList(),
                              ),
                            ),
                          // Monster Defense Icon
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
                                    size: 40,
                                  ),
                                  Text(
                                    widget.monsterEffectiveDefense
                                        .toStringAsFixed(0),
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
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 250,
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
                          Text(
                            '${widget.monster.hp.toStringAsFixed(0)} / ${widget.monster.maxHp.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), // Spacing for the dropdown
                    _buildWarpDropdown(), // Warp dropdown
                  ],
                ),
                // Next Stage Button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                  ),
                  onPressed:
                      widget.player.currentStage <
                              widget.player.highestStageCleared &&
                          !widget.isMonsterDefeated
                      ? widget.onGoToNextStage
                      : null,
                ),
              ],
            ),
            // Render damage texts
            ..._damageTexts.map(
              (dt) => _DamageTextWidget(
                key: dt.key,
                damageText: dt,
                animationDuration: widget.autoAttackDelay,
              ),
            ),
            // Reward display (positioned absolutely)
            if (widget.isMonsterDefeated)
              Positioned(
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
                            'images/others/gold.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${NumberFormat('#,###').format(widget.lastGoldReward)}G',
                          style: const TextStyle(
                            color: Colors.yellow,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Dropped box
                        if (widget.lastDroppedBox != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Image.asset(
                                widget.lastDroppedBox!.imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        // Enhancement stones reward
                        if (widget.lastEnhancementStonesReward > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: Image.asset(
                                    'images/others/enhancement_stone.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${NumberFormat('#,###').format(widget.lastEnhancementStonesReward)}개',
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
              ),

            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Selector<GameProvider, bool>(
                selector: (context, game) => game.isAutoAttackActive,
                builder: (context, isAutoAttackActive, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DifficultyData.getDifficultyName(
                          widget.player.currentDifficulty,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Auto-Attack',
                            style: TextStyle(
                              color: isAutoAttackActive
                                  ? Colors.greenAccent
                                  : Colors.white70,
                            ),
                          ),
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
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildHeroExpBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroExpBar() {
    final requiredExp = widget.player.heroLevel * 1000;
    final expPercentage = requiredExp > 0
        ? widget.player.heroExp / requiredExp
        : 0.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '용사 레벨: ${widget.player.heroLevel} (${widget.player.heroExp.toStringAsFixed(0)} / $requiredExp)',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: expPercentage,
              backgroundColor: Colors.grey[700],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.lightBlueAccent,
              ),
            ),
          ],
        ),
      ),
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
