import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ryan_clicker_rpg/models/player.dart';
import 'package:ryan_clicker_rpg/models/monster.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/models/gacha_box.dart';
import 'package:ryan_clicker_rpg/models/damage_modifier.dart';
import 'package:ryan_clicker_rpg/models/passive_stat_modifier.dart';
import 'package:ryan_clicker_rpg/models/status_effect.dart';
import 'package:ryan_clicker_rpg/models/buff.dart';
import 'package:ryan_clicker_rpg/data/monster_data.dart';
import 'package:ryan_clicker_rpg/data/stage_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ryan_clicker_rpg/providers/weapon_skill_provider.dart';
import 'package:ryan_clicker_rpg/services/reward_service.dart';
import 'package:intl/intl.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart';

class GameProvider with ChangeNotifier {
  final RewardService _rewardService = RewardService();
  late Player _player;
  late Monster _monster;
  bool _isMonsterDefeated = false;
  late WeaponSkillProvider _weaponSkillProvider;
  Timer? _timer;
  Timer? _autoAttackTimer; // New
  DateTime? _lastManualClickTime; // New
  Duration _autoAttackDelay = Duration.zero; // New

  final List<DamageModifier> _activeDamageModifiers = [];
  final List<PassiveStatModifier> _activePassiveStatModifiers = [];
  double _currentMonsterEffectiveDefense = 0.0; // New field
  Function(int damage, bool isCritical, bool isMiss)?
  _showFloatingDamageTextCallback;

  Player get player => _player;
  Monster get monster => _monster;
  bool get isMonsterDefeated => _isMonsterDefeated;
  String get currentStageName => StageData.getStageName(_player.currentStage);
  double get currentMonsterEffectiveDefense =>
      _currentMonsterEffectiveDefense; // New getter

  GameProvider() {
    _weaponSkillProvider = WeaponSkillProvider(this);
  }

  void recalculatePlayerStats() {
    final weapon = _player.equippedWeapon;

    // 1. Start with weapon base stats
    double damage = weapon.baseDamage;
    double critChance = weapon.criticalChance;
    double critDamage = weapon.criticalDamage;
    double attackSpeed = weapon.speed;
    double doubleAttackChance = weapon.doubleAttackChance;
    double defensePenetration = weapon.defensePenetration;

    // Calculate auto-attack delay
    _autoAttackDelay = Duration(
      milliseconds: (1000 / attackSpeed).round(),
    ); // New

    // 2. Apply enhancement bonus (damage only)
    damage *= pow(1.08, weapon.enhancement);

    // 3. Apply transcendence bonuses
    if (weapon.transcendence > 0) {
      final bonus = Weapon.transcendenceBonuses[weapon.transcendence];
      if (bonus != null) {
        damage *= (1 + bonus.damageBonus);
        attackSpeed *= (1 + bonus.speedBonus);
        critChance += bonus.critChanceBonus;
        critDamage += bonus.critDamageBonus;
      }
    }

    // 4. Apply player-wide passive bonuses
    damage += _player.passiveWeaponDamageBonus;
    damage *= _player.passiveWeaponDamageMultiplier;
    critChance += _player.passiveWeaponCriticalChanceBonus;
    critDamage += _player.passiveWeaponCriticalDamageBonus;
    doubleAttackChance += _player.passiveWeaponDoubleAttackChanceBonus;
    defensePenetration += _player.passiveWeaponDefensePenetrationBonus;

    // 5. Apply temporary buffs
    for (final buff in _player.buffs) {
      switch (buff.stat) {
        case Stat.damage:
          if (buff.isMultiplicative) {
            damage *= buff.value;
          } else {
            damage += buff.value;
          }
          break;
        case Stat.speed:
          if (buff.isMultiplicative) {
            attackSpeed *= buff.value;
          } else {
            attackSpeed += buff.value;
          }
          break;
        case Stat.criticalChance:
          critChance += buff.value;
          break;
        case Stat.criticalDamage:
          critDamage += buff.value;
          break;
        case Stat.doubleAttackChance:
          doubleAttackChance += buff.value;
          break;
        case Stat.defensePenetration:
          defensePenetration += buff.value;
          break;
      }
    }

    // 6. Set final stats on player object
    _player.finalDamage = damage;
    _player.finalCritChance = critChance;
    _player.finalCritDamage = critDamage;
    _player.finalAttackSpeed = attackSpeed;
    _player.finalDoubleAttackChance = doubleAttackChance;
    _player.finalDefensePenetration = defensePenetration;
  }

  Future<void> initializeGame() async {
    await WeaponData.initialize();
    await _loadGame();
    recalculatePlayerStats(); // Initial stat calculation
    _player.acquiredWeaponIdsHistory.add(_player.equippedWeapon.id);
    _spawnMonster();
    _startGameLoop();
    startAutoAttack(); // New: Start auto-attack on game initialization
  }

  Map<String, dynamic> attackMonster() {
    debugPrint(
      '[GameProvider.attackMonster] Monster HP before attack: ${_monster.hp}, Defense: ${_monster.defense}',
    );
    debugPrint(
      '[GameProvider.attackMonster] Player finalDefensePenetration: ${_player.finalDefensePenetration}',
    );

    // Check for hit/miss based on weapon accuracy
    if (Random().nextDouble() > _player.equippedWeapon.accuracy) {
      showFloatingDamageText(0, false, true); // Notify UI about miss
      return {'damageDealt': 0, 'isCritical': false, 'isMiss': true};
    }

    // Check for Freeze/Shatter effect
    if (_monster.hasStatusEffect(StatusEffectType.freeze)) {
      final shatterDamageMultiplier = _monster.isBoss ? 0.10 : 0.25;
      final shatterDamage = _monster.maxHp * shatterDamageMultiplier;
      _monster.hp -= shatterDamage;
      showFloatingDamageText(
        shatterDamage.toInt(),
        true,
        false,
      ); // Show as crit for visual flair
      _monster.statusEffects.removeWhere(
        (effect) => effect.type == StatusEffectType.freeze,
      );
    }

    // Use the final, pre-calculated stats from the player object
    double totalDamage = _player.finalDamage;
    bool isCritical = Random().nextDouble() < _player.finalCritChance;
    if (isCritical) {
      totalDamage *= _player.finalCritDamage;
    }

    debugPrint(
      '[GameProvider.attackMonster] Monster defense before status effect application: ${_monster.defense}',
    );
    double effectiveDefense =
        _monster.defense - _player.finalDefensePenetration;

    // Apply defense reduction from status effects like weakness
    double totalDefenseReduction = 0;
    debugPrint(
      '[GameProvider.attackMonster] Monster status effects: ${_monster.statusEffects.map((e) => '${e.type}:${e.value}').join(', ')}',
    );
    for (final effect in _monster.statusEffects) {
      if (effect.type == StatusEffectType.weakness) {
        totalDefenseReduction += effect.value ?? 0;
        debugPrint(
          '[GameProvider.attackMonster] Adding ${effect.value} from ${effect.type} to totalDefenseReduction. Current total: $totalDefenseReduction',
        );
      }
      // Add disarm logic here
      if (effect.type == StatusEffectType.disarm) {
        if (effect.value != null) {
          if (effect.value! > 1) {
            // Fixed amount reduction
            effectiveDefense -= effect.value!;
            debugPrint(
              '[GameProvider.attackMonster] Effective defense after disarm (fixed reduction: ${effect.value!}): $effectiveDefense',
            );
          } else {
            // Percentage reduction
            effectiveDefense *= (1 - effect.value!);
            debugPrint(
              '[GameProvider.attackMonster] Effective defense after disarm (percentage reduction: ${effect.value! * 100}%): $effectiveDefense',
            );
          }
        }
      }
    }
    effectiveDefense -= totalDefenseReduction;
    debugPrint(
      '[GameProvider.attackMonster] Effective defense after status effects: $effectiveDefense',
    );
    debugPrint(
      '[GameProvider.attackMonster] Monster defense after status effect application: ${_monster.defense}',
    );

    // Charm: 10% defense reduction
    if (_monster.hasStatusEffect(StatusEffectType.charm)) {
      effectiveDefense *= 0.90;
      debugPrint(
        '[GameProvider.attackMonster] Effective defense after charm (10% reduction): $effectiveDefense',
      );
    }

    _currentMonsterEffectiveDefense =
        effectiveDefense; // Store the calculated effective defense
    debugPrint(
      '[GameProvider.attackMonster] Stored _currentMonsterEffectiveDefense: $_currentMonsterEffectiveDefense',
    );

    double defenseDamageMultiplier = 1.0;
    if (effectiveDefense > 0) {
      defenseDamageMultiplier = 1.0 - (effectiveDefense * 0.01);
    } else {
      defenseDamageMultiplier = 1.0 + (effectiveDefense.abs() * 0.025);
    }
    if (effectiveDefense > 0) {
      defenseDamageMultiplier = max(0.1, defenseDamageMultiplier);
    }
    debugPrint(
      '[GameProvider.attackMonster] Defense damage multiplier: $defenseDamageMultiplier',
    );

    double actualDamage = totalDamage * defenseDamageMultiplier;
    actualDamage = max(1, actualDamage);
    debugPrint(
      '[GameProvider.attackMonster] Actual damage before debuffs: $actualDamage',
    );

    // Confuse: 25% more damage
    if (_monster.hasStatusEffect(StatusEffectType.confusion)) {
      actualDamage *= 1.25;
      debugPrint(
        '[GameProvider.attackMonster] Actual damage after confusion (25% increase): $actualDamage',
      );
    }

    // Charm: 10% increased damage taken
    if (_monster.hasStatusEffect(StatusEffectType.charm)) {
      actualDamage *= 1.10;
      debugPrint(
        '[GameProvider.attackMonster] Actual damage after charm (10% increase): $actualDamage',
      );
    }

    for (final modifier in _activeDamageModifiers) {
      bool conditionMet = false;
      if (modifier.requiredRace != null) {
        if (_monster.species.contains(modifier.requiredRace)) {
          conditionMet = true;
        }
      } else if (modifier.requiredStatusEffectType != null) {
        if (_monster.hasStatusEffect(modifier.requiredStatusEffectType!)) {
          conditionMet = true;
        }
      }

      if (conditionMet) {
        actualDamage *= modifier.multiplier;
      }
    }

    if (_monster.hasStatusEffect(StatusEffectType.shock)) {
      final shockDamage = _monster.maxHp * 0.03;
      actualDamage += shockDamage;
    }

    _monster.hp -= actualDamage;
    showFloatingDamageText(
      actualDamage.toInt(),
      isCritical,
      false,
    ); // Show damage for hit

    // Apply shock damage on hit
    if (_monster.hasStatusEffect(StatusEffectType.shock)) {
      final shockDamageMultiplier = _monster.isBoss ? 0.005 : 0.03;
      final shockDamage = _monster.maxHp * shockDamageMultiplier;
      _monster.hp -= shockDamage;
      showFloatingDamageText(shockDamage.toInt(), false, false);
    }

    if (Random().nextDouble() < _player.finalDoubleAttackChance) {
      _monster.hp -= actualDamage;
      // Re-show damage text for the second hit
      showFloatingDamageText(actualDamage.toInt(), isCritical, false);

      // Apply shock damage on double attack hit
      if (_monster.hasStatusEffect(StatusEffectType.shock)) {
        final shockDamageMultiplier = _monster.isBoss ? 0.005 : 0.03;
        final shockDamage = _monster.maxHp * shockDamageMultiplier;
        _monster.hp -= shockDamage;
        showFloatingDamageText(shockDamage.toInt(), false, false);
      }
    }

    _weaponSkillProvider.applySkills(_player, _monster);

    if (_monster.hp <= 0) {
      _weaponSkillProvider.applyOnKillSkills(_player, _monster); // New
      _isMonsterDefeated = true;
      notifyListeners();

      final double bossMultiplier = _monster.isBoss ? 3.0 : 1.0;
      final goldReward =
          (_player.currentStage * 25).toDouble() *
          _player.passiveGoldGainMultiplier *
          bossMultiplier;
      _player.gold += goldReward;

      final maxStones = (_player.currentStage ~/ 100) + 1;
      int stonesDropped = Random().nextInt(maxStones + 1);
      if (stonesDropped > 0) {
        stonesDropped = (stonesDropped * bossMultiplier).toInt();
        stonesDropped =
            (stonesDropped * _player.passiveEnhancementStoneGainMultiplier)
                .toInt();
        stonesDropped += _player.passiveEnhancementStoneGainFlat;
        _player.enhancementStones += stonesDropped;
      }

      GachaBox? droppedBox;
      if (_monster.isBoss) {
        droppedBox = _rewardService.getDropForBoss(
          _player.currentStage,
          _player.defeatedBossNames.toList(),
        );
        final bossId = 'boss_stage_${_player.currentStage}';
        if (droppedBox.id == bossId) {
          if (!_player.defeatedBossNames.contains(bossId)) {
            _player.defeatedBossNames.add(bossId);
          }
        }
      } else {
        droppedBox = _rewardService.getDropForNormalMonster(
          _player.currentStage,
        );
      }

      if (droppedBox != null) {
        _player.gachaBoxes.add(droppedBox);
      }

      if (_player.currentStage >= _player.highestStageCleared) {
        _player.highestStageCleared = _player.currentStage;
      }

      Future.delayed(const Duration(seconds: 1), () {
        goToNextStage();
      });
    } else {
      notifyListeners();
    }
    _saveGame();
    return {'damageDealt': actualDamage.toInt(), 'isCritical': isCritical};
  }

  void equipWeapon(Weapon weaponToEquip) {
    if (_player.equippedWeapon.id == weaponToEquip.id) return;

    final index = _player.inventory.indexWhere((w) => w.id == weaponToEquip.id);
    if (index != -1) {
      final oldInventoryWeapon = _player.inventory[index];
      _player.inventory.removeAt(index);
      _player.inventory.add(_player.equippedWeapon);
      _player.equippedWeapon = oldInventoryWeapon;

      recalculatePlayerStats();
      _weaponSkillProvider.updatePassiveSkills(_player, _monster);

      notifyListeners();
      _saveGame();
    }
  }

  String enhanceEquippedWeapon() {
    final weapon = _player.equippedWeapon;
    if (weapon.id == 0) return '맨손은 강화할 수 없습니다.';
    if (weapon.enhancement >= weapon.maxEnhancement) return '이미 최대 강화 단계입니다.';

    final rarityMultiplier = weapon.rarity.index + 1;
    final goldCost =
        ((weapon.baseLevel + 1) + pow(weapon.enhancement + 1, 2.5)) *
        225 *
        rarityMultiplier;
    final stoneCost =
        ((weapon.enhancement + 1) / 2).ceil() + (rarityMultiplier - 1);

    if (_player.gold < goldCost)
      return '골드가 부족합니다. (필요: ${NumberFormat('#,###').format(goldCost)}G)';
    if (_player.enhancementStones < stoneCost)
      return '강화석이 부족합니다. (필요: $stoneCost)';

    _player.gold -= goldCost;
    _player.enhancementStones -= stoneCost;
    weapon.investedGold += goldCost;
    weapon.investedEnhancementStones += stoneCost;

    final enhancementLevel = weapon.enhancement;
    final probabilities = [
      1.0, 1.0, 1.0, 1.0, 1.0, 1.0, // 0-5
      0.90, 0.85, 0.80, 0.75, 0.70, // 6-10
      0.60, 0.53, 0.47, 0.40, // 11-14
      0.30, 0.25, 0.20, // 15-17
      0.15, 0.10, // 18-19
      0.05, // 20
    ];
    final successChance = enhancementLevel < probabilities.length
        ? probabilities[enhancementLevel]
        : 0.0;

    if (Random().nextDouble() < successChance) {
      weapon.enhancement++;
      recalculatePlayerStats();
      notifyListeners();
      _saveGame();
      return '강화 성공! +${weapon.enhancement}';
    } else {
      String penaltyMessage;
      if (enhancementLevel < 4) {
        penaltyMessage = '강화에 실패했지만 단계는 유지됩니다.';
      } else if (enhancementLevel < 10) {
        weapon.enhancement--;
        penaltyMessage = '강화 실패... 강화 단계가 1 하락했습니다.';
      } else {
        _player.equippedWeapon = Weapon.bareHands();
        penaltyMessage = '강화 실패... 무기가 파괴되었습니다.';
      }
      recalculatePlayerStats();
      notifyListeners();
      _saveGame();
      return penaltyMessage;
    }
  }

  String transcendEquippedWeapon() {
    final weapon = _player.equippedWeapon;
    final rarityMultiplier = weapon.rarity.index + 1;
    if (weapon.id == 0) return '맨손은 초월할 수 없습니다.';
    if (weapon.transcendence >= weapon.maxTranscendence) return '이미 초월한 무기입니다.';
    if (weapon.enhancement < 20) return '초월하려면 +20 강화에 도달해야 합니다.';

    final goldCost =
        (100 + (weapon.baseLevel + 1) * 10) *
        1000000 *
        rarityMultiplier *
        (weapon.transcendence + 1);
    final int stoneCost =
        ((rarityMultiplier + ((weapon.baseLevel + 1) / 200).floor()) *
                (weapon.transcendence + 1))
            .toInt();

    if (_player.gold < goldCost) return '골드가 부족합니다. (필요: $goldCost)';
    if (_player.transcendenceStones < stoneCost)
      return '초월석이 부족합니다. (필요: $stoneCost)';

    _player.gold -= goldCost;
    _player.transcendenceStones -= stoneCost;
    weapon.investedGold += goldCost;
    weapon.investedTranscendenceStones += stoneCost;

    const probabilities = [0.05];
    if (Random().nextDouble() < probabilities[weapon.transcendence]) {
      weapon.transcendence++;
      recalculatePlayerStats();
      notifyListeners();
      _saveGame();
      return '초월 성공! [${weapon.transcendence}]';
    } else {
      _player.equippedWeapon = Weapon.bareHands();
      recalculatePlayerStats();
      notifyListeners();
      _saveGame();
      return '초월 실패... 무기가 파괴되었습니다.';
    }
  }

  // Other methods (load, save, etc.) are here...
  // Make sure to include them in the final replacement string

  void startAutoAttack() {
    _autoAttackTimer?.cancel();
    _autoAttackTimer = Timer.periodic(_autoAttackDelay, (timer) {
      if (!_isMonsterDefeated) {
        attackMonster();
      }
    });
    notifyListeners();
  }

  void stopAutoAttack() {
    _autoAttackTimer?.cancel();
    notifyListeners();
  }

  void handleManualClick() {
    _lastManualClickTime = DateTime.now();
    stopAutoAttack(); // Stop auto-attack immediately on manual click

    // Start a timer to re-engage auto-attack after 3 seconds of inactivity
    Timer(const Duration(seconds: 3), () {
      if (DateTime.now().difference(_lastManualClickTime!).inSeconds >= 3) {
        startAutoAttack();
      }
    });
  }

  void addDamageModifier(DamageModifier modifier) {
    _activeDamageModifiers.add(modifier);
  }

  void clearDamageModifiers() {
    _activeDamageModifiers.clear();
  }

  void addPassiveStatModifier(PassiveStatModifier modifier) {
    _activePassiveStatModifiers.add(modifier);
  }

  void clearPassiveStatModifiers() {
    _activePassiveStatModifiers.clear();
  }

  void setShowFloatingDamageTextCallback(
    Function(int damage, bool isCritical, bool isMiss)? callback,
  ) {
    _showFloatingDamageTextCallback = callback;
  }

  void showFloatingDamageText(int damage, bool isCritical, bool isMiss) {
    _showFloatingDamageTextCallback?.call(damage, isCritical, isMiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoAttackTimer?.cancel(); // New
    super.dispose();
  }

  void _startGameLoop() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updatePerSecond();
    });
  }

  void _updatePerSecond() {
    if (_monster.hp > 0) {
      // Apply damage from DoT effects BEFORE ticking them down
      for (final effect in _monster.statusEffects) {
        switch (effect.type) {
          case StatusEffectType.bleed:
          case StatusEffectType.poison:
          case StatusEffectType.burn:
            if (effect.value != null && effect.value! > 0) {
              _monster.hp -= effect.value!;
              showFloatingDamageText(effect.value!.toInt(), false, false);
            }
            break;
          default:
            // Other effects do not deal damage per second
            break;
        }
      }
      _monster
          .updateStatusEffects(); // This will tick down duration and remove expired effects
    }

    // Handle player buffs
    if (_player.buffs.isNotEmpty) {
      bool buffsExpired = false;
      _player.buffs.removeWhere((buff) {
        buff.duration--;
        if (buff.duration <= 0) {
          buffsExpired = true;
          return true;
        }
        return false;
      });

      if (buffsExpired) {
        recalculatePlayerStats();
      }
    }
    notifyListeners();
  }

  void _spawnMonster() {
    _monster = MonsterData.getMonsterForStage(_player.currentStage);
    _isMonsterDefeated = false;
    _weaponSkillProvider.applyStageStartSkills(_player, _monster);
    notifyListeners();
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final playerDataString = prefs.getString('player_data');

    if (playerDataString != null) {
      final Map<String, dynamic> playerDataJson = jsonDecode(playerDataString);
      _player = Player.fromJson(playerDataJson);
    } else {
      _player = Player(equippedWeapon: Weapon.startingWeapon());
      _player.transcendenceStones = 0;
      _player.enhancementStones = 0;
      _player.gold = 0.0;
      _player.inventory.addAll(
        WeaponData.uniqueWeapons.map((w) => w.copyWith()),
      );
      _player.inventory.addAll(WeaponData.epicWeapons.map((w) => w.copyWith()));
      _player.currentStage = 500;
    }
  }

  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    final playerDataString = jsonEncode(_player.toJson());
    await prefs.setString('player_data', playerDataString);
  }

  void goToNextStage() {
    if (_player.currentStage < _player.highestStageCleared) {
      _player.currentStage++;
      _spawnMonster();
      _saveGame();
    } else if (_isMonsterDefeated) {
      _player.currentStage++;
      _spawnMonster();
      _saveGame();
    }
  }

  void goToPreviousStage() {
    if (_player.currentStage > 1) {
      _player.currentStage--;
      _spawnMonster();
      _saveGame();
    }
  }

  String buyEnhancementStones({required int amount, required int cost}) {
    if (_player.gold >= cost) {
      _player.gold -= cost;
      _player.enhancementStones += amount;
      notifyListeners();
      _saveGame();
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
      _saveGame();
      return '$amount개의 초월석을 구매했습니다.';
    } else {
      return '골드가 부족합니다.';
    }
  }

  String sellEnhancementStones({required int amount}) {
    if (amount <= 0) return '판매할 강화석 수량을 입력해주세요.';
    if (_player.enhancementStones >= amount) {
      _player.enhancementStones -= amount;
      _player.gold += amount.toDouble();
      notifyListeners();
      _saveGame();
      return '$amount개의 강화석을 판매하여 ${amount * 5000} 골드를 획득했습니다.';
    } else {
      return '강화석이 부족합니다.';
    }
  }

  String sellTranscendenceStones({required int amount}) {
    if (amount <= 0) return '판매할 초월석 수량을 입력해주세요.';
    if (_player.transcendenceStones >= amount) {
      _player.transcendenceStones -= amount;
      _player.gold += (amount * 50000).toDouble();
      notifyListeners();
      _saveGame();
      return '$amount개의 초월석을 판매하여 ${amount * 50000} 골드를 획득했습니다.';
    } else {
      return '초월석이 부족합니다.';
    }
  }

  String openGachaBox(GachaBox box) {
    final newWeapon = _rewardService.getWeaponFromBox(
      box,
      _player.highestStageCleared,
    );
    _player.gachaBoxes.removeWhere((b) => b.id == box.id);
    _player.inventory.add(newWeapon);
    _player.acquiredWeaponIdsHistory.add(newWeapon.id);
    notifyListeners();
    _saveGame();
    return '[${newWeapon.name}] 획득!';
  }

  String sellWeapon(Weapon weaponToSell) {
    if (_player.equippedWeapon.id == weaponToSell.id)
      return '장착 중인 무기는 판매할 수 없습니다.';
    final sellPrice =
        weaponToSell.baseSellPrice + (weaponToSell.investedGold / 3);
    final returnedEnhancementStones =
        (weaponToSell.investedEnhancementStones / 3).toInt();
    final returnedTranscendenceStones =
        (weaponToSell.investedTranscendenceStones / 3).toInt();
    _player.gold += sellPrice;
    _player.enhancementStones += returnedEnhancementStones;
    _player.transcendenceStones += returnedTranscendenceStones;
    _player.inventory.removeWhere((w) => w.id == weaponToSell.id);
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

  String disassembleWeapon(Weapon weaponToDisassemble) {
    if (_player.equippedWeapon.id == weaponToDisassemble.id)
      return '장착 중인 무기는 분해할 수 없습니다.';
    final returnedEnhancementStones =
        weaponToDisassemble.investedEnhancementStones;
    final returnedTranscendenceStones =
        weaponToDisassemble.investedTranscendenceStones;
    _player.enhancementStones += returnedEnhancementStones;
    _player.transcendenceStones += returnedTranscendenceStones;
    _player.inventory.removeWhere((w) => w.id == weaponToDisassemble.id);
    notifyListeners();
    _saveGame();
    String message = '${weaponToDisassemble.name} 분해 완료!\n';
    if (returnedEnhancementStones > 0) {
      message += '강화석 $returnedEnhancementStones개 획득!\n';
    }
    if (returnedTranscendenceStones > 0) {
      message += '초월석 $returnedTranscendenceStones개 획득!\n';
    }
    return message;
  }

  String _buyWeaponBox({required int cost, required WeaponBoxType boxType}) {
    if (_player.gold < cost) return '골드가 부족합니다.';
    _player.gold -= cost;
    final newGachaBox = GachaBox(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      boxType: boxType,
      stageLevel: _player.currentStage,
    );
    _player.gachaBoxes.add(newGachaBox);
    notifyListeners();
    _saveGame();
    return '${newGachaBox.name}을(를) 획득했습니다! 인벤토리에서 확인하세요.';
  }

  String buyGuaranteedUniqueBox() {
    return _buyWeaponBox(
      cost: 1, // TODO: Define actual cost
      boxType: WeaponBoxType.guaranteedUnique,
    );
  }

  String buyGuaranteedEpicBox() {
    return _buyWeaponBox(
      cost: 1, // TODO: Define actual cost
      boxType: WeaponBoxType.guaranteedEpic,
    );
  }

  String buyAllRangeUniqueBox() => buyGuaranteedUniqueBox();
  String buyCurrentRangeUniqueBox(int currentStage) => buyGuaranteedUniqueBox();
  String buyAllRangeEpicBox() => buyGuaranteedEpicBox();
  String buyCurrentRangeEpicBox(int currentStage) => buyGuaranteedEpicBox();
}
