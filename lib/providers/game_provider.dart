import 'package:ryan_clicker_rpg/models/hero_skill.dart';
import 'package:ryan_clicker_rpg/data/hero_skill_data.dart';
import 'package:ryan_clicker_rpg/models/difficulty.dart';
import 'package:ryan_clicker_rpg/data/difficulty_data.dart';
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
import 'package:ryan_clicker_rpg/widgets/stage_zone_widget.dart';
import 'package:ryan_clicker_rpg/models/reward.dart';
import 'package:ryan_clicker_rpg/models/achievement.dart';
import 'package:ryan_clicker_rpg/data/achievement_data.dart';

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
  bool _isAutoAttackActive = true;

  Duration get autoAttackDelay => _autoAttackDelay; // New getter
  bool get isAutoAttackActive => _isAutoAttackActive;

  double _lastGoldReward = 0.0; // New field for last gold reward
  GachaBox? _lastDroppedBox; // New field for last dropped box
  double _lastEnhancementStonesReward =
      0.0; // New field for last enhancement stones reward

  final List<DamageModifier> _activeDamageModifiers = [];
  final List<PassiveStatModifier> _activePassiveStatModifiers = [];
  double _currentMonsterEffectiveDefense = 0.0; // New field
  Function(
    int damage,
    bool isCritical,
    bool isMiss, {
    bool isSkillDamage,
    DamageType damageType,
  })?
  _showFloatingDamageTextCallback;

  Function(int xpReward, Difficulty? nextDifficulty)?
  _showDifficultyClearDialogCallback;

  Player get player => _player;
  Monster get monster => _monster;
  bool get isMonsterDefeated => _isMonsterDefeated;
  bool get inSpecialBossZone => false; // This feature is removed
  String get currentStageName => StageData.getStageName(_player.currentStage);
  double get currentMonsterEffectiveDefense =>
      _currentMonsterEffectiveDefense; // New getter
  double get lastGoldReward => _lastGoldReward; // New getter
  GachaBox? get lastDroppedBox => _lastDroppedBox; // New getter
  double get lastEnhancementStonesReward =>
      _lastEnhancementStonesReward; // New getter

  bool get hasCompletableAchievements {
    return AchievementData.achievements.any(
      (a) => a.isCompletable(_player) && !a.isCompleted,
    );
  }

  GameProvider() {
    _weaponSkillProvider = WeaponSkillProvider(this);
  }

  void recalculatePlayerStats() {
    // Auto-unequip weapon if level requirement is no longer met
    if (_player.equippedWeapon.baseLevel > _player.highestStageCleared &&
        _player.equippedWeapon.instanceId != 'bare_hands') {
      _player.equippedWeapon = Weapon.bareHands();
    }

    // Reset passive bonuses before recalculating from skills
    _player.passiveGoldGainMultiplier = 1.0;
    _player.passiveEnhancementStoneGainMultiplier = 1.0;
    _player.passiveWeaponDamageMultiplier = 1.0;
    _player.passiveWeaponCriticalChanceBonus = 0.0;
    _player.passiveWeaponCriticalDamageBonus = 0.0;

    // Apply hero skill effects
    _player.learnedSkills.forEach((skillId, level) {
      final skill = HeroSkillData.findById(skillId);
      if (skill != null) {
        final effectValue = skill.calculateEffect(level);
        switch (skill.effectType) {
          case SkillEffectType.passiveGoldGainMultiplier:
            _player.passiveGoldGainMultiplier += effectValue;
            break;
          case SkillEffectType.passiveEnhancementStoneGainMultiplier:
            _player.passiveEnhancementStoneGainMultiplier += effectValue;
            break;
          case SkillEffectType.passiveWeaponDamageMultiplier:
            _player.passiveWeaponDamageMultiplier += effectValue;
            break;
          case SkillEffectType.passiveWeaponCriticalChanceBonus:
            _player.passiveWeaponCriticalChanceBonus += effectValue;
            break;
          case SkillEffectType.passiveWeaponCriticalDamageBonus:
            _player.passiveWeaponCriticalDamageBonus += effectValue;
            break;
          default:
            break;
        }
      }
    });

    final weapon = _player.equippedWeapon;

    // 1. Start with weapon stats (which now include enhancement and transcendence)
    double damage = weapon.calculatedDamage;
    double critChance = weapon.calculatedCritChance;
    double critDamage = weapon.calculatedCritDamage;
    double attackSpeed = weapon.calculatedSpeed;
    double accuracy = weapon
        .accuracy; // Assuming accuracy is not affected by enhancement/transcendence
    double doubleAttackChance = weapon.doubleAttackChance;
    double defensePenetration = weapon.defensePenetration;

    // Apply stack damage
    if (weapon.stack['enabled'] == true) {
      final currentStacks = weapon.stack['currentStacks'] as int? ?? 0;
      final damagePerStack = weapon.stack['damagePerStack'] as num? ?? 0;
      damage += currentStacks * damagePerStack;
    }

    // 4. Apply player-wide passive bonuses
    damage += _player.passiveWeaponDamageBonus;
    damage *= _player.passiveWeaponDamageMultiplier;
    critChance += _player.passiveWeaponCriticalChanceBonus;
    critChance *= _player.passiveWeaponCriticalChanceMultiplier;
    critDamage += _player.passiveWeaponCriticalDamageBonus;
    critDamage *= _player.passiveWeaponCriticalDamageMultiplier;
    doubleAttackChance += _player.passiveWeaponDoubleAttackChanceBonus;
    defensePenetration += _player.passiveWeaponDefensePenetrationBonus;
    attackSpeed += _player.passiveWeaponSpeedBonus;
    attackSpeed *= _player.passiveWeaponSpeedMultiplier;
    accuracy += _player.passiveWeaponAccuracyBonus;
    accuracy *= _player.passiveWeaponAccuracyMultiplier;

    // 5. Apply temporary buffs
    for (final buff in _player.buffs) {
      switch (buff.stat) {
        case Stat.damage:
          if (buff.isMultiplicative) {
            damage *= (1 + buff.value);
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
    _player.finalAccuracy = accuracy;
    _player.finalDoubleAttackChance = doubleAttackChance;
    _player.finalDefensePenetration = defensePenetration;

    // Calculate auto-attack delay
    _autoAttackDelay = Duration(
      microseconds: (1000000 / _player.finalAttackSpeed).round(),
    ); // New
  }

  void _recalculateMonsterEffectiveDefense() {
    double effectiveDefense =
        _monster.defense - _player.finalDefensePenetration;

    double totalDefenseReduction = 0;
    for (final effect in _monster.statusEffects) {
      if (effect.type == StatusEffectType.weakness) {
        totalDefenseReduction += effect.value ?? 0;
      }
    }
    effectiveDefense -= totalDefenseReduction;

    _currentMonsterEffectiveDefense = effectiveDefense;
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
    if (_isMonsterDefeated) return {}; // Don't attack dead monsters

    // 1. Accuracy Check
    if (Random().nextDouble() > _player.finalAccuracy) {
      _dealDamageToMonster(0, isMiss: true);
      return {'damageDealt': 0, 'isCritical': false, 'isMiss': true};
    }

    // 2. Pre-hit effects (like Shatter)
    _applyShatterEffect();
    if (_monster.hp <= 0) return _handleMonsterDefeat();

    // 3. Calculate Damage
    final attack = _calculateAttackDamage();
    double actualDamage = _applyDamageModifiers(attack.damage);

    // 4. Deal Main Damage and apply shock
    _dealDamageToMonster(actualDamage, isCritical: attack.isCritical);
    _applyShockDamageOnHit(isDoubleAttack: false);
    if (_monster.hp <= 0) return _handleMonsterDefeat();

    // 5. Double Attack
    if (Random().nextDouble() < _player.finalDoubleAttackChance) {
      _dealDamageToMonster(
        actualDamage,
        isCritical: attack.isCritical,
        damageType: DamageType.doubleAttack,
      );
      _applyShockDamageOnHit(isDoubleAttack: true);
      if (_monster.hp <= 0) return _handleMonsterDefeat();
    }

    // 6. Weapon Skills
    _weaponSkillProvider.applySkills(_player, _monster);
    if (_monster.hp <= 0) return _handleMonsterDefeat();

    // 7. Save and return
    _saveGame();
    return {
      'damageDealt': actualDamage.toInt(),
      'isCritical': attack.isCritical,
    };
  }

  void _dealDamageToMonster(
    double damage, {
    bool isCritical = false,
    bool isMiss = false,
    DamageType damageType = DamageType.normal,
  }) {
    if (isMiss) {
      showFloatingDamageText(0, false, true);
      return;
    }
    _monster.hp -= damage;
    _monster.hp = max(0, _monster.hp);
    showFloatingDamageText(
      damage.toInt(),
      isCritical,
      isMiss,
      damageType: damageType,
    );
  }

  void _applyShatterEffect() {
    if (!_monster.hasStatusEffect(StatusEffectType.freeze)) return;

    final shatterDamageMultiplier = _monster.isBoss ? 0.1 : 0.2;
    var shatterDamage = _monster.maxHp * shatterDamageMultiplier;

    final freezeEffect = _monster.statusEffects.firstWhere(
      (e) => e.type == StatusEffectType.freeze,
    );

    if (freezeEffect.maxDmg != null) {
      shatterDamage = min(shatterDamage, freezeEffect.maxDmg!.toDouble());
    } else {
      shatterDamage = min(shatterDamage, _player.finalDamage);
    }

    _dealDamageToMonster(
      shatterDamage,
      isCritical: true, // Shatter is always a "crit" for visual flair
      damageType: DamageType.shatter,
    );
    _monster.statusEffects.removeWhere(
      (effect) => effect.type == StatusEffectType.freeze,
    );
  }

  ({double damage, bool isCritical}) _calculateAttackDamage() {
    double totalDamage = _player.finalDamage;
    bool isCritical = Random().nextDouble() < _player.finalCritChance;
    if (isCritical) {
      totalDamage *= _player.finalCritDamage;
    }
    return (damage: totalDamage, isCritical: isCritical);
  }

  double _applyDamageModifiers(double baseDamage) {
    _recalculateMonsterEffectiveDefense();

    // Defense multiplier
    double defenseDamageMultiplier = 1.0;
    if (_currentMonsterEffectiveDefense > 0) {
      defenseDamageMultiplier = 1.0 - (_currentMonsterEffectiveDefense * 0.005);
    } else {
      defenseDamageMultiplier =
          1.0 + (_currentMonsterEffectiveDefense.abs() * 0.025);
    }
    double actualDamage = baseDamage * defenseDamageMultiplier;

    // Status effect multipliers
    if (_monster.hasStatusEffect(StatusEffectType.confusion)) {
      actualDamage *= 1.25;
    }
    if (_monster.hasStatusEffect(StatusEffectType.charm)) {
      actualDamage *= 1.10;
      final charmEffect = _monster.statusEffects.firstWhere(
        (e) => e.type == StatusEffectType.charm,
      );
      if (charmEffect.attackPerDefence != null) {
        _monster.defense = (_monster.defense - charmEffect.attackPerDefence!)
            .toInt();
      }
    }

    // Active damage modifiers (from weapon skills, etc.)
    for (final modifier in _activeDamageModifiers) {
      bool conditionMet =
          (modifier.requiredRace != null &&
              _monster.species.contains(modifier.requiredRace)) ||
          (modifier.requiredStatusEffectType != null &&
              _monster.hasStatusEffect(modifier.requiredStatusEffectType!));
      if (conditionMet) {
        actualDamage *= (1 + modifier.multiplier);
      }
    }

    return max(1, actualDamage);
  }

  void _applyShockDamageOnHit({required bool isDoubleAttack}) {
    if (!_monster.hasStatusEffect(StatusEffectType.shock)) return;

    final shockDamageMultiplier = _monster.isBoss
        ? (isDoubleAttack ? 0.005 : 0.015)
        : 0.03;
    var shockDamage = _monster.maxHp * shockDamageMultiplier;

    final shockEffect = _monster.statusEffects.firstWhere(
      (e) => e.type == StatusEffectType.shock,
    );
    if (shockEffect.maxDmg != null) {
      shockDamage = min(shockDamage, shockEffect.maxDmg!.toDouble());
    } else {
      shockDamage = min(shockDamage, _player.finalDamage);
    }

    _dealDamageToMonster(shockDamage, damageType: DamageType.shock);
  }

  Map<String, dynamic> _handleMonsterDefeat() {
    if (_isMonsterDefeated) return {}; // Already handled
    _isMonsterDefeated = true;

    _player.monstersKilled++;
    _weaponSkillProvider.applyOnKillSkills(_player, _monster);

    _grantRewards();

    if (_player.currentStage >= _player.highestStageCleared) {
      _player.highestStageCleared = _player.currentStage;
      recalculatePlayerStats(); // Check for weapon requirement changes
    }

    // Check for difficulty completion
    final currentGoal = DifficultyData.getDifficultyGoal(
      _player.currentDifficulty,
    );
    if (_player.currentStage >= currentGoal) {
      _completeDifficulty();
      return {'damageDealt': 0, 'isCritical': false, 'monsterDefeated': true};
    }

    notifyListeners();

    // Use a delayed future to move to the next stage
    Future.delayed(const Duration(seconds: 1), () {
      goToNextStage();
    });

    _saveGame();
    return {'damageDealt': 0, 'isCritical': false, 'monsterDefeated': true};
  }

  void _grantRewards() {
    final double bossMultiplier = _monster.isBoss ? 3.0 : 1.0;

    // Gold
    final goldReward =
        (_player.currentStage * 100).toDouble() *
        _player.passiveGoldGainMultiplier *
        bossMultiplier;
    _player.gold += goldReward;
    _player.totalGoldEarned += goldReward;
    _lastGoldReward = goldReward;

    // Enhancement Stones
    final maxStones = (_player.currentStage ~/ 100) + 1;
    int stonesDropped = Random().nextInt(maxStones + 1);
    if (stonesDropped > 0) {
      stonesDropped = (stonesDropped * bossMultiplier).toInt();
      stonesDropped =
          (stonesDropped * _player.passiveEnhancementStoneGainMultiplier)
              .toInt();
      stonesDropped += _player.passiveEnhancementStoneGainFlat;
      _player.enhancementStones += stonesDropped;
      _lastEnhancementStonesReward = stonesDropped.toDouble();
    } else {
      _lastEnhancementStonesReward = 0.0;
    }

    // Gacha Box
    GachaBox? droppedBox;
    if (_monster.isBoss) {
      final bossId = 'boss_stage_${_player.currentStage}';
      _player.defeatedBosses[bossId] =
          (_player.defeatedBosses[bossId] ?? 0) + 1;
      droppedBox = _rewardService.getDropForBoss(
        _player.currentStage,
        _player.defeatedBosses.keys.toList(),
      );
    } else {
      droppedBox = _rewardService.getDropForNormalMonster(_player.currentStage);
    }

    if (droppedBox != null) {
      _player.gachaBoxes.add(droppedBox);
      _lastDroppedBox = droppedBox;
    } else {
      _lastDroppedBox = null;
    }
  }

  void equipWeapon(Weapon weaponToEquip) {
    if (weaponToEquip.baseLevel > _player.highestStageCleared) {
      // This should ideally be handled by the UI, but as a safeguard.
      return;
    }
    if (_player.equippedWeapon.instanceId == weaponToEquip.instanceId) return;

    final index = _player.inventory.indexWhere(
      (w) => w.instanceId == weaponToEquip.instanceId,
    );
    if (index != -1) {
      final oldInventoryWeapon = _player.inventory[index];
      _player.inventory.removeAt(index);
      _player.inventory.add(_player.equippedWeapon);
      _player.equippedWeapon = oldInventoryWeapon;

      _activeDamageModifiers.clear(); // Clear existing damage modifiers
      recalculatePlayerStats();
      _weaponSkillProvider.updatePassiveSkills(_player, _monster);
      startAutoAttack(); // Restart auto-attack with new speed

      notifyListeners();
      _saveGame();
    }
  }

  Map<String, dynamic> enhanceEquippedWeapon({
    bool useProtectionTicket = false,
  }) {
    final weapon = _player.equippedWeapon;
    if (weapon.instanceId == 'bare_hands') {
      return {'success': false, 'message': '맨손은 강화할 수 없습니다.'};
    }
    if (weapon.enhancement >= weapon.maxEnhancement) {
      return {'success': false, 'message': '이미 최대 강화 단계입니다.'};
    }

    final rarityMultiplier = weapon.rarity.index + 1;
    final goldCost =
        ((weapon.baseLevel + 1) + pow(weapon.enhancement + 1, 2.5)) *
        30 *
        rarityMultiplier;
    final stoneCost =
        ((weapon.enhancement + 1) / 2).ceil() + (rarityMultiplier - 1);

    if (_player.gold < goldCost) {
      return {
        'success': false,
        'message':
            '골드가 부족합니다. (필요: ${NumberFormat('#,###').format(goldCost)}G)',
      };
    }
    if (_player.enhancementStones < stoneCost) {
      return {'success': false, 'message': '강화석이 부족합니다. (필요: $stoneCost)'};
    }

    if (useProtectionTicket) {
      final ticketCost =
          (((rarityMultiplier) +
                      (weapon.enhancement / 5) +
                      (weapon.baseLevel / 100)) /
                  5)
              .truncate();
      if (_player.destructionProtectionTickets < ticketCost) {
        return {
          'success': false,
          'message': '무기 파괴 방지권이 부족합니다. (필요: $ticketCost개)',
        };
      }
      _player.destructionProtectionTickets -= ticketCost;
    }

    final oldStats = {
      'damage': weapon.calculatedDamage,
      'attackSpeed': weapon.calculatedSpeed,
      'critDamage': weapon.calculatedCritDamage,
    };

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

      final newStats = {
        'damage': weapon.calculatedDamage,
        'attackSpeed': weapon.calculatedSpeed,
        'critDamage': weapon.calculatedCritDamage,
      };

      recalculatePlayerStats();
      notifyListeners();
      _saveGame();

      return {
        'success': true,
        'message': '강화 성공! +${weapon.enhancement}',
        'oldStats': oldStats,
        'newStats': newStats,
        'weapon': weapon,
      };
    } else {
      String penaltyMessage;
      if (useProtectionTicket) {
        penaltyMessage = '강화에 실패했지만, 방지권으로 무기와 강화 단계를 보호했습니다.';
      } else {
        if (enhancementLevel < 4) {
          penaltyMessage = '강화에 실패했지만 단계는 유지됩니다.';
        } else if (enhancementLevel < 10) {
          weapon.enhancement--;
          penaltyMessage = '강화 실패... 강화 단계가 1 하락했습니다.';
        } else {
          final rarityMultiplier = weapon.rarity.index + 1;
          final enhancementMultiplier = weapon.enhancement + 1;
          final levelMultiplier = 1 + (weapon.baseLevel / 50);
          final darkMatterGained =
              ((rarityMultiplier *
                          pow(enhancementMultiplier, 2.5) *
                          levelMultiplier) /
                      10)
                  .truncate()
                  .toInt();
          _player.darkMatter += darkMatterGained;

          _player.weaponDestructionCount++;
          _player.equippedWeapon = Weapon.bareHands();
          penaltyMessage =
              '강화 실패... 무기가 파괴되었습니다.\n암흑 물질 $darkMatterGained 개를 획득했습니다.';
        }
      }
      recalculatePlayerStats();
      startAutoAttack(); // Fix: Restart auto-attack with new speed
      notifyListeners();
      _saveGame();
      return {'success': false, 'message': penaltyMessage};
    }
  }

  String transcendEquippedWeapon() {
    final weapon = _player.equippedWeapon;
    final rarityMultiplier = weapon.rarity.index + 1;
    if (weapon.instanceId == 'bare_hands') {
      return '맨손은 초월할 수 없습니다.';
    }
    if (weapon.transcendence >= weapon.maxTranscendence) {
      return '이미 초월한 무기입니다.';
    }
    if (weapon.enhancement < 20) {
      return '초월하려면 +20 강화에 도달해야 합니다.';
    }

    final goldCost =
        (100 + (weapon.baseLevel + 1) * 10) *
        1250 *
        rarityMultiplier *
        (weapon.transcendence + 1);
    final int stoneCost =
        ((rarityMultiplier + ((weapon.baseLevel + 1) / 200).floor()) *
                (weapon.transcendence + 1))
            .toInt();

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

    const probabilities = [0.05];
    if (Random().nextDouble() < probabilities[weapon.transcendence]) {
      _player.transcendenceSuccessCount++;
      weapon.transcendence++;
      recalculatePlayerStats();
      notifyListeners();
      _saveGame();
      return '초월 성공! [${weapon.transcendence}]';
    } else {
      final rarityMultiplier = weapon.rarity.index + 1;
      final enhancementMultiplier = weapon.enhancement + 1;
      final levelMultiplier = 1 + (weapon.baseLevel / 50);
      final darkMatterGained =
          (rarityMultiplier * enhancementMultiplier * levelMultiplier * 2.0)
              .toInt();
      _player.darkMatter += darkMatterGained;

      _player.weaponDestructionCount++;
      _player.equippedWeapon = Weapon.bareHands();
      recalculatePlayerStats();
      startAutoAttack(); // Fix: Restart auto-attack with new speed
      notifyListeners();
      _saveGame();
      return '초월 실패... 무기가 파괴되었습니다.\n암흑 물질 $darkMatterGained 개를 획득했습니다.';
    }
  }

  // Other methods (load, save, etc.) are here...
  // Make sure to include them in the final replacement string

  void startAutoAttack() {
    _autoAttackTimer?.cancel();
    if (!_isAutoAttackActive) return;
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

  void toggleAutoAttack() {
    _isAutoAttackActive = !_isAutoAttackActive;
    if (_isAutoAttackActive) {
      startAutoAttack();
    } else {
      stopAutoAttack();
    }
    notifyListeners();
  }

  void handleManualClick() {
    if (!_player.canManualAttack) return;
    _player.totalClicks++;
    attackMonster();
    _lastManualClickTime = DateTime.now();
    stopAutoAttack(); // Stop auto-attack immediately on manual click

    // Start a timer to re-engage auto-attack after 3 seconds of inactivity
    Timer(const Duration(seconds: 3), () {
      if (DateTime.now().difference(_lastManualClickTime!).inSeconds >= 3) {
        if (_isAutoAttackActive) {
          startAutoAttack();
        }
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
    Function(
      int damage,
      bool isCritical,
      bool isMiss, {
      bool isSkillDamage,
      DamageType damageType,
    })?
    callback,
  ) {
    _showFloatingDamageTextCallback = callback;
  }

  void showFloatingDamageText(
    int damage,
    bool isCritical,
    bool isMiss, {
    bool isSkillDamage = false,
    DamageType damageType = DamageType.normal,
  }) {
    if (!_player.showFloatingDamage) return;
    _showFloatingDamageTextCallback?.call(
      damage,
      isCritical,
      isMiss,
      isSkillDamage: isSkillDamage,
      damageType: damageType,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoAttackTimer?.cancel(); // New
    super.dispose();
  }

  void setShowDifficultyClearDialogCallback(
    Function(int xpReward, Difficulty? nextDifficulty)? callback,
  ) {
    _showDifficultyClearDialogCallback = callback;
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
            if (effect.value != null && effect.value! > 0) {
              _monster.hp -= effect.value!;
              _monster.hp = max(0.0, _monster.hp); // Clamp HP at 0
              showFloatingDamageText(
                effect.value!.toInt(),
                false,
                false,
                damageType: DamageType.bleed,
              );
            }
            break;
          case StatusEffectType.poison:
            if (effect.value != null && effect.value! > 0) {
              var poisonDamage = effect.value!;
              if (effect.maxDmg != null) {
                poisonDamage = min(poisonDamage, effect.maxDmg!.toDouble());
              }
              _monster.hp -= poisonDamage;
              _monster.hp = max(0.0, _monster.hp); // Clamp HP at 0
              showFloatingDamageText(
                poisonDamage.toInt(),
                false,
                false,
                damageType: DamageType.poison,
              );
            }
            break;
          case StatusEffectType.burn:
            if (effect.value != null && effect.value! > 0) {
              _monster.hp -= effect.value!;
              _monster.hp = max(0.0, _monster.hp); // Clamp HP at 0
              showFloatingDamageText(
                effect.value!.toInt(),
                false,
                false,
                damageType: DamageType.fixed,
              );
            }
            break;
          default:
            // Other effects do not deal damage per second
            break;
        }
      }
      _monster
          .updateStatusEffects(); // This will tick down duration and remove expired effects
      _recalculateMonsterEffectiveDefense(); // Recalculate defense after status effects update
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
    final monsterData = MonsterData.getMonsterDataForStage(
      _player.currentStage,
    );

    double hp = 100 + pow(_player.currentStage, 2.5).toDouble();
    int defense = monsterData['def'];

    // Apply difficulty modifiers
    switch (_player.currentDifficulty) {
      case Difficulty.normal:
        hp *= 0.7;
        defense -= 5;
        break;
      case Difficulty.hard:
        // No change for hard
        break;
      case Difficulty.hell:
        hp *= 1.3;
        defense = (defense * 1.25).round();
        if (defense == 0) defense = 3;
        break;
      case Difficulty.infinity:
        hp *= 2.0;
        defense = (defense * 1.5).round();
        if (defense == 0) defense = 10;
        break;
    }

    _monster = Monster(
      name: monsterData['name'],
      imageName: monsterData['imageName'],
      stage: _player.currentStage,
      hp: hp,
      maxHp: hp,
      defense: defense,
      isBoss: monsterData['isBoss'] ?? false,
      species: monsterData['species'] ?? [],
    );

    _isMonsterDefeated = false;
    _lastGoldReward = 0.0; // Clear previous reward
    _lastDroppedBox = null; // Clear previous dropped box
    _lastEnhancementStonesReward =
        0.0; // Clear previous enhancement stones reward
    _activeDamageModifiers
        .clear(); // Clear damage modifiers from previous monster
    _weaponSkillProvider.updatePassiveSkills(
      _player,
      _monster,
    ); // Re-evaluate passive skills for new monster
    _weaponSkillProvider.applyStageStartSkills(_player, _monster);
    _recalculateMonsterEffectiveDefense(); // Recalculate defense for the new monster
    notifyListeners();
  }

  void _completeDifficulty() {
    // Stop game loops
    _timer?.cancel();
    _autoAttackTimer?.cancel();

    final currentGoal = DifficultyData.getDifficultyGoal(
      _player.currentDifficulty,
    );
    if (_player.currentStage >= currentGoal) {
      final nextDifficulty = DifficultyData.getNextDifficulty(
        _player.currentDifficulty,
      );
      int xpReward;
      if (nextDifficulty != null &&
          nextDifficulty.index > _player.highestDifficultyUnlocked.index) {
        _player.highestDifficultyUnlocked = nextDifficulty;
        xpReward = 1000; // Placeholder for first-time clear
      } else {
        xpReward = 200; // Placeholder for subsequent clear
      }
      _player.heroExp += xpReward;
      _levelUpHero();

      // Trigger dialog
      _showDifficultyClearDialogCallback?.call(xpReward, nextDifficulty);
      _saveGame();
    }
  }

  void restartCurrentDifficulty() {
    _player.currentStage = 1;
    recalculatePlayerStats();
    _spawnMonster();
    _startGameLoop();
    startAutoAttack();
    notifyListeners();
    _saveGame();
  }

  void startNextDifficulty() {
    final nextDifficulty = DifficultyData.getNextDifficulty(
      _player.currentDifficulty,
    );
    if (nextDifficulty != null &&
        nextDifficulty.index <= _player.highestDifficultyUnlocked.index) {
      _player.currentDifficulty = nextDifficulty;
      restartCurrentDifficulty(); // Reuse the reset logic
    }
  }

  void _levelUpHero() {
    double requiredExp = _player.heroLevel * 1000; // Simple formula for now
    while (_player.heroExp >= requiredExp) {
      _player.heroExp -= requiredExp;
      _player.heroLevel++;
      _player.skillPoints++;
      requiredExp = _player.heroLevel * 1000;
    }
  }

  String? canLearnSkill(String skillId) {
    final skill = HeroSkillData.findById(skillId);
    if (skill == null) {
      return '존재하지 않는 스킬입니다.';
    }

    final currentLevel = _player.learnedSkills[skillId] ?? 0;
    if (currentLevel >= skill.maxLevel) {
      return '이미 마스터한 스킬입니다.';
    }

    if (_player.skillPoints <= 0) {
      return '스킬 포인트가 부족합니다.';
    }

    if (_player.heroLevel < skill.requiredHeroLevel) {
      return '영웅 레벨이 부족합니다. (필요 레벨: ${skill.requiredHeroLevel})';
    }

    for (final prerequisiteId in skill.prerequisites) {
      final prerequisiteSkill = HeroSkillData.findById(prerequisiteId);
      if (prerequisiteSkill == null) continue;
      final prerequisiteLevel = _player.learnedSkills[prerequisiteId] ?? 0;
      // Assuming prerequisite needs to be at least level 1, can be more complex
      if (prerequisiteLevel < 1) {
        return '선행 스킬이 필요합니다: ${prerequisiteSkill.name}';
      }
    }

    return null; // Can learn
  }

  String learnSkill(String skillId) {
    final skill = HeroSkillData.findById(skillId);
    if (skill == null) {
      return '존재하지 않는 스킬입니다.';
    }

    final currentLevel = _player.learnedSkills[skillId] ?? 0;
    if (currentLevel >= skill.maxLevel) {
      return '이미 마스터한 스킬입니다.';
    }

    if (_player.skillPoints <= 0) {
      return '스킬 포인트가 부족합니다.';
    }

    if (_player.heroLevel < skill.requiredHeroLevel) {
      return '영웅 레벨이 부족합니다. (필요 레벨: ${skill.requiredHeroLevel})';
    }

    for (final prerequisiteId in skill.prerequisites) {
      final prerequisiteSkill = HeroSkillData.findById(prerequisiteId);
      if (prerequisiteSkill == null) continue;
      final prerequisiteLevel = _player.learnedSkills[prerequisiteId] ?? 0;
      // Assuming prerequisite needs to be at least level 1, can be more complex
      if (prerequisiteLevel < 1) {
        return '선행 스킬이 필요합니다: ${prerequisiteSkill.name}';
      }
    }

    _player.skillPoints--;
    _player.learnedSkills[skillId] = currentLevel + 1;
    recalculatePlayerStats();
    notifyListeners();
    _saveGame();

    return '${skill.name} 스킬을 배웠습니다! (레벨 ${currentLevel + 1})';
  }

  void setDifficulty(Difficulty newDifficulty) {
    if (newDifficulty.index <= _player.highestDifficultyUnlocked.index) {
      _player.currentDifficulty = newDifficulty;
      _player.currentStage = 1;
      recalculatePlayerStats();
      _spawnMonster();
      notifyListeners();
      _saveGame();
    }
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
      _player.enhancementStones = 99999999;
      _player.gold = 999999999999.0;
      _player.darkMatter = 999999999;
      _player.currentStage = 99;
    }

    for (final achievement in AchievementData.achievements) {
      if (_player.completedAchievementIds.contains(achievement.id)) {
        achievement.isCompleted = true;
      }
      if (_player.claimedAchievementIds.contains(achievement.id)) {
        achievement.forceClaim();
      }
    }

    // Add test weapons
    // for (int i = 0; i < 24; i++) {
    //   final testWeapon = WeaponData.getWeaponById(30000 + i);
    //   if (testWeapon != null) {
    //     _player.inventory.add(testWeapon);
    //   }
    // }

    // final List<int> enhancementLevels = [8, 11, 13, 15, 17, 19, 20];
    // for (final level in enhancementLevels) {
    //   final testWeapon = WeaponData.getWeaponById(52004);
    //   if (testWeapon != null) {
    //     testWeapon.enhancement = level;
    //     _player.inventory.add(testWeapon);
    //   }
    // }

    final testWeapon = WeaponData.getWeaponById(50000);
    if (testWeapon != null) {
      testWeapon.enhancement = 20;
      _player.inventory.add(testWeapon);
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

  void warpToStage(int targetStage) {
    if (targetStage > _player.highestStageCleared) {
      return;
    }
    _player.currentStage = targetStage;
    _spawnMonster();
    _saveGame();
    notifyListeners();
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
    if (amount <= 0) {
      return '판매할 강화석 수량을 입력해주세요.';
    }
    if (_player.enhancementStones >= amount) {
      _player.enhancementStones -= amount;
      _player.gold += (amount * 5000).toDouble();
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
      _player.gold += (amount * 50000).toDouble();
      notifyListeners();
      _saveGame();
      return '$amount개의 초월석을 판매하여 ${amount * 50000} 골드를 획득했습니다.';
    } else {
      return '초월석이 부족합니다.';
    }
  }

  Weapon openGachaBox(GachaBox box) {
    final newWeapon = _rewardService.getWeaponFromBox(
      box,
      _player.highestStageCleared,
    );
    _player.gachaBoxes.removeWhere((b) => b.id == box.id);
    _player.inventory.add(newWeapon);
    _player.acquiredWeaponIdsHistory.add(newWeapon.id);
    notifyListeners();
    _saveGame();
    return newWeapon;
  }

  List<Weapon> openAllGachaBoxes() {
    if (_player.gachaBoxes.isEmpty) {
      return [];
    }

    final List<Weapon> newWeapons = [];
    for (final box in _player.gachaBoxes) {
      final newWeapon = _rewardService.getWeaponFromBox(
        box,
        _player.highestStageCleared,
      );
      newWeapons.add(newWeapon);
    }

    _player.inventory.addAll(newWeapons);
    for (final weapon in newWeapons) {
      _player.acquiredWeaponIdsHistory.add(weapon.id);
    }
    _player.gachaBoxes.clear();

    notifyListeners();
    _saveGame();

    return newWeapons;
  }

  String sellWeapon(Weapon weaponToSell) {
    if (_player.equippedWeapon.instanceId == weaponToSell.instanceId) {
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
      (w) => w.instanceId == weaponToSell.instanceId,
    );
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

  String sellMultipleWeapons(List<Weapon> weaponsToSell) {
    if (weaponsToSell.isEmpty) {
      return '판매할 무기가 없습니다.';
    }

    double totalGold = 0;
    int totalEnhancementStones = 0;
    int totalTranscendenceStones = 0;
    int soldCount = 0;

    // Create a list of IDs to remove to avoid concurrent modification issues
    final weaponIdsToSell = weaponsToSell.map((w) => w.instanceId).toSet();

    for (final weapon in weaponsToSell) {
      final sellPrice = weapon.baseSellPrice + (weapon.investedGold / 3);
      final returnedEnhancementStones = (weapon.investedEnhancementStones / 3)
          .toInt();
      final returnedTranscendenceStones =
          (weapon.investedTranscendenceStones / 3).toInt();

      totalGold += sellPrice;
      totalEnhancementStones += returnedEnhancementStones;
      totalTranscendenceStones += returnedTranscendenceStones;
      soldCount++;
    }

    _player.inventory.removeWhere(
      (w) => weaponIdsToSell.contains(w.instanceId),
    );

    _player.gold += totalGold;
    _player.enhancementStones += totalEnhancementStones;
    _player.transcendenceStones += totalTranscendenceStones;

    notifyListeners();
    _saveGame();

    String message = '$soldCount개의 무기 일괄 판매 완료!\n';
    message += '골드 ${NumberFormat('#,###').format(totalGold)} 획득!\n';
    if (totalEnhancementStones > 0) {
      message += '강화석 $totalEnhancementStones개 획득!\n';
    }
    if (totalTranscendenceStones > 0) {
      message += '초월석 $totalTranscendenceStones개 획득!\n';
    }
    return message;
  }

  void claimAchievementRewards(Achievement achievement) {
    if (achievement.isCompleted && !achievement.isRewardClaimed) {
      for (final reward in achievement.rewards) {
        switch (reward.type) {
          case RewardType.gold:
            _player.gold += reward.quantity;
            break;
          case RewardType.enhancementStone:
            _player.enhancementStones += reward.quantity;
            break;
          case RewardType.transcendenceStone:
            _player.transcendenceStones += reward.quantity;
            break;
          case RewardType.gachaBox:
            if (reward.item != null) {
              for (int i = 0; i < reward.quantity; i++) {
                // Create a new instance of the box with a unique ID
                final newBox = GachaBox(
                  id: 'ach_${achievement.id}_${DateTime.now().millisecondsSinceEpoch}_$i',
                  boxType: reward.item!.boxType,
                  stageLevel: reward.item!.stageLevel,
                );
                _player.gachaBoxes.add(newBox);
              }
            }
            break;
        }
      }
      achievement
          .claimReward(); // Mark reward as claimed in the achievement object
      _player.claimedAchievementIds.add(achievement.id);
      notifyListeners();
      _saveGame();
    }
  }

  void claimAllCompletableAchievements() {
    final completableAchievements = AchievementData.achievements
        .where((a) => a.isCompletable(_player) && !a.isCompleted)
        .toList();

    if (completableAchievements.isEmpty) {
      return;
    }

    for (final achievement in completableAchievements) {
      if (!achievement.isCompleted) {
        achievement.isCompleted = true;
        _player.completedAchievementIds.add(achievement.id);
      }

      if (achievement.isCompleted && !achievement.isRewardClaimed) {
        for (final reward in achievement.rewards) {
          switch (reward.type) {
            case RewardType.gold:
              _player.gold += reward.quantity;
              break;
            case RewardType.enhancementStone:
              _player.enhancementStones += reward.quantity;
              break;
            case RewardType.transcendenceStone:
              _player.transcendenceStones += reward.quantity;
              break;
            case RewardType.gachaBox:
              if (reward.item != null) {
                for (int i = 0; i < reward.quantity; i++) {
                  final newBox = GachaBox(
                    id: 'ach_${achievement.id}_${DateTime.now().millisecondsSinceEpoch}_$i',
                    boxType: reward.item!.boxType,
                    stageLevel: reward.item!.stageLevel,
                  );
                  _player.gachaBoxes.add(newBox);
                }
              }
              break;
          }
        }
        achievement.claimReward();
        _player.claimedAchievementIds.add(achievement.id);
      }
    }

    notifyListeners();
    _saveGame();
  }

  void completeAndClaimAchievement(Achievement achievement) {
    if (!achievement.isCompleted) {
      achievement.isCompleted = true;
      _player.completedAchievementIds.add(achievement.id);
      claimAchievementRewards(achievement);
      notifyListeners();
    }
  }

  void toggleShowFloatingDamage(bool value) {
    _player.showFloatingDamage = value;
    notifyListeners();
    _saveGame();
  }

  void setGraphicsQuality(String quality) {
    _player.graphicsQuality = quality;
    notifyListeners();
    _saveGame();
  }

  Future<void> resetGame() async {
    // Stop all timers
    _timer?.cancel();
    _autoAttackTimer?.cancel();

    // Clear saved data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('player_data');

    // Reset achievement states
    for (final achievement in AchievementData.achievements) {
      achievement.reset();
    }

    // Re-initialize the game state
    await initializeGame();

    // Notify listeners to rebuild UI
    notifyListeners();
  }

  String disassembleWeapon(Weapon weaponToDisassemble) {
    if (_player.equippedWeapon.instanceId == weaponToDisassemble.instanceId) {
      return '장착 중인 무기는 분해할 수 없습니다.';
    }
    final returnedEnhancementStones =
        (weaponToDisassemble.investedEnhancementStones / 2).truncate();
    final returnedTranscendenceStones =
        (weaponToDisassemble.investedTranscendenceStones / 2).truncate();
    _player.enhancementStones += returnedEnhancementStones;
    _player.transcendenceStones += returnedTranscendenceStones;
    _player.inventory.removeWhere(
      (w) => w.instanceId == weaponToDisassemble.instanceId,
    );
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

  String _buyWeaponBox({
    required int cost,
    required WeaponBoxType boxType,
    bool isAllRange = false,
  }) {
    if (_player.gold < cost) {
      return '골드가 부족합니다.';
    }
    _player.gold -= cost;
    final newGachaBox = GachaBox(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      boxType: boxType,
      stageLevel: _player.currentStage,
      isAllRange: isAllRange,
    );
    _player.gachaBoxes.add(newGachaBox);
    notifyListeners();
    _saveGame();
    return '${newGachaBox.name}을(를) 획득했습니다! 인벤토리에서 확인하세요.';
  }

  String buyGuaranteedUniqueBox({bool isAllRange = false}) {
    return _buyWeaponBox(
      cost: 1, // TODO: Define actual cost
      boxType: WeaponBoxType.guaranteedUnique,
      isAllRange: isAllRange,
    );
  }

  String buyGuaranteedEpicBox({bool isAllRange = false}) {
    return _buyWeaponBox(
      cost: 1, // TODO: Define actual cost
      boxType: WeaponBoxType.guaranteedEpic,
      isAllRange: isAllRange,
    );
  }

  String buyGuaranteedLegendBox({bool isAllRange = false}) {
    return _buyWeaponBox(
      cost: 1, // TODO: Define actual cost
      boxType: WeaponBoxType.guaranteedLegend,
      isAllRange: isAllRange,
    );
  }

  String buyAllRangeUniqueBox() => buyGuaranteedUniqueBox(isAllRange: true);
  String buyAllRangeLegendaryBox() => buyGuaranteedLegendBox(isAllRange: true);
  String buyCurrentRangeUniqueBox(int currentStage) =>
      buyGuaranteedUniqueBox(isAllRange: false);
  String buyAllRangeEpicBox() => buyGuaranteedEpicBox(isAllRange: true);
  String buyCurrentRangeEpicBox(int currentStage) =>
      buyGuaranteedEpicBox(isAllRange: false);
  String buyCurrentRangeLegendaryBox(int currentStage) =>
      buyGuaranteedLegendBox(isAllRange: false);

  String buyDarkMatterEnhancementStones({
    required int amount,
    required int cost,
  }) {
    if (_player.darkMatter >= cost) {
      _player.darkMatter -= cost;
      _player.enhancementStones += amount;
      notifyListeners();
      _saveGame();
      return '$amount개의 강화석을 $cost 암흑 물질에 구매했습니다.';
    } else {
      return '암흑 물질이 부족합니다.';
    }
  }

  String _buyDarkMatterWeaponBox({
    required int cost,
    required WeaponBoxType boxType,
  }) {
    if (_player.darkMatter < cost) {
      return '암흑 물질이 부족합니다.';
    }
    _player.darkMatter -= cost;
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

  String buyDarkMatterUniqueBox() {
    return _buyDarkMatterWeaponBox(
      cost: 1000,
      boxType: WeaponBoxType.guaranteedUnique,
    );
  }

  String buyDarkMatterEpicBox() {
    return _buyDarkMatterWeaponBox(
      cost: 15000,
      boxType: WeaponBoxType.guaranteedEpic,
    );
  }

  String buyDarkMatterLegendBox() {
    return _buyDarkMatterWeaponBox(
      cost: 125000,
      boxType: WeaponBoxType.guaranteedLegend,
    );
  }

  String buyDestructionProtectionTicketsWithGold({
    required int amount,
    required int cost,
  }) {
    if (_player.gold < cost) {
      return '골드가 부족합니다.';
    }

    _player.gold -= cost;
    _player.destructionProtectionTickets += amount;
    notifyListeners();
    _saveGame();
    return '$amount개의 무기 파괴 방지권을 구매했습니다.';
  }

  String buyDestructionProtectionTicketsWithDarkMatter({
    required int amount,
    required int cost,
  }) {
    if (_player.darkMatter < cost) {
      return '암흑 물질이 부족합니다.';
    }

    _player.darkMatter -= cost;
    _player.destructionProtectionTickets += amount;
    notifyListeners();
    _saveGame();
    return '$amount개의 무기 파괴 방지권을 구매했습니다.';
  }
}
