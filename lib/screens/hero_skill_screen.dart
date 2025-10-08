import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/data/hero_skill_data.dart';
import 'package:ryan_clicker_rpg/models/hero_skill.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';

class HeroSkillScreen extends StatelessWidget {
  const HeroSkillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('용사 스킬'),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '영웅 레벨: ${game.player.heroLevel}',
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(width: 24),
                    Text(
                      '스킬 포인트: ${game.player.skillPoints}',
                      style: const TextStyle(
                          color: Colors.yellowAccent, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: HeroSkillData.skills.length,
                  itemBuilder: (context, index) {
                    final skill = HeroSkillData.skills[index];
                    return _buildSkillCard(context, game, skill);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSkillCard(
      BuildContext context, GameProvider game, HeroSkill skill) {
    final currentLevel = game.player.learnedSkills[skill.id] ?? 0;
    final canLearnReason = game.canLearnSkill(skill.id);
    final canLearn = canLearnReason == null;

    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${skill.name} ($currentLevel/${skill.maxLevel})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  if (skill.requiredHeroLevel > 0)
                    Text(
                      '필요 레벨: ${skill.requiredHeroLevel}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Tooltip(
              message: canLearnReason ?? '',
              child: ElevatedButton(
                onPressed: canLearn
                    ? () {
                        final message = game.learnSkill(skill.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    : null,
                child: const Text('배우기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
