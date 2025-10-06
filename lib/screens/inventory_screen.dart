import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/models/gacha_box.dart'; // Import GachaBox
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart'; // NEW IMPORT for WeaponData
import 'package:ryan_clicker_rpg/widgets/weapon_info_widget.dart'; // NEW IMPORT for WeaponInfoWidget
import 'package:collection/collection.dart'; // For list equality
import 'package:intl/intl.dart';

// Data class for the Selector
class _InventoryData {
  final Weapon equippedWeapon;
  final List<Weapon> inventory;
  final List<GachaBox> gachaBoxes;
  final double gold;
  final int enhancementStones;
  final int transcendenceStones;
  final int darkMatter;
  final int destructionProtectionTickets;

  _InventoryData({
    required this.equippedWeapon,
    required this.inventory,
    required this.gachaBoxes,
    required this.gold,
    required this.enhancementStones,
    required this.transcendenceStones,
    required this.darkMatter,
    required this.destructionProtectionTickets,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _InventoryData &&
          runtimeType == other.runtimeType &&
          equippedWeapon == other.equippedWeapon &&
          const ListEquality().equals(inventory, other.inventory) &&
          const ListEquality().equals(gachaBoxes, other.gachaBoxes) &&
          gold == other.gold &&
          enhancementStones == other.enhancementStones &&
          transcendenceStones == other.transcendenceStones &&
          darkMatter == other.darkMatter &&
          destructionProtectionTickets == other.destructionProtectionTickets;

  @override
  int get hashCode =>
      equippedWeapon.hashCode ^
      const ListEquality().hash(inventory) ^
      const ListEquality().hash(gachaBoxes) ^
      gold.hashCode ^
      enhancementStones.hashCode ^
      transcendenceStones.hashCode ^
      darkMatter.hashCode ^
      destructionProtectionTickets.hashCode;
}

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인벤토리'),
        backgroundColor: Colors.grey[850],
        actions: [],
      ),
      backgroundColor: Colors.grey[900],
      body: Selector<GameProvider, _InventoryData>(
        selector: (context, game) => _InventoryData(
          equippedWeapon: game.player.equippedWeapon,
          inventory: List.of(game.player.inventory),
          gachaBoxes: List.of(game.player.gachaBoxes),
          gold: game.player.gold,
          enhancementStones: game.player.enhancementStones,
          transcendenceStones: game.player.transcendenceStones,
          darkMatter: game.player.darkMatter,
          destructionProtectionTickets:
              game.player.destructionProtectionTickets,
        ),
        builder: (context, data, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Equipped Weapon Section
                _buildWeaponCard(
                  context,
                  data.equippedWeapon,
                  isEquipped: true,
                  onEquip: () {},
                ),
                const Divider(color: Colors.yellow),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '보유 재화',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                _buildResourceRow(
                  'images/others/gold.png',
                  '골드',
                  '게임의 기본 재화입니다.',
                  '${NumberFormat('#,###').format(data.gold)}G',
                ),
                _buildResourceRow(
                  'images/others/enhancement_stone.png',
                  '강화석',
                  '무기 강화에 사용됩니다.',
                  '${NumberFormat('#,###').format(data.enhancementStones)}개',
                ),
                _buildResourceRow(
                  'images/others/transcendence_stone.png',
                  '초월석',
                  '무기 초월에 사용됩니다.',
                  '${NumberFormat('#,###').format(data.transcendenceStones)}개',
                ),
                _buildResourceRow(
                  'images/others/dark_matter.png',
                  '암흑 물질',
                  '특별한 아이템 구매에 사용됩니다.',
                  '${NumberFormat('#,###').format(data.darkMatter)}개',
                ),
                _buildResourceRow(
                  'images/others/protection_ticket.png',
                  '파괴 방지권',
                  '강화 실패 시 파괴를 방지합니다.',
                  '${NumberFormat('#,###').format(data.destructionProtectionTickets)}개',
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.inventory.length,
                  itemBuilder: (context, index) {
                    final weapon = data.inventory[index];
                    return _buildWeaponCard(
                      context, // Pass context here
                      weapon,
                      onEquip: () {
                        context.read<GameProvider>().equipWeapon(weapon);
                      },
                    );
                  },
                ),
                const Divider(color: Colors.yellow),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '보유 상자',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.info_outline, color: Colors.white70, size: 20),
                        onPressed: () => _showGachaInfoDialog(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      if (data.gachaBoxes.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            final newWeapons = context.read<GameProvider>().openAllGachaBoxes();
                            _showAllGachaResultsDialog(context, newWeapons);
                          },
                          child: const Text('모두 열기'),
                        ),
                    ],
                  ),
                ), // Inventory List for Gacha Boxes
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.gachaBoxes.length,
                  itemBuilder: (context, index) {
                    final box = data.gachaBoxes[index];
                    return _buildGachaBoxCard(context, box, () {
                      final newWeapon = context
                          .read<GameProvider>()
                          .openGachaBox(box);
                      _showGachaResultDialog(context, newWeapon);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResourceRow(
    String imagePath,
    String name,
    String description,
    String count,
  ) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.asset(
              imagePath,
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              count,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeaponCard(
    BuildContext context, // Add context here
    Weapon weapon, {
    bool isEquipped = false,
    required VoidCallback onEquip,
  }) {
    final gradientColors = _getGradientColorsForEnhancement(weapon.enhancement);

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
                  gradient: gradientColors.isNotEmpty
                      ? LinearGradient(
                          colors: isEquipped
                              ? gradientColors
                                  .map((c) => Color.alphaBlend(
                                      Colors.white.withAlpha(38), c))
                                  .toList()
                              : gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: gradientColors.isEmpty ? Colors.black : null,
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
                    '${weapon.name} +${weapon.enhancement}[${weapon.transcendence}]${isEquipped ? ' [장착중]' : ''}',
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

  void _showGachaInfoDialog(BuildContext context) {
    final List<Map<String, dynamic>> gachaBoxInfo = WeaponData.gachaBoxInfo;

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

  void _showAllGachaResultsDialog(BuildContext context, List<Weapon> newWeapons) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('전체 상자 개봉 결과', style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: newWeapons.length,
              itemBuilder: (context, index) {
                final weapon = newWeapons[index];
                return Text(
                  weapon.name,
                  style: TextStyle(
                    color: WeaponData.getColorForRarity(weapon.rarity),
                  ),
                );
              },
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

  List<Color> _getGradientColorsForEnhancement(int enhancementLevel) {
    if (enhancementLevel >= 20) {
      return [Colors.amber[200]!, Colors.amber[500]!];
    } else if (enhancementLevel >= 19) {
      return [Colors.red[500]!, Colors.red[700]!];
    } else if (enhancementLevel >= 17) {
      return [Colors.red[300]!, Colors.red[500]!];
    } else if (enhancementLevel >= 15) {
      return [Colors.deepOrange[300]!, Colors.deepOrange[500]!];
    } else if (enhancementLevel >= 13) {
      return [Colors.orange[400]!, Colors.orange[600]!];
    } else if (enhancementLevel >= 11) {
      return [Colors.amber[500]!, Colors.amber[700]!];
    } else if (enhancementLevel >= 8) {
      return [Colors.yellow[600]!, Colors.yellow[800]!];
    } else {
      return [];
    }
  }
}
