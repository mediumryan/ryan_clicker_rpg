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
  int level;
  int enhancement;
  int transcendence;
  double damage;
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

  int get maxLevel {
    if (baseLevel <= 100) return 100;
    if (baseLevel <= 200) return 200;
    if (baseLevel <= 300) return 300;
    return (baseLevel / 100).ceil() * 100;
  }

  int get maxEnhancement {
    if (baseLevel <= 100) return 5;
    if (baseLevel <= 200) return 10;
    if (baseLevel <= 300) return 15;
    return (baseLevel / 100).ceil() * 5;
  }

  Weapon({
    required this.id,
    required this.name,
    required this.imageName,
    required this.rarity,
    required this.type,
    required this.baseLevel,
    this.level = 1,
    this.enhancement = 0,
    this.transcendence = 0,
    required this.damage,
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
    'level': level,
    'enhancement': enhancement,
    'transcendence': transcendence,
    'damage': damage,
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
      level: json['level'],
      enhancement: json['enhancement'],
      transcendence: json['transcendence'],
      damage: json['damage'],
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
      imageName: 'rusty_crude_rapier.png',
      rarity: Rarity.common,
      type: WeaponType.rapier,
      baseLevel: 0,
      damage: 45.0,
      criticalChance: 0.1,
      criticalDamage: 1.35,
      baseSellPrice: 10.0,
    );
  }

  Weapon copyWith({
    int? id,
    String? name,
    String? imageName,
    Rarity? rarity,
    WeaponType? type,
    int? baseLevel,
    int? level,
    int? enhancement,
    int? transcendence,
    double? damage,
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
      level: level ?? this.level,
      enhancement: enhancement ?? this.enhancement,
      transcendence: transcendence ?? this.transcendence,
      damage: damage ?? this.damage,
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
