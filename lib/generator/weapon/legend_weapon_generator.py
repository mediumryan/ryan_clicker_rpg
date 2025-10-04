import json
import copy
import os

# --- 베이스 레전드 무기 데이터 ---
BASE_LEGEND_WEAPONS = [
  {
    "id": 50000,
    "name": "토파즈 플래시",
    "imageName": "legend/dagger/50000.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.dagger",
    "baseLevel": 0,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 4.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "토파즈 각인",
        "skill_type": "passive",
        "skill_description": "보석의 힘이 사용자와 무기를 각성시킨다.",
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
    "accuracy": 0.823,
    "description": "토파즈의 따스한 황금빛 광채를 머금은 대검. 전투 능력을 크게 끌어올린다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50001,
    "name": "사일런트 캣",
    "imageName": "legend/dagger/50001.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.dagger",
    "baseLevel": 200,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 20.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "고요한 사냥꾼",
        "skill_type": "passive",
        "skill_description": "조용히 그리고 빠르게 적을 제압한다.",
        "skill_description_detail": "공격속도 +50%, 치명타 확률 +15%, 치명타 배율 +2배, 더블어택 확률 +10%",
        "skill_effect": [
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
              "value": 0.15,
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
              "stat": "doubleAttackChance",
              "value": 0.1,
              "isMultiplicative": False
            }
          }
        ]
      }
    ],
    "accuracy": 0.823,
    "description": "그림자처럼 조용히 움직이는 고양이를 본따 만든 단검. 한순간의 침묵 뒤에 폭풍 같은 연속공격이 시작된다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50002,
    "name": "특급 살수",
    "imageName": "legend/dagger/50002.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.dagger",
    "baseLevel": 400,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 24.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "암살 지령",
        "skill_type": "passive",
        "skill_description": "사전에 적의 정보를 수집하고 약점을 파악한다.",
        "skill_description_detail": "치명타 확률 +25%, 치명타 배율 +4배",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "criticalChance",
              "value": 0.2,
              "isMultiplicative": False
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "criticalDamage",
              "value": 2.0,
              "isMultiplicative": False
            }
          }
        ]
      },
      {
        "skill_name": "급소 찌르기",
        "skill_type": "active",
        "skill_description": "적의 급소를 정확히 찔러 큰 피해를 입힌다.",
        "skill_description_detail": "공격 시 7.5% 확률로 160,000 추가 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyFixedDamage",
            "params": {
              "chance": 0.075,
              "damage": 160000,
              "cooldown": 5,
              "trigger": "onHit"
            }
          }
        ]
      }
    ],
    "accuracy": 0.823,
    "description": "높은 경지에 오른 자객이 사용하는 단검. 적의 급소를 정확히 찔러 큰 피해를 입힌다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50003,
    "name": "지옥 수문장",
    "imageName": "legend/dagger/50003.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.dagger",
    "baseLevel": 600,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 28.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "지옥불",
        "skill_type": "active",
        "skill_description": "지옥불로 적을 불태운다.",
        "skill_description_detail": "공격 시 7.5% 확률로 5초간 화상, 초당 122,000 피해, 중첩 불가, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyBurn",
            "params": {
              "chance": 0.075,
              "duration": 5,
              "damagePerSecond": 122000,
              "stackable": False,
              "trigger": "onHit",
              "cooldown": 5
            }
          }
        ]
      },
      {
        "skill_name": "삼연격",
        "skill_type": "active",
        "skill_description": "빠르게 3회 연속 공격한다.",
        "skill_description_detail": "공격 시 7.5% 확률로 3회 연속 공격, 쿨타임 0초",
        "skill_effect": [
          {
            "effect_name": "applyMultiHitDamage",
            "params": {
              "trigger": "onHit",
              "chance": 0.075,
              "hits": 3,
              "cooldown": 0
            }
          }
        ]
      }
    ],
    "accuracy": 0.823,
    "description": "케로베로스의 목줄을 녹여 만든 단검. 지옥 수문장의 힘을 얻는다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50004,
    "name": "로도스의 줄기",
    "imageName": "legend/dagger/50004.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.dagger",
    "baseLevel": 800,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 28.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "로도스의 장미",
        "skill_type": "passive",
        "skill_description": "장미꽃을 피워 적을 매혹시킨다.",
        "skill_description_detail": "공격 시 7.5% 확률로 5초간 매혹, 적 피격시 방어력 5 감소, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyPoison",
            "params": {
              "chance": 0.075,
              "attackPerDefence": 5.0,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 5
            }
          }
        ]
      },
      {
        "skill_name": "장미의 가시",
        "skill_type": "active",
        "skill_description": "매혹에 걸린 적에게 입히는 피해가 증가한다.",
        "skill_description_detail": "매혹 상태의 적에게 주는 데미지 +100%",
        "skill_effect": [
          {
            "effect_name": "increaseDamageToStatused",
            "params": {
              "status": "charm",
              "damageMultiplier": 1.0
            }
          }
        ]
      }
    ],
    "accuracy": 0.823,
    "description": "아프로디테의 눈물에서 피어난 장미 로도스의 줄기로 벼린 단검. 적을 매혹한다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50005,
    "name": "신성한 파편 - 왼손",
    "imageName": "legend/dagger/50005.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.dagger",
    "baseLevel": 1000,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 40.0,
    "doubleAttackChance": 0.0,
    "speed": 1.0,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
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
        "skill_description_detail": "공격 시 7.5% 확률로 1,000,000 추가 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyFixedDamage",
            "params": {
              "chance": 0.075,
              "damage": 1000000,
              "cooldown": 5,
              "trigger": "onHit"
            }
          }
        ]
      }
    ],
    "accuracy": 0.823,
    "description": "신성국의 열다섯 성물 중 하나. 신의 왼손으로 만들어졌다고 전해진다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  }
]

# --- 무기 타입 분류 ---
TYPE_MAP = {
    "레이피어": "rapier", "도검": "blade", "검": "sword",
    "대검": "greatsword", "단검": "dagger",
    "전투도끼": "battle_axe", "전투망치": "warhammer",
    "창": "spear", "지팡이": "staff", 
    "메이스": "mace", "낫": "scythe", "곡도": "curved_sword", 
}

# --- 무기 타입별 멀티플라이어 ---
WEAPON_TYPE_MODIFIERS = {
     "rapier":       {"damage_mult": 0.90, "speed_mult": 1.30, "accuracy_mult": 1.120, "crit_chance_mult": 1.800, "crit_mult_mult": 0.950},
     "blade":       {"damage_mult": 1.05, "speed_mult": 1.15, "accuracy_mult": 1.070, "crit_chance_mult": 1.500, "crit_mult_mult": 1.050},
     "sword":        {"damage_mult": 1.20, "speed_mult": 1.00, "accuracy_mult": 1.030, "crit_chance_mult": 1.000, "crit_mult_mult": 1.000},
     "greatsword":   {"damage_mult": 1.70, "speed_mult": 0.80, "accuracy_mult": 0.940, "crit_chance_mult": 0.800, "crit_mult_mult": 1.200},
     "dagger":       {"damage_mult": 0.85, "speed_mult": 1.35, "accuracy_mult": 1.100, "crit_chance_mult": 2.000, "crit_mult_mult": 0.900},
     "battle_axe":    {"damage_mult": 1.50, "speed_mult": 0.85, "accuracy_mult": 0.950, "crit_chance_mult": 0.800, "crit_mult_mult": 1.150},
     "warhammer":    {"damage_mult": 1.80, "speed_mult": 0.75, "accuracy_mult": 0.920, "crit_chance_mult": 0.700, "crit_mult_mult": 1.300},
     "spear":        {"damage_mult": 1.10, "speed_mult": 1.05, "accuracy_mult": 1.100, "crit_chance_mult": 1.200, "crit_mult_mult": 1.000},
     "staff":        {"damage_mult": 1.10, "speed_mult": 1.00, "accuracy_mult": 1.120, "crit_chance_mult": 1.300, "crit_mult_mult": 0.950},
     "mace":         {"damage_mult": 1.40, "speed_mult": 0.90, "accuracy_mult": 0.970, "crit_chance_mult": 0.800, "crit_mult_mult": 1.200},
     "scythe":       {"damage_mult": 1.25, "speed_mult": 1.00, "accuracy_mult": 0.990, "crit_chance_mult": 1.300, "crit_mult_mult": 1.150},
     "curved_sword": {"damage_mult": 1.10, "speed_mult": 1.10, "accuracy_mult": 1.030, "crit_chance_mult": 1.200, "crit_mult_mult": 1.050},
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
            new_weapon['defensePenetration'] = round(level / 50 + 10, 0)
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