import 'package:ryan_clicker_rpg/models/difficulty.dart';

class DifficultyData {
  static const Map<Difficulty, Map<String, dynamic>> difficulties = {
    Difficulty.normal: {
      'name': '노멀',
      'goal': 100,
      'unlocks': Difficulty.hard,
    },
    Difficulty.hard: {
      'name': '어려움',
      'goal': 250,
      'unlocks': Difficulty.hell,
    },
    Difficulty.hell: {
      'name': '지옥',
      'goal': 500,
      'unlocks': Difficulty.infinity,
    },
    Difficulty.infinity: {
      'name': '무한',
      'goal': 2000,
      'unlocks': null, // Or a special rebirth flag
    },
  };

  static String getDifficultyName(Difficulty difficulty) {
    return difficulties[difficulty]!['name'] as String;
  }

  static int getDifficultyGoal(Difficulty difficulty) {
    return difficulties[difficulty]!['goal'] as int;
  }

  static Difficulty? getNextDifficulty(Difficulty difficulty) {
    return difficulties[difficulty]!['unlocks'] as Difficulty?;
  }
}
