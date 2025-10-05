import json
import copy
import os

# --- 베이스 레전드 무기 데이터 ---
BASE_LEGEND_WEAPONS = [
  {
    "id": 50000,
    "name": "오닉스 스플린터",
    "imageName": "legend/battle_axe/50000.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.battleAxe",
    "baseLevel": 0,
    "baseDamage": 0,
    "criticalChance": 0.08,
    "criticalDamage": 1.8,
    "defensePenetration": 10.0,
    "doubleAttackChance": 0.0,
    "speed": 0.8,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "오닉스 각인",
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
    "accuracy": 0.8,
    "description": "오닉스의 어둡지만 신비로운 광채를 품은 도끼. 전투 능력을 크게 끌어올린다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50001,
    "name": "그리즐리",
    "imageName": "legend/battle_axe/50001.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.battleAxe",
    "baseLevel": 200,
    "baseDamage": 0,
    "criticalChance": 0.08,
    "criticalDamage": 1.8,
    "defensePenetration": 25.0,
    "doubleAttackChance": 0.0,
    "speed": 0.8,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "곰발",
        "skill_type": "active",
        "skill_description": "강력한 일격으로 눈앞의 적을 가른다.",
        "skill_description_detail": "공격 시 7.5% 확률로 10배의 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyMultiplierDamage",
            "params": {
              "chance": 0.075,
              "trigger": "onHit",
              "multiplier": 10.0,
              "cooldown": 5
            }
          }
        ]
      }
    ],
    "accuracy": 0.8,
    "description": "일격에 모든 것을 찢어버리는 거대한 도끼. 마치 곰의 앞발과도 같다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50002,
    "name": "무자비한 집행자",
    "imageName": "legend/battle_axe/50002.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.battleAxe",
    "baseLevel": 400,
    "baseDamage": 0,
    "criticalChance": 0.08,
    "criticalDamage": 1.8,
    "defensePenetration": 30.0,
    "doubleAttackChance": 0.0,
    "speed": 0.8,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "처형",
        "skill_type": "passive",
        "skill_description": "단두대의 칼날과 같은 공격으로 적을 처형한다.",
        "skill_description_detail": "공격시 2.5% 확률로 적 처치, 보스의 경우 160,000 추가 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyMonsterKill",
            "params": {
              "fixDmg": 160000,
              "trigger": "onHit",
              "chance": 0.025,
              "cooldown": 5
            }
          }
        ]
      }
    ],
    "accuracy": 0.8,
    "description": "죄인의 목을 치던 망나니의 도끼. 공격 시 낮은 확률로 적을 즉시 처형한다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50003,
    "name": "가이안트",
    "imageName": "legend/battle_axe/50003.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.battleAxe",
    "baseLevel": 600,
    "baseDamage": 0,
    "criticalChance": 0.08,
    "criticalDamage": 1.8,
    "defensePenetration": 35.0,
    "doubleAttackChance": 0.0,
    "speed": 0.8,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "가이아의 축복",
        "skill_type": "passive",
        "skill_description": "대지의 신 가이아의 축복으로 사용자의 공격력을 대폭 올려준다.",
        "skill_description_detail": "공격력 +200%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "damage",
              "value": 3.0,
              "isMultiplicative": True
            }
          }
        ]
      },
      {
        "skill_name": "개연성",
        "skill_type": "passive",
        "skill_description": "신의 온전한 축복을 모두 감당하기에는 무기가 완전하지 못하다.",
        "skill_description_detail": "공격속도 -30%, 적중률 -5%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatDebuff",
            "params": {
              "stat": "speed",
              "value": 0.3,
              "isMultiplicative": True
            }
          },
          {
            "effect_name": "applyPassiveStatDebuff",
            "params": {
              "stat": "accuracy",
              "value": 0.05,
              "isMultiplicative": False
            }
          }
        ]
      }
    ],
    "accuracy": 0.8,
    "description": "대지의 신 가이아가 직접 단조했다는 전설의 도끼. 강력한 힘을 지녔으나 그 힘을 감당하기에는 무기가 완전하지 못하다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50004,
    "name": "은도끼",
    "imageName": "legend/battle_axe/50004.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.battleAxe",
    "baseLevel": 800,
    "baseDamage": 0,
    "criticalChance": 0.08,
    "criticalDamage": 1.8,
    "defensePenetration": 45.0,
    "doubleAttackChance": 0.0,
    "speed": 0.8,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "신선 세트",
        "skill_type": "passive",
        "skill_description": "금도끼를 획득한 적이 있는 경우, 능력치가 대폭 상승한다.",
        "skill_description_detail": "무기 도감에 금도끼가 활성화 되어있는 경우 공격속도 +200%, 적중률 +20%",
        "skill_effect": [
          {
            "effect_name": "applySynergyBonus",
            "params": {
              "stat": "speed",
              "value": 3.0,
              "isMultiplicative": True,
              "targetId": [50005]
            }
          },
          {
            "effect_name": "applySynergyBonus",
            "params": {
              "stat": "accuracy",
              "value": 0.2,
              "isMultiplicative": False,
              "targetId": [50005]
            }
          }
        ]
      }
    ],
    "accuracy": 0.8,
    "description": "산 속의 패왕 신선이 사용하던 도끼. 겉보기엔 평범한 은도끼이지만 금도끼를 획득한 적이 있는 경우, 능력치가 대폭 상승한다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50005,
    "name": "금도끼",
    "imageName": "legend/battle_axe/50005.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.battleAxe",
    "baseLevel": 800,
    "baseDamage": 0,
    "criticalChance": 0.08,
    "criticalDamage": 1.8,
    "defensePenetration": 45.0,
    "doubleAttackChance": 0.0,
    "speed": 0.8,
    "baseSellPrice": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "신선 세트",
        "skill_type": "passive",
        "skill_description": "은도끼를 획득한 적이 있는 경우, 능력치가 대폭 상승한다.",
        "skill_description_detail": "무기 도감에 금도끼가 활성화 되어있는 경우 공격력 +150%, 적중률 +20%",
        "skill_effect": [
          {
            "effect_name": "applySynergyBonus",
            "params": {
              "stat": "damage",
              "value": 2.5,
              "isMultiplicative": True,
              "targetId": [50005]
            }
          },
          {
            "effect_name": "applySynergyBonus",
            "params": {
              "stat": "accuracy",
              "value": 0.2,
              "isMultiplicative": False,
              "targetId": [50005]
            }
          }
        ]
      }
    ],
    "accuracy": 0.8,
    "description": "산 속의 패왕 신선이 사용하던 도끼. 겉보기엔 평범한 금도끼이지만 은도끼를 획득한 적이 있는 경우, 능력치가 대폭 상승한다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50006,
    "name": "신성한 파편 - 척추",
    "imageName": "legend/battle_axe/50006.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.battleAxe",
    "baseLevel": 1000,
    "baseDamage": 0,
    "criticalChance": 0.08,
    "criticalDamage": 1.8,
    "defensePenetration": 50.0,
    "doubleAttackChance": 0.0,
    "speed": 0.8,
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
    "accuracy": 0.8,
    "description": "신성국의 열다섯 성물 중 하나. 신의 척추로 만들어졌다고 전해진다.",
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
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(script_dir)))
    output_path = os.path.join(project_root, 'assets', 'data', 'legend_weapons.json')
    
    legend_weapons = generate_legend_weapons()
    
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(legend_weapons, f, ensure_ascii=False, indent=2)
        print(f'Successfully saved {len(legend_weapons)} legend weapons to {output_path}')
    except IOError as e:
        print(f'Error writing {output_path}: {e}')

if __name__ == '__main__':
    main()