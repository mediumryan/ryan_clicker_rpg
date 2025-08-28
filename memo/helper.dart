// ---------------------- // 🟩 Passive (상시 효과) // ----------------------  //

//능력치 상시 증가
void applyPassiveStatBoost({
  required String stat, // 예: "doubleAttackChance"
  required double value, // 예: 0.1 (10%)
  bool isMultiplicative = false, // 곱연산 여부 (기본은 덧셈)
})

// 패시브 디버프 (예: 방어력 감소)
void applyPassiveDebuff({
  required String stat, // 예: "defense"
  required double value, // 예: -20
  // 선택 조건
  double? hpThreshold, // ex: 0.5 → 50%
  String? hpCondition, // "below" or "above"
  String? requiredStatus, // ex: "poison", "stun", etc.
  int? maxStage, // ex: 50 스테이지 이하에만 유효
  bool isMultiplicative = false, // 덧셈 or 곱셈 (기본 덧셈)
})

// 특정 종족 데미지 추가
void applyPassiveBonusDamageToRace({
  required String race, // 예: "undead", "demon", "beast"
  required double multiplier, // 예: 0.3 = 30% 증가
})

// 특정 종족 데미지 감소
void applyPassivePenaltyDamageToRace({
  required String race, // 예: "angel", "divine"
  required double multiplier, // 예: 0.3 = 30% 감소
})

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
})

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
})
