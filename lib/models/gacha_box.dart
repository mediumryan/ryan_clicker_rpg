
import 'package:flutter/foundation.dart';

class GachaBox {
  final String id;
  final String name;
  final int stageLevel; // To determine loot pool based on stage
  final bool isBossBox; // NEW FIELD

  GachaBox({
    required this.id,
    required this.name,
    required this.stageLevel,
    this.isBossBox = false, // Initialize new field
  });

  // Factory constructor for creating a GachaBox from JSON
  factory GachaBox.fromJson(Map<String, dynamic> json) {
    return GachaBox(
      id: json['id'],
      name: json['name'],
      stageLevel: json['stageLevel'],
      isBossBox: json['isBossBox'] ?? false, // Handle null for old saves
    );
  }

  // Method for converting a GachaBox to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stageLevel': stageLevel,
      'isBossBox': isBossBox, // Include new field in JSON
    };
  }
}
