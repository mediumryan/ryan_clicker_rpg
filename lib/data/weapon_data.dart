import 'package:flutter/material.dart'; // For Color
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ryan_clicker_rpg/models/weapon.dart';

class WeaponData {
  static List<Weapon> _commonWeapons = [];
  static List<Weapon> _uncommonWeapons = [];
  static List<Weapon> _rareWeapons = [];
  static List<Weapon> _uniqueWeapons = [];
  static List<Weapon> _epicWeapons = []; // New
  static List<Weapon> _legendWeapons = []; // New
  static List<Weapon> _demigodWeapons = []; // New
  static List<Weapon> _godWeapons = []; // New
  static List<Weapon> _allWeapons = []; // For fallback and other uses
  static bool _isInitialized = false;

  static List<Weapon> get uniqueWeapons => _uniqueWeapons;
  static List<Weapon> get epicWeapons => _epicWeapons;

  // Helper to map rarity to a color (similar to inventory_screen.dart)
  static Color getColorForRarity(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return Colors.grey[400]!;
      case Rarity.uncommon:
        return Colors.green;
      case Rarity.rare:
        return Colors.blue;
      case Rarity.unique:
        return Colors.purple;
      case Rarity.epic:
        return Colors.orange;
      case Rarity.legend:
        return Colors.red;
      case Rarity.demigod:
        return Colors.cyan; // New color for Demigod
      case Rarity.god:
        return Colors.amber; // New color for God
    }
  }

  static String getKoreanRarity(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return '흔함';
      case Rarity.uncommon:
        return '평범';
      case Rarity.rare:
        return '희귀';
      case Rarity.unique:
        return '유니크';
      case Rarity.epic:
        return '에픽';
      case Rarity.legend:
        return '레전드';
      case Rarity.demigod:
        return '데미갓';
      case Rarity.god:
        return '갓';
    }
  }

  static String getKoreanWeaponType(WeaponType type) {
    switch (type) {
      case WeaponType.rapier:
        return '레이피어';
      case WeaponType.katana:
        return '카타나';
      case WeaponType.sword:
        return '검';
      case WeaponType.greatsword:
        return '대검';
      case WeaponType.scimitar:
        return '시미터';
      case WeaponType.dagger:
        return '단검';
      case WeaponType.cleaver:
        return '클리버';
      case WeaponType.battleAxe:
        return '전투 도끼';
      case WeaponType.warhammer:
        return '워해머';
      case WeaponType.spear:
        return '창';
      case WeaponType.staff:
        return '지팡이';
      case WeaponType.trident:
        return '삼지창';
      case WeaponType.mace:
        return '철퇴';
      case WeaponType.scythe:
        return '낫';
      case WeaponType.curvedSword:
        return '곡선형 검';
      case WeaponType.nunchaku:
        return '쌍절곤';
    }
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final String commonJsonString = await rootBundle.loadString(
        'assets/data/common_weapons.json',
      );
      final String uncommonJsonString = await rootBundle.loadString(
        'assets/data/uncommon_weapons.json',
      );
      final String rareJsonString = await rootBundle.loadString(
        'assets/data/rare_weapons.json',
      );
      final String uniqueJsonString = await rootBundle.loadString(
        'assets/data/unique_weapons.json',
      );
      final String epicJsonString = await rootBundle.loadString(
        // New
        'assets/data/epic_weapons.json',
      );
      final String legendJsonString = await rootBundle.loadString(
        // New
        'assets/data/legend_weapons.json',
      );
      final String demigodJsonString = await rootBundle.loadString(
        // New
        'assets/data/demigod_weapons.json',
      );
      final String godJsonString = await rootBundle.loadString(
        // New
        'assets/data/god_weapons.json',
      );

      _commonWeapons = (json.decode(commonJsonString) as List)
          .map((json) => Weapon.fromJson(json))
          .toList();
      _uncommonWeapons = (json.decode(uncommonJsonString) as List)
          .map((json) => Weapon.fromJson(json))
          .toList();
      _rareWeapons = (json.decode(rareJsonString) as List)
          .map((json) => Weapon.fromJson(json))
          .toList();
      _uniqueWeapons = (json.decode(uniqueJsonString) as List)
          .map((json) => Weapon.fromJson(json))
          .toList();
      _epicWeapons =
          (json.decode(epicJsonString) as List) // New
              .map((json) => Weapon.fromJson(json))
              .toList();
      _legendWeapons =
          (json.decode(legendJsonString) as List) // New
              .map((json) => Weapon.fromJson(json))
              .toList();
      _demigodWeapons =
          (json.decode(demigodJsonString) as List) // New
              .map((json) => Weapon.fromJson(json))
              .toList();
      _godWeapons =
          (json.decode(godJsonString) as List) // New
              .map((json) => Weapon.fromJson(json))
              .toList();

      _allWeapons = [
        ..._commonWeapons,
        ..._uncommonWeapons,
        ..._rareWeapons,
        ..._uniqueWeapons,
        ..._epicWeapons, // New
        ..._legendWeapons, // New
        ..._demigodWeapons, // New
        ..._godWeapons, // New
      ];

      _isInitialized = true;
    } catch (e, stacktrace) {
      debugPrint('ERROR: Failed to initialize WeaponData: $e\n$stacktrace');
    }
  }

  static Weapon? getRandomWeaponDrop() {
    if (!_isInitialized || _allWeapons.isEmpty) {
      return null;
    }

    // 10% chance to drop a weapon
    if (Random().nextDouble() < 0.1) {
      return _allWeapons[Random().nextInt(_allWeapons.length)].copyWith();
    }
    return null;
  }

  static Weapon getGuaranteedRandomWeapon() {
    if (!_isInitialized || _allWeapons.isEmpty) {
      return Weapon.startingWeapon();
    }
    return _allWeapons[Random().nextInt(_allWeapons.length)].copyWith();
  }

  static Weapon getWeaponForStageLevel(
    int stageLevel, {
    Rarity? guaranteedRarity,
    bool isAllRange = false,
  }) {
    if (!_isInitialized || _allWeapons.isEmpty) {
      return Weapon.startingWeapon();
    }

    Rarity selectedRarity;

    if (guaranteedRarity != null) {
      selectedRarity = guaranteedRarity;
    } else {
      final random = Random();
      double roll = random.nextDouble();

      // Define rarity probabilities for monster chest drops (up to Legend)
      // Common: 50% (0.0 to 0.50)
      if (roll < 0.50) {
        selectedRarity = Rarity.common;
      }
      // Uncommon: 25% (0.50 to 0.75)
      else if (roll < 0.75) {
        selectedRarity = Rarity.uncommon;
      }
      // Rare: 15% (0.75 to 0.90)
      else if (roll < 0.90) {
        selectedRarity = Rarity.rare;
      }
      // Unique: 7% (0.90 to 0.97)
      else if (roll < 0.97) {
        selectedRarity = Rarity.unique;
      }
      // Epic: 2% (0.97 to 0.99)
      else if (roll < 0.99) {
        selectedRarity = Rarity.epic;
      }
      // Legend: 1% (0.99 to 1.00)
      else {
        selectedRarity = Rarity.legend;
      }
    }

    // Use the new helper method
    return getWeaponForRarity(
      selectedRarity,
      isAllRange: isAllRange,
      currentStageLevel: stageLevel,
    );
  }

  static Weapon getWeaponForRarity(
    Rarity rarity, {
    bool isAllRange = false,
    int? currentStageLevel,
  }) {
    List<Weapon> candidates = [];
    switch (rarity) {
      case Rarity.common:
        candidates = _commonWeapons;
        break;
      case Rarity.uncommon:
        candidates = _uncommonWeapons;
        break;
      case Rarity.rare:
        candidates = _rareWeapons;
        break;
      case Rarity.unique:
        candidates = _uniqueWeapons;
        break;
      case Rarity.epic:
        candidates = _epicWeapons;
        break;
      case Rarity.legend:
        candidates = _legendWeapons;
        break;
      case Rarity.demigod:
        candidates = _demigodWeapons;
        break;
      case Rarity.god:
        candidates = _godWeapons;
        break;
    }

    if (candidates.isEmpty) {
      return Weapon.startingWeapon(); // Fallback
    }

    if (isAllRange) {
      return candidates[Random().nextInt(candidates.length)].copyWith();
    } else {
      // Filter by currentStageLevel or below
      if (currentStageLevel == null) {
        return Weapon.startingWeapon(); // Fallback if currentStageLevel is not provided for non-all-range
      }
      final targetBaseLevel = (currentStageLevel ~/ 25) * 25;
      List<Weapon> filteredCandidates = candidates
          .where((weapon) => weapon.baseLevel <= targetBaseLevel)
          .toList();

      if (filteredCandidates.isEmpty) {
        // Fallback to any weapon of this rarity if no weapon found for the level range
        return candidates[Random().nextInt(candidates.length)].copyWith();
      }
      return filteredCandidates[Random().nextInt(filteredCandidates.length)]
          .copyWith();
    }
  }

  static List<Map<String, dynamic>> getWeaponDropProbabilitiesRichText() {
    return [
      {'text': '무기 드롭 확률:', 'color': Colors.white},
      {
        'text': '\n흔함: 50%',
        'color': WeaponData.getColorForRarity(Rarity.common),
      },
      {
        'text': '\n평범: 25%',
        'color': WeaponData.getColorForRarity(Rarity.uncommon),
      }, // Changed to 평범
      {'text': '\n희귀: 15%', 'color': WeaponData.getColorForRarity(Rarity.rare)},
      {
        'text': '\n고유: 7%',
        'color': WeaponData.getColorForRarity(Rarity.unique),
      },
      {'text': '\n에픽: 2%', 'color': WeaponData.getColorForRarity(Rarity.epic)},
      {
        'text': '\n레전드: 1%',
        'color': WeaponData.getColorForRarity(Rarity.legend),
      },
    ];
  }

  // Optional: A way to access all base weapons if needed elsewhere
  static List<Weapon> getAllWeapons() {
    if (!_isInitialized) {
      return [];
    }
    return List<Weapon>.from(_allWeapons);
  }

  static double getDefaultAccuracyForRarity(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return 0.7;
      case Rarity.uncommon:
        return 0.75;
      case Rarity.rare:
        return 0.8;
      default: // For unique, epic, legend, demigod, god
        return 1.0; // Or some other default for higher rarities
    }
  }
}
