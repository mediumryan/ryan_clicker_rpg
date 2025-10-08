import 'package:ryan_clicker_rpg/models/hero_skill.dart';

class HeroSkillData {
  static final List<HeroSkill> skills = [
    const HeroSkill(
      id: 'gold_1',
      name: '골드 획득량 증가',
      description: '골드 획득량이 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 1,
      effectType: SkillEffectType.passiveGoldGainMultiplier,
      baseValue: 0.05, // 5% bonus at level 1
      valuePerLevel: 0.05, // Additional 5% per level
    ),
    const HeroSkill(
      id: 'damage_1',
      name: '공격력 강화',
      description: '모든 무기의 공격력이 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 1,
      effectType: SkillEffectType.passiveWeaponDamageMultiplier,
      baseValue: 0.05, // 5% bonus at level 1
      valuePerLevel: 0.05, // Additional 5% per level
    ),
    const HeroSkill(
      id: 'crit_chance_1',
      name: '치명적인 일격',
      description: '치명타 확률이 영구적으로 증가합니다.',
      maxLevel: 5,
      requiredHeroLevel: 10,
      prerequisites: ['damage_1'], // Requires damage_1
      effectType: SkillEffectType.passiveWeaponCriticalChanceBonus,
      baseValue: 0.01, // 1% bonus at level 1
      valuePerLevel: 0.01, // Additional 1% per level
    ),
  ];

  static HeroSkill? findById(String id) {
    try {
      return skills.firstWhere((skill) => skill.id == id);
    } catch (e) {
      return null;
    }
  }
}
