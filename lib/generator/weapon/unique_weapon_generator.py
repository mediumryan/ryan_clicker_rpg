import json
import copy
import os

# --- 베이스 유니크 무기 데이터 ---
BASE_UNIQUE_WEAPONS = [
  {
    "id": 10000,
    "name": "첫걸음",
    "imageName": "unique/rapier/10000.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "초보 모험가들의 인기상품 입니다.",
    "baseLevel": 0,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 1.0,
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
        "skill_name": "순조로운 시작",
        "skill_type": "passive",
        "skill_description": "전투 시작 시 5초간 공격력이 30% 증가 합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyStatBoost",
            "params": {
              "stat": "damage",
              "value": 1.3,
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
    "id": 10001,
    "name": "장식용 레이피어",
    "imageName": "unique/rapier/10001.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "장식용이지만 쓸만한 무기입니다. 행운을 불러온다는 소문이 있습니다.",
    "baseLevel": 50,
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
        "skill_name": "관상용 무구",
        "skill_type": "passive",
        "skill_description": "골드 획득량이 25% 증가 합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyGoldGainBoost",
            "params": { "multiplier": 1.25 }
          }
        ]
      }
    ]
  },
  {
    "id": 10002,
    "name": "수작",
    "imageName": "unique/rapier/10002.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "대장장이 윌터의 수작 중 하나로, 마감이 그럭저럭 잘 되어있습니다.",
    "baseLevel": 50,
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
        "skill_name": "나름 쓸만한 작품",
        "skill_type": "passive",
        "skill_description": "공격력이 15% 증가합니다. 공격속도가 15% 증가합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "damage",
              "value": 1.15,
              "isMultiplicative": True
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "speed",
              "value": 1.15,
              "isMultiplicative": True
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10003,
    "name": "독초",
    "imageName": "unique/rapier/10003.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "소량의 맹독이 함유되어있는 무기 입니다. 중독되지 않도록 취급에 주의해야 합니다.",
    "baseLevel": 100,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 5.0,
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
        "skill_description": "공격 시 2.5% 확률로 적을 5초간 중독 상태로 만듭니다. 쿨타임 10초",
        "skill_description_detail": "중독 : 초당 최대 체력의 2.5% 피해를 입힙니다. 최대 데미지 11,300",
        "skill_effect": [
          {
            "effect_name": "applyPoison",
            "params": {
              "chance": 0.05,
              "percentPerSecond": 0.025,
              "maxDmg": 11300,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 10
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10004,
    "name": "괴력",
    "imageName": "unique/rapier/10004.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "매우 무거운 소재로 만들어진 무기 입니다. 일반인은 들기조차 버겁습니다.",
    "baseLevel": 200,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 6.0,
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
        "skill_name": "과중량",
        "skill_type": "passive",
        "skill_description": "공격력이 30% 증가합니다. 공격속도가 30% 감소합니다.",
        "skill_description_detail": "",
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
              "value": 1.3,
              "isMultiplicative": True
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10005,
    "name": "불씨",
    "imageName": "unique/rapier/10005.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "미약한 화염마법이 각인되어있어 낮은 확률로 적을 불태울 수 있는 무기입니다.",
    "baseLevel": 300,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 7.0,
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
        "skill_description": "공격 시 2.5% 확률로 적을 5초간 화상 상태로 만듭니다. 쿨타임 10초",
        "skill_description_detail": "화상 - 초당 24,500의 피해를 입힙니다.",
        "skill_effect": [
          {
            "effect_name": "applyBurn",
            "params": {
              "chance": 0.05,
              "duration": 5,
              "fixedDamagePerSecond": 24500,
              "stackable": False,
              "trigger": "onHit",
              "cooldown": 10
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10006,
    "name": "갈증",
    "imageName": "unique/rapier/10006.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "적을 처치할 수록 강해지는 무기입니다.",
    "baseLevel": 400,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 9.0,
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
      "damagePerStack": 30
    },
    "skills": [
      {
        "skill_name": "수혈",
        "skill_type": "active",
        "skill_description": "적 처치 시 무기의 공격력이 30씩 증가합니다.",
        "skill_description_detail": "최대 중첩 - 100회",
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
    "id": 10007,
    "name": "약점",
    "imageName": "unique/rapier/10007.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "상대의 약점을 노릴 수 있도록 날카롭게 설계된 무기입니다.",
    "baseLevel": 500,
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
        "skill_name": "약점 간파",
        "skill_type": "active",
        "skill_description": "공격 시 2.5% 확률로 적을 5초간 무장해제 상태로 만듭니다. 쿨타임 10초",
        "skill_description_detail": "무장해제 - 방어력 25 감소",
        "skill_effect": [
          {
            "effect_name": "applyDisarm",
            "params": {
              "chance": 0.05,
              "defenseReduction": 25,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 10
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10008,
    "name": "급소",
    "imageName": "unique/rapier/10008.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "적에게 치명적인 공격이 가능하도록 설계된 무기입니다.",
    "baseLevel": 600,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 11.0,
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
        "skill_name": "급소 공략",
        "skill_type": "passive",
        "skill_description": "치명타 배율이 3배 증가합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "criticalDamage",
              "value": 3.0,
              "isMultiplicative": False
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10009,
    "name": "가시",
    "imageName": "unique/rapier/10009.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "거칠게 연마된 무기로 적에게 출혈을 유도합니다.",
    "baseLevel": 700,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 13.0,
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
        "skill_name": "찢어발기기",
        "skill_type": "passive",
        "skill_description": "공격 시 2.5% 확률로 5초간 적을 출혈 상태로 만듭니다. 쿨타임 10초",
        "skill_description_detail": "출혈 - 초당 94,300 피해",
        "skill_effect": [
          {
            "effect_name": "applyBleed",
            "params": {
              "chance": 0.05,
              "duration": 5,
              "damagePerSecond": 94300,
              "stackable": False,
              "trigger": "onHit",
              "cooldown": 10
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10010,
    "name": "안개",
    "imageName": "unique/rapier/10010.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "적을 혼란에 빠뜨려 전투에 도움을 주는 무기입니다.",
    "baseLevel": 800,
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
        "skill_name": "혼란한 시야",
        "skill_type": "active",
        "skill_description": "공격 시 2.5% 확률로 적을 5초간 혼란 상태로 만듭니다. 쿨타임 10초",
        "skill_description_detail": "혼란 - 적의 피격 데미지 25% 증가",
        "skill_effect": [
          {
            "effect_name": "applyConfusion",
            "params": {
              "chance": 0.05,
              "duration": 3,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 10
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10011,
    "name": "사신",
    "imageName": "unique/rapier/10011.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "",
    "baseLevel": 900,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 15.0,
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
        "skill_name": "죽음 선사",
        "skill_type": "active",
        "skill_description": "공격 시 0.44% 확률로 적에게 죽음을 선사합니다. 쿨타임 10초",
        "skill_description_detail": "죽음선사 - 몬스터의 최대 체력의 100% 데미지(보스 몬스터의 경우 1/3 적용). 최대 데미지 1,500,000",
        "skill_effect": [
          {
            "effect_name": "applyPercentageMaxHealthDamage",
            "params": {
              "chance": 0.0044,
              "percentDamage": 1,
              "trigger": "onHit",
              "maxDmg": 1500000,
              "cooldown": 10
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10012,
    "name": "대작",
    "imageName": "unique/rapier/10012.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "대장장이 윌터의 대작 중 하나로, 마감이 뛰어납니다.",
    "baseLevel": 1000,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 17.0,
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
        "skill_name": "훌륭한 작품",
        "skill_type": "passive",
        "skill_description": "공격력이 15% 증가합니다. 공격속도가 15% 증가합니다. 치명타 확률이 +10% 증가합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "damage",
              "value": 1.15,
              "isMultiplicative": True
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "speed",
              "value": 1.15,
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
          }
        ]
      }
    ]
  },
  {
    "id": 10013,
    "name": "포식자",
    "imageName": "unique/rapier/10013.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "체력이 낮은 적에게 더 많은 피해를 주는 특수한 무기입니다.",
    "baseLevel": 1100,
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
      "enabled": False,
      "currentStacks": 0,
      "maxStacks": 0,
      "damagePerStack": 0
    },
    "skills": [
      {
        "skill_name": "사냥 본능",
        "skill_type": "active",
        "skill_description": "체력이 50% 이하인 적을 공격 시 공격력의 2.5%에 해당하는 추가 피해를 입힙니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyHpConditionalBonusDamage",
            "params": {
              "chance": 1.0,
              "hpThreshold": 0.5,
              "condition": "le",
              "multiplier": 0.025,
              "trigger": "onHit",
              "cooldown": 0
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10014,
    "name": "충격",
    "imageName": "unique/rapier/10014.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "미약한 대지마법이 각인되어있어, 낮을 확률로 충격파를 발산하는 무기입니다.",
    "baseLevel": 1200,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 19.0,
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
        "skill_description": "공격 시 2.5% 확률로 공격력의 10배의 피해를 입힙니다. 쿨타임 10초",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyMultiplierDamage",
            "params": {
              "chance": 0.05,
              "trigger": "onHit",
              "multiplier": 10.0,
              "cooldown": 10
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10015,
    "name": "인내",
    "imageName": "unique/rapier/10015.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "",
    "baseLevel": 1300,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 21.0,
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
        "skill_name": "담금질",
        "skill_type": "passive",
        "skill_description": "공격 시 5초간 공격력 2.5% 증가",
        "skill_description_detail": "최대중첩 - 20회",
        "skill_effect": [
          {
            "effect_name": "applyStackingBuff",
            "params": {
              "trigger": "onHit",
              "duration": 2.5,
              "maxStacks": 20,
              "stat": "damage",
              "increasePerStack": 0.025,
              "isMultiplicative": True
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10016,
    "name": "날개",
    "imageName": "unique/rapier/10016.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "미약한 바람마법이 각인되어있는 무기입니다. 더블어택 확률이 소폭 증가합니다.",
    "baseLevel": 1400,
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
        "skill_name": "속공",
        "skill_type": "passive",
        "skill_description": "더블 어택 확률이 7.5% 증가합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "doubleAttackChance",
              "value": 0.075,
              "isMultiplicative": False
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10017,
    "name": "고급 장식용 레이피어",
    "imageName": "unique/rapier/10017.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "장식용이지만 실전에서도 사용 가능한 훌륭한 무기입니다. 골드를 끌어들이는 힘이 있습니다.",
    "baseLevel": 1500,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 23.0,
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
        "skill_name": "고급 관상용 무구",
        "skill_type": "passive",
        "skill_description": "골드 획득량이 77% 증가합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyGoldGainBoost",
            "params": { "multiplier": 1.77 }
          }
        ]
      }
    ]
  },
  {
    "id": 10018,
    "name": "눈꽃",
    "imageName": "unique/rapier/10018.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "미약한 얼음마법이 각인되어있어, 낮은 확률로 적을 얼릴 수 있는 무기입니다.",
    "baseLevel": 1500,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 25.0,
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
        "skill_description": "공격 시 2.5% 확률로 적을 5초간 빙결 상태로 만듭니다. 쿨타임 10초",
        "skill_description_detail": "빙결 - 피격시 최대 체력의 25%에 해당하는 추가 피해(보스 몬스터의 경우 1/2 적용). 최대 데미지 643,000",
        "skill_effect": [
          {
            "effect_name": "applyFreeze",
            "params": {
              "chance": 0.05,
              "duration": 3,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 10,
              "maxDmg": 643000
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10019,
    "name": "경량",
    "imageName": "unique/rapier/10019.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "매우 가벼운 소재로 만들어진 무기입니다. 위력을 포기하고 속도에 중점을 두었습니다.",
    "baseLevel": 1600,
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
        "skill_name": "경금속 재질",
        "skill_type": "passive",
        "skill_description": "공격력이 60% 감소합니다. 공격속도가 100% 증가합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatDebuff",
            "params": {
              "stat": "damage",
              "value": 0.4,
              "isMultiplicative": True
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "speed",
              "value": 2.0,
              "isMultiplicative": True
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10020,
    "name": "대담함",
    "imageName": "unique/rapier/10020.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "체력이 높은 적에게 더 많은 피해를 주는 특수한 무기입니다.",
    "baseLevel": 1700,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 27.0,
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
        "skill_description": "체력이 50% 이상인 적을 공격 시 공격력의 2.5%에 해당하는 추가 피해를 입힙니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyHpConditionalBonusDamage",
            "params": {
              "chance": 1.0,
              "hpThreshold": 0.5,
              "condition": "ge",
              "multiplier": 0.025,
              "trigger": "onHit",
              "cooldown": 0
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10021,
    "name": "전류",
    "imageName": "unique/rapier/10021.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "미약한 전기마법이 각인되어있어, 낮을 확률로 적을 감전시킬 수 있습니다.",
    "baseLevel": 1800,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 29.0,
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
        "skill_description": "공격 시 2.5% 확률로 적을 5초간 감전 상태로 만듭니다. 쿨타임 10초",
        "skill_description_detail": "감전 - 피격시 최대 체력의 3%에 해당하는 추가피해(보스 몬스터의 경우 1/2 적용). 최대 데미지 62,500, ",
        "skill_effect": [
          {
            "effect_name": "applyShock",
            "params": {
              "chance": 0.05,
              "duration": 5,
              "trigger": "onHit",
              "stackable": False,
              "cooldown": 10,
              "maxDmg": 62500
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10022,
    "name": "예리함",
    "imageName": "unique/rapier/10022.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "매우 예리하게 벼려진 무기입니다. 치명타 확률이 증가합니다.",
    "baseLevel": 1900,
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
        "skill_name": "날카로운 일격",
        "skill_type": "passive",
        "skill_description": "치명타 확률이 25% 증가합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "criticalChance",
              "value": 0.25,
              "isMultiplicative": False
            }
          }
        ]
      }
    ]
  },
  {
    "id": 10023,
    "name": "걸작",
    "imageName": "unique/rapier/10022.png",
    "rarity": "Rarity.unique",
    "type": "WeaponType.rapier",
    "description": "대장장이 윌터의 걸작 중 하나로, 마감이 완벽합니다.",
    "baseLevel": 2000,
    "baseDamage": 0,
    "speed": 1.43,
    "criticalChance": 0.18,
    "criticalDamage": 1.42,
    "accuracy": 0.784,
    "defensePenetration": 31.0,
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
        "skill_name": "마스터피스",
        "skill_type": "passive",
        "skill_description": "공격력이 25% 증가합니다. 공격속도가 25% 증가합니다. 치명타 확률이 +10% 증가합니다.",
        "skill_description_detail": "",
        "skill_effect": [
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "damage",
              "value": 1.25,
              "isMultiplicative": True
            }
          },
          {
            "effect_name": "applyPassiveStatBoost",
            "params": {
              "stat": "speed",
              "value": 1.25,
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

def generate_unique_weapons():
    all_unique_weapons = []
    
    base_speed = 1.0
    base_crit_chance = 0.1
    base_crit_damage = 1.5
    base_accuracy = 0.7

    for i, (type_ko, type_key) in enumerate(TYPE_MAP.items()):
        type_modifiers = WEAPON_TYPE_MODIFIERS[type_key]
        
        for base_weapon_template in BASE_UNIQUE_WEAPONS:
            new_weapon = copy.deepcopy(base_weapon_template)
            
            # Generate new ID based on weapon type index
            # The base ID for rapier is 10000, for the next type it will be 11000, and so on.
            new_weapon['id'] = base_weapon_template['id'] + (i * 1000)
            
            new_weapon['type'] = f'WeaponType.{type_key}'
            # Note: The original imageName has the type hardcoded. We update it.
            # e.g., "unique/rapier/10000.png" -> "unique/sword/11000.png"
            new_weapon['imageName'] = f'unique/{type_key}/{new_weapon["id"]}.png'
            
            # Special handling for specific weapon names that include the weapon type
            if '장식용 레이피어' in base_weapon_template['name']:
                new_weapon['name'] = base_weapon_template['name'].replace('레이피어', type_ko)
            # Other names like "첫걸음" will be the same across all weapon types

            # Recalculate stats based on weapon type modifiers
            new_weapon['speed'] = round(1.1 * base_speed * type_modifiers['speed_mult'], 2)
            new_weapon['criticalChance'] = round(base_crit_chance * type_modifiers['crit_chance_mult'], 3)
            new_weapon['criticalDamage'] = round(base_crit_damage * type_modifiers['crit_mult_mult'], 2)
            new_weapon['accuracy'] = round(base_accuracy * type_modifiers['accuracy_mult'], 3)

            # Recalculate base damage if it's based on level, otherwise keep the template's damage
            level = new_weapon['baseLevel']
            new_weapon['defensePenetration'] = round(level / 100 + 3, 0)

            if level == 0:
                new_weapon['baseSellPrice'] = 3000
            else:
                new_weapon['baseSellPrice'] = int(1000 + (level * 300))
            damage_mult = type_modifiers.get('damage_mult', 1)

            if base_weapon_template.get('baseDamage', 0) == 0: # If baseDamage is 0 in template
                if level == 0:
                    damage = 50 * 1.2 * 1.1 * damage_mult # User's requested fixed value
                    new_weapon['baseDamage'] = int(damage)
                elif level > 0:
                    # Original formula for level > 0
                    damage = (0.08 * (level ** 1.75) + 7 * level + 10) * 1.2 * 1.1 * damage_mult
                    new_weapon['baseDamage'] = int(damage)
            else:
                # Keep the original baseDamage from the template if it was specified (i.e., not 0)
                new_weapon['baseDamage'] = base_weapon_template.get('baseDamage', 0)

            all_unique_weapons.append(new_weapon)

    return all_unique_weapons

def main():
    # Ensure the script can be run from anywhere by using absolute paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(script_dir)))
    output_path = os.path.join(project_root, 'assets', 'data', 'unique_weapons.json')
    
    unique_weapons = generate_unique_weapons()
    
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(unique_weapons, f, ensure_ascii=False, indent=2)
        print(f'Successfully saved {len(unique_weapons)} unique weapons to {output_path}')
    except IOError as e:
        print(f'Error writing {output_path}: {e}')

if __name__ == '__main__':
    main()