import 'package:flutter/material.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:provider/provider.dart'; // New import
import 'package:ryan_clicker_rpg/providers/game_provider.dart'; // New import

import 'package:ryan_clicker_rpg/data/weapon_data.dart'; // NEW IMPORT

class WeaponInfoWidget extends StatelessWidget {
  final Weapon weapon;
  const WeaponInfoWidget({super.key, required this.weapon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) =>
              buildWeaponDetailsDialog(dialogContext, weapon),
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
}

Widget buildWeaponDetailsDialog(BuildContext context, Weapon weapon) {
  return AlertDialog(
    backgroundColor: Colors.grey[850],
    title: Text(
      '${weapon.name} +${weapon.enhancement}[${weapon.transcendence}]',
      style: TextStyle(color: WeaponData.getColorForRarity(weapon.rarity)),
    ),
    content: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '등급: ${WeaponData.getKoreanRarity(weapon.rarity)}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            '타입: ${WeaponData.getKoreanWeaponType(weapon.type)}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            '레벨: ${weapon.baseLevel}',
            style: const TextStyle(color: Colors.white70),
          ),
          const Divider(color: Colors.grey),
          Consumer<GameProvider>(
            builder: (context, game, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '데미지: ${weapon.calculatedDamage.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    '공격 속도: ${weapon.speed.toStringAsFixed(2)}',
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
                  Text(
                    '방어력 관통: ${weapon.defensePenetration.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    '더블어택 확률: ${(weapon.doubleAttackChance * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    '적중률: ${(weapon.accuracy * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              );
            },
          ),
          if (weapon.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${weapon.description}',
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
                      '''${skill['skill_name']}
${skill['skill_description']}''',
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
