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
            child: SingleChildScrollView(
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

                  // Enhancement Stones
                  _buildShopItem(
                    context: context,
                    title: '강화석 1개',
                    description: '무기 강화에 사용되는 돌입니다.',
                    cost: 5000,
                    onPressed: () {
                      _showConfirmationDialog(context, '구매 확인', '강화석 1개를 5000 골드에 구매하시겠습니까?', () {
                        final message = game.buyEnhancementStones(amount: 1, cost: 5000);
                        _showResultDialog(context, message);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '강화석 10개',
                    description: '무기 강화에 사용되는 돌입니다. (10% 할인)',
                    cost: 45000,
                    onPressed: () {
                      _showConfirmationDialog(context, '구매 확인', '강화석 10개를 45000 골드에 구매하시겠습니까?', () {
                        final message = game.buyEnhancementStones(amount: 10, cost: 45000);
                        _showResultDialog(context, message);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '강화석 50개',
                    description: '무기 강화에 사용되는 돌입니다. (16% 할인)',
                    cost: 210000,
                    onPressed: () {
                      _showConfirmationDialog(context, '구매 확인', '강화석 50개를 210000 골드에 구매하시겠습니까?', () {
                        final message = game.buyEnhancementStones(amount: 50, cost: 210000);
                        _showResultDialog(context, message);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '강화석 100개',
                    description: '무기 강화에 사용되는 돌입니다. (20% 할인)',
                    cost: 400000,
                    onPressed: () {
                      _showConfirmationDialog(context, '구매 확인', '강화석 100개를 400000 골드에 구매하시겠습니까?', () {
                        final message = game.buyEnhancementStones(amount: 100, cost: 400000);
                        _showResultDialog(context, message);
                      });
                    },
                  ),
                  const Divider(height: 40, color: Colors.grey),

                  // Transcendence Stones
                  _buildShopItem(
                    context: context,
                    title: '초월석 1개',
                    description: '무기 초월에 사용되는 돌입니다.',
                    cost: 100000,
                    onPressed: () {
                      _showConfirmationDialog(context, '구매 확인', '초월석 1개를 100000 골드에 구매하시겠습니까?', () {
                        final message = game.buyTranscendenceStones(amount: 1, cost: 100000);
                        _showResultDialog(context, message);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '초월석 5개',
                    description: '무기 초월에 사용되는 돌입니다. (4% 할인)',
                    cost: 480000,
                    onPressed: () {
                      _showConfirmationDialog(context, '구매 확인', '초월석 5개를 480000 골드에 구매하시겠습니까?', () {
                        final message = game.buyTranscendenceStones(amount: 5, cost: 480000);
                        _showResultDialog(context, message);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '초월석 10개',
                    description: '무기 초월에 사용되는 돌입니다. (5% 할인)',
                    cost: 950000,
                    onPressed: () {
                      _showConfirmationDialog(context, '구매 확인', '초월석 10개를 950000 골드에 구매하시겠습니까?', () {
                        final message = game.buyTranscendenceStones(amount: 10, cost: 950000);
                        _showResultDialog(context, message);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopItem({required BuildContext context, required String title, required String description, required int cost, required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          ElevatedButton(onPressed: onPressed, child: Text('구매 ($cost G)')),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context, String title, String content, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}