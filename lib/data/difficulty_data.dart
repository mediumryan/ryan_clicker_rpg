import 'package:ryan_clicker_rpg/models/difficulty.dart';

class DifficultyData {
  static const Map<Difficulty, Map<String, dynamic>> difficulties = {
    Difficulty.normal: {
      'name': '노멀',
      'goal': 100,
      'unlocks': Difficulty.hard,
      'firstClearXp': 2000,
      'repeatClearXp': 400,
      'xpMultiplier': 1.0,
      'description': '몬스터의 체력과 방어력에 약간의 패널티가 적용됩니다.',
    },
    Difficulty.hard: {
      'name': '어려움',
      'goal': 250,
      'unlocks': Difficulty.hell,
      'firstClearXp': 6000,
      'repeatClearXp': 1200,
      'xpMultiplier': 1.5,
      'description': '표준 난이도입니다.',
    },
    Difficulty.hell: {
      'name': '지옥',
      'goal': 500,
      'unlocks': Difficulty.infinity,
      'firstClearXp': 20000,
      'repeatClearXp': 4000,
      'xpMultiplier': 2.0,
      'description': '몬스터의 체력과 방어력이 약간 증가합니다.',
    },
    Difficulty.infinity: {
      'name': '무한',
      'goal': 2000,
      'unlocks': null, // Or a special rebirth flag
      'firstClearXp': 60000,
      'repeatClearXp': 12000,
      'xpMultiplier': 3.0,
      'description': '몬스터의 체력과 방어력이 대폭 증가합니다.',
    },
  };

  static String getDifficultyName(Difficulty difficulty) {
    return difficulties[difficulty]!['name'] as String;
  }

  static String getDescription(Difficulty difficulty) {
    return difficulties[difficulty]!['description'] as String;
  }

  static int getDifficultyGoal(Difficulty difficulty) {
    return difficulties[difficulty]!['goal'] as int;
  }

  static Difficulty? getNextDifficulty(Difficulty difficulty) {
    return difficulties[difficulty]!['unlocks'] as Difficulty?;
  }

  static int getFirstClearXp(Difficulty difficulty) {
    return difficulties[difficulty]!['firstClearXp'] as int;
  }

  static int getRepeatClearXp(Difficulty difficulty) {
    return difficulties[difficulty]!['repeatClearXp'] as int;
  }

  static double getXpMultiplier(Difficulty difficulty) {
    return difficulties[difficulty]!['xpMultiplier'] as double;
  }
}
