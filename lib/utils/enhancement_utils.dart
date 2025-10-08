import 'package:flutter/material.dart';

class EnhancementUtils {
  static List<Color> getGradientColors(int enhancementLevel) {
    if (enhancementLevel >= 20) {
      return [Colors.amber[200]!, Colors.amber[500]!];
    } else if (enhancementLevel >= 19) {
      return [Colors.red[500]!, Colors.red[700]!];
    } else if (enhancementLevel >= 17) {
      return [Colors.red[300]!, Colors.red[500]!];
    } else if (enhancementLevel >= 15) {
      return [Colors.deepOrange[300]!, Colors.deepOrange[500]!];
    } else if (enhancementLevel >= 13) {
      return [Colors.orange[400]!, Colors.orange[600]!];
    } else if (enhancementLevel >= 11) {
      return [Colors.amber[500]!, Colors.amber[700]!];
    } else if (enhancementLevel >= 8) {
      return [Colors.yellow[600]!, Colors.yellow[800]!];
    } else {
      return [];
    }
  }
}
