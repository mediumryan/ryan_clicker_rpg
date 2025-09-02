import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:ryan_clicker_rpg/models/player.dart';
import 'package:ryan_clicker_rpg/models/monster.dart';
import 'package:ryan_clicker_rpg/models/status_effect.dart';
import 'package:ryan_clicker_rpg/models/monster_species.dart'; // New import
import 'package:ryan_clicker_rpg/models/damage_modifier.dart'; // New import
import 'package:ryan_clicker_rpg/models/passive_stat_modifier.dart'; // New import
import 'package:ryan_clicker_rpg/models/buff.dart'; // New
import 'package:ryan_clicker_rpg/providers/game_provider.dart';

class WeaponSkillProvider with ChangeNotifier {
  final GameProvider _gameProvider;

  WeaponSkillProvider(this._gameProvider);

  void applySkills(Player player, Monster monster) {
    debugPrint('--- applySkills called ---');
    final weapon = player.equippedWeapon;
    for (final skill in weapon.skills) {
      debugPrint('Checking skill: ${skill['skill_name']}');
      final skillEffects = skill['skill_effect'];
      if (skillEffects is List) {
        for (final effect in skillEffects) {
          final effectName = effect['effect_name'];
          final params = effect['params'];
          if (effectName != null && params != null) {
            debugPrint('Applying effect: $effectName');
            _applyEffect(effectName, params, player, monster);
          }
        }
      }
    }
  }

  void updatePassiveSkills(Player player, Monster monster) {
    _gameProvider.clearDamageModifiers(); // Clear existing passive modifiers

    // --- NEW: Reset all player passive weapon stats ---
    player.passiveWeaponDamageBonus = 0.0;
    player.passiveWeaponDamageMultiplier = 1.0;
    player.passiveWeaponCriticalChanceBonus = 0.0;
    player.passiveWeaponCriticalDamageBonus = 0.0;
    player.passiveWeaponDoubleAttackChanceBonus = 0.0;
    player.passiveWeaponDefensePenetrationBonus = 0.0;
    player.passiveGoldGainMultiplier = 1.0;
    player.passiveEnhancementStoneGainMultiplier = 1.0;
    player.passiveEnhancementStoneGainFlat = 0;
    // --- END NEW ---

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
              case 'extraDamageToMonsterType':
                {
                  final monsterType = params['monsterType'] as String?;
                  final multiplier = (params['damageMultiplier'] as num?)
                      ?.toDouble();
                  if (monsterType != null && multiplier != null) {
                    _applyPassiveBonusDamageToRace(
                      {'requiredRace': monsterType, 'multiplier': multiplier},
                      player,
                      monster,
                    );
                  }
                }
                break;
              case 'increaseDamageToPoisoned':
                {
                  final multiplier = (params['damageMultiplier'] as num?)
                      ?.toDouble();
                  if (multiplier != null) {
                    _applyStatusConditionalBonusDamage(
                      {'requiredStatus': 'poison', 'multiplier': multiplier},
                      player,
                      monster,
                    );
                  }
                }
                break;
              case 'applyGoldGainBoost':
                {
                  final multiplier = (params['multiplier'] as num?)?.toDouble();
                  if (multiplier != null) {
                    final percent = (multiplier - 1) * 100;
                    _applyPassiveGoldGainBoost({'percent': percent}, player);
                  }
                }
                break;
              case 'increaseAttackPercent':
                {
                  final value = (params['value'] as num?)?.toDouble();
                  if (value != null) {
                    _applyPassiveStatBoost({
                      'stat': 'damage',
                      'value': value / 100,
                      'isMultiplicative': true,
                    }, player);
                  }
                }
                break;
              case 'increaseAttackSpeed':
                {
                  final value = (params['value'] as num?)?.toDouble();
                  if (value != null) {
                    _applyPassiveStatBoost({
                      'stat': 'speed',
                      'value': value,
                      'isMultiplicative': false,
                    }, player);
                  }
                }
                break;
              case 'increaseCriticalChance':
                {
                  final value = (params['value'] as num?)?.toDouble();
                  if (value != null) {
                    _applyPassiveStatBoost({
                      'stat': 'criticalChance',
                      'value': value,
                      'isMultiplicative': false,
                    }, player);
                  }
                }
                break;
              case 'applyBonusDamageToFrozen':
                {
                  final multiplier = (params['damageMultiplier'] as num?)
                      ?.toDouble();
                  if (multiplier != null) {
                    _applyStatusConditionalBonusDamage(
                      {'requiredStatus': 'freeze', 'multiplier': multiplier},
                      player,
                      monster,
                    );
                  }
                }
                break;
              case 'increaseDoubleAttack':
                {
                  final amount = (params['amount'] as num?)?.toDouble();
                  if (amount != null) {
                    _applyPassiveStatBoost({
                      'stat': 'doubleAttackChance',
                      'value': amount,
                      'isMultiplicative': false,
                    }, player);
                  }
                }
                break;
              case 'applyConditionalDamageBoost':
                _applyConditionalDamageBoost(params, player, monster);
                break;
              // Add other passive effects here if needed
            }
          }
        }
      }
    }
    // After applying all passive skills, recalculate player stats in GameProvider
    _gameProvider.recalculatePlayerStats();
  }

  void _applyEffect(
    String effectName,
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    debugPrint('Inside _applyEffect for $effectName');
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
      case 'applyFreeze':
        _applyFreeze(params, player, monster);
        break;
      case 'applyBurn':
        _applyBurn(params, player, monster);
        break;
      case 'applyShock':
        _applyShock(params, player, monster);
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
      case 'applyHpConditionalBonusDamage':
        _applyHpConditionalBonusDamage(params, player, monster);
        break;
      case 'applyDisarm':
        _applyDisarm(params, player, monster);
        break;
      case 'dealBonusDamage':
        _applyFixedDamage(params, player, monster);
        break;
      case 'applyMultiHit':
        _applyMultiHitDamage(params, player, monster);
        break;
      case 'applyPercentageMaxHealthDamage':
        _applyMaxHpDamage(params, player, monster);
        break;
      case 'criticalDamageBoost':
        _applyCriticalDamageBoost(params, player, monster);
        break;
      case 'applyRandomDebuff':
        _applyRandomDebuff(params, player, monster);
        break;
      case 'applyStackingBuff':
        _applyStackingBuff(params, player);
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
    String? raceString = params['requiredRace'] as String?;
    if (raceString == null) {
      raceString = params['race'] as String?;
      if (raceString != null) {
        debugPrint(
          'WARNING: Using deprecated "race" for passive bonus damage. Please use "requiredRace" instead.',
        );
      }
    }
    final multiplier = (params['multiplier'] as num?)?.toDouble();

    if (raceString == null || multiplier == null) {
      return; // Missing essential parameters
    }

    final requiredRace = _getMonsterSpeciesFromString(raceString);
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
    String? raceString = params['requiredRace'] as String?;
    if (raceString == null) {
      raceString = params['race'] as String?;
      if (raceString != null) {
        debugPrint(
          'WARNING: Using deprecated "race" for passive penalty damage. Please use "requiredRace" instead.',
        );
      }
    }
    final multiplier = (params['multiplier'] as num?)?.toDouble();

    if (raceString == null || multiplier == null) {
      return; // Missing essential parameters
    }

    final requiredRace = _getMonsterSpeciesFromString(raceString);
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

  void _applyDisarm(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    debugPrint('[WeaponSkillProvider._applyDisarm] Called.');
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      debugPrint('[WeaponSkillProvider._applyDisarm] Wrong trigger: $trigger');
      return;
    }

    final chance =
        (params['chance'] as num?)?.toDouble() ?? 1.0; // Default to 100% chance
    final duration = (params['duration'] as num?)?.toInt();
    final cooldown = (params['cooldown'] as num?)?.toInt();
    final excludedRaces = (params['excludedRaces'] as List<dynamic>?)
        ?.cast<String>();

    // Extract defense reduction values
    final defenseReduction = (params['defenseReduction'] as num?)?.toDouble();
    final defenseReductionPer = (params['defenseReductionPer'] as num?)
        ?.toDouble();

    // Determine the value to pass to StatusEffect
    double? effectValue;
    if (defenseReductionPer != null) {
      effectValue =
          defenseReductionPer; // This will be interpreted as percentage in GameProvider
    } else if (defenseReduction != null) {
      effectValue =
          defenseReduction; // This will be interpreted as fixed in GameProvider
    }

    if (duration == null || cooldown == null || effectValue == null) {
      // Check if effectValue is null
      debugPrint(
        '[WeaponSkillProvider._applyDisarm] Missing essential parameters (duration, cooldown, or defense reduction value).',
      );
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          debugPrint(
            '[WeaponSkillProvider._applyDisarm] Monster race excluded.',
          );
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown(
      StatusEffectType.disarm.toString().split('.').last,
      cooldown,
    )) {
      debugPrint('[WeaponSkillProvider._applyDisarm] Skill on cooldown.');
      return;
    }

    // 3. Roll for chance
    if (Random().nextDouble() < chance) {
      final isStackable =
          (params['stackable'] as bool?) ??
          true; // Default to true if not specified
      final effect = StatusEffect(
        type: StatusEffectType.disarm,
        duration: duration,
        value: effectValue, // Pass the determined value
        stackable: isStackable,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown(
        StatusEffectType.disarm.toString().split('.').last,
      );
      debugPrint(
        '[WeaponSkillProvider._applyDisarm] Status effect applied: ${effect.type} with value ${effect.value}',
      );
    } else {
      debugPrint('[WeaponSkillProvider._applyDisarm] Chance roll failed.');
    }
  }

  void _applyWeakness(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    debugPrint('[WeaponSkillProvider._applyWeakness] Called.');
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      debugPrint(
        '[WeaponSkillProvider._applyWeakness] Wrong trigger: $trigger',
      );
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
      debugPrint(
        '[WeaponSkillProvider._applyWeakness] Missing essential parameters.',
      );
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          debugPrint(
            '[WeaponSkillProvider._applyWeakness] Monster race excluded.',
          );
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown(
      StatusEffectType.weakness.toString().split('.').last,
      cooldown,
    )) {
      debugPrint('[WeaponSkillProvider._applyWeakness] Skill on cooldown.');
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
      debugPrint(
        '[WeaponSkillProvider._applyWeakness] Applying reductionValue: $reductionValue',
      );

      final isStackable =
          (params['stackable'] as bool?) ??
          true; // Default to true if not specified
      final effect = StatusEffect(
        type: StatusEffectType.weakness,
        duration: duration,
        value: reductionValue,
        stackable: isStackable,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown(
        StatusEffectType.weakness.toString().split('.').last,
      );
      debugPrint(
        '[WeaponSkillProvider._applyWeakness] Status effect applied: ${effect.type} with value ${effect.value}',
      );
    } else {
      debugPrint('[WeaponSkillProvider._applyWeakness] Chance roll failed.');
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
    // Check for both damagePerSecond and fixedDamagePerSecond
    double? damagePerSecond = (params['damagePerSecond'] as num?)?.toDouble();
    if (damagePerSecond == null) {
      damagePerSecond = (params['fixedDamagePerSecond'] as num?)?.toDouble();
      if (damagePerSecond != null) {
        debugPrint(
          'WARNING: Using deprecated "fixedDamagePerSecond" for bleed. Please use "damagePerSecond" instead.',
        );
      }
    }
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
    final isStackable =
        (params['stackable'] as bool?) ??
        true; // Default to true if not specified
    if (Random().nextDouble() < chance) {
      final effect = StatusEffect(
        type: StatusEffectType.bleed,
        duration: duration,
        value: damagePerSecond,
        stackable: isStackable,
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
    debugPrint('Inside _applyPoison');
    final trigger = params['trigger'] as String?;
    if (trigger != 'onHit') {
      debugPrint('Wrong trigger for poison: $trigger');
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
      debugPrint('Missing parameters for poison');
      return; // Missing essential parameters
    }

    // 1. Check for excluded races
    if (excludedRaces != null) {
      for (final race in excludedRaces) {
        if (monster.species.any((s) => s.toString().split('.').last == race)) {
          debugPrint('Monster race is excluded for poison');
          return;
        }
      }
    }

    // 2. Check for cooldown
    if (monster.isSkillOnCooldown('poison', cooldown)) {
      debugPrint('Poison is on cooldown');
      return;
    }

    // 3. Roll for chance
    final isStackable =
        (params['stackable'] as bool?) ??
        true; // Default to true if not specified
    if (Random().nextDouble() < chance) {
      debugPrint('Poison skill triggered!');
      final damageValue = monster.maxHp * percentPerSecond;
      final effect = StatusEffect(
        type: StatusEffectType.poison,
        duration: duration,
        value: damageValue,
        stackable: isStackable,
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
    final isStackable =
        (params['stackable'] as bool?) ??
        true; // Default to true if not specified
    if (Random().nextDouble() < chance) {
      final effect = StatusEffect(
        type: StatusEffectType.confusion,
        duration: duration,
        stackable: isStackable,
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
    final isStackable =
        (params['stackable'] as bool?) ??
        true; // Default to true if not specified
    if (Random().nextDouble() < chance) {
      final effect = StatusEffect(
        type: StatusEffectType.charm,
        duration: duration,
        stackable: isStackable,
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
      _gameProvider.showFloatingDamageText(
        damage.toInt(),
        false,
        false,
      ); // Show skill damage
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
      _gameProvider.showFloatingDamageText(
        damage.toInt(),
        false,
        false,
      ); // Show skill damage
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
      final damage = player.finalDamage * multiplier;
      monster.hp -= damage; // Apply damage based on weapon damage multiplier
      monster.setSkillCooldown('multiplierDamage');
      _gameProvider.showFloatingDamageText(
        damage.toInt(),
        false,
        false,
      ); // Show skill damage
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
        final bonusDamage = player.finalDamage * multiplier;
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
        bonusDamage = player.finalDamage * (percentDamageBonus / 100);
      }

      monster.hp -= bonusDamage;
      monster.setSkillCooldown('goldConsumePerHitDamage');
      _gameProvider.notifyListeners(); // Notify listeners for HP change
    }
  }

  void _applyGoldConsumeBuff(Map<String, dynamic> params, Player player) {}

  void _applyStoneConsumeBuff(Map<String, dynamic> params, Player player) {}

  void _applyCriticalDamageBoost(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final trigger = params['trigger'] as String?;
    if (trigger == 'onHit') {
      final chance = (params['triggerChance'] as num?)?.toDouble();
      final multiplier = (params['multiplier'] as num?)?.toDouble();

      if (chance == null || multiplier == null) {
        return; // Missing params
      }

      if (Random().nextDouble() < chance) {
        final damage = player.finalDamage * multiplier;
        monster.hp -= damage;
        _gameProvider.showFloatingDamageText(
          damage.toInt(),
          true,
          false,
        ); // Show as crit
        _gameProvider.notifyListeners();
      }
    }
  }

  void _applyRandomDebuff(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final chance = (params['chance'] as num?)?.toDouble();
    final duration = (params['duration'] as num?)?.toInt();
    final bleedPerDmg = (params['bleedPerDmg'] as num?)?.toDouble();
    final poisonPerDmg = (params['poisonPerDmg'] as num?)?.toDouble();

    if (chance == null ||
        duration == null ||
        bleedPerDmg == null ||
        poisonPerDmg == null) {
      return;
    }

    if (Random().nextDouble() < chance) {
      final availableDebuffs = [
        StatusEffectType.bleed,
        StatusEffectType.poison,
        StatusEffectType.confusion,
        StatusEffectType.charm,
        StatusEffectType.weakness,
        StatusEffectType.disarm,
      ];

      final randomDebuff =
          availableDebuffs[Random().nextInt(availableDebuffs.length)];

      double? value;
      if (randomDebuff == StatusEffectType.bleed) {
        value = bleedPerDmg;
      } else if (randomDebuff == StatusEffectType.poison) {
        value = monster.maxHp * poisonPerDmg;
      } else if (randomDebuff == StatusEffectType.weakness) {
        value = monster.defense * 0.1;
      } else if (randomDebuff == StatusEffectType.disarm) {
        value = monster.defense * 0.25;
      }

      final isStackable =
          (params['stackable'] as bool?) ??
          true; // Default to true if not specified
      final effect = StatusEffect(
        type: randomDebuff,
        duration: duration,
        value: value,
        stackable: isStackable,
      );
      monster.applyStatusEffect(effect);
    }
  }

  void applyStageStartSkills(Player player, Monster monster) {
    final weapon = player.equippedWeapon;
    for (final skill in weapon.skills) {
      final trigger = skill['trigger'] as String?;
      if (trigger == 'stageStart') {
        final skillEffects = skill['skill_effect'];
        if (skillEffects is List) {
          for (final effect in skillEffects) {
            final effectName = effect['effect_name'];
            final params = effect['params'];
            if (effectName != null && params != null) {
              // We could use the main _applyEffect switch, but for now let's be specific
              if (effectName == 'applyStatBoost') {
                _applyStatBoost(params, player);
              }
            }
          }
        }
      }
    }
  }

  void _applyStatBoost(Map<String, dynamic> params, Player player) {
    final statString = params['stat'] as String?;
    final value = (params['value'] as num?)?.toDouble();
    final isMultiplicative = params['isMultiplicative'] as bool? ?? false;
    final duration = (params['duration'] as num?)?.toInt();

    if (statString == null || value == null || duration == null) {
      return;
    }

    final stat = Stat.values.firstWhere(
      (e) => e.toString().split('.').last == statString,
      orElse: () => Stat.damage,
    );

    final buff = Buff(
      id: 'statBoost_$statString', // Unique ID for non-stacking buff
      stat: stat,
      value: value,
      isMultiplicative: isMultiplicative,
      duration: duration,
    );

    // Remove existing buff of same type before adding new one
    player.buffs.removeWhere((b) => b.id == buff.id);
    player.buffs.add(buff);
    _gameProvider.recalculatePlayerStats();
  }

  void _applyStackingBuff(Map<String, dynamic> params, Player player) {
    final statString = params['stat'] as String?;
    final increasePerStack = (params['increasePerStack'] as num?)?.toDouble();
    final isMultiplicative = (params['isMultiplicative'] as bool? ?? false);
    final duration = (params['duration'] as num?)?.toInt();
    final maxStacks = (params['maxStacks'] as num?)?.toInt();

    if (statString == null ||
        increasePerStack == null ||
        duration == null ||
        maxStacks == null) {
      return;
    }

    final stat = Stat.values.firstWhere(
      (e) => e.toString().split('.').last == statString,
      orElse: () => Stat.damage,
    );
    final buffId = 'stackingBuff_$statString';

    // Count existing stacks
    final currentStacks = player.buffs.where((b) => b.id == buffId).length;

    if (currentStacks < maxStacks) {
      final buff = Buff(
        id: buffId,
        stat: stat,
        value: increasePerStack,
        isMultiplicative: isMultiplicative,
        duration: duration,
      );
      player.buffs.add(buff);
    }

    // Refresh duration of all stacks
    for (final buff in player.buffs) {
      if (buff.id == buffId) {
        buff.duration = duration;
      }
    }

    _gameProvider.recalculatePlayerStats();
  }

  void applyOnKillSkills(Player player, Monster monster) {
    final weapon = player.equippedWeapon;
    for (final skill in weapon.skills) {
      final trigger = skill['trigger'] as String?;
      if (trigger == 'killMonster') {
        final skillEffects = skill['skill_effect'];
        if (skillEffects is List) {
          for (final effect in skillEffects) {
            final effectName = effect['effect_name'];
            final params = effect['params'];
            if (effectName != null && params != null) {
              if (effectName == 'increaseStat') {
                _increaseStat(params, player);
              }
            }
          }
        }
      }
    }
  }

  void _increaseStat(Map<String, dynamic> params, Player player) {
    final stat = params['stat'] as String?;
    if (stat != 'baseDamage') return; // Only support baseDamage for now

    final stackPerValue = (params['stackPerValue'] as num?)?.toDouble();
    final maxStacks = (params['maxStacks'] as num?)?.toInt();
    final skillId =
        params['skillId'] as String? ??
        'increaseStat_baseDamage'; // Need a unique ID for the skill

    if (stackPerValue == null || maxStacks == null) {
      return;
    }

    final weapon = player.equippedWeapon;
    final currentStacks = weapon.skillStacks[skillId] ?? 0;

    if (currentStacks < maxStacks) {
      weapon.skillStacks[skillId] = currentStacks + 1;
      // This permanently modifies the weapon object.
      // The baseDamage of the weapon is final, so we need to replace the weapon with a new one.
      final newWeapon = weapon.copyWith(
        baseDamage: weapon.baseDamage + stackPerValue,
      );
      player.equippedWeapon = newWeapon;
      // Update the weapon in the player's inventory as well
      final indexInInventory = player.inventory.indexWhere(
        (w) => w.id == newWeapon.id,
      );
      if (indexInInventory != -1) {
        player.inventory[indexInInventory] = newWeapon;
      }
      _gameProvider.recalculatePlayerStats();
    }
  }

  void _applyFreeze(
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
    if (monster.isSkillOnCooldown('freeze', cooldown)) {
      return;
    }

    // 3. Roll for chance
    final isStackable =
        (params['stackable'] as bool?) ??
        true; // Default to true if not specified
    if (Random().nextDouble() < chance) {
      final effect = StatusEffect(
        type: StatusEffectType.freeze,
        duration: duration,
        stackable: isStackable,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown('freeze');
    }
  }

  void _applyBurn(Map<String, dynamic> params, Player player, Monster monster) {
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
    if (monster.isSkillOnCooldown('burn', cooldown)) {
      return;
    }

    // 3. Roll for chance
    final isStackable =
        (params['stackable'] as bool?) ??
        true; // Default to true if not specified
    if (Random().nextDouble() < chance) {
      final effect = StatusEffect(
        type: StatusEffectType.burn,
        duration: duration,
        value: damagePerSecond,
        stackable: isStackable,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown('burn');
    }
  }

  void _applyShock(
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
    if (monster.isSkillOnCooldown('shock', cooldown)) {
      return;
    }

    // 3. Roll for chance
    final isStackable =
        (params['stackable'] as bool?) ??
        true; // Default to true if not specified
    if (Random().nextDouble() < chance) {
      final effect = StatusEffect(
        type: StatusEffectType.shock,
        duration: duration,
        stackable: isStackable,
      );
      monster.applyStatusEffect(effect);
      monster.setSkillCooldown('shock');
    }
  }

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

  void _applyConditionalDamageBoost(
    Map<String, dynamic> params,
    Player player,
    Monster monster,
  ) {
    final conditionString = params['condition'] as String?;
    final threshold = (params['threshold'] as num?)?.toDouble();
    final damageMultiplier = (params['damageMultiplier'] as num?)?.toDouble();

    if (conditionString == null ||
        threshold == null ||
        damageMultiplier == null) {
      return; // Missing essential parameters
    }

    final conditionType = _getConditionTypeFromString(conditionString);
    if (conditionType == null) {
      return; // Invalid condition type
    }

    final modifier = DamageModifier(
      requiredMonsterHpCondition: conditionType,
      requiredMonsterHpThreshold: threshold,
      multiplier: damageMultiplier,
    );
    _gameProvider.addDamageModifier(modifier);
  }

  ConditionType? _getConditionTypeFromString(String type) {
    try {
      return ConditionType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
      );
    } catch (e) {
      return null;
    }
  }
}
