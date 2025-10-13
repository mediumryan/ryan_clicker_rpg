import 'package:ryan_clicker_rpg/models/hero_skill.dart';

class HeroSkillData {
  static final List<HeroSkill> skills = [
    // Group A: Combat Support
    const HeroSkill(
      id: 'damage_1',
      name: '데미지 증가',
      description: '모든 무기의 공격력이 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 1,
      group: HeroSkillGroup.combat,
      effectType: SkillEffectType.passiveWeaponDamageMultiplier,
      baseValue: 0.05,
      valuePerLevel: 0.05,
    ),
    const HeroSkill(
      id: 'crit_chance_1',
      name: '치명타 확률 증가',
      description: '치명타 확률이 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 5,
      prerequisites: ['damage_1'],
      group: HeroSkillGroup.combat,
      effectType: SkillEffectType.passiveWeaponCriticalChanceBonus,
      baseValue: 0.01,
      valuePerLevel: 0.01,
    ),
    const HeroSkill(
      id: 'crit_damage_1',
      name: '치명타 데미지 증가',
      description: '치명타 데미지가 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 5,
      prerequisites: ['crit_chance_1'],
      group: HeroSkillGroup.combat,
      effectType: SkillEffectType.passiveWeaponCriticalDamageBonus,
      baseValue: 0.1,
      valuePerLevel: 0.1,
    ),
    const HeroSkill(
      id: 'attack_speed_1',
      name: '공격 속도 증가',
      description: '공격 속도가 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 10,
      prerequisites: ['damage_1'],
      group: HeroSkillGroup.combat,
      effectType: SkillEffectType.passiveWeaponSpeedBonus,
      baseValue: 0.025,
      valuePerLevel: 0.025,
    ),
    const HeroSkill(
      id: 'accuracy_1',
      name: '명중률 증가',
      description: '명중률이 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 10,
      group: HeroSkillGroup.combat,
      effectType: SkillEffectType.passiveWeaponAccuracyBonus,
      baseValue: 0.005,
      valuePerLevel: 0.005,
    ),
    const HeroSkill(
      id: 'defense_penetration_1',
      name: '방어력 관통 증가',
      description: '방어력 관통이 영구적으로 증가합니다.',
      maxLevel: 5,
      requiredHeroLevel: 50,
      group: HeroSkillGroup.combat,
      effectType: SkillEffectType.passiveWeaponDefensePenetrationBonus,
      baseValue: 1,
      valuePerLevel: 1,
    ),
    const HeroSkill(
      id: 'double_attack_1',
      name: '더블 어택 확률 증가',
      description: '더블 어택 확률이 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 50,
      prerequisites: ['attack_speed_1'],
      group: HeroSkillGroup.combat,
      effectType: SkillEffectType.passiveWeaponDoubleAttackChanceBonus,
      baseValue: 0.001,
      valuePerLevel: 0.001,
    ),

    // Group B: Economy
    const HeroSkill(
      id: 'gold_1',
      name: '골드 획득량 증가',
      description: '골드 획득량이 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 1,
      group: HeroSkillGroup.economy,
      effectType: SkillEffectType.passiveGoldGainMultiplier,
      baseValue: 0.05,
      valuePerLevel: 0.05,
    ),
    const HeroSkill(
      id: 'exp_1',
      name: '경험치 획득량 증가',
      description: '경험치 획득량이 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 10,
      group: HeroSkillGroup.economy,
      effectType: SkillEffectType.passiveExpGainMultiplier,
      baseValue: 0.025,
      valuePerLevel: 0.025,
    ),

    // Group C: Debuffs
    const HeroSkill(
      id: 'monster_def_1',
      name: '몬스터 방어력 감소',
      description: '몬스터의 방어력이 영구적으로 감소합니다.',
      maxLevel: 5,
      requiredHeroLevel: 20,
      group: HeroSkillGroup.debuff,
      effectType: SkillEffectType.monsterDefenseReduction,
      baseValue: 1,
      valuePerLevel: 1,
    ),
    const HeroSkill(
      id: 'monster_hp_1',
      name: '몬스터 최대 체력 감소',
      description: '몬스터의 최대 체력이 영구적으로 감소합니다.',
      maxLevel: 10,
      requiredHeroLevel: 20,
      group: HeroSkillGroup.debuff,
      effectType: SkillEffectType.monsterMaxHpReduction,
      baseValue: 0.005,
      valuePerLevel: 0.005,
    ),
    const HeroSkill(
      id: 'monster_damage_taken_1',
      name: '몬스터 받는 데미지 증가',
      description: '몬스터가 받는 데미지가 영구적으로 증가합니다.',
      maxLevel: 10,
      requiredHeroLevel: 50,
      group: HeroSkillGroup.debuff,
      effectType: SkillEffectType.monsterDamageTakenIncrease,
      baseValue: 0.025,
      valuePerLevel: 0.025,
    ),

    // Group D: Smithing
    const HeroSkill(
      id: 'enhance_gold_1',
      name: '강화 비용 감소(골드)',
      description: '강화 비용(골드)이 영구적으로 감소합니다.',
      maxLevel: 10,
      requiredHeroLevel: 50,
      group: HeroSkillGroup.smithing,
      effectType: SkillEffectType.enhancementGoldCostReduction,
      baseValue: 0.01,
      valuePerLevel: 0.01,
    ),
    const HeroSkill(
      id: 'enhance_stone_1',
      name: '강화 비용 감소(강화석)',
      description: '강화 비용(강화석)이 영구적으로 감소합니다.',
      maxLevel: 3,
      requiredHeroLevel: 50,
      group: HeroSkillGroup.smithing,
      effectType: SkillEffectType.enhancementStoneCostReduction,
      baseValue: 1,
      valuePerLevel: 1,
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
