import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/data/weapon_data.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';

class EquipmentCodexDialog extends StatelessWidget {
  const EquipmentCodexDialog({super.key});

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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: Consumer<GameProvider>(
        builder: (context, game, child) {
          final allWeapons = WeaponData.getAllWeapons();

          // Use acquiredWeaponIdsHistory directly for the count
          final acquiredWeaponsCount =
              game.player.acquiredWeaponIdsHistory.length;

          return Text(
            '장비 도감 ($acquiredWeaponsCount / ${allWeapons.length})',
            style: const TextStyle(color: Colors.white),
          );
        },
      ),
      content: Consumer<GameProvider>(
        builder: (context, game, child) {
          final allWeapons = WeaponData.getAllWeapons();
          allWeapons.sort((a, b) => a.id.compareTo(b.id)); // Sort by ID

          // Use acquiredWeaponIdsHistory directly for checking acquisition
          final acquiredWeaponIds = game.player.acquiredWeaponIdsHistory;

          return SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.8, // 80% of screen width
            height:
                MediaQuery.of(context).size.height *
                0.7, // 70% of screen height
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 items per row
                crossAxisSpacing: 4.0, // Reduced spacing
                mainAxisSpacing: 4.0, // Reduced spacing
                childAspectRatio:
                    0.5, // Adjusted aspect ratio to make items much shorter
              ),
              itemCount: allWeapons.length,
              itemBuilder: (context, index) {
                final weapon = allWeapons[index];
                // Check acquisition directly from history
                final isAcquired = acquiredWeaponIds.contains(weapon.id);

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _getColorForRarity(weapon.rarity),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: ColorFiltered(
                        colorFilter: isAcquired
                            ? const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.multiply,
                              )
                            : const ColorFilter.matrix(<double>[
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ]),
                        child: Image.asset(
                          'images/weapons/common/${weapon.imageName}',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.broken_image,
                              color: Colors.red,
                            );
                          },
                        ),
                      ),
                    ),
                    Text(
                      weapon.name,
                      style: TextStyle(
                        color: isAcquired ? Colors.white : Colors.grey,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Lvl: ${weapon.baseLevel}',
                      style: TextStyle(
                        color: isAcquired ? Colors.white70 : Colors.grey[600],
                        fontSize: 8,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('닫기', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
