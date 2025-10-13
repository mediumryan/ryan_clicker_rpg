import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/data/hero_skill_data.dart';
import 'package:ryan_clicker_rpg/models/hero_skill.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';

class HeroSkillScreen extends StatefulWidget {
  const HeroSkillScreen({super.key});

  @override
  State<HeroSkillScreen> createState() => _HeroSkillScreenState();
}

class _HeroSkillScreenState extends State<HeroSkillScreen> {
  HeroSkillGroup _selectedGroup = HeroSkillGroup.combat;

  String _getGroupName(HeroSkillGroup group) {
    switch (group) {
      case HeroSkillGroup.combat:
        return '전투 보조';
      case HeroSkillGroup.economy:
        return '재화 및 경험치';
      case HeroSkillGroup.debuff:
        return '디버프';
      case HeroSkillGroup.smithing:
        return '강화 및 재련';
    }
  }

  Widget _buildChoiceChip(HeroSkillGroup group) {
    return ChoiceChip(
      label: Center(child: Text(_getGroupName(group))),
      selected: _selectedGroup == group,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedGroup = group;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredSkills = HeroSkillData.skills
        .where((s) => s.group == _selectedGroup)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('스킬'),

        backgroundColor: Colors.grey[850],
      ),

      backgroundColor: Colors.grey[900],

      body: Column(
        children: [
          Selector<GameProvider, (int, int)>(
            selector: (context, game) =>
                (game.player.heroLevel, game.player.skillPoints),

            builder: (context, data, child) {
              final (heroLevel, skillPoints) = data;

              return Padding(
                padding: const EdgeInsets.all(16.0),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(
                      '영웅 레벨: $heroLevel',

                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),

                    const SizedBox(width: 24),

                    Text(
                      '스킬 포인트: $skillPoints',

                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildChoiceChip(HeroSkillGroup.combat)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildChoiceChip(HeroSkillGroup.economy)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildChoiceChip(HeroSkillGroup.debuff)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildChoiceChip(HeroSkillGroup.smithing)),
                    const SizedBox(width: 8),
                    Expanded(child: Container()), // Placeholder
                    const SizedBox(width: 8),
                    Expanded(child: Container()), // Placeholder
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filteredSkills.length,

              itemBuilder: (context, index) {
                final skill = filteredSkills[index];

                return _SkillCard(skill: skill);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.skill});

  final HeroSkill skill;

  @override
  Widget build(BuildContext context) {
    return Selector<GameProvider, (int, String?)>(
      selector: (context, game) {
        final currentLevel = game.player.learnedSkills[skill.id] ?? 0;

        final canLearnReason = game.canLearnSkill(skill.id);

        return (currentLevel, canLearnReason);
      },

      builder: (context, data, child) {
        final (currentLevel, canLearnReason) = data;

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

                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        skill.detailedDescription,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (skill.requiredHeroLevel > 0)
                        Text(
                          '필요 레벨: ${skill.requiredHeroLevel}',

                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
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
                            final game = context.read<GameProvider>();

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
      },
    );
  }
}
