import json
import copy
import os

# --- 베이스 레전드 무기 데이터 ---
BASE_LEGEND_WEAPONS = [
  {
    "id": 50000,
    "name": "에메랄드 플레어",
    "imageName": "legend/rapier/50000.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.rapier",
    "baseLevel": 0,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 4.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "skills": [
      {
        "skill_name": "에메랄드 각인",
        "skill_type": "passive",
        "skill_description": "보석의 힘이 사용자와 무기를 각성시킨다. (공격력 +50%, 공격속도 +50%, 치명타 확률 +10%, 치명타 피해 +1배, 적중률 +5%)",
        "skill_description_detail": "공격력 +50%, 공격속도 +50%, 치명타 확률 +10%, 치명타 배율 +1배, 적중률 +5%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "damage",
              "value": 1.5,
              "isMultiplicative": True
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "speed",
              "value": 1.5,
              "isMultiplicative": True
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "criticalChance",
              "value": 0.1,
              "isMultiplicative": False
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "criticalDamage",
              "value": 1.0,
              "isMultiplicative": False
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "accuracy",
              "value": 0.05,
              "isMultiplicative": False
            }
          }
        ]
      }
    ],
    "accuracy": 0.86,
    "description": "에메랄드의 광채가 깃든 레이피어. 전투 능력을 대폭 향상시킨다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 10,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50001,
    "name": "팔콘 스트라이크",
    "imageName": "legend/rapier/50001.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.rapier",
    "baseLevel": 100,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 20.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "skills": [
      {
        "skill_name": "낚아채기",
        "skill_type": "active",
        "skill_description": "매처럼 날카롭고 빠르게 적을 꿰뚫는다.",
        "skill_description_detail": "공격 시 7.5% 확률로 104,000의 추가 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyFixedDamage",
            "params": {
              "chance": 0.075,
              "damage": 104000,
              "cooldown": 5,
              "trigger": "onHit"
            }
          }
        ]
      },
      {
        "skill_name": "매의 눈",
        "skill_type": "passive",
        "skill_description": "매의 시력이 적중률을 높인다. (적중률 +10%)",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "accuracy",
              "value": 0.1,
              "isMultiplicative": False
            }
          }
        ]
      }
    ],
    "accuracy": 0.96,
    "description": "매처럼 날카로운 시선을 가진 레이피어. 빠르고 정확한 찌르기로 적을 꿰뚫는다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 30,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50002,
    "name": "그림자 사냥꾼",
    "imageName": "legend/rapier/50002.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.rapier",
    "baseLevel": 200,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 24.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "skills": [
      {
        "skill_name": "끈질긴 추격",
        "skill_type": "passive",
        "skill_description": "적을 놓치지 않는 추격자가 된다.",
        "skill_description_detail": "공격 시 5초간 공격력 +15%, 최대 10중첩",
        "skill_effect": [
          {
            "effect_name": "applyStackingBuff",
            "params": {
              "trigger": "onHit",
              "duration": 5,
              "maxStacks": 10,
              "stat": "damage",
              "increasePerStack": 0.15,
              "isMultiplicative": True
            }
          }
        ]
      }
    ],
    "accuracy": 0.86,
    "description": "적의 그림자처럼 따라붙어 점점 숨통을 조이는 무기. 연속 공격 시 점점 강해진다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 50,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50002,
    "name": "뇌운",
    "imageName": "legend/rapier/50002.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.rapier",
    "baseLevel": 300,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 28.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "skills": [
      {
        "skill_name": "방전",
        "skill_type": "active",
        "skill_description": "칼끝에서 흐르는 강력한 전류가 적을 감전시킨다.",
        "skill_description_detail": "공격 시 7.5% 확률로 5초간 감전, 최대 데미지 12,000, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyShock",
            "params": {
              "chance": 0.075,
              "duration": 5,
              "stackable": False,
              "trigger": "onHit",
              "cooldown": 5,
              "maxDmg": 12000
            }
          }
        ]
      },
      {
        "skill_name": "충전",
        "skill_type": "passive",
        "skill_description": "감전 상태의 적에게 입히는 피해가 증가한다.",
        "skill_description_detail": "감전 상태의 적에게 주는 피해 +100%",
        "skill_effect": [
          {
            "effect_name": "increaseDamageToStatused",
            "params": { "status": "shock", "damageMultiplier": 1 }
          }
        ]
      }
    ],
    "accuracy": 0.86,
    "description": "신수 기린의 뿔로 만든 레이피어. 강한 번개의 힘을 담고 있다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 100,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50004,
    "name": "리볼버샷",
    "imageName": "legend/rapier/50004.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.rapier",
    "baseLevel": 400,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 36.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "skills": [
      {
        "skill_name": "정조준",
        "skill_type": "passive",
        "skill_description": "이 검에 의한 공격은 빗나가지 않는다.",
        "skill_description_detail": "적중률 +100%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "accuracy",
              "value": 1.0,
              "isMultiplicative": False
            }
          }
        ]
      },
      {
        "skill_name": "패닝",
        "skill_type": "passive",
        "skill_description": "적이 눈으로 쫓지 못할 만큼 빠르게 공격한다.",
        "skill_description_detail": "더블어택 확률 +20%, 공격속도 +50%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "doubleAttackChance",
              "value": 0.2,
              "isMultiplicative": False
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "speed",
              "value": 0.5,
              "isMultiplicative": True
            }
          }
        ]
      }
    ],
    "accuracy": 0.86,
    "description": "명사수 데스페라도의 축복이 담긴 레이피어. 빠르고 정확한 일격이 적을 관통한다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 150,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50005,
    "name": "신성한 일침",
    "imageName": "legend/rapier/50005.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.rapier",
    "baseLevel": 500,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 40.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "skills": [
      {
        "skill_name": "정화",
        "skill_type": "passive",
        "skill_description": "성물이 선과 악을 구분해 전투를 돕는다.",
        "skill_description_detail": "언데드·데몬 종족에게 추가 피해 +100%, 신성·천사 종족에게 추가 피해 -30%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveBonusDamageToRace",
            "params": { "race": "undead", "multiplier": 1 }
          },
          {
            "effect_name": "applyPassiveBonusDamageToRace",
            "params": { "race": "demon", "multiplier": 1 }
          },
          {
            "effect_name": "applyPassivePenaltyDamageToRace",
            "params": { "race": "divine", "multiplier": 0.3 }
          },
          {
            "effect_name": "applyPassivePenaltyDamageToRace",
            "params": { "race": "angel", "multiplier": 0.3 }
          }
        ]
      },
      {
        "skill_name": "심판",
        "skill_type": "active",
        "skill_description": "성물이 찬란한 빛을 발산해 몬스터를 심판한다.",
        "skill_description_detail": "공격 시 7.5% 확률로 83,500 추가 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyFixedDamage",
            "params": {
              "chance": 0.075,
              "damage": 83500,
              "cooldown": 5,
              "trigger": "onHit"
            }
          }
        ]
      }
    ],
    "accuracy": 0.86,
    "description": "신성국에 전해지는 성물 중 하나. 신성한 기운이 느껴진다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 150,
    "investedTranscendenceStones": 0
  },
]


# --- 무기 타입 분류 ---
TYPE_MAP = {
    "레이피어": "rapier", "도검": "blade", "검": "sword",
    "대검": "greatsword", "시미터": "scimitar", "단검": "dagger",
    "도축칼": "cleaver", "전투도끼": "battle_axe", "전투망치": "warhammer",
    "창": "spear", "지팡이": "staff", "삼지창": "trident",
    "메이스": "mace", "낫": "scythe", "곡도": "curved_sword", "쌍절곤": "nunchaku"
}

# --- 무기 타입별 멀티플라이어 ---
WEAPON_TYPE_MODIFIERS = {
     "rapier":       {"damage_mult": 0.90, "speed_mult": 1.30, "accuracy_mult": 1.120, "crit_chance_mult": 1.800, "crit_mult_mult": 0.950},
     "blade":       {"damage_mult": 1.05, "speed_mult": 1.15, "accuracy_mult": 1.070, "crit_chance_mult": 1.500, "crit_mult_mult": 1.050},
     "sword":        {"damage_mult": 1.20, "speed_mult": 1.00, "accuracy_mult": 1.030, "crit_chance_mult": 1.000, "crit_mult_mult": 1.000},
     "greatsword":   {"damage_mult": 1.70, "speed_mult": 0.80, "accuracy_mult": 0.940, "crit_chance_mult": 0.800, "crit_mult_mult": 1.200},
     "scimitar":     {"damage_mult": 1.05, "speed_mult": 1.15, "accuracy_mult": 1.040, "crit_chance_mult": 1.200, "crit_mult_mult": 1.000},
     "dagger":       {"damage_mult": 0.85, "speed_mult": 1.35, "accuracy_mult": 1.100, "crit_chance_mult": 2.000, "crit_mult_mult": 0.900},
     "cleaver":      {"damage_mult": 1.35, "speed_mult": 0.90, "accuracy_mult": 1.000, "crit_chance_mult": 1.200, "crit_mult_mult": 1.100},
     "battle_axe":    {"damage_mult": 1.50, "speed_mult": 0.85, "accuracy_mult": 0.950, "crit_chance_mult": 0.800, "crit_mult_mult": 1.150},
     "warhammer":    {"damage_mult": 1.80, "speed_mult": 0.75, "accuracy_mult": 0.920, "crit_chance_mult": 0.700, "crit_mult_mult": 1.300},
     "spear":        {"damage_mult": 1.10, "speed_mult": 1.05, "accuracy_mult": 1.100, "crit_chance_mult": 1.200, "crit_mult_mult": 1.000},
     "staff":        {"damage_mult": 1.10, "speed_mult": 1.00, "accuracy_mult": 1.120, "crit_chance_mult": 1.300, "crit_mult_mult": 0.950},
     "trident":      {"damage_mult": 1.20, "speed_mult": 0.95, "accuracy_mult": 1.080, "crit_chance_mult": 1.200, "crit_mult_mult": 1.050},
     "mace":         {"damage_mult": 1.40, "speed_mult": 0.90, "accuracy_mult": 0.970, "crit_chance_mult": 0.800, "crit_mult_mult": 1.200},
     "scythe":       {"damage_mult": 1.25, "speed_mult": 1.00, "accuracy_mult": 0.990, "crit_chance_mult": 1.300, "crit_mult_mult": 1.150},
     "curved_sword": {"damage_mult": 1.10, "speed_mult": 1.10, "accuracy_mult": 1.030, "crit_chance_mult": 1.200, "crit_mult_mult": 1.050},
     "nunchaku":     {"damage_mult": 0.95, "speed_mult": 1.30, "accuracy_mult": 1.060, "crit_chance_mult": 1.800, "crit_mult_mult": 0.950},
}

def generate_legend_weapons():
    all_legend_weapons = []
    
    base_speed = 1.0
    base_crit_chance = 0.1
    base_crit_damage = 1.5
    base_accuracy = 0.7

    for i, (korean_name, english_name) in enumerate(TYPE_MAP.items()):
        type_modifiers = WEAPON_TYPE_MODIFIERS[english_name]
        
        for base_weapon_template in BASE_LEGEND_WEAPONS:
            new_weapon = copy.deepcopy(base_weapon_template)
            
            # Generate new ID based on weapon type index
            # The base ID for rapier is 50000, for the next type it will be 51000, and so on.
            new_weapon['id'] = base_weapon_template['id'] + (i * 1000)
            
            new_weapon['type'] = f'WeaponType.{english_name}'
            # Note: The original imageName has the type hardcoded. We update it.
            # e.g., "legend/rapier/50000.png" -> "legend/sword/51000.png"
            new_weapon['imageName'] = f'legend/{english_name}/{new_weapon["id"]}.png'
            
            # Recalculate stats based on weapon type modifiers
            new_weapon['speed'] = round(1.5 * base_speed * type_modifiers['speed_mult'], 2)
            new_weapon['criticalChance'] = round(1.2 * base_crit_chance * type_modifiers['crit_chance_mult'], 3)
            new_weapon['criticalDamage'] = round(2 * base_crit_damage * type_modifiers['crit_mult_mult'], 2)
            new_weapon['accuracy'] = round(1.05 * base_accuracy * type_modifiers['accuracy_mult'], 3)

            # Recalculate base damage if it's based on level, otherwise keep the template's damage
            level = new_weapon['baseLevel']
            if level == 0:
                new_weapon['baseSellPrice'] = 18000
            else:
                new_weapon['baseSellPrice'] = int(level * 1800)
            damage_mult = type_modifiers.get('damage_mult', 1)

            if base_weapon_template.get('baseDamage', 0) == 0: # If baseDamage is 0 in template
                if level == 0:
                    damage = 75 * 1.2 * 1.5 * damage_mult # User's requested fixed value
                    new_weapon['baseDamage'] = int(damage)
                elif level > 0:
                    # Original formula for level > 0
                    damage = (0.08 * (level ** 1.75) + 7 * level + 10) * 1.2 * 1.5 * damage_mult
                    new_weapon['baseDamage'] = int(damage)
            else:
                # Keep the original baseDamage from the template if it was specified (i.e., not 0)
                new_weapon['baseDamage'] = base_weapon_template.get('baseDamage', 0)

            all_legend_weapons.append(new_weapon)

    return all_legend_weapons

def main():
    # Ensure the script can be run from anywhere by using absolute paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, '..', 'assets', 'data', 'legend_weapons.json')
    
    legend_weapons = generate_legend_weapons()
    
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(legend_weapons, f, ensure_ascii=False, indent=2)
        print(f'Successfully saved {len(legend_weapons)} legend weapons to {output_path}')
    except IOError as e:
        print(f'Error writing {output_path}: {e}')

if __name__ == '__main__':
    main()