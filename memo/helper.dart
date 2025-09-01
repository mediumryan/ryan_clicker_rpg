// ---------------------- // 🟩 Passive (상시 효과) // ----------------------  //

//능력치 상시 증가
void applyPassiveStatBoost({
  required String stat, // 예: "doubleAttackChance"
  required double value, // 예: 0.1 (10%)
  bool isMultiplicative = false, // 곱연산 여부 (기본은 덧셈)
}) {}

// ---------------------- // 🟥 Active (확률, 지속 등 조건 포함) // ----------------------

// 골드 차감형 공격력 증가 (지속형 버프)
void applyGoldConsumeBuff({
  required int goldCost,
  double? flatAttackBonus,
  double? percentAttackBonus,
  required double duration,
  bool isStackable = false,
  double chance = 1.0,
  String trigger = "onSkillUse",
  List<String>? excludedRaces,
  List<String>? onlyApplyToRaces,
}) {}

// 강화석 차감형 공격력 증가 (지속형 버프)
void applyStoneConsumeBuff({
  required int stoneCost,
  double? flatAttackBonus,
  double? percentAttackBonus,
  required double duration,
  bool isStackable = false,
  double chance = 1.0,
  String trigger = "onSkillUse",
  List<String>? excludedRaces,
  List<String>? onlyApplyToRaces,
}) {}
