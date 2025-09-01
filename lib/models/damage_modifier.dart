import 'package:ryan_clicker_rpg/models/monster_species.dart';
import 'package:ryan_clicker_rpg/models/status_effect.dart';

enum ConditionType {
  targetHealthBelowPercent,
  targetHealthAbovePercent,
}

class DamageModifier {
  final MonsterSpecies? requiredRace;
  final StatusEffectType? requiredStatusEffectType;
  final ConditionType? requiredMonsterHpCondition; // New
  final double? requiredMonsterHpThreshold; // New
  final double multiplier;

  DamageModifier({
    this.requiredRace,
    this.requiredStatusEffectType,
    this.requiredMonsterHpCondition, // New
    this.requiredMonsterHpThreshold, // New
    required this.multiplier,
  });
}