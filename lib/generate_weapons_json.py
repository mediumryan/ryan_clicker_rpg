import json

prefixes = ["녹슨", "평범한", "쓸만한"]
suffixes = [
    "조잡한", "용병의", "고블린족의", "기사단의", "리자드맨의",
    "엘프족의", "정령의 힘이 깃든", "신성국의", "악마의 힘이 깃든", "용의 힘이 깃든"
]
weapon_types = [
    "레이피어", "카타나", "검", "대검", "시미터", "단검", "도축칼",
    "전투도끼", "전투망치", "창", "지팡이", "삼지창", "메이스", "낫", "곡도", "쌍절곤"
]

# Mappings for English names
prefix_map = {
    "녹슨": "rusty", "평범한": "plain", "쓸만한": "decent"
}
suffix_map = {
    "조잡한": "crude", "용병의": "mercenary", "고블린족의": "goblin",
    "기사단의": "knights", "리자드맨의": "lizardman", "엘프족의": "elf",
    "정령의 힘이 깃든": "elemental", "신성국의": "holy",
    "악마의 힘이 깃든": "demonic", "용의 힘이 깃든": "dragon"
}
type_map = {
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

initial_damage = 45
initial_crit_chance = 0.1
initial_crit_multiplier = 1.35
initial_sell_price = 125.0 # Adjusted for 12.5x

damage_growth_factor = 1.20 # New exponential growth factor
price_increment = 250.0 # Adjusted for 12.5x
crit_chance_increment = 0.025
crit_multiplier_increment = 0.05

all_weapons = []
weapon_id = 1
step_counter = 0

for suffix_kr in suffixes:
    for prefix_kr in prefixes:
        base_level = step_counter * 25
        damage = initial_damage * (damage_growth_factor ** step_counter) # Exponential damage
        crit_chance = initial_crit_chance + (step_counter * crit_chance_increment)
        crit_multiplier = initial_crit_multiplier + (step_counter * crit_multiplier_increment)
        sell_price = initial_sell_price + (step_counter * price_increment)

        for type_kr in weapon_types:
            name_kr = f"{prefix_kr} {suffix_kr} {type_kr}"
            
            # Generate English imageName
            prefix_en = prefix_map[prefix_kr]
            suffix_en = suffix_map[suffix_kr]
            type_en_for_image = type_map[type_kr]
            
            # Special handling for image names that are snake_case
            if type_en_for_image == "battleAxe":
                image_name_en = f"{prefix_en}_{suffix_en}_battle_axe.png".replace(" ", "_").lower()
            elif type_en_for_image == "curvedSword":
                image_name_en = f"{prefix_en}_{suffix_en}_curved_sword.png".replace(" ", "_").lower()
            else:
                image_name_en = f"{prefix_en}_{suffix_en}_{type_en_for_image}.png".replace(" ", "_").lower()


            weapon = {
                "id": weapon_id,
                "name": name_kr,
                "imageName": image_name_en, # Now includes extension
                "rarity": "Rarity.common", # All common as per user request
                "type": f"WeaponType.{type_map[type_kr]}",
                "baseLevel": base_level,
                "level": 1,
                "enhancement": 0,
                "transcendence": 0,
                "damage": round(damage, 1),
                "criticalChance": round(crit_chance, 4),
                "criticalDamage": round(crit_multiplier, 3),
                "baseSellPrice": round(sell_price, 2),
                "investedGold": 0,
                "investedEnhancementStones": 0,
                "investedTranscendenceStones": 0,
                "specialAbilityDescription": None,
                "abilityType": None,
                "abilityProcChance": None,
                "abilityValue": None
            }
            all_weapons.append(weapon)
            weapon_id += 1
        step_counter += 1

# Output to a file
output_path = "/Users/ryan/ryan_clicker_rpg/lib/data/weapons.json"
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(all_weapons, f, ensure_ascii=False, indent=2)

print(f"Successfully generated {len(all_weapons)} weapon entries to {output_path}")