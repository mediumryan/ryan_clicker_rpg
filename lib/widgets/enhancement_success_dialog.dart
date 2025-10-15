import 'package:flutter/material.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';

class EnhancementSuccessDialog extends StatelessWidget {
  final Weapon weapon;
  final Map<String, dynamic> oldStats;
  final Map<String, dynamic> newStats;

  const EnhancementSuccessDialog({
    super.key,
    required this.weapon,
    required this.oldStats,
    required this.newStats,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: Text(
        '강화 성공! +${weapon.enhancement}',
        style: const TextStyle(color: Colors.yellow),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: Image.asset(
                  'assets/images/weapons/${weapon.imageName}',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              weapon.name,
              style: TextStyle(
                color: WeaponData.getColorForRarity(weapon.rarity),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.grey),
            _buildStatRow('공격력', oldStats['damage'], newStats['damage']),
            _buildStatRow(
              '공격속도',
              oldStats['attackSpeed'],
              newStats['attackSpeed'],
            ),
            _buildStatRow(
              '치명타 배율',
              oldStats['critDamage'],
              newStats['critDamage'],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('확인'),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, double oldValue, double newValue) {
    final difference = newValue - oldValue;
    String valueStr = newValue.toStringAsFixed(2);
    String diffStr = difference > 0.001
        ? ' (+${difference.toStringAsFixed(2)})'
        : '';

    if (label == '공격력') {
      valueStr = newValue.toStringAsFixed(0);
      diffStr = difference > 0 ? ' (+${difference.toStringAsFixed(0)})' : '';
    } else if (label == '치명타 배율') {
      valueStr = 'x${newValue.toStringAsFixed(2)}';
      diffStr = difference > 0.001
          ? ' (+${difference.toStringAsFixed(2)})'
          : '';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(color: Colors.white70)),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 16),
              children: [
                TextSpan(text: valueStr),
                if (diffStr.isNotEmpty)
                  TextSpan(
                    text: diffStr,
                    style: const TextStyle(color: Colors.yellow),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
