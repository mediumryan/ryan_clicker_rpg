import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/screens/blacksmith_screen.dart';
import 'package:ryan_clicker_rpg/screens/inventory_screen.dart';
import 'package:ryan_clicker_rpg/screens/shop_screen.dart';
import 'package:ryan_clicker_rpg/widgets/achievement_dialog.dart';
import 'package:ryan_clicker_rpg/widgets/equipment_codex_dialog.dart';
import 'package:ryan_clicker_rpg/widgets/settings_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[850],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.grey[800]),
                child: const Text(
                  '메뉴',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNavButton(
                  context,
                  icon: Icons.inventory,
                  label: '인벤토리',
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryScreen(),
                      ),
                    );
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.gavel,
                  label: '대장간',
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BlacksmithScreen(),
                      ),
                    );
                  },
                ),
                Selector<GameProvider, bool>(
                  selector: (context, game) => game.hasCompletableAchievements,
                  builder: (context, hasCompletableAchievements, child) {
                    return _buildNavButton(
                      context,
                      icon: Icons.emoji_events,
                      label: '업적',
                      onPressed: () {
                        Navigator.pop(context); // Close the drawer
                        showDialog(
                          context: context,
                          builder: (context) => const AchievementDialog(),
                        );
                      },
                      highlightColor: hasCompletableAchievements
                          ? Colors.yellow
                          : null,
                    );
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.book,
                  label: '도감',
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                    showDialog(
                      context: context,
                      builder: (context) => EquipmentCodexDialog(),
                    );
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.shopping_cart,
                  label: '상점',
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ShopScreen(),
                      ),
                    );
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.public,
                  label: '차원이동',
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                    // TODO: Implement Dimension Shift screen
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.mail,
                  label: '우편함',
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                    // TODO: Implement mailbox functionality
                  },
                ),
                const SizedBox.shrink(),
                const SizedBox.shrink(),
                _buildNavButton(
                  context,
                  icon: Icons.settings,
                  label: '설정',
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                    showDialog(
                      context: context,
                      builder: (context) => const SettingsDialog(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? highlightColor,
  }) {
    return Card(
      color: Colors.grey[800],
      child: InkWell(
        onTap: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: highlightColor ?? Colors.white),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: highlightColor ?? Colors.white70)),
          ],
        ),
      ),
    );
  }
}