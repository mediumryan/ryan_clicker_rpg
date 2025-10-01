import 'dart:math';
import 'package:ryan_clicker_rpg/models/gacha_box.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart';

class RewardService {
  final Random _random = Random();

  GachaBox? getDropForNormalMonster(int currentStage) {
    // 20% chance to drop a box
    if (_random.nextDouble() < 0.2) {
      return GachaBox(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        boxType: _getBoxTypeForStage(currentStage),
        stageLevel: currentStage,
      );
    }
    return null;
  }

  GachaBox? getDropForBoss(int currentStage, List<String> defeatedBosses) {
    // Guaranteed drop for bosses
    return GachaBox(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      boxType: _getBoxTypeForStage(currentStage, isBoss: true),
      stageLevel: currentStage,
    );
  }

  Weapon getWeaponFromBox(GachaBox box, int highestStageCleared) {
    bool isAllRange = box.isAllRange;

    return WeaponData.getWeaponFromBox(
      box.boxType,
      isAllRange ? highestStageCleared : box.stageLevel,
      isAllRange: isAllRange,
    );
  }

  WeaponBoxType _getBoxTypeForStage(int stage, {bool isBoss = false}) {
    if (isBoss) {
      if (stage >= 1800) return WeaponBoxType.holy;
      if (stage >= 1500) return WeaponBoxType.mystic;
      if (stage >= 1000) return WeaponBoxType.shiny;
      if (stage >= 500) return WeaponBoxType.rare;
      return WeaponBoxType.plain;
    }

    // Logic for normal monsters
    final randomValue = _random.nextDouble();

    if (stage <= 50) {
      return WeaponBoxType.common;
    } else if (stage <= 200) {
      if (randomValue < 0.75) return WeaponBoxType.common;
      return WeaponBoxType.plain;
    } else if (stage <= 500) {
      if (randomValue < 0.50) return WeaponBoxType.common;
      if (randomValue < 0.75) return WeaponBoxType.plain;
      if (randomValue < 0.90) return WeaponBoxType.rare;
      return WeaponBoxType.shiny;
    } else if (stage <= 1000) {
      if (randomValue < 0.35) return WeaponBoxType.common;
      if (randomValue < 0.60) return WeaponBoxType.plain;
      if (randomValue < 0.80) return WeaponBoxType.rare;
      if (randomValue < 0.92) return WeaponBoxType.shiny;
      return WeaponBoxType.mystic;
    } else {
      // stage > 1000
      if (randomValue < 0.25) return WeaponBoxType.common;
      if (randomValue < 0.50) return WeaponBoxType.plain;
      if (randomValue < 0.75) return WeaponBoxType.rare;
      if (randomValue < 0.91) return WeaponBoxType.shiny;
      if (randomValue < 0.96) return WeaponBoxType.mystic;
      return WeaponBoxType.holy;
    }
  }
}
