import 'dart:math';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/foundation.dart';
import 'package:ryan_clicker_rpg/models/player.dart';
import 'package:ryan_clicker_rpg/models/monster.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/models/gacha_box.dart'; // Import GachaBox
import 'package:ryan_clicker_rpg/data/monster_data.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart';
import 'package:ryan_clicker_rpg/data/stage_data.dart'; // New import
import 'package:shared_preferences/shared_preferences.dart';

class GameProvider with ChangeNotifier {
  late Player _player;
  late Monster _monster;
  bool _isMonsterDefeated = false;

  Player get player => _player;
  Monster get monster => _monster;
  bool get isMonsterDefeated => _isMonsterDefeated;
  String get currentStageName =>
      StageData.getStageName(_player.currentStage); // New getter

  GameProvider(); // Constructor no longer calls _initializeGame

  Future<void> initializeGame() async {
    // New public initialization method
    await _loadGame(); // Load player data
    _player.acquiredWeaponIdsHistory.add(_player.equippedWeapon.id); // ADD THIS LINE: Ensure equipped weapon is always in history
    _spawnMonster(); // Spawn initial monster
  }

  void _spawnMonster() {
    _monster = MonsterData.getMonsterForStage(_player.currentStage);
    _isMonsterDefeated = false; // Reset when a new monster spawns
    notifyListeners();
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final playerDataString = prefs.getString('player_data');

    if (playerDataString != null) {
      final Map<String, dynamic> playerDataJson = jsonDecode(playerDataString);
      _player = Player.fromJson(playerDataJson);
    } else {
      // This is the critical part: WeaponData must be initialized here
      // WeaponData.getGuaranteedRandomWeapon() will now work correctly
      _player = Player(equippedWeapon: Weapon.startingWeapon().copyWith());
    }
  }

  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    final playerDataString = jsonEncode(_player.toJson());
    await prefs.setString('player_data', playerDataString);
  }

  Map<String, dynamic> attackMonster() {
    // Calculate damage
    double totalDamage = _player.equippedWeapon.damage;
    bool isCritical =
        Random().nextDouble() < _player.equippedWeapon.criticalChance;
    if (isCritical) {
      totalDamage *= _player.equippedWeapon.criticalDamage;
    }

    // Handle special ability
    final weapon = _player.equippedWeapon;
    if (weapon.abilityType == SpecialAbilityType.onHitProcDamage) {
      if (Random().nextDouble() < weapon.abilityProcChance!) {
        totalDamage += weapon.abilityValue!;
        // In a real game, you might want to show a special effect here
      }
    }

    // Apply monster defense
    double actualDamage = max(1, totalDamage - _monster.defense);
    _monster.hp -= actualDamage;

    if (_monster.hp <= 0) {
      // Monster defeated
      _isMonsterDefeated = true; // Set to true when monster is defeated
      notifyListeners(); // Notify listeners immediately to update UI

      _player.gold += (_player.currentStage * 5)
          .toDouble(); // Gold reward based on stage level
      // Drop enhancement stones with a low probability
      if (Random().nextDouble() < 0.1) {
        // 10% chance to drop 1 stone
        _player.enhancementStones += 1;
      }

      // Grant transcendence stone if the monster was a boss and passes a low probability check
      if (_monster.isBoss) {
        // Example: 5% chance to drop a transcendence stone from a boss
        if (Random().nextDouble() < 0.05) {
          _player.transcendenceStones++;
        }
      }

      // Attempt to get a gacha box drop instead of a weapon
      if (Random().nextDouble() < 0.2) {
        // 20% chance to drop a gacha box
        final newGachaBox = GachaBox(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
          name: 'Stage ${_player.currentStage} Gacha Box',
          stageLevel: _player.currentStage,
        );
        _player.gachaBoxes.add(newGachaBox);
        // In a real game, you'd want to notify the user here about the box drop.
      }

      if (_player.currentStage >= _player.highestStageCleared) {
        _player.highestStageCleared = _player.currentStage;
        // _player.currentStage++; // Removed: Stage progression handled by goToNextStage
      } else {
        // If not the highest stage, just move to the next one without updating highest
        // _player.currentStage++; // Removed: Stage progression handled by goToNextStage
      }
      // Do not spawn monster immediately, let UI handle it after defeat animation/message
    } else {
      notifyListeners();
    }
    _saveGame(); // Save game after every attack/monster defeat
    return {'damageDealt': actualDamage.toInt(), 'isCritical': isCritical};
  }

  void goToNextStage() {
    if (_player.currentStage < _player.highestStageCleared) {
      _player.currentStage++;
      _spawnMonster(); // Spawn monster after stage change
      _saveGame(); // Save game after stage change
    } else if (_isMonsterDefeated) {
      // Allow going to next stage only if monster is defeated on current highest stage
      _player.currentStage++;
      _spawnMonster(); // Spawn monster after stage change
      _saveGame(); // Save game after stage change
    }
  }

  void goToPreviousStage() {
    if (_player.currentStage > 1) {
      _player.currentStage--;
      _spawnMonster(); // Spawn monster after stage change
      _saveGame(); // Save game after stage change
    }
  }

  // Returns a message indicating the result of the level up attempt.
  String levelUpEquippedWeapon() {
    final weapon = _player.equippedWeapon;
    final cost = weapon.level * 100; // Placeholder for cost formula

    if (_player.gold >= cost) {
      _player.gold -= cost;
      weapon.investedGold += cost; // Track invested gold
      weapon.level++;
      weapon.damage +=
          weapon.level * 2; // Placeholder for damage increase formula
      notifyListeners();
      _saveGame(); // Save game after level up
      return '레벨업 성공! Lvl: ${weapon.level}, Dmg: ${weapon.damage.toStringAsFixed(0)}';
    } else {
      return '골드가 부족합니다. (필요: $cost)';
    }
  }

  // Returns a message indicating the result of the enhancement attempt.
  String enhanceEquippedWeapon() {
    final weapon = _player.equippedWeapon;
    final goldCost =
        (weapon.enhancement + 1) * 1000; // Placeholder for cost formula
    final stoneCost = weapon.level <= 50
        ? 0
        : weapon.enhancement + 1; // No stone cost for weapons up to level 50

    if (_player.gold < goldCost) {
      return '골드가 부족합니다. (필요: $goldCost)';
    }
    if (_player.enhancementStones < stoneCost) {
      return '강화석이 부족합니다. (필요: $stoneCost)';
    }

    _player.gold -= goldCost;
    _player.enhancementStones -= stoneCost;
    weapon.investedGold += goldCost; // Track invested gold
    weapon.investedEnhancementStones += stoneCost; // Track invested stones
    weapon.enhancement++;
    weapon.damage *= 1.5; // Placeholder for damage increase formula

    notifyListeners();
    _saveGame(); // Save game after enhancement
    return '강화 성공! +${weapon.enhancement} (Dmg: ${weapon.damage.toStringAsFixed(0)})';
  }

  // Returns a message indicating the result of the transcendence attempt.
  String transcendEquippedWeapon() {
    final weapon = _player.equippedWeapon;

    // Check conditions
    if (weapon.level < weapon.maxLevel) {
      return '초월하려면 최대 레벨(${weapon.maxLevel})에 도달해야 합니다.';
    }
    if (weapon.enhancement < weapon.maxEnhancement) {
      return '초월하려면 최대 강화(+${weapon.maxEnhancement})에 도달해야 합니다.';
    }

    final goldCost = 100000; // Placeholder for cost formula
    final stoneCost = 1; // Placeholder for cost formula

    if (_player.gold < goldCost) {
      return '골드가 부족합니다. (필요: $goldCost)';
    }
    if (_player.transcendenceStones < stoneCost) {
      return '초월석이 부족합니다. (필요: $stoneCost)';
    }

    _player.gold -= goldCost;
    _player.transcendenceStones -= stoneCost;
    weapon.investedGold += goldCost; // Track invested gold
    weapon.investedTranscendenceStones += stoneCost; // Track invested stones
    weapon.transcendence++;
    weapon.level = 1;
    weapon.enhancement = 0;
    weapon.damage *= 5; // Placeholder for game balance

    notifyListeners();
    _saveGame(); // Save game after transcendence
    return '초월 성공! [${weapon.transcendence}] (Dmg: ${weapon.damage.toStringAsFixed(0)})';
  }

  void equipWeapon(Weapon weaponToEquip) {
    if (_player.equippedWeapon == weaponToEquip) return; // Already equipped

    // Find the weaponToEquip in inventory
    final index = _player.inventory.indexWhere(
      (w) => w.id == weaponToEquip.id,
    ); // Assuming IDs are unique
    if (index != -1) {
      // Get the weapon from inventory (this is the one we want to equip)
      final oldInventoryWeapon = _player.inventory[index];

      // Remove the weapon from inventory
      _player.inventory.removeAt(index);

      // Add the currently equipped weapon back to inventory
      _player.inventory.add(
        _player.equippedWeapon,
      ); // Add the modified equipped weapon back

      // Equip the new weapon
      _player.equippedWeapon =
          oldInventoryWeapon; // Equip the weapon from inventory

      notifyListeners();
      _saveGame(); // Save game after equipping weapon
    }
  }

  String buyEnhancementStones({required int amount, required int cost}) {
    if (_player.gold >= cost) {
      _player.gold -= cost;
      _player.enhancementStones += amount;
      notifyListeners();
      _saveGame(); // Save game after purchase
      return '$amount개의 강화석을 구매했습니다.';
    } else {
      return '골드가 부족합니다.';
    }
  }

  String buyRandomWeaponBox({required int cost}) {
    if (_player.gold >= cost) {
      _player.gold -= cost;
      final newWeapon = WeaponData.getGuaranteedRandomWeapon();
      _player.inventory.add(newWeapon);
      _player.acquiredWeaponIdsHistory.add(newWeapon.id); // Add to history
      notifyListeners();
      _saveGame(); // Save game after purchase
      return '[${newWeapon.name}] 획득!';
    } else {
      return '골드가 부족합니다.';
    }
  }

  // New method to open a gacha box
  String openGachaBox(GachaBox box) {
    _player.gachaBoxes.removeWhere(
      (b) => b.id == box.id,
    ); // Remove the opened box

    String resultMessage = '상자 개봉!\n';
    final random = Random();

    // Gold reward
    final goldAmount =
        random.nextInt(box.stageLevel * 100) + (box.stageLevel * 25);
    _player.gold += goldAmount.toDouble();
    resultMessage += '골드 $goldAmount 획득!\n';

    // Enhancement Stones reward
    final enhancementStoneAmount = random.nextInt((box.stageLevel ~/ 10) + 1);
    if (enhancementStoneAmount > 0) {
      _player.enhancementStones += enhancementStoneAmount;
      resultMessage += '강화석 $enhancementStoneAmount개 획득!\n';
    }

    // Transcendence Stones reward
    if (random.nextDouble() < 0.025) {
      _player.transcendenceStones += 1;
      resultMessage += '초월석 1개 획득!\n';
    }

    // Weapon reward (guaranteed for now, but could be probabilistic)
    final newWeapon = WeaponData.getWeaponForStageLevel(
      box.stageLevel,
    ); // Filter by stageLevel
    _player.inventory.add(newWeapon);
    _player.acquiredWeaponIdsHistory.add(newWeapon.id); // Add to history
    resultMessage += '[${newWeapon.name}] 획득!\n';

    notifyListeners();
    _saveGame();
    return resultMessage;
  }

  // New method to sell a weapon
  String sellWeapon(Weapon weaponToSell) {
    if (_player.equippedWeapon == weaponToSell) {
      return '장착 중인 무기는 판매할 수 없습니다.';
    }

    final sellPrice =
        weaponToSell.baseSellPrice + (weaponToSell.investedGold / 3);
    final returnedEnhancementStones =
        (weaponToSell.investedEnhancementStones / 3).toInt();
    final returnedTranscendenceStones =
        (weaponToSell.investedTranscendenceStones / 3).toInt();

    _player.gold += sellPrice;
    _player.enhancementStones += returnedEnhancementStones;
    _player.transcendenceStones += returnedTranscendenceStones;
    _player.inventory.removeWhere(
      (w) => w.id == weaponToSell.id,
    ); // Assuming unique IDs for weapons

    notifyListeners();
    _saveGame();

    String message = '${weaponToSell.name} 판매 완료!\n';
    message += '골드 ${sellPrice.toStringAsFixed(0)} 획득!\n';
    if (returnedEnhancementStones > 0) {
      message += '강화석 $returnedEnhancementStones개 획득!\n';
    }
    if (returnedTranscendenceStones > 0) {
      message += '초월석 $returnedTranscendenceStones개 획득!\n';
    }
    return message;
  }

  // New method to disassemble a weapon
  String disassembleWeapon(Weapon weaponToDisassemble) {
    if (_player.equippedWeapon == weaponToDisassemble) {
      return '장착 중인 무기는 분해할 수 없습니다.';
    }

    final returnedGold = 0.0; // Gold is not returned on disassemble
    final returnedEnhancementStones = weaponToDisassemble
        .investedEnhancementStones; // All invested enhancement stones
    final returnedTranscendenceStones = weaponToDisassemble
        .investedTranscendenceStones; // All invested transcendence stones

    // Gold is NOT added to player's balance
    _player.enhancementStones += returnedEnhancementStones;
    _player.transcendenceStones += returnedTranscendenceStones;
    _player.inventory.removeWhere(
      (w) => w.id == weaponToDisassemble.id,
    ); // Assuming unique IDs for weapons

    notifyListeners();
    _saveGame();

    String message = '${weaponToDisassemble.name} 분해 완료!\n';
    message += '골드 ${returnedGold.toStringAsFixed(0)} 획득!\n';
    if (returnedEnhancementStones > 0) {
      message += '강화석 $returnedEnhancementStones개 획득!\n';
    }
    if (returnedTranscendenceStones > 0) {
      message += '초월석 $returnedTranscendenceStones개 획득!\n';
    }
    return message;
  }
}
