import 'package:ryan_clicker_rpg/models/monster_species.dart';
import 'package:ryan_clicker_rpg/models/status_effect.dart';

class Monster {
  final String name;
  final String imageName;
  final int stage;
  double hp;
  final double maxHp;
  final int defense;
  final bool isBoss;
  final List<MonsterSpecies> species;
  List<StatusEffect> statusEffects;
  Map<String, DateTime> skillCooldowns; // To track cooldowns

  Monster({
    required this.name,
    required this.imageName,
    required this.stage,
    required this.hp,
    required this.maxHp,
    required this.defense,
    required this.species,
    List<StatusEffect>? statusEffects,
    Map<String, DateTime>? skillCooldowns,
    this.isBoss = false,
  }) : statusEffects = statusEffects ?? [],
       skillCooldowns = skillCooldowns ?? {};

  void applyStatusEffect(StatusEffect newEffect) {
    // A more robust implementation would check for existing effects.
    // For now, we just add it.
    statusEffects.add(newEffect);
  }

  bool isSkillOnCooldown(String skillName, int cooldownSeconds) {
    if (skillCooldowns.containsKey(skillName)) {
      final lastUsed = skillCooldowns[skillName]!;
      return DateTime.now().difference(lastUsed).inSeconds < cooldownSeconds;
    }
    return false;
  }

  void setSkillCooldown(String skillName) {
    skillCooldowns[skillName] = DateTime.now();
  }

  void updateStatusEffects() {
    // Using removeWhere for a more concise way to iterate and remove.
    statusEffects.removeWhere((effect) {
      effect.duration--;
      return effect.duration <= 0;
    });
  }

  bool hasStatusEffect(StatusEffectType type) {
    return statusEffects.any((effect) => effect.type == type);
  }
}
