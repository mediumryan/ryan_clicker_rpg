import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ryan_clicker_rpg/models/weapon.dart';

class WeaponData {
  static List<Weapon> _baseWeapons = [];
  static bool _isInitialized = false;

  // Call this method from main.dart to load data at startup
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String commonJsonString = await rootBundle.loadString(
        'assets/data/common_weapons.json',
      );
      final String uncommonJsonString = await rootBundle.loadString(
        'assets/data/uncommon_weapons.json',
      );
      final String uniqueJsonString = await rootBundle.loadString(
        'assets/data/unique_weapons.json',
      );
      final String rareJsonString = await rootBundle.loadString(
        'assets/data/rare_weapons.json',
      );

      final List<dynamic> commonJsonList = json.decode(commonJsonString);
      final List<dynamic> uncommonJsonList = json.decode(uncommonJsonString);
      final List<dynamic> rareJsonList = json.decode(rareJsonString);
      final List<dynamic> uniqueJsonList = json.decode(uniqueJsonString);

      _baseWeapons = [
        ...commonJsonList.map((json) => Weapon.fromJson(json)),
        ...uncommonJsonList.map((json) => Weapon.fromJson(json)),
        ...rareJsonList.map((json) => Weapon.fromJson(json)),
        ...uniqueJsonList.map((json) => Weapon.fromJson(json)),
      ].toList();
      _isInitialized = true;
    } catch (e, stacktrace) {
      print('ERROR: Failed to initialize WeaponData: $e\n$stacktrace');
    }
  }

  static Weapon? getRandomWeaponDrop() {
    if (!_isInitialized || _baseWeapons.isEmpty) {
      return null;
    }

    // 10% chance to drop a weapon
    if (Random().nextDouble() < 0.1) {
      return _baseWeapons[Random().nextInt(_baseWeapons.length)].copyWith();
    }
    return null;
  }

  static Weapon getGuaranteedRandomWeapon() {
    if (!_isInitialized || _baseWeapons.isEmpty) {
      return Weapon.startingWeapon();
    }
    return _baseWeapons[Random().nextInt(_baseWeapons.length)].copyWith();
  }

  static Weapon getWeaponForStageLevel(int stageLevel) {
    if (!_isInitialized || _baseWeapons.isEmpty) {
      return Weapon.startingWeapon();
    }

    final targetBaseLevel = (stageLevel ~/ 25) * 25;

    final availableWeapons = _baseWeapons
        .where((weapon) => weapon.baseLevel == targetBaseLevel)
        .toList();

    if (availableWeapons.isEmpty) {
      // Fallback: if no specific level weapon found, return any random weapon
      return _baseWeapons[Random().nextInt(_baseWeapons.length)].copyWith();
    }

    return availableWeapons[Random().nextInt(availableWeapons.length)]
        .copyWith();
  }

  // Optional: A way to access all base weapons if needed elsewhere
  static List<Weapon> getAllWeapons() {
    if (!_isInitialized) {
      return [];
    }
    return List<Weapon>.from(_baseWeapons);
  }
}
