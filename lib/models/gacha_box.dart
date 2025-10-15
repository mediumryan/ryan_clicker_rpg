// Defines the type of weapon box, which determines its loot table.
enum WeaponBoxType {
  // Field drop boxes
  common, // 흔한 무기상자
  plain, // 평범한 무기상자
  rare, // 희귀한 무기상자
  shiny, // 빛나는 무기상자
  mystic, // 신비로운 무기상자
  holy, // 신성한 기운이 감도는 무기상자
  // Grade-specific boxes (from quests, achievements, or special drops)
  guaranteedUnique,
  guaranteedEpic,
  guaranteedLegend,
  guaranteedDemigod,
  guaranteedGod,

  // Special boxes (e.g., from shop)
  gamble, // 무기 갬블상자
}

class GachaBox {
  final String id;
  final WeaponBoxType boxType;
  final int stageLevel; // Stage level when the box was acquired
  final bool isAllRange;

  GachaBox({
    required this.id,
    required this.boxType,
    required this.stageLevel,
    this.isAllRange = false,
  });

  // Helper to get the display name for the box
  String get name {
    switch (boxType) {
      case WeaponBoxType.common:
        return '흔한 무기상자';
      case WeaponBoxType.plain:
        return '평범한 무기상자';
      case WeaponBoxType.rare:
        return '희귀한 무기상자';
      case WeaponBoxType.shiny:
        return '빛나는 무기상자';
      case WeaponBoxType.mystic:
        return '신비로운 무기상자';
      case WeaponBoxType.holy:
        return '신성한 무기상자';
      case WeaponBoxType.guaranteedUnique:
        return '유니크 등급 무기상자';
      case WeaponBoxType.guaranteedEpic:
        return '에픽 등급 무기상자';
      case WeaponBoxType.guaranteedLegend:
        return '레전드 등급 무기상자';
      case WeaponBoxType.guaranteedDemigod:
        return '데미갓 등급 무기상자';
      case WeaponBoxType.guaranteedGod:
        return '신 등급 무기상자';
      case WeaponBoxType.gamble:
        return '무기 갬블상자';
    }
  }

  factory GachaBox.fromJson(Map<String, dynamic> json) {
    return GachaBox(
      id: json['id'],
      boxType: WeaponBoxType.values.firstWhere(
        (e) => e.toString() == json['boxType'],
        orElse: () => WeaponBoxType.common, // Fallback
      ),
      stageLevel: json['stageLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'boxType': boxType.toString(), 'stageLevel': stageLevel};
  }

  String get imagePath {
    switch (boxType) {
      case WeaponBoxType.common:
        return 'assets/images/chests/common.png';
      case WeaponBoxType.plain:
        return 'assets/images/chests/plain.png';
      case WeaponBoxType.rare:
        return 'assets/images/chests/rare.png';
      case WeaponBoxType.shiny:
        return 'assets/images/chests/shiny.png';
      case WeaponBoxType.mystic:
        return 'assets/images/chests/mystic.png';
      case WeaponBoxType.holy:
        return 'assets/images/chests/holy.png';
      case WeaponBoxType.guaranteedUnique:
        return 'assets/images/chests/unique.png';
      case WeaponBoxType.guaranteedEpic:
        return 'assets/images/chests/epic.png';
      case WeaponBoxType.guaranteedLegend:
        return 'assets/images/chests/legend.png';
      case WeaponBoxType.guaranteedDemigod:
        return 'assets/images/chests/demi_god.png';
      case WeaponBoxType.guaranteedGod:
        return 'assets/images/chests/god.png';
      case WeaponBoxType.gamble:
        return 'assets/images/chests/gamble.png';
    }
  }

  bool get isSpecialBox {
    return boxType == WeaponBoxType.mystic ||
        boxType == WeaponBoxType.holy ||
        boxType == WeaponBoxType.guaranteedUnique ||
        boxType == WeaponBoxType.guaranteedEpic ||
        boxType == WeaponBoxType.guaranteedLegend ||
        boxType == WeaponBoxType.guaranteedDemigod ||
        boxType == WeaponBoxType.guaranteedGod;
  }
}
