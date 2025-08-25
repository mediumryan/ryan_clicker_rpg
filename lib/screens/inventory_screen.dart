import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/models/gacha_box.dart'; // Import GachaBox
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/widgets/equipment_codex_dialog.dart'; // NEW IMPORT

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  // Helper to map rarity to a color (Copied from weapon_info_widget.dart)
  Color _getColorForRarity(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return Colors.grey[400]!;
      case Rarity.uncommon:
        return Colors.green;
      case Rarity.rare:
        return Colors.blue;
      case Rarity.unique:
        return Colors.purple;
      case Rarity.epic:
        return Colors.orange;
      case Rarity.legend:
        return Colors.red;
      case Rarity.demigod:
        return Colors.yellow;
      case Rarity.god:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인벤토리'),
        backgroundColor: Colors.grey[850],
        actions: [
          // NEW ACTIONS BLOCK
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
          return Column(
            children: [
              // Equipped Weapon Section
              _buildWeaponCard(
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
                      weapon,
                      onEquip: () {
                        game.equipWeapon(weapon);
                      },
                    );
                  },
                ),
              ),
              const Divider(color: Colors.yellow),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '보유 상자',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              // Inventory List for Gacha Boxes
              Expanded(
                child: ListView.builder(
                  itemCount: game.player.gachaBoxes.length,
                  itemBuilder: (context, index) {
                    final box = game.player.gachaBoxes[index];
                    return _buildGachaBoxCard(context, box, () {
                      final result = game.openGachaBox(box);
                      _showGachaResultDialog(context, result);
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // NEW: Weapon Image with border
            Container(
              width: 50, // Fixed width for the image container
              height: 50, // Fixed height for the image container
              decoration: BoxDecoration(
                color: Colors.black, // MOVED HERE
                border: Border.all(
                  color: _getColorForRarity(
                    weapon.rarity,
                  ), // Rarity color border
                  width: 2.0, // Border thickness
                ),
                borderRadius: BorderRadius.circular(
                  4.0,
                ), // Slightly rounded corners
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
            const SizedBox(width: 12), // Spacing between image and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${weapon.name} [${weapon.enhancement}][${weapon.transcendence}]${isEquipped ? ' [E]' : ''}',
                  style: TextStyle(
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
                  'Crit: ${weapon.criticalChance * 100}% / x${weapon.criticalDamage}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            if (!isEquipped)
              ElevatedButton(onPressed: onEquip, child: const Text('장착')),
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
      color: box.isBossBox ? Colors.red[800] : Colors.purple[800], // Different color for boss boxes
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
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
                if (box.isBossBox) // Add a visual indicator for boss box
                  const Text(
                    '★ 보스 상자 ★',
                    style: TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            ElevatedButton(onPressed: onOpen, child: const Text('열기')),
          ],
        ),
      ),
    );
  }

  void _showGachaResultDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: const Text('상자 개봉 결과', style: TextStyle(color: Colors.white)),
          content: Text(message, style: const TextStyle(color: Colors.white70)),
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
}
