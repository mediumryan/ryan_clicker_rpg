import json
import math

# --- 무기 타입 분류 ---

FIRST_GROUP_WEAPONS = [
    "레이피어", "카타나", "검", "대검", "시미터", "단검", "도축칼", "전투도끼"
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
    "레이피어": "rapier", "카타나": "katana", "검": "sword",
    "대검": "greatsword", "시미터": "scimitar", "단검": "dagger",
    "도축칼": "cleaver", "전투도끼": "battle_axe", "전투망치": "warhammer",
    "창": "spear", "지팡이": "staff", "삼지창": "trident",
    "메이스": "mace", "낫": "scythe", "곡도": "curved_sword", "쌍절곤": "nunchaku"
}

# --- 무기 타입별 멀티플라이어 ---
WEAPON_TYPE_MODIFIERS = {
     "rapier":       {"damage_mult": 0.89, "speed_mult": 1.35, "accuracy_mult": 1.143, "crit_chance_mult": 2.000, "crit_mult_mult": 0.933},
     "katana":       {"damage_mult": 1.11, "speed_mult": 1.15, "accuracy_mult": 1.071, "crit_chance_mult": 1.600, "crit_mult_mult": 1.067},
     "sword":        {"damage_mult": 1.36, "speed_mult": 1.00, "accuracy_mult": 1.029, "crit_chance_mult": 1.000, "crit_mult_mult": 1.000},
     "greatsword":   {"damage_mult": 1.98, "speed_mult": 0.75, "accuracy_mult": 0.929, "crit_chance_mult": 0.800, "crit_mult_mult": 1.267},
     "scimitar":     {"damage_mult": 1.11, "speed_mult": 1.20, "accuracy_mult": 1.043, "crit_chance_mult": 1.200, "crit_mult_mult": 1.000},
     "dagger":       {"damage_mult": 0.88, "speed_mult": 1.40, "accuracy_mult": 1.114, "crit_chance_mult": 2.400, "crit_mult_mult": 0.900},
     "cleaver":      {"damage_mult": 1.52, "speed_mult": 0.90, "accuracy_mult": 1.000, "crit_chance_mult": 1.200, "crit_mult_mult": 1.133},
     "battle_axe":    {"damage_mult": 1.72, "speed_mult": 0.85, "accuracy_mult": 0.943, "crit_chance_mult": 0.800, "crit_mult_mult": 1.233},
     "warhammer":    {"damage_mult": 2.19, "speed_mult": 0.70, "accuracy_mult": 0.900, "crit_chance_mult": 0.600, "crit_mult_mult": 1.400},
     "spear":        {"damage_mult": 1.18, "speed_mult": 1.05, "accuracy_mult": 1.114, "crit_chance_mult": 1.200, "crit_mult_mult": 1.033},
     "staff":        {"damage_mult": 1.22, "speed_mult": 1.00, "accuracy_mult": 1.143, "crit_chance_mult": 1.400, "crit_mult_mult": 0.933},
     "trident":      {"damage_mult": 1.34, "speed_mult": 0.95, "accuracy_mult": 1.086, "crit_chance_mult": 1.200, "crit_mult_mult": 1.067},
     "mace":         {"damage_mult": 1.58, "speed_mult": 0.90, "accuracy_mult": 0.971, "crit_chance_mult": 0.800, "crit_mult_mult": 1.267},
     "scythe":       {"damage_mult": 1.37, "speed_mult": 1.00, "accuracy_mult": 0.986, "crit_chance_mult": 1.400, "crit_mult_mult": 1.200},
     "curved_sword": {"damage_mult": 1.22, "speed_mult": 1.10, "accuracy_mult": 1.029, "crit_chance_mult": 1.200, "crit_mult_mult": 1.067},
     "nunchaku":     {"damage_mult": 0.96, "speed_mult": 1.35, "accuracy_mult": 1.057, "crit_chance_mult": 2.000, "crit_mult_mult": 0.933},
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
        'baseDamage': 100 if level == 0 else int(6.21 * level + 5),
        'criticalChance': 0.05,
        'criticalDamage': 1.5,
        'speed': 1.0,
        'accuracy': 0.7
    } for level in range(0, 1476, 25)
}

# --- 판매가 계산 공식 ---

def calculate_sell_price(level):
    base_price = 1000
    if level == 0:
        return base_price

    # Piecewise exponential scaling for sell price
    # Using base_price * (exponent ^ level)
    
    price = base_price
    
    # Segment 1: 1 to 100 (exponent 1.025)
    if level <= 100:
        price = base_price * math.pow(1.025, level)
    # Segment 2: 101 to 200 (exponent 1.01)
    elif level <= 200:
        price_at_100 = base_price * math.pow(1.025, 100)
        price = price_at_100 * math.pow(1.01, level - 100)
    # Segment 3: 201 to 300 (exponent 1.0075)
    elif level <= 300:
        price_at_100 = base_price * math.pow(1.025, 100)
        price_at_200 = price_at_100 * math.pow(1.01, 100)
        price = price_at_200 * math.pow(1.0075, level - 200)
    # Segment 4: 301 to 400 (exponent 1.005)
    elif level <= 400:
        price_at_100 = base_price * math.pow(1.025, 100)
        price_at_200 = price_at_100 * math.pow(1.01, 100)
        price_at_300 = price_at_200 * math.pow(1.0075, 100)
        price = price_at_300 * math.pow(1.005, level - 300)
    # Segment 5: 401 to 500 (exponent 1.0075)
    elif level <= 500:
        price_at_100 = base_price * math.pow(1.025, 100)
        price_at_200 = price_at_100 * math.pow(1.01, 100)
        price_at_300 = price_at_200 * math.pow(1.0075, 100)
        price_at_400 = price_at_300 * math.pow(1.005, 100)
        price = price_at_400 * math.pow(1.0075, level - 400)
    # Segment 6: 501 to 1000 (exponent 1.005)
    elif level <= 1000:
        price_at_100 = base_price * math.pow(1.025, 100)
        price_at_200 = price_at_100 * math.pow(1.01, 100)
        price_at_300 = price_at_200 * math.pow(1.0075, 100)
        price_at_400 = price_at_300 * math.pow(1.005, 100)
        price_at_500 = price_at_400 * math.pow(1.0075, 100) # 500 - 400 = 100
        price = price_at_500 * math.pow(1.005, level - 500)
    # Segment 7: 1001 to 2000 (exponent 1.0025)
    else: # level > 1000
        price_at_100 = base_price * math.pow(1.025, 100)
        price_at_200 = price_at_100 * math.pow(1.01, 100)
        price_at_300 = price_at_200 * math.pow(1.0075, 100)
        price_at_400 = price_at_300 * math.pow(1.005, 100)
        price_at_500 = price_at_400 * math.pow(1.0025, 100)
        price_at_1000 = price_at_500 * math.pow(1.005, 500) # 1000 - 500 = 500
        price = price_at_1000 * math.pow(1.0025, level - 1000)

    return int(price)

# --- 무기 생성 함수 ---

def generate_weapons():
    temp_common_weapons = []
    temp_uncommon_weapons = []
    temp_rare_weapons = []
    
    # Iterate through each tier
    for tier_data in TIERS_DATA:
        tier_base_level = tier_data['base_level']
        
        # Determine the range of baseLevels for this tier
        tier_end_level = 1475 # Default for the last tier
        tier_index = TIERS_DATA.index(tier_data) # Re-add tier_index for tier_end_level calculation
        if tier_index + 1 < len(TIERS_DATA):
            tier_end_level = TIERS_DATA[tier_index + 1]['base_level'] - 25 # Changed to -50
        
        # Iterate through baseLevels within this tier's range, step 50
        for current_base_level in range(tier_base_level, tier_end_level + 1, 25):
            # Determine tier_data based on current_base_level (MOVED INSIDE)
            selected_tier_data = TIERS_DATA[0] # Default to crude
            for t_data in TIERS_DATA:
                if current_base_level >= t_data['base_level']:
                    selected_tier_data = t_data
                else:
                    break # Tiers are sorted by base_level, so we can break
            tier_data = selected_tier_data
            # Determine weapon group name (1군무기 or 2군무기) for the name string
            group_name_selector = (current_base_level // 25) % 2

            # Select weapon types based on the group_name_selector
            selected_weapon_types = []
            if group_name_selector == 0:
                selected_weapon_types = FIRST_GROUP_WEAPONS
            else:
                selected_weapon_types = SECOND_GROUP_WEAPONS
            
            for type_ko in selected_weapon_types: # Iterate through selected weapon types
                type_key = TYPE_MAP[type_ko]
                base_stats = BASE_LEVEL_STATS.get(current_base_level)
                if base_stats is None: continue
                
                type_modifiers = WEAPON_TYPE_MODIFIERS.get(type_key, {})

                # Generate weapons for each quality (녹슨, 평범한, 쓸만한)
                for quality_data in QUALITIES_DATA:
                    # Apply quality_data['stat_mult'] and type_modifiers here
                    quality_mult = quality_data['stat_mult']
                    
                    base_damage = int(base_stats['baseDamage'] * quality_mult * type_modifiers.get('damage_mult', 1))
                    speed = round(base_stats['speed'] * type_modifiers.get('speed_mult', 1), 2)
                    critical_chance = min(1.0, round(base_stats['criticalChance'] * type_modifiers.get('crit_chance_mult', 1), 3))
                    critical_damage = round(base_stats['criticalDamage'] * type_modifiers.get('crit_mult_mult', 1), 2)
                    accuracy = min(1.0, round(base_stats['accuracy'] * type_modifiers.get('accuracy_mult', 1), 3))

                    base_sell_price = int(calculate_sell_price(current_base_level) * quality_data['stat_mult'])
                    
                    weapon = {
                        'name': f"{quality_data['name_ko']} {tier_data['name_ko']} {type_ko}", # Add group suffix to name
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
                        'description': f'A {quality_data["name_en"]} {tier_data["name_en"]} weapon.'
                    }
                    
                    # Assign to temporary lists based on quality_data
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
    weapons_by_rarity = generate_weapons()
    output_dir = './assets/data/'

    for rarity, weapons_list in weapons_by_rarity.items():
        if rarity == 'unique': # Skip unique weapons for now as they are not generated by the loop
            continue
        output_path = f'{output_dir}{rarity}_weapons.json'
        try:
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(weapons_list, f, ensure_ascii=False, indent=2)
            print(f'Successfully saved {len(weapons_list)} {rarity} weapons to {output_path}')
        except IOError as e:
            print(f'Error writing {output_path}: {e}')

if __name__ == '__main__':
    main()