import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/widgets/stage_zone_widget.dart';

class SpecialBossScreen extends StatefulWidget {
  const SpecialBossScreen({super.key});

  @override
  State<SpecialBossScreen> createState() => _SpecialBossScreenState();
}

class _SpecialBossScreenState extends State<SpecialBossScreen> {
  final List<DamageText> _damageTexts = [];

  @override
  void initState() {
    super.initState();
    Provider.of<GameProvider>(
      context,
      listen: false,
    ).setShowFloatingDamageTextCallback(_showDamageText);
  }

  @override
  void dispose() {
    Provider.of<GameProvider>(
      context,
      listen: false,
    ).setShowFloatingDamageTextCallback(null);
    super.dispose();
  }

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

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _damageTexts.remove(newDamageText);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('스페셜 보스'),
        backgroundColor: Colors.red[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Provider.of<GameProvider>(
              context,
              listen: false,
            ).exitSpecialBossZone();
          },
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final boss = game.monster;
          double hpPercentage = boss.maxHp > 0 ? boss.hp / boss.maxHp : 0;

          return GestureDetector(
            onTap: game.isMonsterDefeated
                ? null
                : () {
                    game.handleManualClick();
                    game.attackMonster();
                  },
            child: Container(
              color: Colors.grey[900],
              width: double.infinity,
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        boss.name,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: Image.asset(
                          'images/monsters/${boss.imageName}',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 350,
                        child: Column(
                          children: [
                            LinearProgressIndicator(
                              value: hpPercentage,
                              minHeight: 25,
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${NumberFormat('#,###').format(boss.hp)} / ${NumberFormat('#,###').format(boss.maxHp)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ..._damageTexts.map(
                    (dt) => _DamageTextWidget(
                      key: dt.key,
                      damageText: dt,
                      animationDuration: game.autoAttackDelay,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Using a modified copy of _DamageTextWidget from stage_zone_widget.dart
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
      duration: widget.animationDuration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, -1.0),
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
      if (widget.damageText.isMiss) return Colors.yellow;
      if (widget.damageText.isCritical) return Colors.red;
      return Colors.white;
    }

    double getFontSize() {
      return widget.damageText.isMiss
          ? 32
          : (widget.damageText.isCritical ? 28 : 20);
    }

    return Positioned.fill(
      child: Align(
        alignment: Alignment.center,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Text(
              widget.damageText.isMiss
                  ? 'MISS!'
                  : NumberFormat('#,###').format(widget.damageText.damage),
              style: TextStyle(
                color: getColor(),
                fontSize: getFontSize(),
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    blurRadius: 2.0,
                    color: Colors.black,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
