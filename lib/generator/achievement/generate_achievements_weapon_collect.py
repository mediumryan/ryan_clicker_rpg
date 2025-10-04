prefixes = [    "조잡한", "용병의", "고블린족의", "기사단의", "리자드맨의", "엘프족의", "정령의 힘이 깃든", "신성국의", "악마의 힘이 깃든", "용의 힘이 깃든"]
roman_numerals = ["", "Ⅰ ", "ⅠⅠ ", "ⅠⅠⅠ ", "ⅠⅠⅠⅠ "]
achievements_string = ""
for round_num, roman_prefix in enumerate(roman_numerals):
    for i, prefix in enumerate(prefixes):
        min_level = (round_num * 500) + (i * 50)
        max_level = min_level + 25
        if min_level > 2375:
            break
        # Tier 1
        gold_reward = (1000 if i == 0 else i * 10000) * (10 ** round_num)
        stone_reward = (1 if i == 0 else i * 5) * (5 ** round_num)
        achievements_string += f'''    Achievement(
      id: \'ach_collect_{round_num}_{i}_1\',
      name: \'{roman_prefix}{prefix} 무기 수집가Ⅰ\',
      description: \'레벨{min_level}~{max_level}의 커먼,언커먼,레어 등급의 무기 1개 수집\',
      rewards: [
        Reward(type: RewardType.gold, quantity: {gold_reward}),
        Reward(type: RewardType.enhancementStone, quantity: {stone_reward}),
      ],
      isCompletable: (Player player) => _countAcquiredWeaponsByLevelAndRarity(player, {min_level}, {max_level}, [Rarity.common, Rarity.uncommon, Rarity.rare]) >= 1,
      progressText: (Player player) => \'$_countAcquiredWeaponsByLevelAndRarity(player, {min_level}, {max_level}, [Rarity.common, Rarity.uncommon, Rarity.rare]) / 1\',
    ),'''
        # Tier 2
        achievements_string += f'''    Achievement(
      id: \'ach_collect_{round_num}_{i}_2\',
      name: \'{roman_prefix}{prefix} 무기 수집가ⅠⅠ\',
      description: \'레벨{min_level}~{max_level}의 커먼,언커먼,레어 등급의 무기 10개 수집\',
      rewards: [
        Reward(type: RewardType.gachaBox, quantity: 2, item: GachaBox(id: \'ach_collect_{round_num}_{i}_2_reward\', boxType: WeaponBoxType.rare, stageLevel: {min_level})),
      ],
      isCompletable: (Player player) => _countAcquiredWeaponsByLevelAndRarity(player, {min_level}, {max_level}, [Rarity.common, Rarity.uncommon, Rarity.rare]) >= 10,
      progressText: (Player player) => \'$_countAcquiredWeaponsByLevelAndRarity(player, {min_level}, {max_level}, [Rarity.common, Rarity.uncommon, Rarity.rare]) / 10\',
    ),'''
        # Tier 3
        achievements_string += f'''    Achievement(
      id: \'ach_collect_{round_num}_{i}_3\',
      name: \'{roman_prefix}{prefix} 무기 수집가ⅠⅠⅠ\',
      description: \'레벨{min_level}~{max_level}의 커먼,언커먼,레어 등급의 무기 36개 수집\',
      rewards: [
        Reward(type: RewardType.gachaBox, quantity: 1, item: GachaBox(id: \'ach_collect_{round_num}_{i}_3_reward\', boxType: WeaponBoxType.guaranteedUnique, stageLevel: {min_level})),
      ],
      isCompletable: (Player player) => _countAcquiredWeaponsByLevelAndRarity(player, {min_level}, {max_level}, [Rarity.common, Rarity.uncommon, Rarity.rare]) >= 36,
      progressText: (Player player) => \'$_countAcquiredWeaponsByLevelAndRarity(player, {min_level}, {max_level}, [Rarity.common, Rarity.uncommon, Rarity.rare]) / 36\',
    ),'''
with open('assets/data/achievement.txt', 'w', encoding='utf-8') as f:
    f.write(achievements_string)
