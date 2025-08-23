import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart'; // Import Weapon model

class BlacksmithScreen extends StatelessWidget {
  const BlacksmithScreen({super.key});

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
          final levelUpCost = equippedWeapon.level * 100;
          final enhancementGoldCost = (equippedWeapon.enhancement + 1) * 1000;
          final enhancementStoneCost = equippedWeapon.level <= 50
              ? 0
              : equippedWeapon.enhancement + 1;
          final transcendenceGoldCost = 100000;
          final transcendenceStoneCost = 1;

          // Filter out the equipped weapon from inventory for selling/disassembling
          final inventoryWeapons = game.player.inventory
              .where((w) => w.id != equippedWeapon.id)
              .toList();

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
                  Text(
                    '보유 강화석: ${game.player.enhancementStones}',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '보유 초월석: ${game.player.transcendenceStones}',
                    style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Level Up Section
                  _buildSection(
                    title: '레벨업',
                    description:
                        '현재 레벨: ${equippedWeapon.level} / ${equippedWeapon.maxLevel}\n필요 골드: $levelUpCost\n\n골드를 소모하여 무기의 레벨을 올립니다. 레벨업 시 데미지가 소폭 상승합니다.',
                    buttonText: '레벨업',
                    onPressed: () {
                      final message = game.levelUpEquippedWeapon();
                      _showResultDialog(context, message);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Enhancement Section
                  _buildSection(
                    title: '강화',
                    description:
                        '현재 강화: +${equippedWeapon.enhancement} / +${equippedWeapon.maxEnhancement}\n필요 골드: $enhancementGoldCost\n필요 강화석: $enhancementStoneCost\n\n골드와 강화석을 소모하여 무기를 강화합니다. 강화 시 데미지가 큰 폭으로 상승합니다.',
                    buttonText: '강화',
                    onPressed: () {
                      final message = game.enhanceEquippedWeapon();
                      _showResultDialog(context, message);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Transcendence Section
                  _buildSection(
                    title: '초월',
                    description:
                        '현재 초월: [${equippedWeapon.transcendence}]\n조건: 최대 레벨 & 최대 강화\n필요 골드: $transcendenceGoldCost\n필요 초월석: $transcendenceStoneCost\n\n최대 레벨, 최대 강화 무기를 초월시킵니다. 초월 시 능력치가 막대하게 상승합니다.',
                    buttonText: '초월',
                    onPressed: () {
                      final message = game.transcendEquippedWeapon();
                      _showResultDialog(context, message);
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
    required String buttonText,
    required VoidCallback onPressed,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weapon.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Damage: ${weapon.damage.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Level: ${weapon.level}, Enhancement: +${weapon.enhancement}, Transcendence: [${weapon.transcendence}]',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '판매 시 획득 골드: ${(weapon.baseSellPrice + (weapon.investedGold / 3)).toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '분해 시 획득 자원: 골드 ${weapon.investedGold.toStringAsFixed(0)}, 강화석 ${weapon.investedEnhancementStones}개, 초월석 ${weapon.investedTranscendenceStones}개',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final message = game.sellWeapon(weapon);
                    _showResultDialog(context, message);
                  },
                  child: const Text('판매'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final message = game.disassembleWeapon(weapon);
                    _showResultDialog(context, message);
                  },
                  child: const Text('분해'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
