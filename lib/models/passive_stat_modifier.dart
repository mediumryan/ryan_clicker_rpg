import 'package:ryan_clicker_rpg/models/status_effect.dart';

class PassiveStatModifier {
  final String stat; // e.g., "defense"
  final double value;
  final bool isMultiplicative; // true for multiplication, false for addition

  // Optional conditions
  final double? hpThreshold; // ex: 0.5 → 50%
  final String? hpCondition; // "below" or "above"
  final StatusEffectType? requiredStatus; // ex: StatusEffectType.poison
  final int? maxStage; // ex: 50 (stage)

  PassiveStatModifier({
    required this.stat,
    required this.value,
    this.isMultiplicative = false,
    this.hpThreshold,
    this.hpCondition,
    this.requiredStatus,
    this.maxStage,
  });
}