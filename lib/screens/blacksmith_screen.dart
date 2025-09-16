import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart'; // Import Weapon model
import 'package:ryan_clicker_rpg/data/weapon_data.dart'; // NEW IMPORT for WeaponData
import 'package:intl/intl.dart';
import 'package:ryan_clicker_rpg/widgets/weapon_info_widget.dart';
import 'dart:math'; // Import dart:math for pow function

enum StoneType { enhancement, transcendence }

class BlacksmithScreen extends StatefulWidget {
  const BlacksmithScreen({super.key});

  @override
  State<BlacksmithScreen> createState() => _BlacksmithScreenState();
}

class _BlacksmithScreenState extends State<BlacksmithScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('대장간'),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final equippedWeapon = game.player.equippedWeapon;
          final rarityMultiplier = equippedWeapon.rarity.index + 1;
          final enhancementGoldCost =
              ((equippedWeapon.baseLevel + 1) +
                  pow(equippedWeapon.enhancement + 1, 2.5)) *
              100 *
              rarityMultiplier;
          final enhancementStoneCost =
              ((equippedWeapon.enhancement + 1) / 2).ceil() +
              (rarityMultiplier - 1);

          final enhancementLevel = equippedWeapon.enhancement;
          const enhancementDamageMultipliers = [
            1.00,
            1.05,
            1.10,
            1.15,
            1.20,
            1.30,
            1.40,
            1.50,
            1.60,
            1.70,
            1.85,
            2.00,
            2.20,
            2.40,
            2.70,
            3.10,
            3.60,
            4.20,
            5.00,
            6.00,
            7.50,
          ];
          final expectedEnhancementDamage =
              enhancementLevel < enhancementDamageMultipliers.length
              ? equippedWeapon.calculatedDamage *
                    enhancementDamageMultipliers[enhancementLevel]
              : equippedWeapon.calculatedDamage;
          const enhancementProbabilities = [
            100, 100, 100, 100, 100, 100, // 0-5
            90, 85, 80, 75, 70, // 6-10
            60, 53, 47, 40, // 11-14
            30, 25, 20, // 15-17
            15, 10, // 18-19
            5, // 20
          ]; // In percentage

          final newTranscendenceGoldCost =
              (100 + (equippedWeapon.baseLevel + 1) * 10) *
              1250 *
              rarityMultiplier * // rarityMultiplier is already defined above
              (equippedWeapon.transcendence + 1);
          final newTranscendenceStoneCost =
              ((rarityMultiplier +
                          ((equippedWeapon.baseLevel + 1) / 200).floor()) *
                      (equippedWeapon.transcendence + 1))
                  .toInt();

          // Filter out the equipped weapon from inventory for selling/disassembling
          final inventoryWeapons = game.player.inventory
              .where((w) => w.instanceId != equippedWeapon.instanceId)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Gold Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'images/others/gold.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ': ${NumberFormat('#,###').format(game.player.gold)}G',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Image.asset(
                        'images/others/enhancement_stone.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ': ${NumberFormat('#,###').format(game.player.enhancementStones)}개',
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Image.asset(
                        'images/others/transcendence_stone.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ': ${NumberFormat('#,###').format(game.player.transcendenceStones)}개',
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Enhancement Section
                  _buildSection(
                    title: '강화',
                    description:
                        equippedWeapon.enhancement >=
                            equippedWeapon.maxEnhancement
                        ? '현재 강화: +${equippedWeapon.enhancement} / +${equippedWeapon.maxEnhancement}\n\n최대 강화에 도달하였습니다.'
                        : '현재 강화: +${equippedWeapon.enhancement} / +${equippedWeapon.maxEnhancement}\n강화 확률: ${enhancementProbabilities[enhancementLevel]}%\n필요 골드: ${NumberFormat('#,###').format(enhancementGoldCost)}G\n필요 강화석: ${NumberFormat('#,###').format(enhancementStoneCost)}개\n성공 시 기대 데미지: ${NumberFormat('#,###').format(expectedEnhancementDamage)}\n\n골드와 강화석을 소모하여 무기를 강화합니다. 강화 시 데미지가 큰 폭으로 상승합니다.',
                    buttonText: '강화',
                    onPressed:
                        equippedWeapon.enhancement >=
                            equippedWeapon.maxEnhancement
                        ? null
                        : () {
                            _showConfirmationDialog(
                              context,
                              '강화',
                              '정말로 강화하시겠습니까?',
                              () {
                                final message = game.enhanceEquippedWeapon();
                                _showResultDialog(context, message);
                              },
                            );
                          },
                  ),

                  const SizedBox(height: 20),

                  // Transcendence Section
                  _buildSection(
                    title: '초월',
                    description:
                        equippedWeapon.transcendence >=
                            equippedWeapon.maxTranscendence
                        ? '현재 초월: [${equippedWeapon.transcendence}] / ${equippedWeapon.maxTranscendence}\n\n이미 최대 초월 단계입니다.'
                        : '현재 초월: [${equippedWeapon.transcendence}] / ${equippedWeapon.maxTranscendence}\n초월 확률: 5%\n조건: +20 강화\n필요 골드: ${NumberFormat('#,###').format(newTranscendenceGoldCost)}G\n필요 초월석: ${NumberFormat('#,###').format(newTranscendenceStoneCost)}개\n성공 시 능력치 상승\n\n최대 강화 무기를 초월시킵니다. 초월 시 능력치가 막대하게 상승합니다.',
                    buttonText: '초월',
                    onPressed:
                        equippedWeapon.transcendence >=
                                equippedWeapon.maxTranscendence ||
                            equippedWeapon.enhancement < 20
                        ? null
                        : () {
                            _showConfirmationDialog(
                              context,
                              '초월',
                              '정말로 초월하시겠습니까?',
                              () {
                                final message = game.transcendEquippedWeapon();
                                _showResultDialog(context, message);
                              },
                            );
                          },
                  ),

                  const SizedBox(height: 20),
                  const Divider(color: Colors.yellow),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '보유 무기 (판매/분해)',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      '판매: 기본 판매가 + 투자 자원(골드, 강화석, 초월석)의 1/3 회수.\n분해: 투자 자원(강화석, 초월석) 100% 회수 (골드 제외).',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),

                  // Bulk Sell Section
                  _buildBulkSellSection(context, game, inventoryWeapons),

                  // Inventory List for Selling/Disassembling
                  ListView.builder(
                    shrinkWrap:
                        true, // Important for nested ListView in SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scrolling for nested ListView
                    itemCount: inventoryWeapons.length,
                    itemBuilder: (context, index) {
                      final weapon = inventoryWeapons[index];
                      return _buildSellDisassembleWeaponCard(
                        context,
                        weapon,
                        game,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.yellow),
                  _buildSection(
                    title: '보유 재화 판매',
                    description:
                        '강화석: ${game.player.enhancementStones}개 (개당 5000 골드)\n'
                        '초월석: ${game.player.transcendenceStones}개 (개당 50000 골드)',
                    children: [
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _showSellStoneDialog(
                          context,
                          StoneType.enhancement,
                          game,
                        ),
                        child: const Text('강화석 판매'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _showSellStoneDialog(
                          context,
                          StoneType.transcendence,
                          game,
                        ),
                        child: const Text('초월석 판매'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    String? buttonText,
    VoidCallback? onPressed,
    List<Widget>? children, // New optional parameter
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (children != null) // Render children if provided
            ...children
          else if (buttonText != null &&
              onPressed !=
                  null) // Render button if text and onPressed are provided
            ElevatedButton(onPressed: onPressed, child: Text(buttonText)),
        ],
      ),
    );
  }

  Widget _buildSellDisassembleWeaponCard(
    BuildContext context,
    Weapon weapon,
    GameProvider game,
  ) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Left Box (Image)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      buildWeaponDetailsDialog(context, weapon),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: WeaponData.getColorForRarity(weapon.rarity),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Image.asset(
                  'images/weapons/${weapon.imageName}',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right Box (Info and Buttons)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top part of Right Box (Info)
                  Text(
                    '${weapon.name} +${weapon.enhancement}[${weapon.transcendence}]',
                    style: TextStyle(
                      color: WeaponData.getColorForRarity(weapon.rarity),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '데미지: ${weapon.calculatedDamage.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  // Bottom part of Right Box (Buttons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (game.player.equippedWeapon.instanceId !=
                          weapon.instanceId)
                        ElevatedButton(
                          onPressed: () {
                            game.equipWeapon(weapon);
                            _showResultDialog(
                              context,
                              '${weapon.name}을(를) 장착했습니다.',
                            );
                          },
                          child: const Text('장착'),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final double sellPrice =
                              weapon.baseSellPrice +
                              (weapon.investedGold / 3) +
                              (weapon.investedEnhancementStones * 5000 / 3) +
                              (weapon.investedTranscendenceStones * 50000 / 3);

                          final content =
                              '${weapon.name}을(를) 정말로 판매하시겠습니까?\n\n판매금액: ${NumberFormat('#,###').format(sellPrice)}G';

                          _showConfirmationDialog(context, '판매', content, () {
                            final message = game.sellWeapon(weapon);
                            _showResultDialog(context, message);
                          });
                        },
                        child: const Text('판매'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showConfirmationDialog(
                            context,
                            '분해',
                            '${weapon.name}을(를) 정말로 분해하시겠습니까?',
                            () {
                              final message = game.disassembleWeapon(weapon);
                              _showResultDialog(context, message);
                            },
                          );
                        },
                        child: const Text('분해'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Future<void> _showSellStoneDialog(
    BuildContext context,
    StoneType type,
    GameProvider game,
  ) async {
    int currentAmount = 0; // This will be managed by StatefulBuilder

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final int maxStones = (type == StoneType.enhancement)
                ? game.player.enhancementStones
                : game.player.transcendenceStones;
            final String stoneName = (type == StoneType.enhancement)
                ? '강화석'
                : '초월석';
            final int sellPricePerStone = (type == StoneType.enhancement)
                ? 5000
                : 50000;

            // Ensure currentAmount doesn't exceed maxStones
            if (currentAmount > maxStones) {
              currentAmount = maxStones;
            }

            void updateAmount(int increment) {
              setState(() {
                currentAmount = (currentAmount + increment).clamp(0, maxStones);
              });
            }

            return AlertDialog(
              title: Text('$stoneName 판매'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      '보유 $stoneName: $maxStones개',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => updateAmount(-10),
                          child: const Text('-10'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => updateAmount(-1),
                          child: const Text('-1'),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$currentAmount개',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => updateAmount(1),
                          child: const Text('+1'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => updateAmount(10),
                          child: const Text('+10'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '판매 시 획득 골드: ${currentAmount * sellPricePerStone} 골드',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  child: const Text('판매'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Dismiss dialog first
                    String message;
                    if (type == StoneType.enhancement) {
                      message = game.sellEnhancementStones(
                        amount: currentAmount,
                      );
                    } else {
                      message = game.sellTranscendenceStones(
                        amount: currentAmount,
                      );
                    }
                    _showResultDialog(context, message);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBulkSellSection(
    BuildContext context,
    GameProvider game,
    List<Weapon> inventoryWeapons,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBulkSellButton(context, game, inventoryWeapons, [
            Rarity.common,
          ], '커먼'),
          _buildBulkSellButton(context, game, inventoryWeapons, [
            Rarity.common,
            Rarity.uncommon,
          ], '커먼~언커먼'),
          _buildBulkSellButton(context, game, inventoryWeapons, [
            Rarity.common,
            Rarity.uncommon,
            Rarity.rare,
          ], '커먼~레어'),
          _buildBulkSellButton(context, game, inventoryWeapons, [
            Rarity.common,
            Rarity.uncommon,
            Rarity.rare,
            Rarity.unique,
          ], '유니크 이하'),
        ],
      ),
    );
  }

  Widget _buildBulkSellButton(
    BuildContext context,
    GameProvider game,
    List<Weapon> inventoryWeapons,
    List<Rarity> raritiesToSell,
    String buttonText,
  ) {
    final rarityColor = WeaponData.getColorForRarity(raritiesToSell.last);

    return ElevatedButton(
      onPressed: () {
        _showBulkSellConfirmationDialog(
          context,
          game,
          inventoryWeapons,
          raritiesToSell,
          buttonText,
        );
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: rarityColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: const Text('판매'),
    );
  }

  void _showBulkSellConfirmationDialog(
    BuildContext context,
    GameProvider game,
    List<Weapon> inventoryWeapons,
    List<Rarity> raritiesToSell,
    String rarityText,
  ) {
    final weaponsToSell = inventoryWeapons
        .where((w) => raritiesToSell.contains(w.rarity))
        .toList();

    if (weaponsToSell.isEmpty) {
      _showResultDialog(context, '판매할 $rarityText 등급의 무기가 없습니다.');
      return;
    }

    final double totalSellPrice = weaponsToSell.fold(
      0,
      (sum, weapon) =>
          sum +
          (weapon.baseSellPrice +
              (weapon.investedGold / 3) +
              (weapon.investedEnhancementStones * 5000 / 3) +
              (weapon.investedTranscendenceStones * 50000 / 3)),
    );

    final content =
        '현재 보유한 $rarityText 등급의 모든 무기 (${weaponsToSell.length}개)를 일괄판매하시겠습니까?\n\n판매금액: ${NumberFormat('#,###').format(totalSellPrice)}G';

    _showConfirmationDialog(context, '일괄 판매', content, () {
      final message = game.sellMultipleWeapons(weaponsToSell);
      _showResultDialog(context, message);
    });
  }
}
