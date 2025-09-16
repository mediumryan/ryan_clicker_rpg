import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/models/gacha_box.dart'; // Import GachaBox
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/widgets/achievement_dialog.dart';
import 'package:ryan_clicker_rpg/widgets/equipment_codex_dialog.dart'; // NEW IMPORT
import 'package:ryan_clicker_rpg/data/weapon_data.dart'; // NEW IMPORT for WeaponData
import 'package:ryan_clicker_rpg/widgets/weapon_info_widget.dart'; // NEW IMPORT for WeaponInfoWidget

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인벤토리'),
        backgroundColor: Colors.grey[850],
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events, color: Colors.white),
            onPressed: () {
              _showAchievementDialog(context);
            },
            tooltip: '업적',
          ),
          IconButton(
            icon: const Icon(
              Icons.book,
              color: Colors.white,
            ), // Book icon for codex
            onPressed: () {
              _showEquipmentCodexDialog(context);
            },
            tooltip: '장비 도감', // Tooltip for accessibility
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          // Debug print for equipped weapon
          debugPrint(
            'Equipped Weapon: ${game.player.equippedWeapon.name} - Rarity Multiplier: ${game.player.equippedWeapon.rarity.index + 1}',
          );

          // Debug print for inventory weapons
          for (var weapon in game.player.inventory) {
            debugPrint(
              'Inventory Weapon: ${weapon.name} - Rarity Multiplier: ${weapon.rarity.index + 1}',
            );
          }

          return Column(
            children: [
              // Equipped Weapon Section
              _buildWeaponCard(
                context, // Pass context here
                game.player.equippedWeapon,
                isEquipped: true,
                onEquip: () {},
              ),
              const Divider(color: Colors.yellow),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '보유 무기',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              // Inventory List for Weapons
              Expanded(
                child: ListView.builder(
                  itemCount: game.player.inventory.length,
                  itemBuilder: (context, index) {
                    final weapon = game.player.inventory[index];
                    return _buildWeaponCard(
                      context, // Pass context here
                      weapon,
                      onEquip: () {
                        game.equipWeapon(weapon);
                      },
                    );
                  },
                ),
              ),
              const Divider(color: Colors.yellow),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Changed to spaceBetween
                  children: [
                    Row(
                      // New inner Row to group text and icon
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '보유 상자',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(width: 16), // Spacing
                        IconButton(
                          // Changed from Tooltip
                          icon: const Icon(
                            Icons.info_outline, // Changed icon to info_outline
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: () {
                            _showGachaInfoDialog(
                              context,
                            ); // New method to show info
                          },
                          padding: EdgeInsets.zero, // Remove default padding
                          constraints:
                              const BoxConstraints(), // Remove default constraints
                        ),
                      ],
                    ),
                    // No other widgets here, the IconButton is now part of the inner Row
                  ],
                ),
              ),
              // Inventory List for Gacha Boxes
              Expanded(
                child: ListView.builder(
                  itemCount: game.player.gachaBoxes.length,
                  itemBuilder: (context, index) {
                    final box = game.player.gachaBoxes[index];
                    return _buildGachaBoxCard(context, box, () {
                      final newWeapon = game.openGachaBox(box);
                      _showGachaResultDialog(context, newWeapon);
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeaponCard(
    BuildContext context, // Add context here
    Weapon weapon, {
    bool isEquipped = false,
    required VoidCallback onEquip,
  }) {
    return Card(
      color: isEquipped ? Colors.blueGrey[800] : Colors.grey[800],
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
                width: 50, // Fixed width for the image container
                height: 50, // Fixed height for the image container
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
            // Right Box (Info and Button)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top part of Right Box (Info)
                  Text(
                    '${weapon.name} +${weapon.enhancement}[${weapon.transcendence}]${isEquipped ? ' [E]' : ''}',
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
                  // Bottom part of Right Box (Button)
                  if (!isEquipped)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: onEquip,
                        child: const Text('장착'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGachaBoxCard(
    BuildContext context,
    GachaBox box,
    VoidCallback onOpen,
  ) {
    return Card(
      color: box.isSpecialBox ? Colors.red[800] : Colors.purple[800],
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(box.imagePath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    box.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Stage Level: ${box.stageLevel}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: onOpen,
                      child: const Text('열기'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGachaResultDialog(BuildContext context, Weapon newWeapon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('상자 개봉 결과', style: TextStyle(color: Colors.white)),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              children: <TextSpan>[
                TextSpan(
                  text: '[${newWeapon.name}]',
                  style: TextStyle(
                    color: WeaponData.getColorForRarity(newWeapon.rarity),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: ' 획득!'),
              ],
            ),
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

  // NEW METHOD FOR EQUIPMENT CODEX DIALOG
  void _showEquipmentCodexDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EquipmentCodexDialog(); // Use the new widget here
      },
    );
  }

  void _showAchievementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AchievementDialog();
      },
    );
  }

  void _showGachaInfoDialog(BuildContext context) {
    final List<Map<String, dynamic>> gachaBoxInfo = [
      {
        'name': '흔한 무기상자',
        'description': '획득한 스테이지 기준 레벨의 커먼~에픽 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.common, 'percent': 50.0},
          {'rarity': Rarity.uncommon, 'percent': 35.0},
          {'rarity': Rarity.rare, 'percent': 10.0},
          {'rarity': Rarity.unique, 'percent': 4.5},
          {'rarity': Rarity.epic, 'percent': 0.5},
        ],
      },
      {
        'name': '평범한 무기상자',
        'description': '획득한 스테이지 기준 레벨의 커먼~레전드 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.common, 'percent': 35.0},
          {'rarity': Rarity.uncommon, 'percent': 33.0},
          {'rarity': Rarity.rare, 'percent': 24.0},
          {'rarity': Rarity.unique, 'percent': 6.0},
          {'rarity': Rarity.epic, 'percent': 1.5},
          {'rarity': Rarity.legend, 'percent': 0.5},
        ],
      },
      {
        'name': '희귀한 무기상자',
        'description': '획득한 스테이지 기준 레벨의 커먼~레전드 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.common, 'percent': 30.0},
          {'rarity': Rarity.uncommon, 'percent': 33.0},
          {'rarity': Rarity.rare, 'percent': 25.0},
          {'rarity': Rarity.unique, 'percent': 8.0},
          {'rarity': Rarity.epic, 'percent': 3.0},
          {'rarity': Rarity.legend, 'percent': 1.0},
        ],
      },
      {
        'name': '빛나는 무기상자',
        'description': '획득한 스테이지 기준 레벨의 언커먼~레전드 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.common, 'percent': 20.0},
          {'rarity': Rarity.uncommon, 'percent': 28.0},
          {'rarity': Rarity.rare, 'percent': 25.0},
          {'rarity': Rarity.unique, 'percent': 15.0},
          {'rarity': Rarity.epic, 'percent': 9.0},
          {'rarity': Rarity.legend, 'percent': 1.0},
        ],
      },
      {
        'name': '신비로운 무기상자',
        'description': '획득한 스테이지 기준 레벨의 언커먼~데미갓 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.uncommon, 'percent': 20.0},
          {'rarity': Rarity.rare, 'percent': 30.0},
          {'rarity': Rarity.unique, 'percent': 35.0},
          {'rarity': Rarity.epic, 'percent': 10.0},
          {'rarity': Rarity.legend, 'percent': 4.9},
          {'rarity': Rarity.demigod, 'percent': 0.1},
        ],
      },
      {
        'name': '신성한 기운이 감도는 무기상자',
        'description': '획득한 스테이지 기준 레벨의 레어~갓 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.rare, 'percent': 25.0},
          {'rarity': Rarity.unique, 'percent': 35.0},
          {'rarity': Rarity.epic, 'percent': 25.0},
          {'rarity': Rarity.legend, 'percent': 12.5},
          {'rarity': Rarity.demigod, 'percent': 2.4},
          {'rarity': Rarity.god, 'percent': 0.1},
        ],
      },
      {
        'name': '무기 갬블상자',
        'description': '현재 클리어한 최대 스테이지 기준 레벨의 커먼~갓 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.common, 'percent': 30.0},
          {'rarity': Rarity.uncommon, 'percent': 30.0},
          {'rarity': Rarity.rare, 'percent': 25.0},
          {'rarity': Rarity.unique, 'percent': 8.0},
          {'rarity': Rarity.epic, 'percent': 4.0},
          {'rarity': Rarity.legend, 'percent': 2.0},
          {'rarity': Rarity.demigod, 'percent': 0.9},
          {'rarity': Rarity.god, 'percent': 0.1},
        ],
      },
      {
        'name': '유니크 등급 무기상자',
        'description': '현재 클리어한 최대 스테이지 기준 레벨의 유니크 등급무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.unique, 'percent': 100.0},
        ],
      },
      {
        'name': '에픽 등급 무기상자',
        'description': '현재 클리어한 최대 스테이지 기준 레벨의 에픽 등급 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.epic, 'percent': 100.0},
        ],
      },
      {
        'name': '레전드 등급 무기상자',
        'description': '현재 클리어한 최대 스테이지 기준 레벨의 레전드 등급 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.legend, 'percent': 100.0},
        ],
      },
      {
        'name': '데미갓 등급 무기상자',
        'description': '현재 클리어한 최대 스테이지 기준 레벨의 데미갓 등급 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.demigod, 'percent': 100.0},
        ],
      },
      {
        'name': '갓 등급 무기상자',
        'description': '현재 클리어한 최대 스테이지 기준 레벨의 갓 등급 무기가 랜덤으로 1개 들어있습니다.',
        'probabilities': [
          {'rarity': Rarity.god, 'percent': 100.0},
        ],
      },
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('상자 정보', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: gachaBoxInfo.map((boxInfo) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '- ${boxInfo['name']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      boxInfo['description'],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    if ((boxInfo['probabilities'] as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: '확률\n',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12, // Smaller font size for "확률"
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ...(boxInfo['probabilities']
                                      as List<Map<String, dynamic>>)
                                  .map((prob) {
                                    final Rarity rarity = prob['rarity'];
                                    final double percent = prob['percent'];
                                    return TextSpan(
                                      text:
                                          '${WeaponData.getKoreanRarity(rarity)}: ${percent.toStringAsFixed(1)}%\n',
                                      style: TextStyle(
                                        color: WeaponData.getColorForRarity(
                                          rarity,
                                        ),
                                        fontSize:
                                            12, // Smaller font size for probabilities
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16), // Spacing between box types
                  ],
                );
              }).toList(),
            ),
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
