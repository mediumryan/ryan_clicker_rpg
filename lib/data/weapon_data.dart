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
      final String jsonString = await rootBundle.loadString(
        'assets/data/weapons.json',
      );
      print('Loaded jsonString length: ${jsonString.length}'); // Debug print
      print('JSON String: ${jsonString.substring(0, min(jsonString.length, 500))}'); // Print first 500 chars of JSON
      final List<dynamic> jsonList = json.decode(jsonString);

      // The fromJson factory now expects a Map<String, dynamic>, which is correct.
      _baseWeapons = jsonList.map((json) => Weapon.fromJson(json)).toList();
      _isInitialized = true;
      print(
        'WeaponData initialized. Loaded ${_baseWeapons.length} weapons.',
      ); // Debug print

      // Add debug print for first 25 weapons
      for (int i = 0; i < min(25, _baseWeapons.length); i++) {
        final weapon = _baseWeapons[i];
        print(
          'Weapon ${i + 1}: ID=${weapon.id}, Name=${weapon.name}, BaseLevel=${weapon.baseLevel}, Damage=${weapon.calculatedDamage.toStringAsFixed(0)}',
        );
      }
    } catch (e) {
      print('Error initializing WeaponData: $e');
      // Handle error, maybe load some default data or show an error state
    }
  }

  static Weapon? getRandomWeaponDrop() {
    if (!_isInitialized || _baseWeapons.isEmpty) {
      print("WeaponData not initialized. Call WeaponData.initialize() first.");
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
      print("WeaponData not initialized. Returning a default starting weapon.");
      return Weapon.startingWeapon();
    }
    return _baseWeapons[Random().nextInt(_baseWeapons.length)].copyWith();
  }

  static Weapon getWeaponForStageLevel(int stageLevel) {
    if (!_isInitialized || _baseWeapons.isEmpty) {
      print(
        "WeaponData not initialized. Returning a default starting weapon for stage level.",
      );
      return Weapon.startingWeapon();
    }

    final targetBaseLevel = (stageLevel ~/ 25) * 25;
    print(
      'Target Base Level: $targetBaseLevel for Stage: $stageLevel',
    ); // Debug print

    final availableWeapons = _baseWeapons
        .where((weapon) => weapon.baseLevel == targetBaseLevel)
        .toList();

    print(
      'Available Weapons count for targetBaseLevel $targetBaseLevel: ${availableWeapons.length}',
    ); // Debug print
    if (availableWeapons.isNotEmpty) {
      print(
        'First available weapon damage: ${availableWeapons.first.calculatedDamage.toStringAsFixed(0)}',
      ); // Debug print
    }

    if (availableWeapons.isEmpty) {
      print(
        "No weapons found for baseLevel $targetBaseLevel. Returning a random weapon from all available.",
      );
      // Fallback: if no specific level weapon found, return any random weapon
      return _baseWeapons[Random().nextInt(_baseWeapons.length)].copyWith();
    }

    return availableWeapons[Random().nextInt(availableWeapons.length)]
        .copyWith();
  }

  // Optional: A way to access all base weapons if needed elsewhere
  static List<Weapon> getAllWeapons() {
    if (!_isInitialized) {
      print("WeaponData not initialized.");
      return [];
    }
    return List<Weapon>.from(_baseWeapons);
  }
}
