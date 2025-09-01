import 'dart:math';

import 'package:ryan_clicker_rpg/models/gacha_box.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart';

class RewardService {
  final Random _random = Random();

  // Helper function for weighted random selection
  T _getWeightedRandom<T>(Map<T, double> weights) {
    if (weights.isEmpty) {
      throw ArgumentError('Weights map cannot be empty');
    }
    double totalWeight = weights.values.reduce((a, b) => a + b);
    if (totalWeight <= 0) {
      return weights.keys.first;
    }
    double randomNumber = _random.nextDouble() * totalWeight;

    double cumulativeWeight = 0;
    for (var entry in weights.entries) {
      cumulativeWeight += entry.value;
      if (randomNumber < cumulativeWeight) {
        return entry.key;
      }
    }
    return weights.keys.last;
  }

  GachaBox? getDropForNormalMonster(int stage) {
    double dropChance;
    Map<WeaponBoxType, double> boxDistribution;

    if (stage <= 50) {
      dropChance = 0.10; // 10%
      boxDistribution = {WeaponBoxType.common: 1.0};
    } else if (stage <= 200) {
      dropChance = 0.15; // 15%
      boxDistribution = {WeaponBoxType.common: 0.75, WeaponBoxType.plain: 0.25};
    } else if (stage <= 500) {
      dropChance = 0.20; // 20%
      boxDistribution = {
        WeaponBoxType.common: 0.50,
        WeaponBoxType.plain: 0.25,
        WeaponBoxType.rare: 0.15,
        WeaponBoxType.shiny: 0.10,
      };
    } else if (stage <= 1000) {
      dropChance = 0.25; // 25%
      boxDistribution = {
        WeaponBoxType.common: 0.35,
        WeaponBoxType.plain: 0.25,
        WeaponBoxType.rare: 0.20,
        WeaponBoxType.shiny: 0.12,
        WeaponBoxType.mystic: 0.08,
      };
    } else {
      // 1001 - 2000
      dropChance = 0.30; // 30%
      boxDistribution = {
        WeaponBoxType.common: 0.25,
        WeaponBoxType.plain: 0.20,
        WeaponBoxType.rare: 0.18,
        WeaponBoxType.shiny: 0.12,
        WeaponBoxType.mystic: 0.12,
        WeaponBoxType.holy: 0.13,
      };
    }

    if (_random.nextDouble() > dropChance) {
      return null;
    }

    WeaponBoxType droppedBoxType = _getWeightedRandom(boxDistribution);

    return GachaBox(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      boxType: droppedBoxType,
      stageLevel: stage,
    );
  }

  GachaBox getDropForBoss(int stage, List<String> defeatedBossNames) {
    Map<WeaponBoxType, double> boxDistribution;
    String bossId = 'boss_stage_$stage';

    if (stage == 500 && !defeatedBossNames.contains(bossId)) {
      return GachaBox(
        id: bossId,
        boxType: WeaponBoxType.mystic,
        stageLevel: stage,
      );
    }
    if (stage == 1000 && !defeatedBossNames.contains(bossId)) {
      return GachaBox(
        id: bossId,
        boxType: WeaponBoxType.holy,
        stageLevel: stage,
      );
    }

    if (stage <= 50) {
      boxDistribution = {WeaponBoxType.common: 1.0};
    } else if (stage <= 200) {
      boxDistribution = {WeaponBoxType.common: 0.7, WeaponBoxType.plain: 0.3};
    } else if (stage <= 500) {
      boxDistribution = {
        WeaponBoxType.common: 0.40,
        WeaponBoxType.plain: 0.35,
        WeaponBoxType.rare: 0.20,
        WeaponBoxType.shiny: 0.05,
      };
    } else if (stage <= 1000) {
      boxDistribution = {
        WeaponBoxType.common: 0.30,
        WeaponBoxType.plain: 0.25,
        WeaponBoxType.rare: 0.20,
        WeaponBoxType.shiny: 0.15,
        WeaponBoxType.mystic: 0.10,
      };
    } else {
      // 1001 - 2000
      boxDistribution = {
        WeaponBoxType.common: 0.20,
        WeaponBoxType.plain: 0.20,
        WeaponBoxType.rare: 0.18,
        WeaponBoxType.shiny: 0.15,
        WeaponBoxType.mystic: 0.15,
        WeaponBoxType.holy: 0.12,
      };
    }

    WeaponBoxType droppedBoxType = _getWeightedRandom(boxDistribution);

    return GachaBox(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      boxType: droppedBoxType,
      stageLevel: stage,
    );
  }

  Weapon getWeaponFromBox(GachaBox box, int highestStageCleared) {
    Rarity selectedRarity;
    Map<Rarity, double> rarityDistribution;

    switch (box.boxType) {
      case WeaponBoxType.common:
        rarityDistribution = {
          Rarity.common: 50,
          Rarity.uncommon: 30,
          Rarity.rare: 15,
          Rarity.unique: 4,
          Rarity.epic: 0.9,
          Rarity.legend: 0.1,
        };
        break;
      case WeaponBoxType.plain:
        rarityDistribution = {
          Rarity.uncommon: 45,
          Rarity.rare: 30,
          Rarity.unique: 15,
          Rarity.epic: 9,
          Rarity.legend: 1,
        };
        break;
      case WeaponBoxType.rare:
        rarityDistribution = {
          Rarity.rare: 75,
          Rarity.unique: 15,
          Rarity.epic: 7.5,
          Rarity.legend: 2.5,
        };
        break;
      case WeaponBoxType.shiny:
        rarityDistribution = {
          Rarity.uncommon: 30,
          Rarity.rare: 35,
          Rarity.unique: 23,
          Rarity.epic: 9,
          Rarity.legend: 3,
        };
        break;
      case WeaponBoxType.mystic:
        rarityDistribution = {
          Rarity.uncommon: 30,
          Rarity.rare: 25,
          Rarity.unique: 20,
          Rarity.epic: 15,
          Rarity.legend: 9,
          Rarity.demigod: 1,
        };
        break;
      case WeaponBoxType.holy:
        rarityDistribution = {
          Rarity.uncommon: 10,
          Rarity.rare: 25,
          Rarity.unique: 35,
          Rarity.epic: 16,
          Rarity.legend: 9,
          Rarity.demigod: 4,
          Rarity.god: 1,
        };
        break;
      case WeaponBoxType.gamble:
        rarityDistribution = {
          Rarity.common: 15,
          Rarity.uncommon: 20,
          Rarity.rare: 20,
          Rarity.unique: 23,
          Rarity.epic: 12,
          Rarity.legend: 7,
          Rarity.demigod: 2.5,
          Rarity.god: 0.5,
        };
        break;
      case WeaponBoxType.guaranteedUnique:
        rarityDistribution = {Rarity.unique: 1};
        break;
      case WeaponBoxType.guaranteedEpic:
        rarityDistribution = {Rarity.epic: 1};
        break;
      case WeaponBoxType.guaranteedLegend:
        rarityDistribution = {Rarity.legend: 1};
        break;
      case WeaponBoxType.guaranteedDemigod:
        rarityDistribution = {Rarity.demigod: 1};
        break;
      case WeaponBoxType.guaranteedGod:
        rarityDistribution = {Rarity.god: 1};
        break;
    }

    selectedRarity = _getWeightedRandom(rarityDistribution);

    final stageLevelForLoot = box.boxType == WeaponBoxType.gamble
        ? highestStageCleared
        : box.stageLevel;

    final isAllRange =
        box.boxType == WeaponBoxType.gamble ||
        box.boxType == WeaponBoxType.guaranteedUnique ||
        box.boxType == WeaponBoxType.guaranteedEpic;

    return WeaponData.getWeaponForRarity(
      selectedRarity,
      currentStageLevel: stageLevelForLoot,
      isAllRange: isAllRange,
    );
  }
}
