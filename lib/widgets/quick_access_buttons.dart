import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/screens/blacksmith_screen.dart';
import 'package:ryan_clicker_rpg/screens/inventory_screen.dart';
import 'package:ryan_clicker_rpg/widgets/achievement_dialog.dart';

class QuickAccessButtons extends StatelessWidget {
  const QuickAccessButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisSpacing = 4.0;
        final mainAxisSpacing = 4.0;
        final itemWidth = (constraints.maxWidth - crossAxisSpacing) / 2;
        final itemHeight = (constraints.maxHeight - mainAxisSpacing) / 2;
        final childAspectRatio = itemWidth / itemHeight;

        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: [
            _buildButton(
              context,
              icon: Icons.inventory,
              label: '인벤토리',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InventoryScreen(),
                  ),
                );
              },
            ),
            _buildButton(
              context,
              icon: Icons.gavel,
              label: '대장간',
              onPressed: () {
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
                return _buildButton(
                  context,
                  icon: Icons.emoji_events,
                  label: '업적',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AchievementDialog(),
                    );
                  },
                  highlightColor:
                      hasCompletableAchievements ? Colors.yellow : null,
                );
              },
            ),
            _buildButton(
              context,
              icon: Icons.public,
              label: '차원이동',
              onPressed: () {
                // TODO: Implement Dimension Shift screen
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(
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
            Icon(icon, size: 24, color: highlightColor ?? Colors.white),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(label,
                  style: TextStyle(color: highlightColor ?? Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}