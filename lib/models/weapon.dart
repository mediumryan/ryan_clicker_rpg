import 'dart:math';

enum Rarity { common, uncommon, rare, unique, epic, legend, demigod, god }

enum WeaponType {
  rapier,
  katana,
  sword,
  greatsword,
  scimitar,
  dagger,
  cleaver,
  battleAxe,
  warhammer,
  spear,
  staff,
  trident,
  mace,
  scythe,
  curvedSword,
  nunchaku,
}

class Weapon {
  final int id;
  final String name;
  final String imageName;
  final Rarity rarity;
  final WeaponType type;
  final int baseLevel;
  int enhancement;
  int transcendence;
  final double baseDamage; // New: Base damage
  double criticalChance;
  double criticalDamage;
  double baseSellPrice;
  String? description;
  double defensePenetration;
  double doubleAttackChance;
  double speed;

  // Resources invested in this weapon
  double investedGold;
  int investedEnhancementStones;
  int investedTranscendenceStones;

  // Skills
  List<Map<String, dynamic>> skills;

  int get maxTranscendence => 5;

  int get maxEnhancement => 5;

  double get calculatedDamage {
    double currentDamage = baseDamage;

    // Apply enhancement multipliers
    const enhancementMultipliers = [1.05, 1.07, 1.10, 1.15, 1.20];
    print(
      'DEBUG: enhancement: $enhancement, multipliers length: ${enhancementMultipliers.length}',
    ); // ADD THIS LINE
    for (int i = 0; i < enhancement; i++) {
      print('DEBUG: i: $i, accessing index: $i'); // ADD THIS LINE
      if (i < enhancementMultipliers.length) {
        currentDamage *= enhancementMultipliers[i];
      }
    }

    // Apply transcendence multipliers
    const transcendenceMultipliers = [1.75, 2.25, 2.75, 3.25, 4.0];
    for (int i = 0; i < transcendence; i++) {
      if (i < transcendenceMultipliers.length) {
        currentDamage *= transcendenceMultipliers[i];
      }
    }

    return currentDamage;
  }

  Weapon({
    required this.id,
    required this.name,
    required this.imageName,
    required this.rarity,
    required this.type,
    required this.baseLevel,
    this.enhancement = 0,
    this.transcendence = 0,
    required this.baseDamage,
    required this.criticalChance,
    required this.criticalDamage,
    required this.baseSellPrice,
    this.investedGold = 0,
    this.investedEnhancementStones = 0,
    this.investedTranscendenceStones = 0,
    this.description,
    this.defensePenetration = 0.0,
    this.doubleAttackChance = 0.0,
    this.speed = 1.0,
    this.skills = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageName': imageName,
    'rarity': rarity.toString(),
    'type': type.toString(),
    'baseLevel': baseLevel,
    'enhancement': enhancement,
    'transcendence': transcendence,
    'baseDamage': baseDamage,
    'criticalChance': criticalChance,
    'criticalDamage': criticalDamage,
    'baseSellPrice': baseSellPrice,
    'investedGold': investedGold,
    'investedEnhancementStones': investedEnhancementStones,
    'investedTranscendenceStones': investedTranscendenceStones,
    'description': description,
    'defensePenetration': defensePenetration,
    'doubleAttackChance': doubleAttackChance,
    'speed': speed,
    'skills': skills,
  };

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'],
      name: json['name'],
      imageName: json['imageName'] ?? '',
      rarity: Rarity.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            json['rarity'].toString().split('.').last.toLowerCase(),
        orElse: () {
          print(
            'WARNING: Unknown rarity: ${json['rarity']}. Defaulting to common.',
          );
          return Rarity.common;
        },
      ),
      type: WeaponType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            json['type'].toString().toLowerCase(),
        orElse: () {
          print(
            'WARNING: Unknown weapon type: ${json['type']}. Defaulting to rapier.',
          );
          return WeaponType.rapier;
        },
      ),
      baseLevel: json['baseLevel'],
      enhancement: json['enhancement'] ?? 0,
      transcendence: json['transcendence'] ?? 0,
      baseDamage: json['baseDamage'] ?? json['damage'] ?? 0.0,
      criticalChance: json['criticalChance'] ?? 0.0,
      criticalDamage: json['criticalDamage'] ?? 0.0,
      baseSellPrice: json['baseSellPrice'] ?? 0.0,
      investedGold: json['investedGold'] ?? 0.0,
      investedEnhancementStones: json['investedEnhancementStones'] ?? 0,
      investedTranscendenceStones: json['investedTranscendenceStones'] ?? 0,
      description: json['description'],
      defensePenetration: json['defensePenetration'] ?? 0.0,
      doubleAttackChance: json['doubleAttackChance'] ?? 0.0,
      speed: json['speed'] ?? 1.0,
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );
  }

  factory Weapon.startingWeapon() {
    return Weapon(
      id: 1, // Changed to ID 1 for rusty crude rapier
      name: '녹슨 조잡한 레이피어',
      imageName: 'group1/rusty_crude_rapier.png',
      rarity: Rarity.common,
      type: WeaponType.rapier,
      baseLevel: 0,
      baseDamage: 100.0, // Changed from damage to baseDamage
      criticalChance: 0.1,
      criticalDamage: 1.35,
      baseSellPrice: 125.0,
    );
  }

  Weapon copyWith({
    int? id,
    String? name,
    String? imageName,
    Rarity? rarity,
    WeaponType? type,
    int? baseLevel,
    int? enhancement,
    int? transcendence,
    double? baseDamage,
    double? criticalChance,
    double? criticalDamage,
    double? baseSellPrice,
    double? investedGold,
    int? investedEnhancementStones,
    int? investedTranscendenceStones,
    String? description,
    double? defensePenetration,
    double? doubleAttackChance,
    double? speed,
    List<Map<String, dynamic>>? skills,
  }) {
    return Weapon(
      id: id ?? this.id,
      name: name ?? this.name,
      imageName: imageName ?? this.imageName,
      rarity: rarity ?? this.rarity,
      type: type ?? this.type,
      baseLevel: baseLevel ?? this.baseLevel,
      enhancement: enhancement ?? this.enhancement,
      transcendence: transcendence ?? this.transcendence,
      baseDamage: baseDamage ?? this.baseDamage,
      criticalChance: criticalChance ?? this.criticalChance,
      criticalDamage: criticalDamage ?? this.criticalDamage,
      baseSellPrice: baseSellPrice ?? this.baseSellPrice,
      investedGold: investedGold ?? this.investedGold,
      investedEnhancementStones:
          investedEnhancementStones ?? this.investedEnhancementStones,
      investedTranscendenceStones:
          investedTranscendenceStones ?? this.investedTranscendenceStones,
      description: description ?? this.description,
      defensePenetration: defensePenetration ?? this.defensePenetration,
      doubleAttackChance: doubleAttackChance ?? this.doubleAttackChance,
      speed: speed ?? this.speed,
      skills: skills ?? this.skills,
    );
  }
}
