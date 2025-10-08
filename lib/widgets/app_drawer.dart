import 'package:ryan_clicker_rpg/screens/hero_skill_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/screens/blacksmith_screen.dart';
import 'package:ryan_clicker_rpg/screens/inventory_screen.dart';
import 'package:ryan_clicker_rpg/screens/shop_screen.dart';
import 'package:ryan_clicker_rpg/widgets/achievement_dialog.dart';
import 'package:ryan_clicker_rpg/widgets/equipment_codex_dialog.dart';
import 'package:ryan_clicker_rpg/widgets/settings_dialog.dart';
import 'package:ryan_clicker_rpg/models/difficulty.dart';
import 'package:ryan_clicker_rpg/data/difficulty_data.dart';

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
                _buildNavButton(
                  context,
                  icon: Icons.person,
                  label: '용사',
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HeroSkillScreen(),
                      ),
                    );
                  },
                ),
                _buildNavButton(
                  context,
                  icon: Icons.stairs_outlined,
                  label: '난이도',
                  onPressed: () {
                    Navigator.pop(context); // Close the drawer
                    _showDifficultyDialog(context);
                  },
                ),
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

  void _showDifficultyDialog(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context, listen: false);
    final highestUnlocked = gameProvider.player.highestDifficultyUnlocked;
    final currentDifficulty = gameProvider.player.currentDifficulty;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('난이도 선택', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Difficulty.values.map((difficulty) {
                final bool isUnlocked = difficulty.index <= highestUnlocked.index;
                final bool isCurrent = difficulty == currentDifficulty;

                return ListTile(
                  title: Text(
                    DifficultyData.getDifficultyName(difficulty),
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.grey[600],
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isCurrent
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                      : null,
                  onTap: isUnlocked && !isCurrent
                      ? () {
                          _showDifficultyConfirmationDialog(
                              dialogContext, difficulty, gameProvider);
                        }
                      : null,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  void _showDifficultyConfirmationDialog(
      BuildContext listDialogContext, Difficulty difficulty, GameProvider gameProvider) {
    showDialog(
      context: listDialogContext,
      builder: (BuildContext confirmDialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('난이도 변경 확인', style: TextStyle(color: Colors.white)),
          content: Text(
            '${DifficultyData.getDifficultyName(difficulty)} 난이도로 변경하시겠습니까?\n\n스테이지 진행 상황이 1단계로 초기화됩니다.\n(보유한 재화와 아이템은 유지됩니다.)',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(confirmDialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                gameProvider.setDifficulty(difficulty);
                Navigator.of(confirmDialogContext).pop(); // Close confirmation dialog
                Navigator.of(listDialogContext).pop(); // Close list dialog
              },
              child: const Text('확인', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}