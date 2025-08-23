
class Monster {
  final String name;
  final String imageName;
  final int stage;
  double hp;
  final double maxHp;
  final int defense;
  final bool isBoss;

  Monster({
    required this.name,
    required this.imageName,
    required this.stage,
    required this.hp,
    required this.maxHp,
    required this.defense,
    this.isBoss = false,
  });
}
