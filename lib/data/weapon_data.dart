import 'package:flutter/material.dart'; // For Color
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ryan_clicker_rpg/models/gacha_box.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';

class WeaponData {
  static final List<Map<String, dynamic>> gachaBoxInfo = [
    {
      'boxType': WeaponBoxType.common,
      'name': '흔한 무기상자',
      'description': '획득한 스테이지 기준 레벨의 커먼~에픽 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.common, 'percent': 50.0},
        {'rarity': Rarity.uncommon, 'percent': 35.0},
        {'rarity': Rarity.rare, 'percent': 10.0},
        {'rarity': Rarity.unique, 'percent': 4.5},
        {'rarity': Rarity.epic, 'percent': 0.5},
      ],
    },
    {
      'boxType': WeaponBoxType.plain,
      'name': '평범한 무기상자',
      'description': '획득한 스테이지 기준 레벨의 커먼~레전드 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.common, 'percent': 35.0},
        {'rarity': Rarity.uncommon, 'percent': 33.0},
        {'rarity': Rarity.rare, 'percent': 24.0},
        {'rarity': Rarity.unique, 'percent': 6.0},
        {'rarity': Rarity.epic, 'percent': 1.5},
        {'rarity': Rarity.legend, 'percent': 0.5},
      ],
    },
    {
      'boxType': WeaponBoxType.rare,
      'name': '희귀한 무기상자',
      'description': '획득한 스테이지 기준 레벨의 커먼~레전드 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.common, 'percent': 30.0},
        {'rarity': Rarity.uncommon, 'percent': 33.0},
        {'rarity': Rarity.rare, 'percent': 25.0},
        {'rarity': Rarity.unique, 'percent': 8.0},
        {'rarity': Rarity.epic, 'percent': 3.0},
        {'rarity': Rarity.legend, 'percent': 1.0},
      ],
    },
    {
      'boxType': WeaponBoxType.shiny,
      'name': '빛나는 무기상자',
      'description': '획득한 스테이지 기준 레벨의 언커먼~레전드 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.common, 'percent': 20.0},
        {'rarity': Rarity.uncommon, 'percent': 28.0},
        {'rarity': Rarity.rare, 'percent': 25.0},
        {'rarity': Rarity.unique, 'percent': 15.0},
        {'rarity': Rarity.epic, 'percent': 9.0},
        {'rarity': Rarity.legend, 'percent': 1.0},
      ],
    },
    {
      'boxType': WeaponBoxType.mystic,
      'name': '신비로운 무기상자',
      'description': '획득한 스테이지 기준 레벨의 언커먼~데미갓 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.uncommon, 'percent': 20.0},
        {'rarity': Rarity.rare, 'percent': 30.0},
        {'rarity': Rarity.unique, 'percent': 35.0},
        {'rarity': Rarity.epic, 'percent': 10.0},
        {'rarity': Rarity.legend, 'percent': 4.9},
        {'rarity': Rarity.demigod, 'percent': 0.1},
      ],
    },
    {
      'boxType': WeaponBoxType.holy,
      'name': '신성한 기운이 감도는 무기상자',
      'description': '획득한 스테이지 기준 레벨의 레어~갓 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.rare, 'percent': 25.0},
        {'rarity': Rarity.unique, 'percent': 35.0},
        {'rarity': Rarity.epic, 'percent': 25.0},
        {'rarity': Rarity.legend, 'percent': 12.5},
        {'rarity': Rarity.demigod, 'percent': 2.4},
        {'rarity': Rarity.god, 'percent': 0.1},
      ],
    },
    {
      'boxType': WeaponBoxType.gamble,
      'name': '무기 갬블상자',
      'description': '현재 클리어한 최대 스테이지 기준 레벨의 커먼~갓 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.common, 'percent': 30.0},
        {'rarity': Rarity.uncommon, 'percent': 30.0},
        {'rarity': Rarity.rare, 'percent': 25.0},
        {'rarity': Rarity.unique, 'percent': 8.0},
        {'rarity': Rarity.epic, 'percent': 4.0},
        {'rarity': Rarity.legend, 'percent': 2.0},
        {'rarity': Rarity.demigod, 'percent': 0.9},
        {'rarity': Rarity.god, 'percent': 0.1},
      ],
    },
    {
      'boxType': WeaponBoxType.guaranteedUnique,
      'name': '유니크 등급 무기상자',
      'description': '현재 클리어한 최대 스테이지 기준 레벨의 유니크 등급무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.unique, 'percent': 100.0},
      ],
    },
    {
      'boxType': WeaponBoxType.guaranteedEpic,
      'name': '에픽 등급 무기상자',
      'description': '현재 클리어한 최대 스테이지 기준 레벨의 에픽 등급 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.epic, 'percent': 100.0},
      ],
    },
    {
      'boxType': WeaponBoxType.guaranteedLegend,
      'name': '레전드 등급 무기상자',
      'description': '현재 클리어한 최대 스테이지 기준 레벨의 레전드 등급 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.legend, 'percent': 100.0},
      ],
    },
    {
      'boxType': WeaponBoxType.guaranteedDemigod,
      'name': '데미갓 등급 무기상자',
      'description': '현재 클리어한 최대 스테이지 기준 레벨의 데미갓 등급 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.demigod, 'percent': 100.0},
      ],
    },
    {
      'boxType': WeaponBoxType.guaranteedGod,
      'name': '갓 등급 무기상자',
      'description': '현재 클리어한 최대 스테이지 기준 레벨의 갓 등급 무기가 랜덤으로 1개 들어있습니다.',
      'probabilities': [
        {'rarity': Rarity.god, 'percent': 100.0},
      ],
    },
  ];
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
        return '커먼';
      case Rarity.uncommon:
        return '언커먼';
      case Rarity.rare:
        return '레어';
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
      case WeaponType.none:
        return '없음';
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
        'assets/data/epic_weapons.json',
      );
      final String legendJsonString = await rootBundle.loadString(
        'assets/data/legend_weapons.json',
      );
      final String demigodJsonString = await rootBundle.loadString(
        'assets/data/demigod_weapons.json',
      );
      final String godJsonString = await rootBundle.loadString(
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
      _epicWeapons = (json.decode(epicJsonString) as List)
          .map((json) => Weapon.fromJson(json))
          .toList();
      _legendWeapons = (json.decode(legendJsonString) as List)
          .map((json) => Weapon.fromJson(json))
          .toList();
      _demigodWeapons = (json.decode(demigodJsonString) as List)
          .map((json) => Weapon.fromJson(json))
          .toList();
      _godWeapons = (json.decode(godJsonString) as List)
          .map((json) => Weapon.fromJson(json))
          .toList();

      _allWeapons = [
        ..._commonWeapons,
        ..._uncommonWeapons,
        ..._rareWeapons,
        ..._uniqueWeapons,
        ..._epicWeapons,
        ..._legendWeapons,
        ..._demigodWeapons,
        ..._godWeapons,
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

  static Weapon getWeaponFromBox(
    WeaponBoxType boxType,
    int stageLevel, {
    bool isAllRange = false,
  }) {
    if (!_isInitialized || _allWeapons.isEmpty) {
      return Weapon.startingWeapon();
    }

    final boxInfo = gachaBoxInfo.firstWhere(
      (info) => info['boxType'] == boxType,
      orElse: () => gachaBoxInfo.first, // Fallback to common box
    );

    final probabilities =
        boxInfo['probabilities'] as List<Map<String, dynamic>>;

    final random = Random();
    double roll = random.nextDouble() * 100;
    double cumulative = 0;
    Rarity selectedRarity =
        probabilities.last['rarity'] as Rarity; // Default to last

    for (var prob in probabilities) {
      cumulative += prob['percent'] as double;
      if (roll < cumulative) {
        selectedRarity = prob['rarity'] as Rarity;
        break;
      }
    }

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
      if (currentStageLevel == null) {
        return Weapon.startingWeapon();
      }

      final targetBaseLevel = (currentStageLevel ~/ 25) * 25;

      // 1. Try to find a weapon at the exact targetBaseLevel
      List<Weapon> exactLevelCandidates = candidates
          .where((weapon) => weapon.baseLevel == targetBaseLevel)
          .toList();

      if (exactLevelCandidates.isNotEmpty) {
        return exactLevelCandidates[Random().nextInt(
              exactLevelCandidates.length,
            )]
            .copyWith();
      } else {
        // 2. If no exact level weapon, search for the closest available weapon level <= targetBaseLevel
        List<Weapon> lowerLevelCandidates = candidates
            .where((weapon) => weapon.baseLevel <= targetBaseLevel)
            .toList();

        if (lowerLevelCandidates.isNotEmpty) {
          // Find the highest baseLevel among the lowerLevelCandidates
          lowerLevelCandidates.sort(
            (a, b) => b.baseLevel.compareTo(a.baseLevel),
          );
          final highestAvailableBaseLevel =
              lowerLevelCandidates.first.baseLevel;

          // Filter for weapons at this highest available baseLevel
          List<Weapon> finalCandidates = lowerLevelCandidates
              .where((weapon) => weapon.baseLevel == highestAvailableBaseLevel)
              .toList();

          return finalCandidates[Random().nextInt(finalCandidates.length)]
              .copyWith();
        } else {
          // 3. Fallback to any weapon of this rarity if no weapon found for the level range
          return candidates[Random().nextInt(candidates.length)].copyWith();
        }
      }
    }
  }

  static List<Map<String, dynamic>> getWeaponDropProbabilitiesRichText() {
    return [
      {'text': '무기 드롭 확률:', 'color': Colors.white},
      {
        'text': '\n언커먼: 50%',
        'color': WeaponData.getColorForRarity(Rarity.common),
      },
      {
        'text': '\n커먼: 25%',
        'color': WeaponData.getColorForRarity(Rarity.uncommon),
      },
      {'text': '\n레어: 15%', 'color': WeaponData.getColorForRarity(Rarity.rare)},
      {
        'text': '\n유니크: 7%',
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

  static Weapon? getWeaponById(int id) {
    if (!_isInitialized) {
      return null;
    }
    try {
      return _allWeapons.firstWhere((weapon) => weapon.id == id).copyWith();
    } catch (e) {
      return null;
    }
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
