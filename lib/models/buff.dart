enum Stat {
  damage,
  speed,
  criticalChance,
  criticalDamage,
  doubleAttackChance,
  defensePenetration,
}

class Buff {
  final String id;
  final Stat stat;
  final double value;
  final bool isMultiplicative;
  int duration; // in seconds

  Buff({
    required this.id,
    required this.stat,
    required this.value,
    required this.isMultiplicative,
    required this.duration,
  });

  factory Buff.fromJson(Map<String, dynamic> json) {
    return Buff(
      id: json['id'] as String,
      stat: Stat.values.firstWhere((e) => e.toString() == json['stat']),
      value: (json['value'] as num).toDouble(),
      isMultiplicative: json['isMultiplicative'] as bool,
      duration: json['duration'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'stat': stat.toString(),
        'value': value,
        'isMultiplicative': isMultiplicative,
        'duration': duration,
      };
}