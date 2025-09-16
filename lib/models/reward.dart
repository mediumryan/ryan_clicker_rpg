import 'package:ryan_clicker_rpg/models/gacha_box.dart';

enum RewardType { gold, enhancementStone, transcendenceStone, gachaBox }

class Reward {
  final RewardType type;
  final int quantity;
  final GachaBox? item; // For gachaBox rewards

  Reward({required this.type, required this.quantity, this.item});

  String get description {
    switch (type) {
      case RewardType.gold:
        return '$quantity 골드';
      case RewardType.enhancementStone:
        return '강화석 $quantity개';
      case RewardType.transcendenceStone:
        return '초월석 $quantity개';
      case RewardType.gachaBox:
        if (item != null) {
          return '${item!.stageLevel} 스테이지 ${item!.name}';
        }
        return '무기 상자';
    }
  }
}
