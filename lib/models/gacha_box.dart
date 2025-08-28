
import 'package:ryan_clicker_rpg/models/weapon.dart'; // Import Rarity enum

class GachaBox {
  final String id;
  final String name;
  final int stageLevel; // To determine loot pool based on stage
  final bool isBossBox;
  final Rarity? guaranteedRarity; // New: Specific rarity guaranteed
  final bool isAllRange; // New: True if weapon can be from any stage level

  GachaBox({
    required this.id,
    required this.name,
    required this.stageLevel,
    this.isBossBox = false,
    this.guaranteedRarity, // Optional
    this.isAllRange = false, // Default to false
  });

  // Factory constructor for creating a GachaBox from JSON
  factory GachaBox.fromJson(Map<String, dynamic> json) {
    return GachaBox(
      id: json['id'],
      name: json['name'],
      stageLevel: json['stageLevel'],
      isBossBox: json['isBossBox'] ?? false,
      guaranteedRarity: json['guaranteedRarity'] != null
          ? Rarity.values.firstWhere(
              (e) => e.toString().split('.').last == json['guaranteedRarity'].toString().split('.').last,
              orElse: () => Rarity.common, // Fallback
            )
          : null,
      isAllRange: json['isAllRange'] ?? false,
    );
  }

  // Method for converting a GachaBox to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stageLevel': stageLevel,
      'isBossBox': isBossBox,
      'guaranteedRarity': guaranteedRarity?.toString(), // Store as string
      'isAllRange': isAllRange,
    };
  }
}
