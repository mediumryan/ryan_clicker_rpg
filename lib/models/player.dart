import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/models/gacha_box.dart';
import 'package:ryan_clicker_rpg/models/buff.dart';
import 'package:ryan_clicker_rpg/models/difficulty.dart';

class Player {
  double gold;
  int enhancementStones;
  int transcendenceStones;
  int darkMatter;
  int destructionProtectionTickets;
  Weapon equippedWeapon;
  List<Weapon> inventory;
  List<GachaBox> gachaBoxes;
  List<Buff> buffs; // New
  int currentStage;
  int highestStageCleared;
  final Set<int> acquiredWeaponIdsHistory;
  final Map<String, int> defeatedBosses;
  final Set<String> completedAchievementIds;
  final Set<String> claimedAchievementIds;
  int monstersKilled;

  // New fields for Difficulty and Hero systems
  Difficulty currentDifficulty;
  Difficulty highestDifficultyUnlocked;
  int heroLevel;
  double heroExp;
  int skillPoints;
  Map<String, int> learnedSkills;

  // Achievement-related stats
  double totalGoldEarned;
  int weaponDestructionCount;
  int transcendenceSuccessCount;
  int totalClicks;

  // --- Base Stats & Passive Bonuses ---
  // These are saved to disk.
  double passiveGoldGainMultiplier;
  double passiveEnhancementStoneGainMultiplier;
  int passiveEnhancementStoneGainFlat;

  double passiveWeaponDamageBonus;
  double passiveWeaponDamageMultiplier;
  double passiveWeaponCriticalChanceBonus;
  double passiveWeaponCriticalChanceMultiplier;
  double passiveWeaponCriticalDamageBonus;
  double passiveWeaponCriticalDamageMultiplier;
  double passiveWeaponDoubleAttackChanceBonus;
  double passiveWeaponDefensePenetrationBonus;
  double passiveWeaponSpeedBonus;
  double passiveWeaponSpeedMultiplier;
  double passiveWeaponAccuracyBonus;
  double passiveWeaponAccuracyMultiplier;

  // --- Final Calculated Stats ---
  // These are calculated at runtime and not saved.
  double finalDamage = 0;
  double finalCritChance = 0;
  double finalCritDamage = 0;
  double finalAttackSpeed = 1.0;
  double finalDoubleAttackChance = 0;
  double finalDefensePenetration = 0;
  double finalAccuracy = 0;
  bool manualClickDisabled = false;
  bool canManualAttack = true;
  bool showFloatingDamage;
  String graphicsQuality;

  Player({
    this.gold = 0,
    this.enhancementStones = 0,
    this.transcendenceStones = 0,
    this.darkMatter = 0,
    this.destructionProtectionTickets = 0,
    required this.equippedWeapon,
    List<Weapon>? inventory,
    List<GachaBox>? gachaBoxes,
    List<Buff>? buffs,
    this.currentStage = 1,
    this.highestStageCleared = 0,
    Set<int>? acquiredWeaponIdsHistory,
    Map<String, int>? defeatedBosses,
    Set<String>? completedAchievementIds,
    Set<String>? claimedAchievementIds,
    this.monstersKilled = 0,
    this.totalGoldEarned = 0,
    this.weaponDestructionCount = 0,
    this.transcendenceSuccessCount = 0,
    this.totalClicks = 0,
    this.passiveGoldGainMultiplier = 1.0,
    this.passiveEnhancementStoneGainMultiplier = 1.0,
    this.passiveEnhancementStoneGainFlat = 0,
    this.passiveWeaponDamageBonus = 0.0,
    this.passiveWeaponDamageMultiplier = 1.0,
    this.passiveWeaponCriticalChanceBonus = 0.0,
    this.passiveWeaponCriticalChanceMultiplier = 1.0,
    this.passiveWeaponCriticalDamageBonus = 0.0,
    this.passiveWeaponCriticalDamageMultiplier = 1.0,
    this.passiveWeaponDoubleAttackChanceBonus = 0.0,
    this.passiveWeaponDefensePenetrationBonus = 0.0,
    this.passiveWeaponSpeedBonus = 0.0,
    this.passiveWeaponSpeedMultiplier = 1.0,
    this.passiveWeaponAccuracyBonus = 0.0,
    this.passiveWeaponAccuracyMultiplier = 1.0,
    this.showFloatingDamage = true,
    this.graphicsQuality = 'Medium',
    this.currentDifficulty = Difficulty.normal,
    this.highestDifficultyUnlocked = Difficulty.normal,
    this.heroLevel = 1,
    this.heroExp = 0,
    this.skillPoints = 0,
    Map<String, int>? learnedSkills,
  }) : inventory = inventory ?? [],
       gachaBoxes = gachaBoxes ?? [],
       buffs = buffs ?? [],
       acquiredWeaponIdsHistory = acquiredWeaponIdsHistory ?? {},
       defeatedBosses = defeatedBosses ?? {},
       completedAchievementIds = completedAchievementIds ?? {},
       claimedAchievementIds = claimedAchievementIds ?? {},
       learnedSkills = learnedSkills ?? {};

  // Serialization
  Map<String, dynamic> toJson() => {
    'gold': gold,
    'enhancementStones': enhancementStones,
    'transcendenceStones': transcendenceStones,
    'darkMatter': darkMatter,
    'destructionProtectionTickets': destructionProtectionTickets,
    'equippedWeapon': equippedWeapon.toJson(),
    'inventory': inventory.map((w) => w.toJson()).toList(),
    'gachaBoxes': gachaBoxes.map((b) => b.toJson()).toList(),
    'buffs': buffs.map((b) => b.toJson()).toList(), // New
    'currentStage': currentStage,
    'highestStageCleared': highestStageCleared,
    'acquiredWeaponIdsHistory': acquiredWeaponIdsHistory.toList(),
    'defeatedBosses': defeatedBosses,
    'completedAchievementIds': completedAchievementIds.toList(),
    'claimedAchievementIds': claimedAchievementIds.toList(),
    'monstersKilled': monstersKilled,
    'totalGoldEarned': totalGoldEarned,
    'weaponDestructionCount': weaponDestructionCount,
    'transcendenceSuccessCount': transcendenceSuccessCount,
    'totalClicks': totalClicks,
    'passiveGoldGainMultiplier': passiveGoldGainMultiplier,
    'passiveEnhancementStoneGainMultiplier':
        passiveEnhancementStoneGainMultiplier,
    'passiveEnhancementStoneGainFlat': passiveEnhancementStoneGainFlat,
    'passiveWeaponDamageBonus': passiveWeaponDamageBonus,
    'passiveWeaponDamageMultiplier': passiveWeaponDamageMultiplier,
    'passiveWeaponCriticalChanceBonus': passiveWeaponCriticalChanceBonus,
    'passiveWeaponCriticalChanceMultiplier':
        passiveWeaponCriticalChanceMultiplier,
    'passiveWeaponCriticalDamageBonus': passiveWeaponCriticalDamageBonus,
    'passiveWeaponCriticalDamageMultiplier':
        passiveWeaponCriticalDamageMultiplier,
    'passiveWeaponDoubleAttackChanceBonus':
        passiveWeaponDoubleAttackChanceBonus,
    'passiveWeaponDefensePenetrationBonus':
        passiveWeaponDefensePenetrationBonus,
    'passiveWeaponSpeedBonus': passiveWeaponSpeedBonus,
    'passiveWeaponSpeedMultiplier': passiveWeaponSpeedMultiplier,
    'passiveWeaponAccuracyBonus': passiveWeaponAccuracyBonus,
    'passiveWeaponAccuracyMultiplier': passiveWeaponAccuracyMultiplier,
    'showFloatingDamage': showFloatingDamage,
    'graphicsQuality': graphicsQuality,
    'currentDifficulty': currentDifficulty.name,
    'highestDifficultyUnlocked': highestDifficultyUnlocked.name,
    'heroLevel': heroLevel,
    'heroExp': heroExp,
    'skillPoints': skillPoints,
    'learnedSkills': learnedSkills,
  }; // Deserialization
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      gold: json['gold'],
      enhancementStones: json['enhancementStones'],
      transcendenceStones: json['transcendenceStones'],
      darkMatter: json['darkMatter'] ?? 0,
      destructionProtectionTickets: json['destructionProtectionTickets'] ?? 0,
      equippedWeapon: Weapon.fromJson(json['equippedWeapon']),
      inventory: (json['inventory'] as List)
          .map((item) => Weapon.fromJson(item))
          .toList(),
      gachaBoxes:
          (json['gachaBoxes'] as List?)
              ?.map((item) => GachaBox.fromJson(item))
              .toList() ??
          [],
      buffs:
          (json['buffs'] as List?)
              ?.map((item) => Buff.fromJson(item))
              .toList() ??
          [], // New
      currentStage: json['currentStage'],
      highestStageCleared: json['highestStageCleared'],
      acquiredWeaponIdsHistory:
          (json['acquiredWeaponIdsHistory'] as List?)
              ?.map((id) => id as int)
              .toSet() ??
          {},
      defeatedBosses: Map<String, int>.from(json['defeatedBosses'] ?? {}),
      completedAchievementIds:
          (json['completedAchievementIds'] as List?)
              ?.map((id) => id.toString())
              .toSet() ??
          {},
      claimedAchievementIds:
          (json['claimedAchievementIds'] as List?)
              ?.map((id) => id.toString())
              .toSet() ??
          {},
      monstersKilled: json['monstersKilled'] ?? 0,
      totalGoldEarned: json['totalGoldEarned'] ?? 0,
      weaponDestructionCount: json['weaponDestructionCount'] ?? 0,
      transcendenceSuccessCount: json['transcendenceSuccessCount'] ?? 0,
      totalClicks: json['totalClicks'] ?? 0,
      passiveGoldGainMultiplier: json['passiveGoldGainMultiplier'] ?? 1.0,
      passiveEnhancementStoneGainMultiplier:
          json['passiveEnhancementStoneGainMultiplier'] ?? 1.0,
      passiveEnhancementStoneGainFlat:
          json['passiveEnhancementStoneGainFlat'] ?? 0,
      passiveWeaponDamageBonus: json['passiveWeaponDamageBonus'] ?? 0.0,
      passiveWeaponDamageMultiplier:
          json['passiveWeaponDamageMultiplier'] ?? 1.0,
      passiveWeaponCriticalChanceBonus:
          json['passiveWeaponCriticalChanceBonus'] ?? 0.0,
      passiveWeaponCriticalChanceMultiplier:
          json['passiveWeaponCriticalChanceMultiplier'] ?? 1.0,
      passiveWeaponCriticalDamageBonus:
          json['passiveWeaponCriticalDamageBonus'] ?? 0.0,
      passiveWeaponCriticalDamageMultiplier:
          json['passiveWeaponCriticalDamageMultiplier'] ?? 1.0,
      passiveWeaponDoubleAttackChanceBonus:
          json['passiveWeaponDoubleAttackChanceBonus'] ?? 0.0,
      passiveWeaponDefensePenetrationBonus:
          json['passiveWeaponDefensePenetrationBonus'] ?? 0.0,
      passiveWeaponSpeedBonus: json['passiveWeaponSpeedBonus'] ?? 0.0,
      passiveWeaponSpeedMultiplier: json['passiveWeaponSpeedMultiplier'] ?? 1.0,
      passiveWeaponAccuracyBonus: json['passiveWeaponAccuracyBonus'] ?? 0.0,
      passiveWeaponAccuracyMultiplier:
          json['passiveWeaponAccuracyMultiplier'] ?? 1.0,
      showFloatingDamage: json['showFloatingDamage'] ?? true,
      graphicsQuality: json['graphicsQuality'] ?? 'Medium',
      currentDifficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['currentDifficulty'],
        orElse: () => Difficulty.normal,
      ),
      highestDifficultyUnlocked: Difficulty.values.firstWhere(
        (e) => e.name == json['highestDifficultyUnlocked'],
        orElse: () => Difficulty.normal,
      ),
      heroLevel: json['heroLevel'] ?? 1,
      heroExp: json['heroExp'] ?? 0.0,
      skillPoints: json['skillPoints'] ?? 0,
      learnedSkills: Map<String, int>.from(json['learnedSkills'] ?? {}),
    );
  }
}
