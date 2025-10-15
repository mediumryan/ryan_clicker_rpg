import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:intl/intl.dart';

// Helper class to hold player resources for the Selector
class _PlayerResources {
  final double gold;
  final int darkMatter;

  _PlayerResources(this.gold, this.darkMatter);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _PlayerResources &&
          runtimeType == other.runtimeType &&
          gold == other.gold &&
          darkMatter == other.darkMatter;

  @override
  int get hashCode => gold.hashCode ^ darkMatter.hashCode;
}

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gold and Dark Matter Info - Optimized with Selector
            Selector<GameProvider, _PlayerResources>(
              selector: (_, game) =>
                  _PlayerResources(game.player.gold, game.player.darkMatter),
              builder: (context, resources, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the row
                  children: [
                    Image.asset(
                      'assets/images/others/gold.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8), // Spacing between image and text
                    Text(
                      ': ${NumberFormat('#,###').format(resources.gold)}G',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ), // Spacing between gold and dark matter
                    Image.asset(
                      'assets/images/others/dark_matter.png',
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 8), // Spacing between image and text
                    Text(
                      ': ${NumberFormat('#,###').format(resources.darkMatter)}개',
                      style: const TextStyle(
                        color: Colors.deepPurpleAccent,
                        fontSize: 18,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Shop Items - Using Consumer as it needs access to methods
            Expanded(
              child: Consumer<GameProvider>(
                builder: (context, game, child) {
                  final List<ShopItemData> enhancementStoneItems = [
                    ShopItemData(
                      imagePath: 'assets/images/others/enhancement_stone.png',
                      quantity: 1,
                      description: '무기 강화에 사용되는 돌입니다.',
                      cost: 5000,
                      amountToBuy: 1,
                      costToBuy: 5000,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/others/enhancement_stone.png',
                      quantity: 10,
                      description: '무기 강화에 사용되는 돌입니다. (10% 할인)',
                      cost: 45000,
                      amountToBuy: 10,
                      costToBuy: 45000,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/others/enhancement_stone.png',
                      quantity: 50,
                      description: '무기 강화에 사용되는 돌입니다. (16% 할인)',
                      cost: 210000,
                      amountToBuy: 50,
                      costToBuy: 210000,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/others/enhancement_stone.png',
                      quantity: 100,
                      description: '무기 강화에 사용되는 돌입니다. (20% 할인)',
                      cost: 400000,
                      amountToBuy: 100,
                      costToBuy: 400000,
                    ),
                  ];

                  final List<ShopItemData> transcendenceStoneItems = [
                    ShopItemData(
                      imagePath: 'assets/images/others/transcendence_stone.png',
                      quantity: 1,
                      description: '무기 초월에 사용되는 돌입니다.',
                      cost: 100000,
                      amountToBuy: 1,
                      costToBuy: 100000,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/others/transcendence_stone.png',
                      quantity: 5,
                      description: '무기 초월에 사용되는 돌입니다. (4% 할인)',
                      cost: 480000,
                      amountToBuy: 5,
                      costToBuy: 480000,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/others/transcendence_stone.png',
                      quantity: 10,
                      description: '무기 초월에 사용되는 돌입니다. (5% 할인)',
                      cost: 950000,
                      amountToBuy: 10,
                      costToBuy: 950000,
                    ),
                  ];

                  final List<ShopItemData> darkMatterEnhancementStoneItems = [
                    ShopItemData(
                      imagePath: 'assets/images/others/enhancement_stone.png',
                      quantity: 10,
                      description: '암흑 물질로 구매하는 강화석입니다.',
                      cost: 200,
                      amountToBuy: 10,
                      costToBuy: 200,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/others/enhancement_stone.png',
                      quantity: 100,
                      description: '암흑 물질로 구매하는 강화석입니다.',
                      cost: 2000,
                      amountToBuy: 100,
                      costToBuy: 2000,
                    ),
                  ];

                  final List<ShopItemData> darkMatterWeaponBoxItems = [
                    ShopItemData(
                      imagePath: 'assets/images/chests/unique.png',
                      quantity: 1,
                      description: '암흑 물질로 구매하는 현재 레벨 구간 유니크 무기 상자입니다.',
                      cost: 1000,
                      amountToBuy: 1,
                      costToBuy: 1000,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/chests/epic.png',
                      quantity: 1,
                      description: '암흑 물질로 구매하는 현재 레벨 구간 에픽 무기 상자입니다.',
                      cost: 15000,
                      amountToBuy: 1,
                      costToBuy: 15000,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/chests/legend.png',
                      quantity: 1,
                      description: '암흑 물질로 구매하는 현재 레벨 구간 레전드 무기 상자입니다.',
                      cost: 125000,
                      amountToBuy: 1,
                      costToBuy: 125000,
                    ),
                  ];

                  final List<ShopItemData> protectionTicketItems = [
                    ShopItemData(
                      imagePath: 'assets/images/others/protection_ticket.png',
                      quantity: 1,
                      description: '강화 실패 시 무기 파괴를 1회 방지합니다.',
                      cost: 1000000,
                      amountToBuy: 1,
                      costToBuy: 1000000,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/others/protection_ticket.png',
                      quantity: 10,
                      description: '강화 실패 시 무기 파괴를 10회 방지합니다. (10% 할인)',
                      cost: 9000000,
                      amountToBuy: 10,
                      costToBuy: 9000000,
                    ),
                  ];

                  final List<ShopItemData> darkMatterProtectionTicketItems = [
                    ShopItemData(
                      imagePath: 'assets/images/others/protection_ticket.png',
                      quantity: 1,
                      description: '강화 실패 시 무기 파괴를 1회 방지합니다.',
                      cost: 500,
                      amountToBuy: 1,
                      costToBuy: 500,
                    ),
                    ShopItemData(
                      imagePath: 'assets/images/others/protection_ticket.png',
                      quantity: 10,
                      description: '강화 실패 시 무기 파괴를 10회 방지합니다. (10% 할인)',
                      cost: 4500,
                      amountToBuy: 10,
                      costToBuy: 4500,
                    ),
                  ];
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ShopItemSection(
                          title: '강화석 상점',
                          items: enhancementStoneItems,
                          buyFunction:
                              ({required int amount, required int cost}) =>
                                  game.buyEnhancementStones(
                                    amount: amount,
                                    cost: cost,
                                  ),
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
                          buyFunction:
                              ({required int amount, required int cost}) =>
                                  game.buyTranscendenceStones(
                                    amount: amount,
                                    cost: cost,
                                  ),
                          confirmationMessage: (amount, cost) =>
                              '초월석 $amount개를 $cost 골드에 구매하시겠습니까?',
                          showResultDialog: _showResultDialog,
                          showConfirmationDialog: _showConfirmationDialog,
                          buildShopItem: _buildShopItem,
                        ),

                        const Divider(height: 40, color: Colors.grey),

                        ShopItemSection(
                          title: '파괴 방지권 상점 (골드)',
                          items: protectionTicketItems,
                          buyFunction:
                              ({required int amount, required int cost}) =>
                                  game.buyDestructionProtectionTicketsWithGold(
                                    amount: amount,
                                    cost: cost,
                                  ),
                          confirmationMessage: (amount, cost) =>
                              '파괴 방지권 $amount개를 $cost 골드에 구매하시겠습니까?',
                          showResultDialog: _showResultDialog,
                          showConfirmationDialog: _showConfirmationDialog,
                          buildShopItem: _buildShopItem,
                        ),

                        const Divider(height: 40, color: Colors.grey),

                        ShopItemSection(
                          title: '파괴 방지권 상점 (암흑 물질)',
                          items: darkMatterProtectionTicketItems,
                          buyFunction:
                              ({required int amount, required int cost}) => game
                                  .buyDestructionProtectionTicketsWithDarkMatter(
                                    amount: amount,
                                    cost: cost,
                                  ),
                          confirmationMessage: (amount, cost) =>
                              '파괴 방지권 $amount개를 $cost 암흑 물질에 구매하시겠습니까?',
                          showResultDialog: _showResultDialog,
                          showConfirmationDialog: _showConfirmationDialog,
                          buildShopItem:
                              ({
                                required BuildContext context,
                                String? title,
                                String? imagePath,
                                int? quantity,
                                required String description,
                                required int cost,
                                required VoidCallback onPressed,
                              }) => _buildShopItem(
                                context: context,
                                title: title,
                                imagePath: imagePath,
                                quantity: quantity,
                                description: description,
                                cost: cost,
                                onPressed: onPressed,
                                currencyUnit: '개',
                              ),
                        ),

                        const Divider(height: 40, color: Colors.grey),

                        ShopItemSection(
                          title: '암흑 물질 강화석 상점',
                          items: darkMatterEnhancementStoneItems,
                          buyFunction:
                              ({required int amount, required int cost}) =>
                                  game.buyDarkMatterEnhancementStones(
                                    amount: amount,
                                    cost: cost,
                                  ),
                          confirmationMessage: (amount, cost) =>
                              '강화석 $amount개를 $cost 암흑 물질에 구매하시겠습니까?',
                          showResultDialog: _showResultDialog,
                          showConfirmationDialog: _showConfirmationDialog,
                          buildShopItem:
                              ({
                                required BuildContext context,
                                String? title,
                                String? imagePath,
                                int? quantity,
                                required String description,
                                required int cost,
                                required VoidCallback onPressed,
                              }) => _buildShopItem(
                                context: context,
                                title: title,
                                imagePath: imagePath,
                                quantity: quantity,
                                description: description,
                                cost: cost,
                                onPressed: onPressed,
                                currencyUnit: '개',
                              ),
                        ),

                        const Divider(height: 40, color: Colors.grey),

                        ShopItemSection(
                          title: '암흑 물질 무기 상점',
                          items: darkMatterWeaponBoxItems,
                          buyFunction:
                              ({required int amount, required int cost}) {
                                // The amount here is always 1 for weapon boxes
                                if (cost == 1000) {
                                  // Unique box
                                  return game.buyDarkMatterUniqueBox();
                                } else if (cost == 15000) {
                                  // Epic box
                                  return game.buyDarkMatterEpicBox();
                                } else if (cost == 125000) {
                                  // Legend box
                                  return game.buyDarkMatterLegendBox();
                                }
                                return '잘못된 무기 상자 구매 요청입니다.';
                              },
                          confirmationMessage: (amount, cost) {
                            String boxType = '';
                            if (cost == 1000) {
                              boxType = '유니크';
                            } else if (cost == 15000) {
                              boxType = '에픽';
                            } else if (cost == 125000) {
                              boxType = '레전드';
                            }
                            return '$boxType 무기 상자를 $cost 암흑 물질에 구매하시겠습니까?';
                          },
                          showResultDialog: _showResultDialog,
                          showConfirmationDialog: _showConfirmationDialog,
                          buildShopItem:
                              ({
                                required BuildContext context,
                                String? title,
                                String? imagePath,
                                int? quantity,
                                required String description,
                                required int cost,
                                required VoidCallback onPressed,
                              }) => _buildShopItem(
                                context: context,
                                title: title,
                                imagePath: imagePath,
                                quantity: quantity,
                                description: description,
                                cost: cost,
                                onPressed: onPressed,
                                currencyUnit: '개',
                              ),
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
                          imagePath: 'assets/images/chests/unique.png',
                          quantity: 1,
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
                          imagePath: 'assets/images/chests/unique.png',
                          quantity: 1,
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
                          imagePath: 'assets/images/chests/epic.png',
                          quantity: 1,
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
                          title: '현재 레벨구간 에픽 무기 상자',
                          imagePath: 'assets/images/chests/epic.png',
                          quantity: 1,
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
                        const SizedBox(height: 12),
                        _buildShopItem(
                          context: context,
                          title: '전구간 랜덤 레전드 무기 상자',
                          imagePath: 'assets/images/chests/legend.png',
                          quantity: 1,
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
                          title: '현재 레벨구간 레전드 무기 상자',
                          imagePath: 'assets/images/chests/legend.png',
                          quantity: 1,
                          description: '현재 레벨 구간 이하의 레전드 무기를 획득할 수 있습니다.',
                          cost: 1,
                          onPressed: () {
                            _showConfirmationDialog(
                              context,
                              '구매 확인',
                              '현재 레벨구간 레전드 무기 상자를 1 골드에 구매하시겠습니까?',
                              () {
                                final message = game
                                    .buyCurrentRangeLegendaryBox(
                                      game.player.currentStage,
                                    );
                                _showResultDialog(context, message);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
    String currencyUnit = 'G', // New parameter
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
            child: Text(
              '구매 (${NumberFormat('#,###').format(cost)}$currencyUnit)',
            ),
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
              item.description; // Use item's own description
          if (item.description.contains('할인')) {
            itemDescription +=
                '\n${item.description.substring(item.description.indexOf('('))}'
                    .replaceAll('\n', '\n'); // Ensure newline is correctly escaped
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