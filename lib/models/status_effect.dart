enum StatusEffectType {
  poison, // 중독
  bleed, // 출혈
  stun, // 기절
  confusion, // 혼란
  sleep, // 수면
  disarm, // 무장해제
  charm, // 매혹
  weakness, // 약화
  freeze, // 빙결
  burn, // 화상
  shock, // 감전
}

class StatusEffect {
  final StatusEffectType type;
  int duration; // in seconds
  final double? value;

  StatusEffect({required this.type, required this.duration, this.value});
}
