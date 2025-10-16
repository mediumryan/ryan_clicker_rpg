import json
import copy
import os

# --- 베이스 레전드 무기 데이터 ---
BASE_LEGEND_WEAPONS = [
    {
    "id": 50000,
    "name": "룬드 스태프",
    "imageName": "legend/staff/50000.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.staff",
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
        "skill_name": "룬 각인",
        "skill_type": "passive",
        "skill_description": "공격력이 50% 증가합니다. 공격속도가 50% 증가합니다. 치명타 확률이 10% 증가합니다. 치명타 배율이 1.5배 증가합니다. 적중률이 5% 증가합니다.",
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
              "value": 1.5,
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
    "description": "드워프족의 고유 기술인 룬 문자를 새긴 지팡이. 전투 능력을 크게 끌어올린다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 10,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50001,
    "name": "세이지 아울",
    "imageName": "legend/staff/50001.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.staff",
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
        "skill_name": "깨달음",
        "skill_type": "passive",
        "skill_description": "경험치 획득량이 증가한다.",
        "skill_description_detail": "경험치 획득량 +100%",
        "skill_effect": [
          {
            "effect_name": "applyExpGainBoost",
            "params": { "multiplier": 2.0 }
          }
        ]
      },
      {
        "skill_name": "관찰",
        "skill_type": "passive",
        "skill_description": "상대방의 움직임을 정확히 파악해 공격한다.",
        "skill_description_detail": "명중률 +15%, 더블 어택 확률 +20%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "accuracy",
              "value": 0.15,
              "isMultiplicative": False
            }
          },
          {
            "effect_name": "criticalDamage",
            "params": {
              "stat": "doubleAttackChance",
              "value": 0.2,
              "isMultiplicative": False
            }
          }
        ]
      }
    ],
    "accuracy": 0.823,
    "description": "밤의 고요한 현자 올빼미에 영감을 받아 만들어진 지팡이.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 30,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50002,
    "name": "참된 스승",
    "imageName": "legend/staff/50002.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.staff",
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
        "skill_name": "갈!",
        "skill_type": "active",
        "skill_description": "큰 소리로 상대방을 꾸짖는다.",
        "skill_description_detail": "공격 시 7.5% 확률로 5초간 무장 해제, 방어력 40 감소, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyDisarm",
            "params": {
              "chance": 0.075,
              "defenseReduction": 40,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 5
            }
          }
        ]
      },
      {
        "skill_name": "교육열",
        "skill_type": "passive",
        "skill_description": "끝난 전투를 복기하며 성장한다.",
        "skill_description_detail": "무기 획득 시 경험치 획득량 25% 영구 증가.",
        "skill_effect": []
      }
    ],
    "accuracy": 0.823,
    "description": "참된 스승의 가르침은 때와 장소를 가리지 않는다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 50,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50003,
    "name": "신성한 뿔",
    "imageName": "legend/staff/50003.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.staff",
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
        "skill_name": "행운의 상징",
        "skill_type": "active",
        "skill_description": "신수의 힘이 모든 것을 사용자에게 유리한 방향으로 이끈다.",
        "skill_description_detail": "치명타 확률 +25%, 명중률 +10%, 더블 어택 확률 +10%",
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
      },
      {
        "skill_name": "행운의 상징 Ⅱ",
        "skill_type": "active",
        "skill_description": "골드 획득량이 영구적으로 증가한다.",
        "skill_description_detail": "골드 획득량 50% 영구 증가",
        "skill_effect": []
      }
    ],
    "accuracy": 0.823,
    "description": "신수 페가수스의 뿔로 벼린 지팡이. 사용자의 행운을 높여준다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 100,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50004,
    "name": "아킬레우스의 창",
    "imageName": "legend/staff/50004.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.staff",
    "baseLevel": 800,
    "baseDamage": 0,
    "criticalChance": 0.1,
    "criticalDamage": 1.5,
    "defensePenetration": 36.0,
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
        "skill_name": "전쟁의 영웅",
        "skill_type": "passive",
        "skill_description": "트로이 전쟁을 승리로 이끈 위대한 영웅처럼, 모든 전투에서 승리를 쟁취한다.",
        "skill_description_detail": "공격력 +100%, 치명타 확률 +15%, 명중률 +10%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "criticalChance",
              "value": 1.0,
              "isMultiplicative": False
            }
          }
        ]
      },
      {
        "skill_name": "아킬레스건",
        "skill_type": "passive",
        "skill_description": "사용자와 마찬가지로 무기 또한 치명적인 약점을 갖는다.",
        "skill_description_detail": "공격속도 -1000/s (자동공격 불가)",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatDebuff",
            "params": {
              "stat": "speed",
              "value": 1000.0,
              "isMultiplicative": False
            }
          }
        ]
      }
    ],
    "accuracy": 0.823,
    "description": "반신이자 영웅인 아킬레우스의 창. 펠리온 산의 물푸레 나무로 만들어져 매우 무겁다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 150,
    "investedTranscendenceStones": 0
  },
  {
    "id": 50005,
    "name": "신성한 파편 - 왼발",
    "imageName": "legend/staff/50005.png",
    "rarity": "Rarity.legend",
    "type": "WeaponType.staff",
    "baseLevel": 500,
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
        "skill_description_detail": "공격 시 7.5% 확률로 1,367,000 추가 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyFixedDamage",
            "params": {
              "chance": 0.075,
              "damage": 1367000,
              "cooldown": 5,
              "trigger": "onHit"
            }
          }
        ]
      }
    ],
    "accuracy": 0.823,
    "description": "신성국의 열다섯 성물 중 하나. 신의 왼발으로 만들어졌다고 전해진다.",
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 150,
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