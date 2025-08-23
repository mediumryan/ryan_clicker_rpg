import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';

class PlayerResourcesWidget extends StatelessWidget {
  const PlayerResourcesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResourceDisplay(
                '골드',
                game.player.gold.toStringAsFixed(0),
                Colors.amber,
              ),
              _buildResourceDisplay(
                '강화석',
                game.player.enhancementStones.toString(),
                Colors.blueGrey,
              ),
              _buildResourceDisplay(
                '초월석',
                game.player.transcendenceStones.toString(),
                Colors.purple,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResourceDisplay(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18)),
      ],
    );
  }
}
