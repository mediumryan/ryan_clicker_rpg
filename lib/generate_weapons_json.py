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

# --- 티어, 퀄리티 정의 ---

TIERS_DATA = [
    {"name_ko": "조잡한", "name_en": "crude", "base_level": 0},
    {"name_ko": "용병의", "name_en": "mercenary", "base_level": 150},
    {"name_ko": "고블린족의", "name_en": "goblin", "base_level": 300},
    {"name_ko": "기사단의", "name_en": "knights", "base_level": 450},
    {"name_ko": "리자드맨의", "name_en": "lizardman", "base_level": 600},
    {"name_ko": "엘프족의", "name_en": "elf", "base_level": 750},
    {"name_ko": "정령의 힘이 깃든", "name_en": "elemental", "base_level": 900},
    {"name_ko": "신성국의", "name_en": "holy", "base_level": 1050},
    {"name_ko": "악마의 힘이 깃든", "name_en": "demonic", "base_level": 1200},
    {"name_ko": "용의 힘이 깃든", "name_en": "dragon", "base_level": 1350},
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
        'criticalChance': 0.1,
        'criticalDamage': 1.35,
        'speed': 1.0,
        'accuracy': 1.0
    } for level in range(0, 1476, 25)
}

# --- 판매가 계산 공식 ---

def calculate_sell_price(level):
    return int(50 * math.pow(1.015, level))

# --- 무기 생성 함수 ---

def generate_weapons():
    common_weapons = []
    uncommon_weapons = []
    rare_weapons = []
    weapon_id_counter = 1

    for final_level in range(0, 1476, 25): # Levels from 0 to 1475, step 25
        # Determine quality_data based on final_level pattern
        if (final_level % 150) < 50:
            quality_data = QUALITIES_DATA[0] # 녹슨
        elif (final_level % 150) < 100:
            quality_data = QUALITIES_DATA[1] # 평범한
        else:
            quality_data = QUALITIES_DATA[2] # 쓸만한

        # Determine tier_data based on final_level
        tier_index = final_level // 150
        if tier_index >= len(TIERS_DATA):
            continue # Should not happen with range 0-1475 and TIERS_DATA length 10

        tier_data = TIERS_DATA[tier_index]

        # Determine which group (FIRST_GROUP_WEAPONS or SECOND_GROUP_WEAPONS) to use
        group_index = (final_level // 25) % 2
        current_group = FIRST_GROUP_WEAPONS if group_index == 0 else SECOND_GROUP_WEAPONS

        for type_ko in current_group:
            type_key = TYPE_MAP[type_ko]
            base_stats = BASE_LEVEL_STATS.get(final_level)

            if base_stats is None:
                continue # Should not happen if BASE_LEVEL_STATS covers all 25-step levels

            base_weapon_template = {
                'name': f"{quality_data['name_ko']} {tier_data['name_ko']} {type_ko}",
                'imageName': f"group1/{quality_data['name_en']}_{tier_data['name_en']}_{type_key}.png",
                'type': f'WeaponType.{type_key}',
                'baseLevel': final_level,
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

            # Generate Common weapon
            common_weapon = generate_weapon_by_rarity(base_weapon_template, 'common', 1.0, weapon_id_counter)
            common_weapons.append(common_weapon)
            weapon_id_counter += 1

            # Generate Uncommon weapon
            uncommon_weapon = generate_weapon_by_rarity(base_weapon_template, 'uncommon', 1.25, weapon_id_counter)
            uncommon_weapons.append(uncommon_weapon)
            weapon_id_counter += 1

            # Generate Rare weapon
            rare_weapon = generate_weapon_by_rarity(base_weapon_template, 'rare', 1.5, weapon_id_counter)
            rare_weapons.append(rare_weapon)
            weapon_id_counter += 1

    return {
        'common': common_weapons,
        'uncommon': uncommon_weapons,
        'rare': rare_weapons,
    }

def generate_weapon_by_rarity(base_weapon, rarity_name, stat_multiplier, id_counter):
    weapon = base_weapon.copy()
    weapon['id'] = id_counter
    weapon['rarity'] = f'Rarity.{rarity_name}'
    weapon['description'] = f'A {rarity_name} weapon.'

    # Apply stat multipliers
    weapon['baseDamage'] = int(base_weapon['baseDamage'] * stat_multiplier)
    weapon['speed'] = round(base_weapon['speed'] * stat_multiplier, 2)
    weapon['criticalChance'] = min(1.0, round(base_weapon['criticalChance'] * stat_multiplier, 3))
    weapon['criticalDamage'] = round(base_weapon['criticalDamage'] * stat_multiplier, 2)
    weapon['accuracy'] = min(1.0, round(base_weapon['accuracy'] * stat_multiplier, 3))
    weapon['baseSellPrice'] = int(base_weapon['baseSellPrice'] * stat_multiplier)

    return weapon

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