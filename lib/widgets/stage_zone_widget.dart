import 'package:flutter/material.dart';
import 'package:ryan_clicker_rpg/models/monster.dart';
import 'package:ryan_clicker_rpg/models/player.dart';

import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'package:ryan_clicker_rpg/models/monster.dart';
import 'package:ryan_clicker_rpg/models/player.dart';

// Class to hold damage text information
class DamageText {
  final int damage;
  final bool isCritical;
  final Key key;

  DamageText({required this.damage, required this.isCritical})
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

  @override
  void didUpdateWidget(covariant StageZoneWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMonsterDefeated && !oldWidget.isMonsterDefeated) {
      // Monster just got defeated, start timer
      _defeatTimer = Timer(const Duration(seconds: 2), () {
        widget.onGoToNextStage();
      });
    } else if (!widget.isMonsterDefeated && oldWidget.isMonsterDefeated) {
      // Monster is no longer defeated (new monster spawned), cancel timer
      _defeatTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _defeatTimer?.cancel();
    super.dispose();
  }

  // Method to add and manage damage text
  void _showDamageText(int damage, bool isCritical) {
    final newDamageText = DamageText(damage: damage, isCritical: isCritical);
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
              final damageInfo = widget.onAttack(
                {},
              ); // Call onAttack and get damage info
              _showDamageText(
                damageInfo['damageDealt'],
                damageInfo['isCritical'],
              );
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
                      widget.monster.name,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
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
                      child: SizedBox(
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
      duration: const Duration(milliseconds: 1000), // Animation duration
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
              widget.damageText.damage.toString(),
              style: TextStyle(
                color: widget.damageText.isCritical ? Colors.red : Colors.white,
                fontSize: widget.damageText.isCritical ? 28 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
