import 'dart:math';

enum Rarity { common, uncommon, rare, unique, epic, legend, demigod, god }

enum SpecialAbilityType { onHitProcDamage }

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

  // Resources invested in this weapon
  double investedGold;
  int investedEnhancementStones;
  int investedTranscendenceStones;

  // Special Ability
  String? specialAbilityDescription;
  SpecialAbilityType? abilityType;
  double? abilityProcChance;
  double? abilityValue;

  int get maxTranscendence => 5;

  int get maxEnhancement => 5;

  double get calculatedDamage {
    double currentDamage = baseDamage;

    // Apply enhancement multipliers
    const enhancementMultipliers = [1.05, 1.07, 1.10, 1.15, 1.20];
    print('DEBUG: enhancement: $enhancement, multipliers length: ${enhancementMultipliers.length}'); // ADD THIS LINE
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
    required this.baseDamage, // Changed from damage to baseDamage
    required this.criticalChance,
    required this.criticalDamage,
    required this.baseSellPrice,
    this.investedGold = 0,
    this.investedEnhancementStones = 0,
    this.investedTranscendenceStones = 0,
    this.specialAbilityDescription,
    this.abilityType,
    this.abilityProcChance,
    this.abilityValue,
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
    'baseDamage': baseDamage, // Added baseDamage
    'criticalChance': criticalChance,
    'criticalDamage': criticalDamage,
    'baseSellPrice': baseSellPrice,
    'investedGold': investedGold,
    'investedEnhancementStones': investedEnhancementStones,
    'investedTranscendenceStones': investedTranscendenceStones,
    'specialAbilityDescription': specialAbilityDescription,
    'abilityType': abilityType?.toString(),
    'abilityProcChance': abilityProcChance,
    'abilityValue': abilityValue,
  };

  factory Weapon.fromJson(Map<String, dynamic> json) {
    return Weapon(
      id: json['id'],
      name: json['name'],
      imageName: json['imageName'] ?? '',
      rarity: Rarity.values.firstWhere((e) => e.toString() == json['rarity']),
      type: WeaponType.values.firstWhere((e) => e.toString() == json['type']),
      baseLevel: json['baseLevel'],
      enhancement: json['enhancement'],
      transcendence: json['transcendence'],
      baseDamage:
          json['baseDamage'] ??
          json['damage'] ??
          0.0, // Prioritize baseDamage, fallback to damage, then 0.0
      criticalChance: json['criticalChance'],
      criticalDamage: json['criticalDamage'],
      baseSellPrice: json['baseSellPrice'] ?? 0.0,
      investedGold: json['investedGold'] ?? 0.0,
      investedEnhancementStones: json['investedEnhancementStones'] ?? 0,
      investedTranscendenceStones: json['investedTranscendenceStones'] ?? 0,
      specialAbilityDescription: json['specialAbilityDescription'],
      abilityType: json['abilityType'] != null
          ? SpecialAbilityType.values.firstWhere(
              (e) => e.toString() == json['abilityType'],
            )
          : null,
      abilityProcChance: json['abilityProcChance'],
      abilityValue: json['abilityValue'],
    );
  }

  factory Weapon.startingWeapon() {
    return Weapon(
      id: 1, // Changed to ID 1 for rusty crude rapier
      name: '녹슨 조잡한 레이피어',
      imageName: 'common/rusty_crude_rapier.png',
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
    double? baseDamage, // Changed from damage to baseDamage
    double? criticalChance,
    double? criticalDamage,
    double? baseSellPrice,
    double? investedGold,
    int? investedEnhancementStones,
    int? investedTranscendenceStones,
    String? specialAbilityDescription,
    SpecialAbilityType? abilityType,
    double? abilityProcChance,
    double? abilityValue,
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
      baseDamage:
          baseDamage ?? this.baseDamage, // Changed from damage to baseDamage
      criticalChance: criticalChance ?? this.criticalChance,
      criticalDamage: criticalDamage ?? this.criticalDamage,
      baseSellPrice: baseSellPrice ?? this.baseSellPrice,
      investedGold: investedGold ?? this.investedGold,
      investedEnhancementStones:
          investedEnhancementStones ?? this.investedEnhancementStones,
      investedTranscendenceStones:
          investedTranscendenceStones ?? this.investedTranscendenceStones,
      specialAbilityDescription:
          specialAbilityDescription ?? this.specialAbilityDescription,
      abilityType: abilityType ?? this.abilityType,
      abilityProcChance: abilityProcChance ?? this.abilityProcChance,
      abilityValue: abilityValue ?? this.abilityValue,
    );
  }
}
