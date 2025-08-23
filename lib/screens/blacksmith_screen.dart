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
          final enhancementGoldCost = (100 + (equippedWeapon.baseLevel * 10)) * 5 + (equippedWeapon.enhancement * 250);
          final enhancementStoneCost = 1 + (equippedWeapon.baseLevel / 100).floor() + equippedWeapon.enhancement;
          
          final enhancementLevel = equippedWeapon.enhancement;
          const enhancementDamageMultipliers = [1.05, 1.07, 1.10, 1.15, 1.20];
          final expectedEnhancementDamage = enhancementLevel < enhancementDamageMultipliers.length
              ? equippedWeapon.calculatedDamage * enhancementDamageMultipliers[enhancementLevel]
              : equippedWeapon.calculatedDamage;
          const enhancementProbabilities = [100, 90, 70, 50, 30]; // In percentage

          final transcendenceLevel = equippedWeapon.transcendence;
          const transcendenceDamageMultipliers = [1.75, 2.25, 2.75, 3.25, 4.0];
          final transcendenceDamageMultiplier = transcendenceLevel < transcendenceDamageMultipliers.length
              ? transcendenceDamageMultipliers[transcendenceLevel]
              : 1.0;
          const transcendenceProbabilities = [100, 75, 50, 30, 10]; // In percentage

          final newTranscendenceGoldCost = (100 + (equippedWeapon.baseLevel * 10)) * 100 * (equippedWeapon.transcendence + 1);
          final newTranscendenceStoneCost = (1 + (equippedWeapon.baseLevel / 200).floor()) * (equippedWeapon.transcendence + 1);


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

                  // Enhancement Section
                  _buildSection(
                    title: '강화',
                    description:
                        '현재 강화: +${equippedWeapon.enhancement} / +${equippedWeapon.maxEnhancement}\n강화 확률: ${enhancementProbabilities[enhancementLevel]}%\n필요 골드: $enhancementGoldCost\n필요 강화석: $enhancementStoneCost\n성공 시 기대 데미지: ${expectedEnhancementDamage.toStringAsFixed(0)}\n\n골드와 강화석을 소모하여 무기를 강화합니다. 강화 시 데미지가 큰 폭으로 상승합니다.',
                    buttonText: '강화',
                    onPressed: () {
                      _showConfirmationDialog(context, '강화', '정말로 강화하시겠습니까?', () {
                        final message = game.enhanceEquippedWeapon();
                        _showResultDialog(context, message);
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Transcendence Section
                  _buildSection(
                    title: '초월',
                    description:
                        '현재 초월: [${equippedWeapon.transcendence}] / ${equippedWeapon.maxTranscendence}\n초월 확률: ${transcendenceProbabilities[transcendenceLevel]}%\n조건: 최대 강화\n필요 골드: $newTranscendenceGoldCost\n필요 초월석: $newTranscendenceStoneCost\n성공 시 데미지 x${transcendenceDamageMultiplier.toStringAsFixed(2)}\n\n최대 강화 무기를 초월시킵니다. 초월 시 능력치가 막대하게 상승합니다.',
                    buttonText: '초월',
                    onPressed: () {
                      _showConfirmationDialog(context, '초월', '정말로 초월하시겠습니까?', () {
                        final message = game.transcendEquippedWeapon();
                        _showResultDialog(context, message);
                      });
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
              'Damage: ${weapon.calculatedDamage.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Enhancement: +${weapon.enhancement}, Transcendence: [${weapon.transcendence}]',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '판매 시 획득 골드: ${(weapon.baseSellPrice + (weapon.investedGold / 3)).toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              '분해 시 획득 자원: 강화석 ${weapon.investedEnhancementStones}개, 초월석 ${weapon.investedTranscendenceStones}개',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(context, '판매', '${weapon.name}을(를) 정말로 판매하시겠습니까?', () {
                      final message = game.sellWeapon(weapon);
                      _showResultDialog(context, message);
                    });
                  },
                  child: const Text('판매'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog(context, '분해', '${weapon.name}을(를) 정말로 분해하시겠습니까?', () {
                      final message = game.disassembleWeapon(weapon);
                      _showResultDialog(context, message);
                    });
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