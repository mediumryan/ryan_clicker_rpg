enum HeroSkillGroup {
  combat,
  economy,
  debuff,
  smithing,
}

enum SkillEffectType {
  passiveGoldGainMultiplier,
  passiveEnhancementStoneGainMultiplier,
  passiveWeaponDamageBonus,
  passiveWeaponDamageMultiplier,
  passiveWeaponCriticalChanceBonus,
  passiveWeaponCriticalDamageBonus,
  passiveWeaponSpeedBonus,
  passiveWeaponAccuracyBonus,
  passiveWeaponDefensePenetrationBonus,
  passiveWeaponDoubleAttackChanceBonus,
  passiveExpGainMultiplier,
  monsterDefenseReduction,
  monsterMaxHpReduction,
  monsterDamageTakenIncrease,
  enhancementGoldCostReduction,
  enhancementStoneCostReduction,
}

class HeroSkill {
  final String id;
  final String name;
  final String description;
  final int maxLevel;
  final int requiredHeroLevel;
  final List<String> prerequisites;
  final SkillEffectType effectType;
  final double baseValue;
  final double valuePerLevel;
  final HeroSkillGroup group;

  const HeroSkill({
    required this.id,
    required this.name,
    required this.description,
    required this.maxLevel,
    required this.requiredHeroLevel,
    this.prerequisites = const [],
    required this.effectType,
    required this.baseValue,
    required this.valuePerLevel,
    required this.group,
  });

  double calculateEffect(int level) {
    if (level <= 0) return 0;
    return baseValue + (valuePerLevel * (level - 1));
  }

  String get detailedDescription {
    final percentageTypes = [
      SkillEffectType.passiveWeaponDamageMultiplier,
      SkillEffectType.passiveWeaponCriticalChanceBonus,
      SkillEffectType.passiveWeaponCriticalDamageBonus,
      SkillEffectType.passiveWeaponSpeedBonus,
      SkillEffectType.passiveWeaponAccuracyBonus,
      SkillEffectType.passiveWeaponDoubleAttackChanceBonus,
      SkillEffectType.passiveGoldGainMultiplier,
      SkillEffectType.passiveExpGainMultiplier,
      SkillEffectType.monsterMaxHpReduction,
      SkillEffectType.monsterDamageTakenIncrease,
      SkillEffectType.enhancementGoldCostReduction,
    ];

    String valueString;
    if (percentageTypes.contains(effectType)) {
      valueString =
          '${(valuePerLevel * 100).toStringAsFixed(1).replaceAll('.0', '')}%';
    } else {
      valueString = '${valuePerLevel.toInt()}';
    }

    String suffix = '증가';
    final reductionTypes = [
      SkillEffectType.monsterDefenseReduction,
      SkillEffectType.monsterMaxHpReduction,
      SkillEffectType.enhancementGoldCostReduction,
      SkillEffectType.enhancementStoneCostReduction,
    ];
    if (reductionTypes.contains(effectType)) {
      suffix = '감소';
    }

    return '매 레벨 당 $valueString $suffix';
  }
}
