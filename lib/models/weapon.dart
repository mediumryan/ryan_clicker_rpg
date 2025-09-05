import 'dart:math';
import 'package:ryan_clicker_rpg/data/weapon_data.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

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

// New class to hold transcendence bonus data
class TranscendenceBonus {
  final double damageBonus;
  final double speedBonus;
  final double critChanceBonus;
  final double critDamageBonus;

  const TranscendenceBonus({
    this.damageBonus = 0.0,
    this.speedBonus = 0.0,
    this.critChanceBonus = 0.0,
    this.critDamageBonus = 0.0,
  });
}

class Weapon {
  final String instanceId;
  final int id;
  final String name;
  final String imageName;
  final Rarity rarity;
  final WeaponType type;
  final int baseLevel;
  int enhancement;
  int transcendence;
  final double baseDamage;
  double criticalChance;
  double criticalDamage;
  double baseSellPrice;
  String? description;
  double defensePenetration;
  double doubleAttackChance;
  double speed;
  double accuracy;

  // Resources invested in this weapon
  double investedGold;
  int investedEnhancementStones;
  int investedTranscendenceStones;

  // Skills
  List<Map<String, dynamic>> skills;
  Map<String, int> skillStacks;

  int get maxTranscendence => 1;
  int get maxEnhancement => 20;

  // Static map for transcendence bonuses
  static const Map<int, TranscendenceBonus> transcendenceBonuses = {
    1: TranscendenceBonus(
      damageBonus: 9.0,
      speedBonus: 1.0,
      critChanceBonus: 0.1,
      critDamageBonus: 2.0,
    ),
  };

  // These getters calculate the weapon's own stats including enhancement and transcendence.
  // They do NOT include player-wide passive bonuses.
  double get calculatedDamage {
    double damage = baseDamage;
    damage *= pow(1.08, enhancement);
    final bonus = Weapon.transcendenceBonuses[transcendence];
    if (bonus != null) {
      damage *= (1 + bonus.damageBonus);
    }
    return damage;
  }

  double get calculatedCritChance {
    double crit = criticalChance;
    final bonus = Weapon.transcendenceBonuses[transcendence];
    if (bonus != null) {
      crit += bonus.critChanceBonus;
    }
    return crit;
  }

  double get calculatedCritDamage {
    double critDmg = criticalDamage;
    final bonus = Weapon.transcendenceBonuses[transcendence];
    if (bonus != null) {
      critDmg += bonus.critDamageBonus;
    }
    return critDmg;
  }

  double get calculatedSpeed {
    double spd = speed;
    final bonus = Weapon.transcendenceBonuses[transcendence];
    if (bonus != null) {
      spd *= (1 + bonus.speedBonus);
    }
    return spd;
  }

  Weapon({
    required this.instanceId,
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
    this.accuracy = 1.0,
    Map<String, int>? skillStacks,
  }) : skillStacks = skillStacks ?? {};

  Map<String, dynamic> toJson() => {
        'instanceId': instanceId,
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
        'accuracy': accuracy,
        'skillStacks': skillStacks,
      };

  factory Weapon.fromJson(Map<String, dynamic> json) {
    final calculatedRarity = Rarity.values.firstWhere(
      (e) =>
          e.toString().split('.').last.toLowerCase() ==
          json['rarity'].toString().split('.').last.toLowerCase(),
      orElse: () {
        return Rarity.common;
      },
    );

    return Weapon(
      instanceId: json['instanceId'] ?? uuid.v4(),
      id: json['id'],
      name: json['name'],
      imageName: json['imageName'] ?? '',
      rarity: calculatedRarity,
      type: WeaponType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            json['type']
                .toString()
                .replaceAll('_', '')
                .split('.')
                .last
                .toLowerCase(),
        orElse: () {
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
      accuracy:
          json['accuracy'] ??
          WeaponData.getDefaultAccuracyForRarity(calculatedRarity),
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      skillStacks:
          (json['skillStacks'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }

  factory Weapon.startingWeapon() {
    return Weapon(
      instanceId: uuid.v4(),
      id: 1,
      name: '녹슨 조잡한 레이피어',
      imageName: 'group1/rusty_crude_rapier.png',
      rarity: Rarity.common,
      type: WeaponType.rapier,
      baseLevel: 0,
      baseDamage: 80,
      criticalChance: 0.08,
      criticalDamage: 1.08,
      defensePenetration: 0,
      doubleAttackChance: 0.0,
      speed: 0.8,
      baseSellPrice: 120,
      skills: [],
      description: "기본 무기입니다.",
      accuracy: 0.7,
    );
  }

  factory Weapon.bareHands() {
    return Weapon(
      instanceId: 'bare_hands', // A fixed unique ID for bare hands
      id: 0,
      name: '맨손',
      imageName: 'bare_hands.png',
      rarity: Rarity.common,
      type: WeaponType.rapier,
      baseLevel: 1,
      baseDamage: 1,
      criticalChance: 0.0,
      criticalDamage: 1.0,
      baseSellPrice: 0,
      description: "무기가 없습니다.",
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
    double? accuracy,
    List<Map<String, dynamic>>? skills,
    Map<String, int>? skillStacks,
  }) {
    return Weapon(
      instanceId: uuid.v4(), // Always generate a new UUID for a copy
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
      accuracy: accuracy ?? this.accuracy,
      skills: skills ?? this.skills,
      skillStacks: skillStacks ?? this.skillStacks,
    );
  }
}
