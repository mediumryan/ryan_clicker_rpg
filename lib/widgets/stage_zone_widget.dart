import 'package:flutter/material.dart';
import 'package:ryan_clicker_rpg/models/monster.dart';
import 'package:ryan_clicker_rpg/models/status_effect.dart';
import 'package:ryan_clicker_rpg/models/player.dart';
import 'dart:async'; // Import for Timer
import 'package:provider/provider.dart'; // New import
import 'package:ryan_clicker_rpg/providers/game_provider.dart'; // New import

// Class to hold damage text information
class DamageText {
  final int damage;
  final bool isCritical;
  final bool isMiss; // New
  final Key key;

  DamageText({required this.damage, required this.isCritical, required this.isMiss}) // Modified
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

  const StageZoneWidget({
    super.key,
    required this.player,
    required this.monster,
    required this.onAttack,
    required this.onGoToNextStage,
    required this.onGoToPreviousStage,
    required this.isMonsterDefeated,
    required this.stageName, // New: Required in constructor
  });

  @override
  State<StageZoneWidget> createState() => _StageZoneWidgetState();
}

class _StageZoneWidgetState extends State<StageZoneWidget> {
  Timer? _defeatTimer;
  final List<DamageText> _damageTexts = []; // List to hold active damage texts

  // Helper map to get icon and color for each status effect
  final Map<StatusEffectType, Map<String, dynamic>> _statusEffectIcons = {
    StatusEffectType.poison: {'icon': Icons.science, 'color': Colors.green},
    StatusEffectType.bleed: {'icon': Icons.bloodtype, 'color': Colors.red[900]},
    StatusEffectType.stun: {'icon': Icons.star, 'color': Colors.yellow},
    StatusEffectType.confusion: {'icon': Icons.psychology, 'color': Colors.orange},
    StatusEffectType.sleep: {'icon': Icons.bedtime, 'color': Colors.blue[200]},
    StatusEffectType.disarm: {'icon': Icons.gpp_bad, 'color': Colors.grey},
    StatusEffectType.charm: {'icon': Icons.favorite, 'color': Colors.pink},
    StatusEffectType.weakness: {'icon': Icons.trending_down, 'color': Colors.brown},
    StatusEffectType.freeze: {'icon': Icons.ac_unit, 'color': Colors.lightBlueAccent},
    StatusEffectType.burn: {'icon': Icons.whatshot, 'color': Colors.deepOrange},
    StatusEffectType.shock: {'icon': Icons.bolt, 'color': Colors.yellowAccent},
  };

  @override
  void initState() {
    super.initState();
    // Get GameProvider instance and set the callback
    Provider.of<GameProvider>(
      context,
      listen: false,
    ).setShowFloatingDamageTextCallback(_showDamageText);
  }

  @override
  void dispose() {
    // Clear the callback when the widget is disposed
    Provider.of<GameProvider>(
      context,
      listen: false,
    ).setShowFloatingDamageTextCallback(null);
    _defeatTimer?.cancel();
    super.dispose();
  }

  // Method to add and manage damage text
  void _showDamageText(int damage, bool isCritical, bool isMiss) {
    final newDamageText = DamageText(damage: damage, isCritical: isCritical, isMiss: isMiss);
    setState(() {
      _damageTexts.add(newDamageText);
    });

    // Remove the damage text after a delay (e.g., 1.5 seconds for animation)
    Timer(const Duration(milliseconds: 1500), () {
      setState(() {
        _damageTexts.remove(newDamageText);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double hpPercentage = widget.monster.maxHp > 0
        ? widget.monster.hp / widget.monster.maxHp
        : 0;

    return GestureDetector(
      onTap: widget.isMonsterDefeated
          ? null
          : () {
              Provider.of<GameProvider>(context, listen: false).handleManualClick(); // New: Handle manual click
              widget.onAttack(
                {},
              ); // Call onAttack, damage display is now handled internally
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
                                children: widget.monster.statusEffects.map((effect) {
                                  final effectIcon = _statusEffectIcons[effect.type];
                                  if (effectIcon != null) {
                                    return Tooltip(
                                      message: '${effect.type.toString().split('.').last} (${effect.duration}s)',
                                      child: Icon(
                                        effectIcon['icon'],
                                        color: effectIcon['color'],
                                        size: 30, // A bit smaller to fit multiple icons
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink(); // Should not happen
                                }).toList(),
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
                                        '몬스터의 방어력 1당 1%의 데미지가 경감됩니다.\n\n'
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
                                    widget.monster.defense.toString(),
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
              (dt) => _DamageTextWidget(key: dt.key, damageText: dt),
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

  const _DamageTextWidget({super.key, required this.damageText});

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
      duration: const Duration(milliseconds: 2000), // Animation duration
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
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              widget.damageText.isMiss ? 'MISS!' : widget.damageText.damage.toString(),
              style: TextStyle(
                color: widget.damageText.isMiss ? Colors.yellow : (widget.damageText.isCritical ? Colors.red : Colors.white),
                fontSize: widget.damageText.isMiss ? 32 : (widget.damageText.isCritical ? 28 : 20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
