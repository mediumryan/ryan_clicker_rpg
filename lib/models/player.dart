import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/models/gacha_box.dart';

class Player {
  double gold;
  int enhancementStones;
  int transcendenceStones;
  Weapon equippedWeapon;
  List<Weapon> inventory;
  List<GachaBox> gachaBoxes;
  int currentStage;
  int highestStageCleared;
  final Set<int> acquiredWeaponIdsHistory;
  final Set<String> defeatedBossNames;

  // Passive Gain Boosts
  double passiveGoldGainMultiplier;
  double passiveEnhancementStoneGainMultiplier;
  int passiveEnhancementStoneGainFlat;

  // Passive Weapon Stat Boosts
  double passiveWeaponDamageBonus;
  double passiveWeaponDamageMultiplier;
  double passiveWeaponCriticalChanceBonus;
  double passiveWeaponCriticalDamageBonus;
  double passiveWeaponDoubleAttackChanceBonus;
  double passiveWeaponDefensePenetrationBonus;

  Player({
    this.gold = 0,
    this.enhancementStones = 0,
    this.transcendenceStones = 0,
    required this.equippedWeapon,
    List<Weapon>? inventory,
    List<GachaBox>? gachaBoxes,
    this.currentStage = 1,
    this.highestStageCleared = 0,
    Set<int>? acquiredWeaponIdsHistory,
    Set<String>? defeatedBossNames,
    this.passiveGoldGainMultiplier = 1.0,
    this.passiveEnhancementStoneGainMultiplier = 1.0,
    this.passiveEnhancementStoneGainFlat = 0,
    this.passiveWeaponDamageBonus = 0.0,
    this.passiveWeaponDamageMultiplier = 1.0,
    this.passiveWeaponCriticalChanceBonus = 0.0,
    this.passiveWeaponCriticalDamageBonus = 0.0,
    this.passiveWeaponDoubleAttackChanceBonus = 0.0,
    this.passiveWeaponDefensePenetrationBonus = 0.0,
  }) : inventory = inventory ?? [],
       gachaBoxes = gachaBoxes ?? [],
       acquiredWeaponIdsHistory = acquiredWeaponIdsHistory ?? {},
       defeatedBossNames = defeatedBossNames ?? {};

  // Effective Weapon Stat Getters
  double get effectiveDamage {
    return equippedWeapon.currentDamage * passiveWeaponDamageMultiplier + passiveWeaponDamageBonus;
  }

  double get effectiveCriticalChance {
    return equippedWeapon.criticalChance + passiveWeaponCriticalChanceBonus;
  }

  double get effectiveCriticalDamage {
    return equippedWeapon.criticalDamage + passiveWeaponCriticalDamageBonus;
  }

  double get effectiveDoubleAttackChance {
    return equippedWeapon.doubleAttackChance + passiveWeaponDoubleAttackChanceBonus;
  }

  double get effectiveDefensePenetration {
    return equippedWeapon.defensePenetration + passiveWeaponDefensePenetrationBonus;
  }

  // Serialization
  Map<String, dynamic> toJson() => {
    'gold': gold,
    'enhancementStones': enhancementStones,
    'transcendenceStones': transcendenceStones,
    'equippedWeapon': equippedWeapon.toJson(),
    'inventory': inventory.map((w) => w.toJson()).toList(),
    'gachaBoxes': gachaBoxes.map((b) => b.toJson()).toList(),
    'currentStage': currentStage,
    'highestStageCleared': highestStageCleared,
    'acquiredWeaponIdsHistory': acquiredWeaponIdsHistory.toList(),
    'defeatedBossNames': defeatedBossNames.toList(),
    'passiveGoldGainMultiplier': passiveGoldGainMultiplier,
    'passiveEnhancementStoneGainMultiplier': passiveEnhancementStoneGainMultiplier,
    'passiveEnhancementStoneGainFlat': passiveEnhancementStoneGainFlat,
    'passiveWeaponDamageBonus': passiveWeaponDamageBonus,
    'passiveWeaponDamageMultiplier': passiveWeaponDamageMultiplier,
    'passiveWeaponCriticalChanceBonus': passiveWeaponCriticalChanceBonus,
    'passiveWeaponCriticalDamageBonus': passiveWeaponCriticalDamageBonus,
    'passiveWeaponDoubleAttackChanceBonus': passiveWeaponDoubleAttackChanceBonus,
    'passiveWeaponDefensePenetrationBonus': passiveWeaponDefensePenetrationBonus,
  };

  // Deserialization
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      gold: json['gold'],
      enhancementStones: json['enhancementStones'],
      transcendenceStones: json['transcendenceStones'],
      equippedWeapon: Weapon.fromJson(json['equippedWeapon']),
      inventory: (json['inventory'] as List)
          .map((item) => Weapon.fromJson(item))
          .toList(),
      gachaBoxes:
          (json['gachaBoxes'] as List?)
              ?.map((item) => GachaBox.fromJson(item))
              .toList() ??
          [],
      currentStage: json['currentStage'],
      highestStageCleared: json['highestStageCleared'],
      acquiredWeaponIdsHistory:
          (json['acquiredWeaponIdsHistory'] as List?)
              ?.map((id) => id as int)
              .toSet() ??
          {},
      defeatedBossNames:
          (json['defeatedBossNames'] as List?)
              ?.map((name) => name as String)
              .toSet() ??
          {}, // Handle null for old saves
      passiveGoldGainMultiplier: json['passiveGoldGainMultiplier'] ?? 1.0,
      passiveEnhancementStoneGainMultiplier: json['passiveEnhancementStoneGainMultiplier'] ?? 1.0,
      passiveEnhancementStoneGainFlat: json['passiveEnhancementStoneGainFlat'] ?? 0,
      passiveWeaponDamageBonus: json['passiveWeaponDamageBonus'] ?? 0.0,
      passiveWeaponDamageMultiplier: json['passiveWeaponDamageMultiplier'] ?? 1.0,
      passiveWeaponCriticalChanceBonus: json['passiveWeaponCriticalChanceBonus'] ?? 0.0,
      passiveWeaponCriticalDamageBonus: json['passiveWeaponCriticalDamageBonus'] ?? 0.0,
      passiveWeaponDoubleAttackChanceBonus: json['passiveWeaponDoubleAttackChanceBonus'] ?? 0.0,
      passiveWeaponDefensePenetrationBonus: json['passiveWeaponDefensePenetrationBonus'] ?? 0.0,
    );
  }
}