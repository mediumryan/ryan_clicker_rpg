enum SkillEffectType {
  passiveGoldGainMultiplier,
  passiveEnhancementStoneGainMultiplier,
  passiveWeaponDamageBonus,
  passiveWeaponDamageMultiplier,
  passiveWeaponCriticalChanceBonus,
  passiveWeaponCriticalDamageBonus,
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
  });

  double calculateEffect(int level) {
    if (level <= 0) return 0;
    return baseValue + (valuePerLevel * (level - 1));
  }
}
