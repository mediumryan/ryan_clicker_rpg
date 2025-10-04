import json
import copy
import os

# --- 베이스 에픽 무기 데이터 ---
BASE_EPIC_WEAPONS = [
  {
    "id": 30000,
    "name": "기선제압",
    "imageName": "epic/rapier/30000.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "투신의 축복이 담겨 있는 무기. 전투 시작 시 일정 시간 동안 공격력이 상승한다.",
    "baseLevel": 0,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 2.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "선수필승",
        "skill_type": "passive",
        "skill_description": "투신의 축복으로 일정 시간 동안 공격력이 증가한다.",
        "skill_description_detail": "전투 시작 시 5초간 공격력 +50%",
        "skill_effect": [
          {
            "effect_name": "applyStatBoost",
            "params": {
              "stat": "damage",
              "value": 0.5,
              "isMultiplicative": True,
              "duration": 5,
              "trigger": "stageStart"
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30001,
    "name": "초신성",
    "imageName": "epic/rapier/30001.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "빛나는 재능을 지닌 자만이 사용할 수 있는 무기. 사용자의 잠재력을 극대화해준다.",
    "baseLevel": 50,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 4.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "숨길 수 없는 재능",
        "skill_type": "passive",
        "skill_description": "사용자의 잠재력을 끌어올린다.",
        "skill_description_detail": "공격력 +30%, 치명타 확률 +15%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "damage",
              "value": 1.3,
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
          }
        ]
      }
    ]
  },
  {
    "id": 30002,
    "name": "독아",
    "imageName": "epic/rapier/30002.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "대량의 독이 함유되어 있는 무기. 마치 독사의 송곳니 같다.",
    "baseLevel": 100,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 10.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "맹독 주입",
        "skill_type": "active",
        "skill_description": "치명적인 맹독을 주입한다.",
        "skill_description_detail": "공격 시 5% 확률로 5초간 중독, 초당 최대 체력의 5% 피해, 최대 데미지 11,300, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyPoison",
            "params": {
              "chance": 0.05,
              "percentPerSecond": 0.05,
              "maxDmg": 11300,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 5
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30003,
    "name": "중력",
    "imageName": "epic/rapier/30003.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 중력 마법이 각인된 무기. 무게가 무거워진 만큼 엄청난 파괴력을 자랑한다.",
    "baseLevel": 200,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 12.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "중력 각인",
        "skill_type": "passive",
        "skill_description": "무기가 무거워져 공격력이 증가하는 반면, 공격속도가 감소한다.",
        "skill_description_detail": "공격력 +60%, 공격속도 -30%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatDebuff",
            "params": {
              "stat": "speed",
              "value": 0.7,
              "isMultiplicative": True
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "damage",
              "value": 1.6,
              "isMultiplicative": True
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30004,
    "name": "겁화",
    "imageName": "epic/rapier/30004.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 화염 마법이 각인된 무기. 일정 확률로 적을 불태운다.",
    "baseLevel": 300,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 14.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "열 주입",
        "skill_type": "passive",
        "skill_description": "뜨거운 열기가 적을 불태운다.",
        "skill_description_detail": "공격 시 5% 확률로 5초간 화상, 초당 27,800 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyBurn",
            "params": {
              "chance": 0.05,
              "duration": 5,
              "fixedDamagePerSecond": 27800,
              "stackable": False,
              "trigger": "onHit",
              "cooldown": 5
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30005,
    "name": "수확",
    "imageName": "epic/rapier/30005.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 흑마법이 각인된 무기. 적을 처치할 수록 강해진다.",
    "baseLevel": 400,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 18.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": True,
      "currentStacks": 0,
      "maxStacks": 100,
      "damagePerStack": 60
    },
    "skills": [
      {
        "skill_name": "갈증 해소",
        "skill_type": "active",
        "skill_description": "처치한 적의 영혼을 수확하여 힘으로 바꾼다.",
        "skill_description_detail": "적 처치 시 무기 공격력 +60, 최대 100중첩",
        "skill_effect": [
          {
            "effect_name": "increaseStat",
            "params": { "stat": "stack.currentStacks", "increment": 1 }
          }
        ]
      }
    ]
  },
  {
    "id": 30006,
    "name": "아머브레이커",
    "imageName": "epic/rapier/30006.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "예리한 공격으로 적의 방어를 효과적으로 무너뜨리는 무기.",
    "baseLevel": 500,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 20.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "갑옷 부수기",
        "skill_type": "active",
        "skill_description": "예리한 공격으로 적의 방어를 무너뜨린다.",
        "skill_description_detail": "공격 시 5% 확률로 5초간 무장 해제, 방어력 33 감소, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyDisarm",
            "params": {
              "chance": 0.05,
              "defenseReduction": 33,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 5
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30007,
    "name": "파멸",
    "imageName": "epic/rapier/30007.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "적을 처치하는 데 탁월한 성능을 지닌 무기. 치명타는 곧 죽음을 의미한다.",
    "baseLevel": 600,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 22.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "초집중",
        "skill_type": "passive",
        "skill_description": "치명타 배율이 대폭 상승한다.",
        "skill_description_detail": "치명타 배율 +5배",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "criticalDamage",
              "value": 5.0,
              "isMultiplicative": False
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30008,
    "name": "송곳니",
    "imageName": "epic/rapier/30008.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "매우 거칠게 연마된 무기. 일정 확률로 적에게 출혈을 유도한다.",
    "baseLevel": 700,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 26.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "과다출혈",
        "skill_type": "passive",
        "skill_description": "거친 날과 면으로 스치기만 해도 적에게 출혈을 입힌다.",
        "skill_description_detail": "공격 시 5% 확률로 5초간 출혈, 초당 107,000 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyBleed",
            "params": {
              "chance": 0.05,
              "duration": 5,
              "damagePerSecond": 107000,
              "stackable": False,
              "trigger": "onHit",
              "cooldown": 5
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30009,
    "name": "환상",
    "imageName": "epic/rapier/30009.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 환영마법이 각인된 무기. 적에게 환상을 보여 혼란에 빠뜨린다.",
    "baseLevel": 800,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 28.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "어지러운 전장",
        "skill_type": "active",
        "skill_description": "적에게 환상을 보여주어 정신을 못차리게 만든다.",
        "skill_description_detail": "공격 시 5% 확률로 5초간 혼란, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyConfusion",
            "params": {
              "chance": 0.05,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 5
            }
          }
        ]
      },
      {
        "skill_name": "각인 개화",
        "skill_type": "passive",
        "skill_description": "무기에 각인된 힘이 혼란 상태의 적에게 반응해 무기를 강화한다.",
        "skill_description_detail": "혼란 상태의 적에게 주는 데미지 +50%",
        "skill_effect": [
          {
            "effect_name": "increaseDamageToStatused",
            "params": { "status": "confusion", "damageMultiplier": 0.5 }
          }
        ]
      }
    ]
  },
  {
    "id": 30010,
    "name": "족쇄",
    "imageName": "epic/rapier/30010.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "저주받은 무기. 손에 쥐는 순간, 사용자는 자신의 의지대로 움직일 수 없게 된다.",
    "baseLevel": 900,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 30.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "사악한 저주",
        "skill_type": "passive",
        "skill_description": "사악한 저주가 사용자의 움직임을 극도로 둔화시킨다.",
        "skill_description_detail": "공격속도 -95%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatDebuff",
            "params": {
              "stat": "speed",
              "value": 0.05,
              "isMultiplicative": True
            }
          }
        ]
      },
      {
        "skill_name": "저주의 반향",
        "skill_type": "passive",
        "skill_description": "강력한 저주가 공격력을 대폭 상승시킨다.",
        "skill_description_detail": "공격력 +1000%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "damage",
              "value": 10.0,
              "isMultiplicative": True
            }
          }
        ]
      },
      {
        "skill_name": "의지 상실",
        "skill_type": "passive",
        "skill_description": "저주에 의해 사용자의 의지가 꺾여 클릭 공격을 할 수 없게 됩니다.",
        "skill_description_detail": "클릭 공격 비활성화",
        "skill_effect": [
          {
            "effect_name": "disableManualAttack",
            "params": {}
          }
        ]
      }
    ]
  },
  {
    "id": 30011,
    "name": "명작",
    "imageName": "epic/rapier/30011.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "시대를 초월한 명작, 대장장이들의 꿈과도 같은 무기이다.",
    "baseLevel": 1000,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 34.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "시대를 뛰어넘는 작품",
        "skill_type": "passive",
        "skill_description": "무기의 능력이 대폭 상승한다.",
        "skill_description_detail": "공격력 +50%, 공격속도 +50%",
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
          }
        ]
      }
    ]
  },
  {
    "id": 30012,
    "name": "보물",
    "imageName": "epic/rapier/30012.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "매우 희귀한 무기, 소지하는 것만으로도 엄청난 부를 불러온다.",
    "baseLevel": 1000,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 34.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "재물운",
        "skill_type": "passive",
        "skill_description": "소지하는 것만으로도 엄청난 부를 불러온다. ",
        "skill_description_detail": "골드 획득량 +125%",
        "skill_effect": [
          {
            "effect_name": "applyGoldGainBoost",
            "params": { "multiplier": 2.25 }
          }
        ]
      }
    ]
  },
  {
    "id": 30013,
    "name": "최후의 속삭임",
    "imageName": "epic/rapier/30013.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "약해진 적의 숨통을 쉽게 끊도록 설계된 무기.",
    "baseLevel": 1100,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 36.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "최후통첩",
        "skill_type": "active",
        "skill_description": "체력이 약해진 적을 상대할 때 추가 피해를 가한다.",
        "skill_description_detail": "체력이 50% 이하인 적 공격 시, 무기 공격력의 5% 추가 피해",
        "skill_effect": [
          {
            "effect_name": "applyHpConditionalBonusDamage",
            "params": {
              "chance": 1.0,
              "hpThreshold": 0.5,
              "condition": "le",
              "multiplier": 0.05,
              "trigger": "onHit",
              "cooldown": 0
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30014,
    "name": "지진",
    "imageName": "epic/rapier/30014.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 대지마법이 각인된 무기. 일정 확률로 충격파를 발산한다.",
    "baseLevel": 1200,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 38.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "충격파",
        "skill_type": "active",
        "skill_description": "공격과 동시에 충격파를 발산한다.",
        "skill_description_detail": "공격 시 5% 확률로 1,137,000 추가 피해, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyFixedDamage",
            "params": {
              "chance": 0.025,
              "damage": 1137000,
              "cooldown": 5,
              "trigger": "onHit"
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30015,
    "name": "각성",
    "imageName": "epic/rapier/30015.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "전투를 지속할수록 사용자의 감각을 깨워 점점 강해지는 무기.",
    "baseLevel": 1300,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 42.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "감각 깨우기",
        "skill_type": "passive",
        "skill_description": "사용자의 감각을 깨워 점점 강해진다.",
        "skill_description_detail": "공격 시 5초간 공격력 +5%, 최대 20중첩",
        "skill_effect": [
          {
            "effect_name": "applyStackingBuff",
            "params": {
              "trigger": "onHit",
              "duration": 5,
              "maxStacks": 20,
              "stat": "damage",
              "increasePerStack": 0.05,
              "isMultiplicative": True
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30016,
    "name": "질풍",
    "imageName": "epic/rapier/30016.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 바람마법이 각인된 무기. 더블어택 확률이 대폭 증가한다.",
    "baseLevel": 1400,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 44.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "속공",
        "skill_type": "passive",
        "skill_description": "바람마법으로 매우 빠르게 공격한다.",
        "skill_description_detail": "더블 어택 확률 +15%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "doubleAttackChance",
              "value": 0.15,
              "isMultiplicative": False
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30017,
    "name": "광부",
    "imageName": "epic/rapier/30017.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강화석 탐지 기능이 있어 특이한 이명이 생긴 무기. 강화석 획득량이 증가한다.",
    "baseLevel": 1500,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 46.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "강화석 탐지",
        "skill_type": "passive",
        "skill_description": "강화석이 있는 곳을 탐지한다.",
        "skill_description_detail": "강화석 획득 시 추가 획득량 +3",
        "skill_effect": [
          {
            "effect_name": "applyPassiveEnhancementStoneGainBoost",
            "params": { "flatBonus": 3 }
          }
        ]
      }
    ]
  },
  {
    "id": 30018,
    "name": "눈꽃",
    "imageName": "epic/rapier/30018.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 얼음마법이 각인된 무기. 공격시 일정 확률로 적을 얼린다.",
    "baseLevel": 1500,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 50.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "냉기 주입",
        "skill_type": "passive",
        "skill_description": "서린 냉기가 적을 얼린다.",
        "skill_description_detail": "공격 시 5% 확률로 5초간 빙결, 최대 데미지 643,000 ,쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyFreeze",
            "params": {
              "chance": 0.05,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 5,
              "maxDmg": 643000
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30019,
    "name": "반중력",
    "imageName": "epic/rapier/30019.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 중력마법이 각인된 무기. 매우 가벼워져 빠른 공격이 가능해진 만큼 위력이 약해진다.",
    "baseLevel": 1600,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 52.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "중력 각인",
        "skill_type": "passive",
        "skill_description": "무게의 제약에서 벗어나 공격 속도가 폭발적으로 증가하지만, 그 대가로 공격력이 감소한다.",
        "skill_description_detail": "공격속도 +200%, 공격력 -65%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatDebuff",
            "params": {
              "stat": "damage",
              "value": 0.65,
              "isMultiplicative": True
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "speed",
              "value": 3.0,
              "isMultiplicative": True
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30020,
    "name": "위풍당당",
    "imageName": "epic/rapier/30020.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "투신의 축복이 담겨있는 무기. 체력이 높은 적을 상대할 때 위력이 증가한다.",
    "baseLevel": 1700,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 54.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "투지",
        "skill_type": "active",
        "skill_description": "투신의 축복으로 체력이 높은 적을 상대할 때 추가 피해를 가한다.",
        "skill_description_detail": "체력이 50% 이상인 적 공격 시, 무기 공격력의 5% 추가 피해",
        "skill_effect": [
          {
            "effect_name": "applyHpConditionalBonusDamage",
            "params": {
              "chance": 1.0,
              "hpThreshold": 0.5,
              "condition": "ge",
              "multiplier": 0.05,
              "trigger": "onHit",
              "cooldown": 0
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30021,
    "name": "낙뢰",
    "imageName": "epic/rapier/30021.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 전기마법이 각인된 무기. 공격시 일정 확률로 적을 감전시킨다.",
    "baseLevel": 1800,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 58.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "방전",
        "skill_type": "active",
        "skill_description": "번개의 힘이 담긴 일격으로 적을 감전시킨다.",
        "skill_description_detail": "공격 시 5% 확률로 5초간 감전, 최대 데미지 125,000, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyShock",
            "params": {
              "chance": 0.05,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 5,
              "maxDmg": 125000
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30022,
    "name": "매의 눈",
    "imageName": "epic/rapier/30022.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "치명적 일격이 가능하도록 설계된 무기. 매의 눈과 같이 사냥감을 놓치지 않는다.",
    "baseLevel": 1900,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 60.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "날카로운 집중",
        "skill_type": "passive",
        "skill_description": "극도의 집중으로 치명타 확률과 적중률이 상승한다.",
        "skill_description_detail": "치명타 확률 +50%, 적중률 +10%",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "criticalChance",
              "value": 0.5,
              "isMultiplicative": False
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "accuracy",
              "value": 0.1,
              "isMultiplicative": True
            }
          }
        ]
      }
    ]
  },
  {
    "id": 30023,
    "name": "회유",
    "imageName": "epic/rapier/30022.png",
    "rarity": "Rarity.epic",
    "type": "WeaponType.rapier",
    "description": "강력한 정신계마법이 각인된 무기. 공격 시 적을 홀린다.",
    "baseLevel": 2000,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 62.0,
    "doubleAttackChance": 0.0,
    "baseSellPrice": 0,
    "enhancement": 0,
    "transcendence": 0,
    "investedGold": 0.0,
    "investedEnhancementStones": 0,
    "investedTranscendenceStones": 0,
    "stack": {
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "홀리기",
        "skill_type": "passive",
        "skill_description": "적을 매혹 상태로 만든다.",
        "skill_description_detail": "공격 시 5% 확률로 5초간 매혹, 적 피격시 방어력 2 감소, 쿨타임 5초",
        "skill_effect": [
          {
            "effect_name": "applyPoison",
            "params": {
              "chance": 0.05,
              "attackPerDefence": 2.0,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 5
            }
          }
        ]
      }
    ]
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

def generate_epic_weapons():
    all_epic_weapons = []
    
    base_speed = 1.0
    base_crit_chance = 0.1
    base_crit_damage = 1.5
    base_accuracy = 0.7

    for i, (korean_name, english_name) in enumerate(TYPE_MAP.items()):
        type_modifiers = WEAPON_TYPE_MODIFIERS[english_name]
        
        for base_weapon_template in BASE_EPIC_WEAPONS:
            new_weapon = copy.deepcopy(base_weapon_template)
            
            # Generate new ID based on weapon type index
            # The base ID for rapier is 30000, for the next type it will be 31000, and so on.
            new_weapon['id'] = base_weapon_template['id'] + (i * 1000)
            
            new_weapon['type'] = f'WeaponType.{english_name}'
            # Note: The original imageName has the type hardcoded. We update it.
            # e.g., "epic/rapier/30000.png" -> "epic/sword/31000.png"
            new_weapon['imageName'] = f'epic/{english_name}/{new_weapon["id"]}.png'
            
            # Recalculate stats based on weapon type modifiers
            new_weapon['speed'] = round(1.25 * base_speed * type_modifiers['speed_mult'], 2)
            new_weapon['criticalChance'] = round(1.1 * base_crit_chance * type_modifiers['crit_chance_mult'], 3)
            new_weapon['criticalDamage'] = round(1.5 * base_crit_damage * type_modifiers['crit_mult_mult'], 2)
            new_weapon['accuracy'] = round(base_accuracy * type_modifiers['accuracy_mult'], 3)

            # Recalculate base damage if it's based on level, otherwise keep the template's damage
            level = new_weapon['baseLevel']
            new_weapon['defensePenetration'] = round(level / 75 + 7, 0)

            if level == 0:
                new_weapon['baseSellPrice'] = 9000
            else:
                new_weapon['baseSellPrice'] = int(level * 900)
            damage_mult = type_modifiers.get('damage_mult', 1)

            if base_weapon_template.get('baseDamage', 0) == 0: # If baseDamage is 0 in template
                if level == 0:
                    damage = 50 * 1.2 * 1.25 * damage_mult # User's requested fixed value
                    new_weapon['baseDamage'] = int(damage)
                elif level > 0:
                    # Original formula for level > 0
                    damage = (0.08 * (level ** 1.75) + 7 * level + 10) * 1.2 * 1.25 * damage_mult
                    new_weapon['baseDamage'] = int(damage)
            else:
                # Keep the original baseDamage from the template if it was specified (i.e., not 0)
                new_weapon['baseDamage'] = base_weapon_template.get('baseDamage', 0)

            all_epic_weapons.append(new_weapon)

    return all_epic_weapons

def main():
    # Ensure the script can be run from anywhere by using absolute paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(script_dir, '..', 'assets', 'data', 'epic_weapons.json')
    
    epic_weapons = generate_epic_weapons()
    
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(epic_weapons, f, ensure_ascii=False, indent=2)
        print(f'Successfully saved {len(epic_weapons)} epic weapons to {output_path}')
    except IOError as e:
        print(f'Error writing {output_path}: {e}')

if __name__ == '__main__':
    main()