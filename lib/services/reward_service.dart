import 'dart:math';
import 'package:ryan_clicker_rpg/models/gacha_box.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart';

class RewardService {
  final Random _random = Random();

  GachaBox? getDropForNormalMonster(int currentStage) {
    // 10% chance to drop a box
    if (_random.nextDouble() < 0.1) {
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
    bool isAllRange = box.boxType == WeaponBoxType.gamble;

    return WeaponData.getWeaponFromBox(
      box.boxType,
      box.stageLevel,
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

    if (stage >= 1800) return WeaponBoxType.mystic;
    if (stage >= 1500) return WeaponBoxType.shiny;
    if (stage >= 1000) return WeaponBoxType.rare;
    if (stage >= 500) return WeaponBoxType.plain;
    return WeaponBoxType.common;
  }
}
