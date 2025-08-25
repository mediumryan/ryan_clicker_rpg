
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
  final List<StatusEffect> statusEffects;

  Monster({
    required this.name,
    required this.imageName,
    required this.stage,
    required this.hp,
    required this.maxHp,
    required this.defense,
    required this.species,
    this.statusEffects = const [],
    this.isBoss = false,
  });
}
