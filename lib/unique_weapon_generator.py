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
        "description": "많은 초보 모험가와 함께한 인기 무기 중 하나. 무기에 깃든 힘이 사용자에게 전투의지를 불어넣는다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "격려", "skill_type": "passive", "skill_description": "무기에 깃든 희미한 기운이 사용자를 격려한다. ", "skill_description_detail": "전투 시작 시 3초간 공격력 +15%", "skill_effect": [ { "effect_name": "applyStatBoost", "params": { "stat": "damage", "value": 1.15, "isMultiplicative": True, "duration": 3, "trigger": "stageStart" } } ] } ]
    },
    {
        "id": 10001,
        "name": "장식용 레이피어",
        "imageName": "unique/rapier/10001.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "고급 장식이 달린 관상용품. 골드 획득량이 소폭 증가한다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "관상용 무구", "skill_type": "passive", "skill_description": "소지하는 것만으로도 행운을 불러온다. ", "skill_description_detail": "골드 획득량 +25%", "skill_effect": [ { "effect_name": "applyGoldGainBoost", "params": { "multiplier": 1.25 } } ] } ]
    },
    {
        "id": 10002,
        "name": "수작",
        "imageName": "unique/rapier/10002.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "대장장이 윌터의 수작 중 하나. 마감이 우수하다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "괜찮은 작품", "skill_type": "passive", 
                     "skill_description": "대장장이의 우수한 실력으로 무기의 능력이 약간 상승한다. ", 
                     "skill_description_detail": "공격력 +10%, 공격속도 +10%", 
                     "skill_effect": 
                     [ 
                         { 
                             "effect_name": "applyPassiveStatBoost", 
                             "params": { 
                                 "stat": "damage", 
                                 "value": 1.1, "isMultiplicative": True } }, { "effect_name": "applyPassiveStatBoost", "params": { "stat": "speed", "value": 1.1, "isMultiplicative": True } } ] } ]
    },
    {
        "id": 10003,
        "name": "독초",
        "imageName": "unique/rapier/10003.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "소량의 독이 함유되어있는 무기. 취급에 주의해야 한다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "맹독 주입", "skill_type": "active", "skill_description": "치명적인 맹독을 주입한다. ", "skill_description_detail": "공격 시 2.5% 확률로 3초간 중독, 초당 최대 체력의 2.5% 피해, 최대 데미지 11,300, 쿨타임 5초", "skill_effect": [ { "effect_name": "applyPoison", "params": { "chance": 0.025, "percentPerSecond": 0.025, "maxDmg": 11300, "duration": 3, "trigger": "onHit", "stackable": False, "cooldown": 5 } } ] } ]
    },
    {
        "id": 10004,
        "name": "괴력",
        "imageName": "unique/rapier/10004.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "매우 무거운 소재로 만들어진 무기. 일반인은 들기조차 버겁다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "중금속 재질", "skill_type": "passive", "skill_description": "공격력이 증가하는 반면, 공격속도가 감소한다.", "skill_description_detail": "공격력 +30, 공격속도 -30%", "skill_effect": [ { "effect_name": "applyPassiveStatDebuff", "params": { "stat": "speed", "value": 0.7, "isMultiplicative": True } }, { "effect_name": "applyPassiveStatBoost", "params": { "stat": "damage", "value": 1.3, "isMultiplicative": True } } ] } ]
    },
    {
        "id": 10005,
        "name": "불씨",
        "imageName": "unique/rapier/10005.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "미약한 화염마법이 각인되어있는 무기. 낮을 확률로 적을 불태운다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "열 주입", "skill_type": "passive", "skill_description": "뜨거운 열기가 적을 불태운다.", "skill_description_detail": "공격 시 2.5% 확률로 3초간 화상, 초당 24,500 피해, 쿨타임 5초", "skill_effect": [ { "effect_name": "applyBurn", "params": { "chance": 0.025, "duration": 3, "fixedDamagePerSecond": 24500, "stackable": False, "trigger": "onHit", "cooldown": 5 } } ] } ]
    },
    {
        "id": 10006,
        "name": "갈증",
        "imageName": "unique/rapier/10006.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "미약한 흑마법이 각인되어있는 무기. 적을 처치할 수록 강해진다.",
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
        "stack": { "enabled": True, "currentStacks": 0, "maxStacks": 100, "damagePerStack": 30 },
        "skills": [ { "skill_name": "갈증 해소", "skill_type": "active", "skill_description": "처치한 적의 목숨을 수확한다.", "skill_description_detail": "적 처치 시 무기 공격력 +30, 최대 100중첩", "skill_effect": [ { "effect_name": "increaseStat", "params": { "stat": "stack.currentStacks", "increment": 1 } } ] } ]
    },
    {
        "id": 10007,
        "name": "약점",
        "imageName": "unique/rapier/10007.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "약점 간파", "skill_type": "active", "skill_description": "정확한 타점으로 적의 약점을 파고든다.", "skill_description_detail": "공격 시 2.5% 확률로 3초간 무장 해제, 방어력 25 감소, 쿨타임 5초", "skill_effect": [ { "effect_name": "applyDisarm", "params": { "chance": 0.025, "defenseReduction": 25, "duration": 3, "trigger": "onHit", "stackable": False, "cooldown": 5 } } ] } ]
    },
    {
        "id": 10008,
        "name": "파괴",
        "imageName": "unique/rapier/10008.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "적을 처치하는데 탁월한 형태를 지닌 무기. 치명타 배율이 대폭 상승한다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "집중타격", "skill_type": "passive", "skill_description": "치명타 배율이 대폭 상승한다.", "skill_description_detail": "치명타 배율 +1.5배", "skill_effect": [ { "effect_name": "applyPassiveStatBoost", "params": { "stat": "criticalDamage", "value": 1.5, "isMultiplicative": False } } ] } ]
    },
    {
        "id": 10009,
        "name": "가시",
        "imageName": "unique/rapier/10009.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "거칠게 연마된 무기. 적에게 출혈을 유도한다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "찢어발기기", "skill_type": "passive", "skill_description": "거친 날과 면으로 스치기만 해도 적에게 자상을 입힌다.", "skill_description_detail": "공격 시 2.5% 확률로 3초간 출혈, 초당 94,300 피해, 쿨타임 5초", "skill_effect": [ { "effect_name": "applyBleed", "params": { "chance": 0.025, "duration": 3, "damagePerSecond": 94300, "stackable": False, "trigger": "onHit", "cooldown": 5 } } ] } ]
    },
    {
        "id": 10010,
        "name": "잔상",
        "imageName": "unique/rapier/10010.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "미약한 흑마법이 각인되어있는 무기. 간혹 적에게 환각을 보여준다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "혼란한 시야", "skill_type": "active", "skill_description": "환각을 소환해 적을 혼란하게 만든다.", "skill_description_detail": "공격 시 2.5% 확률로 3간 혼란, 쿨타임 5초", "skill_effect": [ { "effect_name": "applyConfusion", "params": { "chance": 0.025, "duration": 3, "trigger": "onHit", "stackable": False, "cooldown": 5 } } ] } ]
    },
    {
        "id": 10011,
        "name": "행운",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "럭키펀치", "skill_type": "active", "skill_description": "아주 낮은 확률로 치명적인 일격을 가한다.", "skill_description_detail": "공격 시 0.77% 확률로 적 최대 체력의 100% 피해, 최대 1,500,000, 쿨타임 5초", "skill_effect": [ { "effect_name": "applyPercentageMaxHealthDamage", "params": { "chance": 0.0077, "percentDamage": 1, "trigger": "onHit", "maxDmg": 1500000, "cooldown": 5 } } ] } ]
    },
    {
        "id": 10012,
        "name": "대작",
        "imageName": "unique/rapier/10012.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "대장장이 윌터의 대작 중 하나. 마감이 뛰어나다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "훌륭한 작품", "skill_type": "passive", "skill_description": "대장장이의 우수한 실력으로 무기의 능력이 상승한다.", "skill_description_detail": "공격력 +15%, 공격속도 +15% 치명타 확률 +5%", "skill_effect": [ { "effect_name": "applyPassiveStatBoost", "params": { "stat": "damage", "value": 1.15, "isMultiplicative": True } }, { "effect_name": "applyPassiveStatBoost", "params": { "stat": "speed", "value": 1.15, "isMultiplicative": True } }, { "effect_name": "applyPassiveStatBoost", "params": { "stat": "criticalChance", "value": 0.05, "isMultiplicative": False } } ] } ]
    },
    {
        "id": 10013,
        "name": "포식자",
        "imageName": "unique/rapier/10013.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "약화된 적의 숨통을 끊기 쉬운 구조로 되어있는 무기.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "사냥 본능", "skill_type": "active", "skill_description": "체력이 약해진 적을 상대할 때 추가 피해를 가한다.", "skill_description_detail": "체력이 50% 이하인 적 공격 시, 무기 공격력의 2.5% 추가 피해", "skill_effect": [ { "effect_name": "applyHpConditionalBonusDamage", "params": { "chance": 1.0, "hpThreshold": 0.5, "condition": "le", "multiplier": 0.025, "trigger": "onHit", "cooldown": 0 } } ] } ]
    },
    {
        "id": 10014,
        "name": "충격",
        "imageName": "unique/rapier/10014.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "미약한 대지마법이 각인되어있는 무기. 낮을 확률로 충격파를 발산한다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "충격파", "skill_type": "active", "skill_description": "공격과 동시에 충격파를 발산한다.", "skill_description_detail": "공격 시 2.5% 확률로 660,000 추가 피해, 쿨타임 5초", "skill_effect": [ { "effect_name": "applyFixedDamage", "params": { "chance": 0.025, "damage": 660000, "cooldown": 5, "trigger": "onHit" } } ] } ]
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "담금질", "skill_type": "passive", "skill_description": "전투를 지속하며 무기가 강해진다.", "skill_description_detail": "공격 시 2.5초간 공격력 +1.5%, 최대 20중첩", "skill_effect": [ { "effect_name": "applyStackingBuff", "params": { "trigger": "onHit", "duration": 2.5, "maxStacks": 20, "stat": "damage", "increasePerStack": 0.015, "isMultiplicative": True } } ] } ]
    },
    {
        "id": 10016,
        "name": "날개",
        "imageName": "unique/rapier/10016.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "미약한 바람마법이 각인되어있는 무기. 더블어택이 가능해진다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "속공", "skill_type": "passive", "skill_description": "바람마법으로 매우 빠르게 공격한다.", "skill_description_detail": "더블 어택 확률 +7.5%", "skill_effect": [ { "effect_name": "applyPassiveStatBoost", "params": { "stat": "doubleAttackChance", "value": 0.075, "isMultiplicative": False } } ] } ]
    },
    {
        "id": 10017,
        "name": "고급 장식용 레이피어",
        "imageName": "unique/rapier/10017.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "고급 장식이 달린 관상용품. 골드 획득량이 증가한다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "고급 관상용 무구", "skill_type": "passive", "skill_description": "소지하는 것만으로도 행운을 불러온다.", "skill_description_detail": "골드 획득량 +77%", "skill_effect": [ { "effect_name": "applyGoldGainBoost", "params": { "multiplier": 1.77 } } ] } ]
    },
    {
        "id": 10018,
        "name": "눈꽃",
        "imageName": "unique/rapier/10018.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "미약한 바람마법이 각인되어있는 무기. 낮은 확률로 적을 얼린다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "냉기 주입", "skill_type": "passive", "skill_description": "서린 냉기가 적을 얼린다.", "skill_description_detail": "공격 시 2.5% 확률로 3초간 빙결, 최대 데미지 643,000 ,쿨타임 5초", "skill_effect": [ { "effect_name": "applyFreeze", "params": { "chance": 0.025, "duration": 3, "trigger": "onHit", "stackable": False, "cooldown": 5, "maxDmg" : 643000 } } ] } ]
    },
    {
        "id": 10019,
        "name": "경량",
        "imageName": "unique/rapier/10019.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "매우 가벼운 소재로 만들어진 무기. 날렵한 공격이 가능해지지만 그만큼 위력도 함께 떨어진다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "경금속 재질", "skill_type": "passive", "skill_description": "공격속도가 증가하는 반면, 공격력이 감소한다.", "skill_description_detail": "공격속도 +100%, 공격력 -50%", "skill_effect": [ { "effect_name": "applyPassiveStatDebuff", "params": { "stat": "damage", "value": 0.5, "isMultiplicative": True } }, { "effect_name": "applyPassiveStatBoost", "params": { "stat": "speed", "value": 2.0, "isMultiplicative": True } } ] } ]
    },
    {
        "id": 10020,
        "name": "대담함",
        "imageName": "unique/rapier/10020.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "특수한 각인이 새겨져 있는 무기. 체력이 높은 적을 상대할 때 진가를 발휘한다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "투지", "skill_type": "active", "skill_description": "투신의 축복으로 체력이 높은 적을 상대할 때 추가 피해를 가한다.", "skill_description_detail": "체력이 50% 이상인 적 공격 시, 무기 공격력의 2.5% 추가 피해", "skill_effect": [ { "effect_name": "applyHpConditionalBonusDamage", "params": { "chance": 1.0, "hpThreshold": 0.5, "condition": "ge", "multiplier": 0.025, "trigger": "onHit", "cooldown": 0 } } ] } ]
    },
    {
        "id": 10021,
        "name": "전류",
        "imageName": "unique/rapier/10021.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "미약한 전기마법이 각인되어있는 무기. 낮을 확률로 적을 감전시킨다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "방전", "skill_type": "active", 
                     "skill_description": "번개의 힘이 담긴 일격으로 적을 감전시킨다.", 
                     "skill_description_detail": "공격 시 2.5% 확률로 3초간 감전, 최대 데미지 62,500, 쿨타임 5초", "skill_effect": [ { "effect_name": "applyShock", "params": { "chance": 0.025, "duration": 3, "trigger": "onHit", "stackable": False, "cooldown": 5, "maxDmg" : 62500 } } ] } ]
    },
    {
        "id": 10022,
        "name": "예리함",
        "imageName": "unique/rapier/10022.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "치명적 일격이 가능하도록 설계된 무기. 매우 예리하다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "날카로운 일격", "skill_type": "passive", "skill_description": "무기 구조상 평범한 일격도 치명타가 될 수 있도록 설계되어 있다.", "skill_description_detail": "치명타 확률 +30%", "skill_effect": [ { "effect_name": "applyPassiveStatBoost", "params": { "stat": "criticalChance", "value": 0.3, "isMultiplicative": False } } ] } ]
    },
    {
        "id": 10023,
        "name": "걸작",
        "imageName": "unique/rapier/10022.png",
        "rarity": "Rarity.unique",
        "type": "WeaponType.rapier",
        "description": "대장장이 윌터의 걸작 중 하나. 매우 정교하고 튼튼하다.",
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
        "stack": { "enabled": False, "currentStacks": 0, "maxStacks": 0, "damagePerStack": 0 },
        "skills": [ { "skill_name": "마스터피스", "skill_type": "passive", "skill_description": "평범한 대장장이는 일생일대 한자루도 만들 수 없을 정도로 잘 만들어진 걸작이다.", "skill_description_detail": "공격력 +25%, 공격속도 +30% 치명타 확률 +10%", "skill_effect": [ { "effect_name": "applyPassiveStatBoost", "params": { "stat": "damage", "value": 1.25, "isMultiplicative": True } }, { "effect_name": "applyPassiveStatBoost", "params": { "stat": "speed", "value": 1.30, "isMultiplicative": True } }, { "effect_name": "applyPassiveStatBoost", "params": { "stat": "criticalChance", "value": 0.1, "isMultiplicative": False } } ] } ]
    }
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
    output_path = os.path.join(script_dir, '..', 'assets', 'data', 'unique_weapons.json')
    
    unique_weapons = generate_unique_weapons()
    
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(unique_weapons, f, ensure_ascii=False, indent=2)
        print(f'Successfully saved {len(unique_weapons)} unique weapons to {output_path}')
    except IOError as e:
        print(f'Error writing {output_path}: {e}')

if __name__ == '__main__':
    main()