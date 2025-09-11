import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:intl/intl.dart';

// New data class for shop items
class ShopItemData {
  final String imagePath;
  final int quantity;
  final String description;
  final int cost;
  final int amountToBuy;
  final int costToBuy;

  ShopItemData({
    required this.imagePath,
    required this.quantity,
    required this.description,
    required this.cost,
    required this.amountToBuy,
    required this.costToBuy,
  });
}

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
          final List<ShopItemData> enhancementStoneItems = [
            ShopItemData(
              imagePath: 'images/others/enhancement_stone.png',
              quantity: 1,
              description: '무기 강화에 사용되는 돌입니다.',
              cost: 5000,
              amountToBuy: 1,
              costToBuy: 5000,
            ),
            ShopItemData(
              imagePath: 'images/others/enhancement_stone.png',
              quantity: 10,
              description: '무기 강화에 사용되는 돌입니다. (10% 할인)',
              cost: 45000,
              amountToBuy: 10,
              costToBuy: 45000,
            ),
            ShopItemData(
              imagePath: 'images/others/enhancement_stone.png',
              quantity: 50,
              description: '무기 강화에 사용되는 돌입니다. (16% 할인)',
              cost: 210000,
              amountToBuy: 50,
              costToBuy: 210000,
            ),
            ShopItemData(
              imagePath: 'images/others/enhancement_stone.png',
              quantity: 100,
              description: '무기 강화에 사용되는 돌입니다. (20% 할인)',
              cost: 400000,
              amountToBuy: 100,
              costToBuy: 400000,
            ),
          ];

          final List<ShopItemData> transcendenceStoneItems = [
            ShopItemData(
              imagePath: 'images/others/transcendence_stone.png',
              quantity: 1,
              description: '무기 초월에 사용되는 돌입니다.',
              cost: 100000,
              amountToBuy: 1,
              costToBuy: 100000,
            ),
            ShopItemData(
              imagePath: 'images/others/transcendence_stone.png',
              quantity: 5,
              description: '무기 초월에 사용되는 돌입니다. (4% 할인)',
              cost: 480000,
              amountToBuy: 5,
              costToBuy: 480000,
            ),
            ShopItemData(
              imagePath: 'images/others/transcendence_stone.png',
              quantity: 10,
              description: '무기 초월에 사용되는 돌입니다. (5% 할인)',
              cost: 950000,
              amountToBuy: 10,
              costToBuy: 950000,
            ),
          ];
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Gold Info
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center the row
                    children: [
                      Image.asset(
                        'images/others/gold.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(
                        width: 8,
                      ), // Spacing between image and text
                      Text(
                        ': ${NumberFormat('#,###').format(game.player.gold)}G',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ShopItemSection(
                    title: '강화석 상점',
                    items: enhancementStoneItems,
                    buyFunction: ({required int amount, required int cost}) =>
                        game.buyEnhancementStones(amount: amount, cost: cost),
                    confirmationMessage: (amount, cost) =>
                        '강화석 $amount개를 $cost 골드에 구매하시겠습니까?',
                    showResultDialog: _showResultDialog,
                    showConfirmationDialog: _showConfirmationDialog,
                    buildShopItem: _buildShopItem,
                  ),
                  const Divider(height: 40, color: Colors.grey),

                  ShopItemSection(
                    title: '초월석 상점',
                    items: transcendenceStoneItems,
                    buyFunction: ({required int amount, required int cost}) =>
                        game.buyTranscendenceStones(amount: amount, cost: cost),
                    confirmationMessage: (amount, cost) =>
                        '초월석 $amount개를 $cost 골드에 구매하시겠습니까?',
                    showResultDialog: _showResultDialog,
                    showConfirmationDialog: _showConfirmationDialog,
                    buildShopItem: _buildShopItem,
                  ),

                  const Divider(height: 40, color: Colors.grey),

                  // Gacha Boxes
                  const Text(
                    '무기 상점',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '전구간 랜덤 유니크 무기 상자',
                    description: '모든 레벨 구간의 유니크 무기를 획득할 수 있습니다.',
                    cost: 1,
                    onPressed: () {
                      _showConfirmationDialog(
                        context,
                        '구매 확인',
                        '전구간 랜덤 유니크 무기 상자를 1 골드에 구매하시겠습니까?',
                        () {
                          final message = game.buyAllRangeUniqueBox();
                          _showResultDialog(context, message);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '현재 레벨구간 유니크 무기 상자',
                    description: '현재 레벨 구간 이하의 유니크 무기를 획득할 수 있습니다.',
                    cost: 1,
                    onPressed: () {
                      _showConfirmationDialog(
                        context,
                        '구매 확인',
                        '현재 레벨구간 유니크 무기 상자를 1 골드에 구매하시겠습니까?',
                        () {
                          final message = game.buyCurrentRangeUniqueBox(
                            game.player.currentStage,
                          );
                          _showResultDialog(context, message);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '전구간 랜덤 에픽 무기 상자',
                    description: '모든 레벨 구간의 에픽 무기를 획득할 수 있습니다.',
                    cost: 1,
                    onPressed: () {
                      _showConfirmationDialog(
                        context,
                        '구매 확인',
                        '전구간 랜덤 에픽 무기 상자를 1 골드에 구매하시겠습니까?',
                        () {
                          final message = game.buyAllRangeEpicBox();
                          _showResultDialog(context, message);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '전구간 랜덤 레전드 무기 상자',
                    description: '모든 레벨 구간의 레전드 무기를 획득할 수 있습니다.',
                    cost: 1,
                    onPressed: () {
                      _showConfirmationDialog(
                        context,
                        '구매 확인',
                        '전구간 랜덤 레전드 무기 상자를 1 골드에 구매하시겠습니까?',
                        () {
                          final message = game.buyAllRangeLegendaryBox();
                          _showResultDialog(context, message);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildShopItem(
                    context: context,
                    title: '현재 레벨구간 에픽 무기 상자',
                    description: '현재 레벨 구간 이하의 에픽 무기를 획득할 수 있습니다.',
                    cost: 1,
                    onPressed: () {
                      _showConfirmationDialog(
                        context,
                        '구매 확인',
                        '현재 레벨구간 에픽 무기 상자를 1 골드에 구매하시겠습니까?',
                        () {
                          final message = game.buyCurrentRangeEpicBox(
                            game.player.currentStage,
                          );
                          _showResultDialog(context, message);
                        },
                      );
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

  Widget _buildShopItem({
    required BuildContext context,
    String? title,
    String? imagePath,
    int? quantity,
    required String description,
    required int cost,
    required VoidCallback onPressed,
  }) {
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
                if (imagePath != null && quantity != null)
                  Row(
                    children: [
                      Image.asset(imagePath, width: 24, height: 24),
                      const SizedBox(width: 8),
                      Text(
                        'x$quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else if (title != null)
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            child: Text('구매 (${NumberFormat('#,###').format(cost)}G)'),
          ),
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

  Future<void> _showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(content)]),
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

typedef BuyFunction = String Function({required int amount, required int cost});
typedef ConfirmationMessageBuilder = String Function(int amount, int cost);
typedef ShowResultDialog = void Function(BuildContext context, String message);
typedef ShowConfirmationDialog =
    Future<void> Function(
      BuildContext context,
      String title,
      String content,
      VoidCallback onConfirm,
    );
typedef BuildShopItem =
    Widget Function({
      required BuildContext context,
      String? title,
      String? imagePath,
      int? quantity,
      required String description,
      required int cost,
      required VoidCallback onPressed,
    });

class ShopItemSection extends StatelessWidget {
  final String title;
  final List<ShopItemData> items;
  final BuyFunction buyFunction;
  final ConfirmationMessageBuilder confirmationMessage;
  final ShowResultDialog showResultDialog;
  final ShowConfirmationDialog showConfirmationDialog;
  final BuildShopItem buildShopItem;

  const ShopItemSection({
    super.key,
    required this.title,
    required this.items,
    required this.buyFunction,
    required this.confirmationMessage,
    required this.showResultDialog,
    required this.showConfirmationDialog,
    required this.buildShopItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) {
          String itemDescription =
              '${title.contains('강화석') ? '강화석' : '초월석'} ${item.quantity}개를 구매합니다.';
          if (item.description.contains('할인')) {
            itemDescription +=
                '\n${item.description.substring(item.description.indexOf('('))}';
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: buildShopItem(
              context: context,
              imagePath: item.imagePath,
              quantity: item.quantity,
              description: itemDescription, // Use the constructed description
              cost: item.cost,
              onPressed: () {
                showConfirmationDialog(
                  context,
                  '구매 확인',
                  confirmationMessage(item.amountToBuy, item.costToBuy),
                  () {
                    final message = buyFunction(
                      amount: item.amountToBuy,
                      cost: item.costToBuy,
                    );
                    showResultDialog(context, message);
                  },
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
