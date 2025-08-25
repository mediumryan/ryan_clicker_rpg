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
    _player.acquiredWeaponIdsHistory.add(
      _player.equippedWeapon.id,
    ); // ADD THIS LINE: Ensure equipped weapon is always in history
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
      // --- START TEST INJECTION ---
      _player.transcendenceStones = 1000;
      _player.enhancementStones = 10000;
      _player.gold = 9999999999.0; // Gold is double
      // --- END TEST INJECTION ---
    }
  }

  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    final playerDataString = jsonEncode(_player.toJson());
    await prefs.setString('player_data', playerDataString);
  }

  Map<String, dynamic> attackMonster() {
    // Calculate damage
    double totalDamage =
        _player.equippedWeapon.calculatedDamage; // Changed to calculatedDamage
    bool isCritical =
        Random().nextDouble() < _player.equippedWeapon.criticalChance;
    if (isCritical) {
      totalDamage *= _player.equippedWeapon.criticalDamage;
    }

    // Handle special ability
    

    // Apply defense penetration
    double effectiveMonsterDefense = max(0, _monster.defense - _player.equippedWeapon.defensePenetration);

    // Apply monster defense
    double actualDamage = max(1, totalDamage - effectiveMonsterDefense);
    _monster.hp -= actualDamage;

    // Handle double attack chance
    if (Random().nextDouble() < _player.equippedWeapon.doubleAttackChance) {
      // Perform another attack (recursive call or duplicate logic)
      // For simplicity, let's just add the same damage again for now
      _monster.hp -= actualDamage; // Apply damage again
      // In a real game, you might want to show a special effect or animation
    }

    // Handle skills
    for (var skill in _player.equippedWeapon.skills) {
      // Placeholder for skill logic
      // Example: if (skill['skill_name'] == '심판') { apply judgment logic }
      // This will be implemented later based on user's request
    }

    if (_monster.hp <= 0) {
      // Monster defeated
      _isMonsterDefeated = true; // Set to true when monster is defeated
      notifyListeners(); // Notify listeners immediately to update UI

      _player.gold += (_player.currentStage * 25)
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

        // 100% chance to drop a Boss Reward Box, but only on first defeat
        if (!_player.defeatedBossNames.contains(_monster.name)) { // Check if boss already defeated by name
          _player.defeatedBossNames.add(_monster.name); // Add boss name to defeated bosses
          final bossGachaBox = GachaBox(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: '보스 처치 보상 상자',
            stageLevel: _player.currentStage,
            isBossBox: true,
          );
          _player.gachaBoxes.add(bossGachaBox);
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

  // Returns a message indicating the result of the enhancement attempt.
  String enhanceEquippedWeapon() {
    final weapon = _player.equippedWeapon;

    if (weapon.enhancement >= weapon.maxEnhancement) {
      return '이미 최대 강화 단계입니다.';
    }

    final goldCost =
        (100 + (weapon.baseLevel * 10)) * 5 + (weapon.enhancement * 250);
    final stoneCost = 1 + (weapon.baseLevel / 100).floor() + weapon.enhancement;

    if (_player.gold < goldCost) {
      return '골드가 부족합니다. (필요: $goldCost)';
    }
    if (_player.enhancementStones < stoneCost) {
      return '강화석이 부족합니다. (필요: $stoneCost)';
    }

    _player.gold -= goldCost;
    _player.enhancementStones -= stoneCost;
    weapon.investedGold += goldCost;
    weapon.investedEnhancementStones += stoneCost;

    final enhancementLevel = weapon.enhancement;
    const probabilities = [1.0, 0.9, 0.75, 0.6, 0.5];
    // const damageMultipliers = [1.05, 1.07, 1.10, 1.15, 1.20]; // Removed, damage is calculated by getter

    if (enhancementLevel >= probabilities.length) {
      return '더 이상 강화할 수 없습니다.'; // Or handle as an error
    }

    final successChance = probabilities[enhancementLevel];

    if (Random().nextDouble() < successChance) {
      // Success
      // weapon.damage *= damageMultipliers[enhancementLevel]; // Removed direct damage modification
      weapon.enhancement++;
      notifyListeners();
      _saveGame();
      return '강화 성공! +${weapon.enhancement} (Dmg: ${weapon.calculatedDamage.toStringAsFixed(0)})'; // Changed to calculatedDamage
    } else {
      // Failure
      String penaltyMessage;
      if (enhancementLevel == 3) {
        // 3 -> 4, level down
        weapon.enhancement--;
        penaltyMessage = '강화 실패... 강화 단계가 1 하락했습니다.';
      } else if (enhancementLevel == 4) {
        // 4 -> 5, reset
        weapon.enhancement = 0;
        penaltyMessage = '강화 실패... 강화 단계가 초기화되었습니다.';
      } else {
        // maintain
        penaltyMessage = '강화에 실패했지만 단계는 유지됩니다.';
      }
      notifyListeners();
      _saveGame();
      return penaltyMessage;
    }
  }

  // Returns a message indicating the result of the transcendence attempt.
  String transcendEquippedWeapon() {
    final weapon = _player.equippedWeapon;

    if (weapon.transcendence >= weapon.maxTranscendence) {
      return '이미 최대 초월 단계입니다.';
    }

    if (weapon.enhancement < weapon.maxEnhancement) {
      return '초월하려면 최대 강화(+${weapon.maxEnhancement})에 도달해야 합니다.';
    }

    final goldCost =
        (100 + (weapon.baseLevel * 10)) * 100 * (weapon.transcendence + 1);
    final stoneCost =
        (1 + (weapon.baseLevel / 200).floor()) * (weapon.transcendence + 1);

    if (_player.gold < goldCost) {
      return '골드가 부족합니다. (필요: $goldCost)';
    }
    if (_player.transcendenceStones < stoneCost) {
      return '초월석이 부족합니다. (필요: $stoneCost)';
    }

    _player.gold -= goldCost;
    _player.transcendenceStones -= stoneCost;
    weapon.investedGold += goldCost;
    weapon.investedTranscendenceStones += stoneCost;

    final transcendenceLevel = weapon.transcendence;
    const probabilities = [1.0, 0.9, 0.75, 0.5, 0.3];

    if (transcendenceLevel >= probabilities.length) {
      return '더 이상 초월할 수 없습니다.'; // Or handle as an error
    }

    if (Random().nextDouble() < probabilities[transcendenceLevel]) {
      // Success
      // weapon.damage *= damageMultipliers[transcendenceLevel]; // Removed direct damage modification
      weapon.transcendence++;
      notifyListeners();
      _saveGame();
      return '초월 성공! [${weapon.transcendence}] (Dmg: ${weapon.calculatedDamage.toStringAsFixed(0)})'; // Changed to calculatedDamage
    } else {
      // Failure
      weapon.enhancement = 0;
      weapon.transcendence = 0;
      notifyListeners();
      _saveGame();
      return '초월 실패... 강화 및 초월 단계가 초기화되었습니다.';
    }
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

  String buyTranscendenceStones({required int amount, required int cost}) {
    if (_player.gold >= cost) {
      _player.gold -= cost;
      _player.transcendenceStones += amount;
      notifyListeners();
      _saveGame(); // Save game after purchase
      return '$amount개의 초월석을 구매했습니다.';
    } else {
      return '골드가 부족합니다.';
    }
  }

  String sellEnhancementStones({required int amount}) {
    if (amount <= 0) {
      return '판매할 강화석 수량을 입력해주세요.';
    }
    if (_player.enhancementStones >= amount) {
      _player.enhancementStones -= amount;
      _player.gold += amount.toDouble(); // 1 stone = 1 gold
      notifyListeners();
      _saveGame();
      return '$amount개의 강화석을 판매하여 ${amount * 5000} 골드를 획득했습니다.';
    } else {
      return '강화석이 부족합니다.';
    }
  }

  String sellTranscendenceStones({required int amount}) {
    if (amount <= 0) {
      return '판매할 초월석 수량을 입력해주세요.';
    }
    if (_player.transcendenceStones >= amount) {
      _player.transcendenceStones -= amount;
      _player.gold += (amount * 50000).toDouble(); // 1 stone = 50000 gold
      notifyListeners();
      _saveGame();
      return '$amount개의 초월석을 판매하여 ${amount * 50000} 골드를 획득했습니다.';
    } else {
      return '초월석이 부족합니다.';
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
    int goldAmount = random.nextInt(box.stageLevel * 100) + (box.stageLevel * 25);

    // Enhancement Stones reward
    int enhancementStoneAmount = random.nextInt((box.stageLevel ~/ 10) + 1);

    // Transcendence Stones reward
    int transcendenceStoneAmount = 0;
    if (random.nextDouble() < 0.025) {
      transcendenceStoneAmount = 1;
    }

    // Apply double rewards for boss boxes
    if (box.isBossBox) {
      goldAmount *= 2;
      enhancementStoneAmount *= 2;
      transcendenceStoneAmount *= 2;
      resultMessage += '보스 상자 보상 2배!\n'; // Add a message for boss box
    }

    // --- RE-INSERTED REWARD APPLICATION ---
    _player.gold += goldAmount.toDouble();
    resultMessage += '골드 $goldAmount 획득!\n';

    if (enhancementStoneAmount > 0) {
      _player.enhancementStones += enhancementStoneAmount;
      resultMessage += '강화석 $enhancementStoneAmount개 획득!\n';
    }

    if (transcendenceStoneAmount > 0) {
      _player.transcendenceStones += transcendenceStoneAmount;
      resultMessage += '초월석 $transcendenceStoneAmount개 획득!\n';
    }
    // --- END RE-INSERTED REWARD APPLICATION ---

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
