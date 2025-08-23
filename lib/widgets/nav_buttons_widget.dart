import 'package:flutter/material.dart';
import 'package:ryan_clicker_rpg/screens/blacksmith_screen.dart';
import 'package:ryan_clicker_rpg/screens/inventory_screen.dart';
import 'package:ryan_clicker_rpg/screens/shop_screen.dart';

class NavButtonsWidget extends StatelessWidget {
  const NavButtonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[850],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InventoryScreen(),
                ),
              );
            },
            child: const Text('인벤토리'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlacksmithScreen(),
                ),
              );
            },
            child: const Text('대장간'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ShopScreen()),
              );
            },
            child: const Text('상점'),
          ),
        ],
      ),
    );
  }
}
