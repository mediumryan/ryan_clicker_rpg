import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:intl/intl.dart'; // NEW IMPORT

class PlayerResourcesWidget extends StatelessWidget {
  const PlayerResourcesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildResourceDisplay(
                        context,
                        'images/others/gold.png',
                        NumberFormat('#,###').format(game.player.gold),
                        Colors.amber,
                        '골드',
                        '골드는 무기 강화, 초월, 상점 이용 등 다양한 곳에 사용되는 기본 재화입니다.',
                        '보너스: +${((game.player.passiveGoldGainMultiplier - 1) * 100).toStringAsFixed(0)}%', // Multiplier value
                        null, // Multiplier description
                      ),
                      const SizedBox(width: 16),
                      _buildResourceDisplay(
                        context,
                        'images/others/enhancement_stone.png',
                        NumberFormat(
                          '#,###',
                        ).format(game.player.enhancementStones),
                        Colors.blueGrey,
                        '강화석',
                        '강화석은 무기 강화에 사용되는 핵심 재료입니다. 강화 단계가 높아질수록 더 많은 강화석이 필요합니다.',
                        '보너스: +${((game.player.passiveEnhancementStoneGainMultiplier - 1) * 100).toStringAsFixed(0)}% (${game.player.passiveEnhancementStoneGainFlat}개)', // Multiplier value
                        null, // Multiplier description
                      ),
                      const SizedBox(width: 16),
                      _buildResourceDisplay(
                        context,
                        'images/others/dark_matter.png',
                        NumberFormat('#,###').format(game.player.darkMatter),
                        Colors.deepPurple,
                        '암흑 물질',
                        '암흑 물질은 무기 강화 또는 초월 실패 시 파괴되었을 때 얻을 수 있는 특별한 재료입니다. 이 재료는 특별한 아이템을 제작하거나 교환하는 데 사용될 수 있습니다.',
                        '보너스: +0% (0개)', // Multiplier value
                        null, // Multiplier description
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu, size: 36.0),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildResourceDisplay(
    BuildContext context,
    String imagePath,
    String value,
    Color color,
    String title,
    String description,
    String? multiplierValue, // New parameter
    String? multiplierDescription, // New parameter
  ) {
    return GestureDetector(
      onTap: () {
        _showResourceDescriptionDialog(
          context,
          title,
          description,
          multiplierDescription,
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath, width: 24, height: 24),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          // New: Display multiplier if available
          if (multiplierValue != null)
            Text(
              multiplierValue,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ), // Use resource color
            ),
        ],
      ),
    );
  }

  static void _showResourceDescriptionDialog(
    BuildContext context,
    String title,
    String description,
    String? multiplierDescription, // New parameter
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: Column(
            // Changed to Column to hold multiple Text widgets
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description, style: const TextStyle(color: Colors.white70)),
              if (multiplierDescription != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    multiplierDescription,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
