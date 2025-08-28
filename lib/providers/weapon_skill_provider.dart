import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:ryan_clicker_rpg/models/player.dart';
import 'package:ryan_clicker_rpg/models/monster.dart';
import 'package:ryan_clicker_rpg/models/status_effect.dart';
import 'package:ryan_clicker_rpg/models/monster_species.dart'; // New import
import 'package:ryan_clicker_rpg/models/damage_modifier.dart'; // New import
import 'package:ryan_clicker_rpg/models/passive_stat_modifier.dart'; // New import
import 'package:ryan_clicker_rpg/providers/game_provider.dart';

class WeaponSkillProvider with ChangeNotifier {
  final GameProvider _gameProvider;

  WeaponSkillProvider(this._gameProvider);

  void applySkills(Player player, Monster monster) {
    final weapon = player.equippedWeapon;
    for (final skill in weapon.skills) {
      final skillEffects = skill['skill_effect'];
      if (skillEffects is List) {
        for (final effect in skillEffects) {
          final effectName = effect['effect_name'];
          final params = effect['params'];
          if (effectName != null && params != null) {
            _applyEffect(effectName, params, player, monster);
          }
        }
      }
    }
  }

  void updatePassiveSkills(Player player, Monster monster) {
    _gameProvider.clearDamageModifiers(); // Clear existing passive modifiers

    final weapon = player.equippedWeapon;
    for (final skill in weapon.skills) {
      final skillEffects = skill['skill_effect'];
      if (skillEffects is List) {
        for (final effect in skillEffects) {
          final effectName = effect['effect_name'];
          final params = effect['params'];
          if (effectName != null && params != null) {
            // Only apply passive effects here
            switch (effectName) {
              case 'applyPassiveStatBoost':
                _applyPassiveStatBoost(params, player);
                break;
              case 'applyPassiveBonusDamageToRace':
                _applyPassiveBonusDamageToRace(params, player, monster);
                break;
              case 'applyPassivePenaltyDamageToRace':
                _applyPassivePenaltyDamageToRace(params, player, monster);
                break;
              case 'applyPassiveGoldGainBoost':
                _applyPassiveGoldGainBoost(params, player);
                break;
              case 'applyPassiveEnhancementStoneGainBoost':
                _applyPassiveEnhancementStoneGainBoost(params, player);
                break;
              case 'applyPassiveDebuff':
                _applyPassiveDebuff(params, player, monster);
                break;
              // Add other passive effects here if needed
            }
          }
        }
      }
    }
  }

  void _applyEffect(
    String effectName,
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    switch (effectName) {
      case 'applyWeakness':
        _applyWeakness(params, player, monster);
        break;

      case 'applyBleed':
        _applyBleed(params, player, monster);
        break;
      case 'applyPoison':
        _applyPoison(params, player, monster);
        break;
      case 'applyConfusion':
        _applyConfusion(params, player, monster);
        break;
      case 'applyCharm':
        _applyCharm(params, player, monster);
        break;
      case 'applyFixedDamage':
        _applyFixedDamage(params, player, monster);
        break;
      case 'applyMaxHpDamage':
        _applyMaxHpDamage(params, player, monster);
        break;
      case 'applyMultiplierDamage':
        _applyMultiplierDamage(params, player, monster);
        break;
      case 'applyMultiHitDamage':
        _applyMultiHitDamage(params, player, monster);
        break;
      case 'applyGoldConsumePerHitDamage':
        _applyGoldConsumePerHitDamage(params, player, monster);
        break;
      case 'applyGoldConsumeBuff':
        _applyGoldConsumeBuff(params, player);
        break;
      case 'applyStoneConsumeBuff':
        _applyStoneConsumeBuff(params, player);
        break;
    }
  }

  void _applyPassiveStatBoost(Map<String, dynamic> params, Player player) {
    final stat = params['stat'] as String?;
    final value = (params['value'] as num?)?.toDouble();
    final isMultiplicative = params['isMultiplicative'] as bool? ?? false;

    if (stat == null || value == null) {
      return; // Missing essential parameters
    }

    switch (stat) {
      case "damage":
        if (isMultiplicative) {
          player.passiveWeaponDamageMultiplier += value;
        } else {
          player.passiveWeaponDamageBonus += value;
        }
        break;
      case "criticalChance":
        player.passiveWeaponCriticalChanceBonus += value;
        break;
      case "criticalDamage":
        player.passiveWeaponCriticalDamageBonus += value;
        break;
      case "doubleAttackChance":
        player.passiveWeaponDoubleAttackChanceBonus += value;
        break;
      case "defensePenetration":
        player.passiveWeaponDefensePenetrationBonus += value;
        break;
      default:
        // Handle unknown stat or log an error
        break;
    }
  }

  void _applyPassiveDebuff(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final stat = params['stat'] as String?;
    final value = (params['value'] as num?)?.toDouble();
    final isMultiplicative = params['isMultiplicative'] as bool? ?? false;
    final hpThreshold = (params['hpThreshold'] as num?)?.toDouble();
    final hpCondition = params['hpCondition'] as String?;
    final requiredStatusString = params['requiredStatus'] as String?;
    final maxStage = (params['maxStage'] as num?)?.toInt();

    if (stat == null || value == null) {
      return; // Missing essential parameters
    }

    StatusEffectType? requiredStatus;
    if (requiredStatusString != null) {
      requiredStatus = _getStatusEffectTypeFromString(requiredStatusString);
      if (requiredStatus == null) {
        return; // Invalid status effect type
      }
    }

    final modifier = PassiveStatModifier(
      stat: stat,
      value: value,
      isMultiplicative: isMultiplicative,
      hpThreshold: hpThreshold,
      hpCondition: hpCondition,
      requiredStatus: requiredStatus,
      maxStage: maxStage,
    );
    _gameProvider.addPassiveStatModifier(modifier);
  }

  void _applyPassiveBonusDamageToRace(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final requiredRaceString = params['requiredRace'] as String?;
    final multiplier = (params['multiplier'] as num?)?.toDouble();

    if (requiredRaceString == null || multiplier == null) {
      return; // Missing essential parameters
    }

    final requiredRace = _getMonsterSpeciesFromString(requiredRaceString);
    if (requiredRace == null) {
      return; // Invalid monster species type
    }

    final modifier = DamageModifier(
      requiredRace: requiredRace,
      multiplier: multiplier,
    );
    _gameProvider.addDamageModifier(modifier);
  }

  void _applyPassivePenaltyDamageToRace(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final requiredRaceString = params['requiredRace'] as String?;
    final multiplier = (params['multiplier'] as num?)?.toDouble();

    if (requiredRaceString == null || multiplier == null) {
      return; // Missing essential parameters
    }

    final requiredRace = _getMonsterSpeciesFromString(requiredRaceString);
    if (requiredRace == null) {
      return; // Invalid monster species type
    }

    final modifier = DamageModifier(
      requiredRace: requiredRace,
      multiplier: multiplier,
    );
    _gameProvider.addDamageModifier(modifier);
  }

  void _applyPassiveGoldGainBoost(Map<String, dynamic> params, Player player) {
    final percent = (params['percent'] as num?)?.toDouble();

    if (percent == null) {
      return; // Missing essential parameters
    }

    player.passiveGoldGainMultiplier += (percent / 100);
  }

  void _applyPassiveEnhancementStoneGainBoost(
    Map<String, dynamic> params,
    Player player,
  ) {
    final percentIncrease = (params['percentIncrease'] as num?)?.toDouble();
    final flatBonus = (params['flatBonus'] as num?)?.toInt();

    if (percentIncrease == null && flatBonus == null) {
      return; // Missing essential parameters
    }

    if (percentIncrease != null) {
      player.passiveEnhancementStoneGainMultiplier += (percentIncrease / 100);
    }
    if (flatBonus != null) {
      player.passiveEnhancementStoneGainFlat += flatBonus;
    }
  }

  void _applyWeakness(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance =
        (params['chance'] as num?)?.toDouble() ?? 1.0; // Default to 100% chance
    final duration = (params['duration'] as num?)?.toInt();
    final defenseReduction = (params['defenseReduction'] as num?)?.toDouble();
    final defenseReductionPer = (params['defenseReductionPer'] as num?)
        ?.toDouble();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (duration == null ||
        cooldown == null ||
        (defenseReduction == null && defenseReductionPer == null)) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('weakness', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      double reductionValue = 0;
      if (defenseReduction != null) {
        reductionValue = defenseReduction;
      } else if (defenseReductionPer != null) {
        reductionValue = monster.defense * (defenseReductionPer / 100);
      }

      final effect = StatusEffect(
        type: StatusEffectType.weakness,
        duration: duration,
        value: reductionValue,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown('weakness');
    }
  }

  void _applyBleed(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance = (params['chance'] as num?)?.toDouble();
    final duration = (params['duration'] as num?)?.toInt();
    final damagePerSecond = (params['damagePerSecond'] as num?)?.toDouble();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (chance == null ||
        duration == null ||
        damagePerSecond == null ||
        cooldown == null) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('bleed', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      final effect = StatusEffect(
        type: StatusEffectType.bleed,
        duration: duration,
        value: damagePerSecond,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown('bleed');
    }
  }

  void _applyPoison(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance = (params['chance'] as num?)?.toDouble();
    final duration = (params['duration'] as num?)?.toInt();
    final percentPerSecond = (params['percentPerSecond'] as num?)?.toDouble();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (chance == null ||
        duration == null ||
        percentPerSecond == null ||
        cooldown == null) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('poison', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      final damageValue = monster.maxHp * (percentPerSecond / 100);
      final effect = StatusEffect(
        type: StatusEffectType.poison,
        duration: duration,
        value: damageValue,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown('poison');
    }
  }

  void _applyConfusion(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance = (params['chance'] as num?)?.toDouble();
    final duration = (params['duration'] as num?)?.toInt();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (chance == null || duration == null || cooldown == null) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('confusion', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      final effect = StatusEffect(
        type: StatusEffectType.confusion,
        duration: duration,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown('confusion');
    }
  }

  void _applyCharm(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance = (params['chance'] as num?)?.toDouble();
    final duration = (params['duration'] as num?)?.toInt();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (chance == null || duration == null || cooldown == null) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('charm', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      final effect = StatusEffect(
        type: StatusEffectType.charm,
        duration: duration,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown('charm');
    }
  }

  void _applyFixedDamage(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance = (params['chance'] as num?)?.toDouble();
    final damage = (params['damage'] as num?)?.toDouble();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (chance == null || damage == null || cooldown == null) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('fixedDamage', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      monster.hp -= damage; // Apply fixed damage directly
      monster.setSkillCooldown('fixedDamage');
      _gameProvider.showFloatingDamageText(damage.toInt(), false); // Show skill damage
      _gameProvider.notifyListeners(); // Notify listeners for HP change
    }
  }

  void _applyMaxHpDamage(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance = (params['chance'] as num?)?.toDouble();
    final percentDamage = (params['percentDamage'] as num?)?.toDouble();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (chance == null || percentDamage == null || cooldown == null) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('maxHpDamage', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      final damage = monster.maxHp * (percentDamage / 100);
      monster.hp -= damage; // Apply damage based on max HP
      monster.setSkillCooldown('maxHpDamage');
      _gameProvider.showFloatingDamageText(damage.toInt(), false); // Show skill damage
      _gameProvider.notifyListeners(); // Notify listeners for HP change
    }
  }

  void _applyMultiplierDamage(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance = (params['chance'] as num?)?.toDouble();
    final multiplier = (params['multiplier'] as num?)?.toDouble();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (chance == null || multiplier == null || cooldown == null) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('multiplierDamage', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      final damage = player.equippedWeapon.currentDamage * multiplier;
      monster.hp -= damage; // Apply damage based on weapon damage multiplier
      monster.setSkillCooldown('multiplierDamage');
      _gameProvider.showFloatingDamageText(damage.toInt(), false); // Show skill damage
      _gameProvider.notifyListeners(); // Notify listeners for HP change
    }
  }

  void _applyMultiHitDamage(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance = (params['chance'] as num?)?.toDouble();
    final hitCount = (params['hitCount'] as num?)?.toInt();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (chance == null || hitCount == null || cooldown == null) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('multiHitDamage', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      for (int i = 0; i < hitCount; i++) {
        // Call attackMonster hitCount times
        _gameProvider.attackMonster();
      }
      monster.setSkillCooldown('multiHitDamage');
    }
  }

  void _applyStatusConditionalBonusDamage(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final requiredStatusString = params['requiredStatus'] as String?;
    final multiplier = (params['multiplier'] as num?)?.toDouble();

    if (requiredStatusString == null || multiplier == null) {
      return; // Missing essential parameters
    }

    final requiredStatus = _getStatusEffectTypeFromString(requiredStatusString);
    if (requiredStatus == null) {
      return; // Invalid status effect type
    }

    final modifier = DamageModifier(
      requiredStatusEffectType: requiredStatus,
      multiplier: multiplier,
    );
    _gameProvider.addDamageModifier(modifier);
  }

  void _applyHpConditionalBonusDamage(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance =
        (params['chance'] as num?)?.toDouble() ?? 1.0; // Default to 100% chance
    final hpThreshold = (params['hpThreshold'] as num?)?.toDouble();
    final condition = params['condition'] as String? ?? '이하'; // Default to '이하'
    final multiplier = (params['multiplier'] as num?)?.toDouble();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (hpThreshold == null || multiplier == null || cooldown == null) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('hpConditionalBonusDamage', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      final monsterHpPercentage = (monster.hp / monster.maxHp) * 100;
      bool conditionMet = false;

      switch (condition) {
        case '이상':
          conditionMet = monsterHpPercentage >= hpThreshold;
          break;
        case '이하':
          conditionMet = monsterHpPercentage <= hpThreshold;
          break;
        case '초과':
          conditionMet = monsterHpPercentage > hpThreshold;
          break;
        case '미만':
          conditionMet = monsterHpPercentage < hpThreshold;
          break;
      }

      if (conditionMet) {
        final bonusDamage = player.equippedWeapon.currentDamage * multiplier;
        monster.hp -= bonusDamage;
        monster.setSkillCooldown('hpConditionalBonusDamage');
        _gameProvider.notifyListeners(); // Notify listeners for HP change
      }
    }
  }

  void _applyGoldConsumePerHitDamage(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      return;
    }

    final chance =
        (params['chance'] as num?)?.toDouble() ?? 1.0; // Default to 100% chance
    final goldPerHit = (params['goldPerHit'] as num?)?.toDouble();
    final flatDamageBonus = (params['flatDamageBonus'] as num?)?.toDouble();
    final percentDamageBonus = (params['percentDamageBonus'] as num?)
        ?.toDouble();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    if (goldPerHit == null ||
        cooldown == null ||
        (flatDamageBonus == null && percentDamageBonus == null)) {
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('goldConsumePerHitDamage', cooldown)) {
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      if (player.gold < goldPerHit) {
        return; // Not enough gold
      }
      player.gold -= goldPerHit;

      double bonusDamage = 0;
      if (flatDamageBonus != null) {
        bonusDamage = flatDamageBonus;
      } else if (percentDamageBonus != null) {
        bonusDamage =
            player.equippedWeapon.currentDamage * (percentDamageBonus / 100);
      }

      monster.hp -= bonusDamage;
      monster.setSkillCooldown('goldConsumePerHitDamage');
      _gameProvider.notifyListeners(); // Notify listeners for HP change
    }
  }

  void _applyGoldConsumeBuff(Map<String, dynamic> params, Player player) {}

  void _applyStoneConsumeBuff(Map<String, dynamic> params, Player player) {}

  StatusEffectType? _getStatusEffectTypeFromString(String type) {
    try {
      return StatusEffectType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
      );
    } catch (e) {
      return null;
    }
  }

  MonsterSpecies? _getMonsterSpeciesFromString(String type) {
    try {
      return MonsterSpecies.values.firstWhere(
        (e) => e.toString().split('.').last == type,
      );
    } catch (e) {
      return null;
    }
  }
}
