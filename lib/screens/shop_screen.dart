
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상점'),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Gold Info
                Text(
                  '보유 골드: ${game.player.gold.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.yellow, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Shop Items
                _buildShopItem(
                  title: '강화석 10개',
                  description: '무기 강화에 사용되는 돌입니다.',
                  cost: 1000,
                  onPressed: () {
                    final message = game.buyEnhancementStones(amount: 10, cost: 1000);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildShopItem(
                  title: '랜덤 무기 상자',
                  description: '사용 시 랜덤한 무기 1개를 획득합니다.',
                  cost: 5000,
                  onPressed: () {
                    final message = game.buyRandomWeaponBox(cost: 5000);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopItem({required String title, required String description, required int cost, required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          ElevatedButton(onPressed: onPressed, child: Text('구매 ($cost G)')),
        ],
      ),
    );
  }
}
