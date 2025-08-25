import json
import math

# --- Data Definitions ---

# Based on lib/models/weapon.dart
WEAPON_TYPES_KO = [
    "레이피어", "카타나", "검", "대검", "시미터", "단검", "도축칼",
    "전투도끼", "전투망치", "창", "지팡이", "삼지창", "메이스", "낫", "곡도", "쌍절곤"
]

# Mappings for English names
PREFIX_MAP = {
    "녹슨": "rusty", "평범한": "plain", "쓸만한": "decent"
}
SUFFIX_MAP = {
    "조잡한": "crude", "용병의": "mercenary", "고블린족의": "goblin",
    "기사단의": "knights", "리자드맨의": "lizardman", "엘프족의": "elf",
    "정령의 힘이 깃든": "elemental", "신성국의": "holy",
    "악마의 힘이 깃든": "demonic", "용의 힘이 깃든": "dragon"
}
TYPE_MAP = {
    "레이피어": "rapier", "카타나": "katana", "검": "sword",
    "대검": "greatsword", "시미터": "scimitar", "단검": "dagger",
    "도축칼": "cleaver",
    "전투도끼": "battleAxe",
    "전투망치": "warhammer",
    "창": "spear", "지팡이": "staff", "삼지창": "trident",
    "메이스": "mace", "낫": "scythe",
    "곡도": "curvedSword",
    "쌍절곤": "nunchaku"
}

# New TIERS_DATA based on user's suffixes and my base_level progression
TIERS_DATA = [
    {"name_ko": "조잡한", "name_en": "crude", "base_level": 0},
    {"name_ko": "용병의", "name_en": "mercenary", "base_level": 75},
    {"name_ko": "고블린족의", "name_en": "goblin", "base_level": 150},
    {"name_ko": "기사단의", "name_en": "knights", "base_level": 225},
    {"name_ko": "리자드맨의", "name_en": "lizardman", "base_level": 300},
    {"name_ko": "엘프족의", "name_en": "elf", "base_level": 375},
    {"name_ko": "정령의 힘이 깃든", "name_en": "elemental", "base_level": 450},
    {"name_ko": "신성국의", "name_en": "holy", "base_level": 525},
    {"name_ko": "악마의 힘이 깃든", "name_en": "demonic", "base_level": 600},
    {"name_ko": "용의 힘이 깃든", "name_en": "dragon", "base_level": 675},
]

# New QUALITIES_DATA based on user's prefixes and my stat_mult/level_add
QUALITIES_DATA = [
    {"name_ko": "녹슨", "name_en": "rusty", "level_add": 0, "stat_mult": 0.8},
    {"name_ko": "평범한", "name_en": "plain", "level_add": 25, "stat_mult": 1.0},
    {"name_ko": "쓸만한", "name_en": "decent", "level_add": 50, "stat_mult": 1.2},
]

# Base stats for each baseLevel, extracted from user's provided weapons.json example
# Now with fixed criticalChance, criticalDamage, speed, and accuracy
BASE_LEVEL_STATS = {
    level: {
        'baseDamage': 100 if level == 0 else int(6.21 * level + 5),
        'criticalChance': 0.1,
        'criticalDamage': 1.35,
        'speed': 1.0,
        'accuracy': 1.0
    } for level in [0, 25, 50, 75, 100, 125, 150, 175, 200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500, 525, 550, 575, 600, 625, 650, 675, 700, 725]
}

# --- Formula Functions ---

def calculate_sell_price(level):
    """Calculates sell price based on an exponential formula."""
    return int(50 * math.pow(1.015, level))

# --- Unique Weapons Data (Hand-crafted) ---
UNIQUE_WEAPONS_RAW_DATA = [
    {
        "name": "벌새",
        "name_en": "Hummingbird",
        "description": "매우 가벼운 레이피어로, 시작의 마을 대장장이 윌터가 만든 수작 중 하나입니다. 빠르고 날렵한 공격이 특징입니다.",
        "rareity": "unique",
        "baselevel": 0,
        "basedamage": 52,
        "criticalChance": 0.1,
        "criticalMultiplier": 1.5,
        "DefensePenetration": 0,
        "DoubleAttack": 0.1,
        "speed": 1.75,
        "sellPrice": 10000,
        "skill": [
            {
                "skill_name": "더 빠르게",
                "skill_effect": "공격시 10% 확률로 두 번 타격합니다."
            }
        ]
    },
    {
        "name": "하얀 송곳니",
        "name_en": "White Fang",
        "description": "알파 울프의 예리한 송곳니로 제작된 레이피어. 날카로운 일격을 갈망하는 초보 모험가들에게 있어, 실전의 문을 여는 상징입니다.",
        "rareity": "unique",
        "baselevel": 50,
        "basedamage": 161,
        "criticalChance": 0.25,
        "criticalMultiplier": 1.75,
        "DefensePenetration": 0,
        "DoubleAttack": 0,
        "speed": 1.25,
        "sellPrice": 35000,
        "skill": [
            {
                "skill_name": "사냥 본능",
                "skill_effect": "체력이 50% 이하인 적에게 25% 추가 데미지를 입힙니다."
            }
        ]
    },
    {
        "name": "아머 브레이커(레이피어, 전투망치, 전투도끼)",
        "name_en": "Armor Breaker",
        "description": "날카로운 찌르기로 수많은 병사의 갑옷을 넝마로 만든 레이피어입니다. 검날은 닳았지만, 여전히 적의 방어구를 꿰뚫기에 충분합니다.",
        "rareity": "unique",
        "baselevel": 100,
        "basedamage": 207,
        "criticalChance": 0.15,
        "criticalMultiplier": 1.5,
        "DefensePenetration": 5,
        "DoubleAttack": 0,
        "speed": 1.25,
        "sellPrice": 50000,
        "skill": [
            {
                "skill_name": "갑옷 부수기",
                "skill_effect": "기본 적 방어력 무시 5, 공격 시 10% 확률로 대상의 방어력을 25 하락시킵니다. 이 효과는 5초 동안 지속되며, 중첩되지 않습니다."
            }
        ]
    },
    {
        "name": "독아",
        "name_en": "Venom Fang",
        "description": "음침한 대장장이가 으슥한 동굴에서 채취한 독과 함께 벼린 레이피어입니다. 외형은 허술해 보이지만, 맞은 자는 그 즉시 이상 징후를 보입니다.",
        "rareity": "unique",
        "baselevel": 200,
        "basedamage": 334,
        "criticalChance": 1.5,
        "criticalMultiplier": 1.5,
        "DefensePenetration": 0,
        "DoubleAttack": 0,
        "speed": 1.25,
        "sellPrice": 125000,
        "skill": [
            {
                "skill_name": "맹독 주입",
                "skill_effect": "공격 시 10% 확률로 몬스터를 중독 상태로 만듭니다. 중독된 몬스터는 5초 동안 초당 최대체력의 2% 피해를 입습니다. (해당 피해는 방어력을 무시합니다)"
            }
        ]
    },
    {
        "name": "복제된 신성한 일침",
        "name_en": "Replicated Divine Pierce",
        "description": "신성국에서 전해 내려오는 《신성한 일침》의 복제품입니다. 일부 신성 기사들에게 하사품 형식으로 보급되며, 진품보다 성능은 떨어지지만 형식적인 권위를 갖춘 무기입니다.",
        "rareity": "unique",
        "baselevel": 300,
        "basedamage": 500,
        "criticalChance": 1.75,
        "criticalMultiplier": 1.5,
        "DefensePenetration": 0,
        "DoubleAttack": 0,
        "speed": 1.35,
        "sellPrice": 225000,
        "skill": [
            {
                "skill_name": "심판 (복제)",
                "skill_effect": "언데드 또는 악마형 적에게 30% 추가 피해를 입힙니다. 신성교 혹은 천사형 적에게는 30% 피해가 감소합니다."
            },
            {
                "skill_name": "신성한 일격 (복제)",
                "skill_effect": "공격 시 10% 확률로 신성한 빛줄기를 내뿜어, 7,500의 추가 피해를 입힙니다."
            }
        ]
    },
    {
        "name": "벌집",
        "name_en": "Hive",
        "description": "강력한 찌르기로 적을 벌집으로 만듭니다. 끝없이 꽂히는 칼날 끝에 맞은 적은 온몸이 피투성이가 되어 무너져 내립니다.",
        "rareity": "unique",
        "baselevel": 400,
        "basedamage": 633,
        "skill": [
            {
                "skill_name": "벌집내기",
                "skill_effect": "상대방을 정신 못 차리게 찌릅니다. 공격 시 15% 확률로 공격력의 4배에 해당하는 추가 피해를 입힙니다."
            }
        ]
    },
    {
        "name": "",
        "name_en": "",
        "description": "",
        "rareity": "",
        "baselevel": 0,
        "basedamage": 0,
        "skill": [
            {
                "skill_name": "",
                "skill_effect": ""
            }
        ]
    },
    {
        "name": "",
        "name_en": "",
        "description": "",
        "rareity": "",
        "baselevel": 0,
        "basedamage": 0,
        "skill": [
            {
                "skill_name": "",
                "skill_effect": ""
            }
        ]
    },
    {
        "name": "신성한 일침",
        "name_en": "Divine Pierce",
        "description": "신성한 기운이 깃든 레이피어입니다. 신성국에서 대대로 전해 내려오는 성유물 중 하나로, 오랜 세월 동안 수많은 영웅과 성기사의 손에서 빛나왔습니다.",
        "rareity": "god",
        "baselevel": 0,
        "basedamage": 0,
        "criticalChance": 0,
        "criticalMultiplier": 0,
        "DefensePenetration": 0,
        "DoubleAttack": 0,
        "speed": 0,
        "sellPrice": 0,
        "skill": [
            {
                "skill_name": "심판",
                "skill_effect": "언데드 또는 악마형 적에게 100% 추가 피해를 입힙니다. 신성교 혹은 천사형 적에게는 30% 피해가 감소합니다."
            },
            {
                "skill_name": "신성한 일격",
                "skill_effect": "공격 시 25% 확률로 신성한 빛줄기를 내뿜어, 0의 추가 피해를 입힙니다."
            }

        ]
    }
]

# --- Unique Weapons Processing ---
def process_unique_weapons(raw_data):
    processed_weapons = []
    for item in raw_data:
        if item['name'] == "신성한 일침": # Skip prototype
            continue
        if item['name'] == "": # Skip empty entries
            continue

        # Handle Armor Breaker expansion
        if item['name'] == "아머 브레이커(레이피어, 전투망치, 전투도끼)":
            types_to_create = ['rapier', 'warhammer', 'battleAxe']
            for weapon_type_str in types_to_create:
                new_item = item.copy()
                new_item['name'] = "아머 브레이커"
                new_item['type'] = weapon_type_str # Assign specific type
                new_item['imageName'] = f"unique/armor_breaker_{weapon_type_str}.png"
                processed_weapons.append(new_item)
        else:
            # Standard unique weapon processing
            # Infer type from name if not explicitly provided (for now, assume rapier for others)
            # This part needs to be more robust if other unique weapons are not rapiers.
            inferred_type = 'rapier' # Default for now
            if item['name'] == "벌새": inferred_type = 'rapier'
            elif item['name'] == "하얀 송곳니": inferred_type = 'rapier'
            elif item['name'] == "독아": inferred_type = 'rapier'
            elif item['name'] == "복제된 신성한 일침": inferred_type = 'rapier'
            elif item['name'] == "벌집": inferred_type = 'rapier' # Assuming from description

            item['type'] = inferred_type
            item['imageName'] = f"unique/{item['name_en'].lower().replace(' ', '_')}.png"
            processed_weapons.append(item)
            
    return processed_weapons

# --- Main Generation Logic ---

def generate_weapons():
    """Generates the list of all weapon data."""
    common_weapons = []
    uncommon_weapons = []
    unique_weapons_list = [] # Renamed to avoid conflict with function name
    weapon_id_counter = 1

    # Generate common and uncommon weapons
    for tier_data in TIERS_DATA:
        for quality_data in QUALITIES_DATA:
            for type_ko in WEAPON_TYPES_KO:
                type_key = TYPE_MAP[type_ko] # Get English type key

                # Common Weapon
                final_level = tier_data['base_level'] + quality_data['level_add']
                base_stats = BASE_LEVEL_STATS[final_level]

                common_weapon = {
                    'id': weapon_id_counter,
                    'name': f"{quality_data['name_ko']} {tier_data['name_ko']} {type_ko}",
                    'imageName': f"common/{quality_data['name_en']}_{tier_data['name_en']}_{TYPE_MAP[type_ko]}.png",
                    'rarity': 'Rarity.common',
                    'type': f'WeaponType.{type_key}',
                    'baseLevel': final_level,
                    'description': f'A common weapon.',
                    'baseDamage': int(base_stats['baseDamage']),
                    'speed': base_stats['speed'],
                    'criticalChance': base_stats['criticalChance'],
                    'criticalDamage': base_stats['criticalDamage'],
                    'accuracy': base_stats['accuracy'],
                    'defensePenetration': 0.0,
                    'doubleAttackChance': 0.0,
                    'baseSellPrice': calculate_sell_price(final_level),
                    'enhancement': 0,
                    'transcendence': 0,
                    'investedGold': 0.0,
                    'investedEnhancementStones': 0,
                    'investedTranscendenceStones': 0,
                    'skills': []
                }
                common_weapons.append(common_weapon)
                weapon_id_counter += 1

                # Uncommon Weapon
                uncommon_weapon = common_weapon.copy()
                uncommon_weapon['id'] = weapon_id_counter
                uncommon_weapon['rarity'] = 'Rarity.uncommon'
                uncommon_weapon['name'] = f"{quality_data['name_ko']} {tier_data['name_ko']} {type_ko}" # Name is same, but rarity is different
                uncommon_weapon['imageName'] = f"uncommon/{quality_data['name_en']}_{tier_data['name_en']}_{TYPE_MAP[type_ko]}.png"
                
                # Apply 1.25x multiplier to stats
                uncommon_weapon['baseDamage'] = int(common_weapon['baseDamage'] * 1.25)
                uncommon_weapon['speed'] = round(common_weapon['speed'] * 1.25, 2)
                uncommon_weapon['criticalChance'] = min(1.0, round(common_weapon['criticalChance'] * 1.25, 3))
                uncommon_weapon['criticalDamage'] = round(common_weapon['criticalDamage'] * 1.25, 2)
                uncommon_weapon['accuracy'] = min(1.0, round(common_weapon['accuracy'] * 1.25, 3))
                uncommon_weapon['baseSellPrice'] = int(common_weapon['baseSellPrice'] * 1.25) # Also scale sell price

                uncommon_weapons.append(uncommon_weapon)
                weapon_id_counter += 1

    # Process and append unique weapons
    unique_weapons_processed = process_unique_weapons(UNIQUE_WEAPONS_RAW_DATA)
    for uw in unique_weapons_processed:
        # Map fields from raw unique data to Weapon model fields
        weapon = {
            'id': weapon_id_counter,
            'name': uw['name'],
            'imageName': uw['imageName'],
            'rarity': 'Rarity.' + uw['rareity'],
            'type': 'WeaponType.' + uw['type'],
            'baseLevel': uw.get('baselevel', 0),
            'baseDamage': uw.get('basedamage', 0),
            'criticalChance': uw.get('criticalChance', 0.0),
            'criticalDamage': uw.get('criticalMultiplier', 1.0), # Map criticalMultiplier to criticalDamage
            'defensePenetration': uw.get('DefensePenetration', 0.0),
            'doubleAttackChance': uw.get('DoubleAttack', 0.0),
            'speed': uw.get('speed', 1.0),
            'baseSellPrice': uw.get('sellPrice', 0),
            'skills': uw.get('skill', []), # Use .get for optional skill field
            'accuracy': uw.get('accuracy', 0.95), # Default accuracy if not provided
            'description': f"{uw.get('name_en', '')} {uw.get('description', '')}".strip(), # Combine name_en and description
            
            # Default values for other fields
            'enhancement': 0,
            'transcendence': 0,
            'investedGold': 0.0,
            'investedEnhancementStones': 0,
            'investedTranscendenceStones': 0,
        }
        unique_weapons_list.append(weapon)
        weapon_id_counter += 1

    return {
        'common': common_weapons,
        'uncommon': uncommon_weapons,
        'unique': unique_weapons_list
    }

def main():
    """Main function to generate and save the weapon data."""
    weapons_by_rarity = generate_weapons()
    
    output_dir = '../assets/data/'

    for rarity, weapons_list in weapons_by_rarity.items():
        output_path = f'{output_dir}{rarity}_weapons.json'
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(weapons_list, f, ensure_ascii=False, indent=2)
            print(f'Successfully generated and saved {len(weapons_list)} {rarity} weapons to {output_path}')
        except IOError as e:
            print(f'Error writing to file {output_path}: {e}')

if __name__ == '__main__':
    main()