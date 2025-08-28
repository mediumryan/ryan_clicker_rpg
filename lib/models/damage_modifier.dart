import 'package:ryan_clicker_rpg/models/monster_species.dart';
import 'package:ryan_clicker_rpg/models/status_effect.dart';

class DamageModifier {
  final MonsterSpecies? requiredRace;
  final StatusEffectType? requiredStatusEffectType;
  final double multiplier;

  DamageModifier({
    this.requiredRace,
    this.requiredStatusEffectType,
    required this.multiplier,
  });
}