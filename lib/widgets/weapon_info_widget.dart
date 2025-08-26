import 'package:flutter/material.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';

class WeaponInfoWidget extends StatelessWidget {
  final Weapon weapon;
  const WeaponInfoWidget({super.key, required this.weapon});

  // Helper to map rarity to a color
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
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _buildWeaponDetailsDialog(context, weapon),
        );
      },
      child: Container(
        color: Colors.grey[800], // Background color for the image container
        padding: const EdgeInsets.all(8.0), // Padding around the image
        child: Center(
          // Center the image within the available space
          child: AspectRatio(
            aspectRatio: 1.0, // Force the image to be square
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: _getColorForRarity(weapon.rarity),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Image.asset(
                'images/weapons/${weapon.imageName}',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image_not_supported, color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeaponDetailsDialog(BuildContext context, Weapon weapon) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: Text(
        weapon.name,
        style: TextStyle(color: _getColorForRarity(weapon.rarity)),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '등급: ${weapon.rarity.toString().split('.').last}',
              style: const TextStyle(color: Colors.white70),
            ),
            const Divider(color: Colors.grey),
            Text(
              '강화: +${weapon.enhancement} / +${weapon.maxEnhancement}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '초월: [${weapon.transcendence}]',
              style: const TextStyle(color: Colors.white),
            ),
            const Divider(color: Colors.grey),
            Text(
              '데미지: ${weapon.calculatedDamage.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '치명타 확률: ${(weapon.criticalChance * 100).toStringAsFixed(2)}%',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '치명타 배율: x${weapon.criticalDamage.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white),
            ),
            if (weapon.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '설명: ${weapon.description}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            if (weapon.skills.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '스킬:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...weapon.skills.map(
                      (skill) => Text(
                        '- ${skill['skill_name']}: ${skill['skill_description']}',
                        style: const TextStyle(color: Colors.cyanAccent),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
