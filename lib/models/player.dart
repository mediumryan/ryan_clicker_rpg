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
  final Set<String> defeatedBossNames; // NEW FIELD

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
    Set<String>? defeatedBossNames, // NEW IN CONSTRUCTOR
  }) : inventory = inventory ?? [],
       gachaBoxes = gachaBoxes ?? [],
       acquiredWeaponIdsHistory = acquiredWeaponIdsHistory ?? {},
       defeatedBossNames = defeatedBossNames ?? {}; // INITIALIZE NEW FIELD

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
    'defeatedBossNames': defeatedBossNames.toList(), // NEW: Serialize as List
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
          (json['defeatedBossNames'] as List?) // NEW: Deserialize from List
              ?.map((name) => name as String)
              .toSet() ??
          {}, // Handle null for old saves
    );
  }
}
