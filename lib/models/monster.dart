import 'package:flutter/foundation.dart';
import 'package:ryan_clicker_rpg/models/monster_species.dart';
import 'package:ryan_clicker_rpg/models/status_effect.dart';

class Monster {
  final String name;
  final String imageName;
  final int stage;
  double hp;
  final double maxHp;
  int defense;
  final bool isBoss;
  final List<MonsterSpecies> species;
  List<StatusEffect> statusEffects;
  Map<String, DateTime> skillCooldowns; // To track cooldowns
  final int _baseDefense; // Store the initial defense

  Monster({
    required this.name,
    required this.imageName,
    required this.stage,
    required this.hp,
    required this.maxHp,
    required this.defense, // Use initializing formal
    required this.species,
    List<StatusEffect>? statusEffects,
    Map<String, DateTime>? skillCooldowns,
    this.isBoss = false,
  }) : _baseDefense = defense, // Store the base defense
       statusEffects = statusEffects ?? [],
       skillCooldowns = skillCooldowns ?? {};

  void applyStatusEffect(StatusEffect newEffect) {
    debugPrint(
      '[Monster.applyStatusEffect] Applying status effect ${newEffect.type} to monster $name. Value: ${newEffect.value}, Duration: ${newEffect.duration}',
    );
    debugPrint(
      '[Monster.applyStatusEffect] Monster defense BEFORE applying effect: $defense',
    ); // Added debugPrint
    // Check if an effect of the same type already exists and is not stackable
    final existingEffectIndex = statusEffects.indexWhere(
      (effect) =>
          effect.type == newEffect.type &&
          !newEffect.stackable, // Use newEffect.stackable here
    );

    if (existingEffectIndex != -1) {
      // Revert the old effect's impact before replacing
      final oldEffect = statusEffects[existingEffectIndex];
      if (oldEffect.type == StatusEffectType.disarm) {
        defense += oldEffect.value!.toInt();
      }
      // Replace existing non-stackable effect
      statusEffects[existingEffectIndex] = newEffect;
    } else {
      statusEffects.add(newEffect);
    }

    // Apply immediate effects
    if (newEffect.type == StatusEffectType.disarm) {
      defense -= newEffect.value!.toInt(); // Reduce defense
      debugPrint(
        '[Monster.applyStatusEffect] Monster $name defense reduced to $defense',
      );
    }
    debugPrint(
      '[Monster.applyStatusEffect] Monster defense AFTER applying effect: $defense',
    ); // Added debugPrint
    debugPrint(
      '[Monster.applyStatusEffect] Current status effects: ${statusEffects.map((e) => '${e.type}:${e.value}').join(', ')}',
    );
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
    // Create a list to hold effects that are expiring this update cycle
    final List<StatusEffect> expiringEffects = [];

    statusEffects.removeWhere((effect) {
      effect.duration--;
      if (effect.duration <= 0) {
        expiringEffects.add(effect); // Add to expiring list
        return true; // Remove this effect
      }
      return false; // Keep this effect
    });

    // Revert effects that have expired
    for (final effect in expiringEffects) {
      if (effect.type == StatusEffectType.disarm) {
        defense += effect.value!.toInt(); // Restore defense
        // Ensure defense doesn't exceed base defense if multiple disarms were applied
        if (defense > _baseDefense) {
          defense = _baseDefense;
        }
        debugPrint(
          '[Monster.updateStatusEffects] Monster $name defense restored to $defense',
        );
      }
    }
  }

  bool hasStatusEffect(StatusEffectType type) {
    return statusEffects.any((effect) => effect.type == type);
  }
}
