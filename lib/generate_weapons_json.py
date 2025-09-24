import json
import math
import unique_weapon_generator
import os

# --- 무기 타입 분류 ---

FIRST_GROUP_WEAPONS = [
    "레이피어", "도검", "검", "대검", "시미터", "단검", "도축칼", "전투도끼"
]
SECOND_GROUP_WEAPONS = [
    "전투망치", "창", "지팡이", "삼지창", "메이스", "낫", "곡도", "쌍절곤"
]

# --- 영어 매핑 ---

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


# --- 티어, 퀄리티 정의 ---

TIERS_DATA = [
    {"name_ko": "조잡한", "name_en": "crude", "base_level": 0},
    {"name_ko": "용병의", "name_en": "mercenary", "base_level": 50},
    {"name_ko": "고블린족의", "name_en": "goblin", "base_level": 100},
    {"name_ko": "기사단의", "name_en": "knights", "base_level": 150},
    {"name_ko": "리자드맨의", "name_en": "lizardman", "base_level": 200},
    {"name_ko": "엘프족의", "name_en": "elf", "base_level": 250},
    {"name_ko": "정령의 힘이 깃든", "name_en": "elemental", "base_level": 300},
    {"name_ko": "신성국의", "name_en": "holy", "base_level": 350},
    {"name_ko": "악마의 힘이 깃든", "name_en": "demonic", "base_level": 400},
    {"name_ko": "용의 힘이 깃든", "name_en": "dragon", "base_level": 450},
]

QUALITIES_DATA = [
    {"name_ko": "녹슨", "name_en": "rusty", "level_add": 0, "stat_mult": 0.8},
    {"name_ko": "평범한", "name_en": "plain", "level_add": 25, "stat_mult": 1.0},
    {"name_ko": "쓸만한", "name_en": "decent", "level_add": 50, "stat_mult": 1.2},
]

# --- 레벨별 스탯 정의 (0 ~ 1450, 간격 25) ---

BASE_LEVEL_STATS = {
    level: {
        'baseDamage': 0.08 * (level ** 1.75) + 7 * level + 50,
        'criticalChance': 0.1,
        'criticalDamage': 1.5,
        'speed': 1.0,
        'accuracy': 0.7
    } for level in range(0, 2376, 25)
}

# --- 판매가 계산 공식 ---

def calculate_sell_price(level):
    base_price = 1000
    price_per_level = 100
    return int(base_price + (level * price_per_level))

# --- 무기 생성 함수 ---

ROMAN_NUMERALS = ["", "Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ", "Ⅹ"]

MAX_BASE_LEVEL = 2375 # New maximum base level

def generate_weapons():
    temp_common_weapons = []
    temp_uncommon_weapons = []
    temp_rare_weapons = []

    # Iterate through all base levels in steps of 25
    for current_base_level in range(0, MAX_BASE_LEVEL + 1, 25):
        # Determine the Roman numeral prefix
        roman_numeral_index = current_base_level // 500
        roman_prefix = ROMAN_NUMERALS[roman_numeral_index] if roman_numeral_index < len(ROMAN_NUMERALS) else ROMAN_NUMERALS[-1] # Fallback to last Roman numeral if index out of bounds

        # Determine the tier_data (suffix) based on the effective base_level within a 500-level cycle
        effective_base_level_in_cycle = current_base_level % 500
        
        selected_tier_data = TIERS_DATA[0] # Default to crude
        for t_data in TIERS_DATA:
            if effective_base_level_in_cycle >= t_data['base_level']:
                selected_tier_data = t_data
            else:
                break # Tiers are sorted by base_level, so we can break
        tier_data = selected_tier_data

        # Determine weapon group name (1군무기 or 2군무기)
        group_name_selector = (current_base_level // 25) % 2

        selected_weapon_types = []
        if group_name_selector == 0:
            selected_weapon_types = FIRST_GROUP_WEAPONS
        else:
            selected_weapon_types = SECOND_GROUP_WEAPONS

        for type_ko in selected_weapon_types:
            type_key = TYPE_MAP[type_ko]
            base_stats = BASE_LEVEL_STATS.get(current_base_level)
            if base_stats is None: continue

            type_modifiers = WEAPON_TYPE_MODIFIERS.get(type_key, {})

            for quality_data in QUALITIES_DATA:
                quality_mult = quality_data['stat_mult']

                base_damage = int(base_stats['baseDamage'] * quality_mult * type_modifiers.get('damage_mult', 1))
                speed = round(base_stats['speed'] * type_modifiers.get('speed_mult', 1), 2)
                critical_chance = min(1.0, round(base_stats['criticalChance'] * type_modifiers.get('crit_chance_mult', 1), 3))
                critical_damage = round(base_stats['criticalDamage'] * type_modifiers.get('crit_mult_mult', 1), 2)
                accuracy = min(1.0, round(base_stats['accuracy'] * type_modifiers.get('accuracy_mult', 1), 3))

                base_sell_price = int(calculate_sell_price(current_base_level) * quality_data['stat_mult'])

                weapon_name = f"{roman_prefix} {quality_data['name_ko']} {tier_data['name_ko']} {type_ko}".strip()
                weapon_name = " ".join(weapon_name.split()) # Handle double spaces if roman_prefix is empty

                weapon = {
                    'name': weapon_name,
                    'imageName': f"group1/{quality_data['name_en']}_{tier_data['name_en']}_{type_key}.png",
                    'type': f'WeaponType.{type_key}',
                    'baseLevel': current_base_level,
                    'baseDamage': base_damage,
                    'speed': speed,
                    'criticalChance': critical_chance,
                    'criticalDamage': critical_damage,
                    'accuracy': accuracy,
                    'defensePenetration': 0.0,
                    'doubleAttackChance': 0.0,
                    'baseSellPrice': base_sell_price,
                    'enhancement': 0,
                    'transcendence': 0,
                    'investedGold': 0.0,
                    'investedEnhancementStones': 0,
                    'investedTranscendenceStones': 0,
                    'skills': [],
                    'description': f'{weapon_name} 입니다.'
                }

                if quality_data['name_ko'] == "녹슨":
                    weapon['rarity'] = 'Rarity.common'
                    temp_common_weapons.append(weapon)
                elif quality_data['name_ko'] == "평범한":
                    weapon['rarity'] = 'Rarity.uncommon'
                    temp_uncommon_weapons.append(weapon)
                elif quality_data['name_ko'] == "쓸만한":
                    weapon['rarity'] = 'Rarity.rare'
                    temp_rare_weapons.append(weapon)

    # Select the first 160 weapons for each rarity and re-assign IDs
    common_weapons = []
    uncommon_weapons = []
    rare_weapons = []
    
    weapon_id_counter = 1
    
    for weapon in temp_common_weapons:
        weapon['id'] = weapon_id_counter
        common_weapons.append(weapon)
        weapon_id_counter += 1
        
    for weapon in temp_uncommon_weapons:
        weapon['id'] = weapon_id_counter
        uncommon_weapons.append(weapon)
        weapon_id_counter += 1
        
    for weapon in temp_rare_weapons:
        weapon['id'] = weapon_id_counter
        rare_weapons.append(weapon)
        weapon_id_counter += 1
    
    return {
        'common': common_weapons,
        'uncommon': uncommon_weapons,
        'rare': rare_weapons,
    }

# --- 저장 함수 ---

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    output_dir = os.path.join(script_dir, '..', 'assets', 'data')

    # Generate common, uncommon, rare weapons
    weapons_by_rarity = generate_weapons()

    for rarity, weapons_list in weapons_by_rarity.items():
        output_path = os.path.join(output_dir, f'{rarity}_weapons.json')
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(weapons_list, f, ensure_ascii=False, indent=2)
            print(f'Successfully saved {len(weapons_list)} {rarity} weapons to {output_path}')
        except IOError as e:
            print(f'Error writing {output_path}: {e}')

    # Generate unique weapons
    unique_weapons = unique_weapon_generator.generate_unique_weapons()
    output_path = os.path.join(output_dir, 'unique_weapons.json')
    try:
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(unique_weapons, f, ensure_ascii=False, indent=2)
        print(f'Successfully saved {len(unique_weapons)} unique weapons to {output_path}')
    except IOError as e:
        print(f'Error writing {output_path}: {e}')

if __name__ == '__main__':
    main()