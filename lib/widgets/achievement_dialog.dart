import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/data/achievement_data.dart';
import 'package:ryan_clicker_rpg/models/achievement.dart';
import 'package:ryan_clicker_rpg/models/player.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';

enum AchievementFilter { all, completable, completed }

class AchievementDialog extends StatefulWidget {
  const AchievementDialog({super.key});

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> {
  AchievementFilter _selectedFilter = AchievementFilter.all;

  List<Achievement> _getFilteredAchievements(
      Player player, List<Achievement> achievements) {
    switch (_selectedFilter) {
      case AchievementFilter.completable:
        return achievements
            .where((a) => a.isCompletable(player) && !a.isCompleted)
            .toList();
      case AchievementFilter.completed:
        return achievements.where((a) => a.isCompleted).toList();
      case AchievementFilter.all:
        return achievements;
    }
  }

  @override
  Widget build(BuildContext context) {
    // We listen to the provider once here, but don't rebuild the whole dialog on change
    final gameProvider = Provider.of<GameProvider>(context, listen: false);

    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: const Text('업적', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400, // Increased width to better display rewards
        height: 400,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () =>
                      setState(() => _selectedFilter = AchievementFilter.all),
                  style: TextButton.styleFrom(
                    backgroundColor: _selectedFilter == AchievementFilter.all
                        ? Colors.blue[800]
                        : Colors.transparent,
                  ),
                  child: const Text('모든 업적',
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () => setState(
                      () => _selectedFilter = AchievementFilter.completable),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _selectedFilter == AchievementFilter.completable
                            ? Colors.blue[800]
                            : Colors.transparent,
                  ),
                  child: const Text('완료 가능',
                      style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: () => setState(
                      () => _selectedFilter = AchievementFilter.completed),
                  style: TextButton.styleFrom(
                    backgroundColor:
                        _selectedFilter == AchievementFilter.completed
                            ? Colors.blue[800]
                            : Colors.transparent,
                  ),
                  child:
                      const Text('완료', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            Selector<GameProvider, bool>(
              selector: (_, provider) => provider.hasCompletableAchievements,
              builder: (context, hasCompletableAchievements, child) {
                if (!hasCompletableAchievements) {
                  return const SizedBox.shrink();
                }
                return Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        gameProvider.claimAllCompletableAchievements();
                      },
                      child: const Text('모두 완료'),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Selector<GameProvider, List<Achievement>>(
                selector: (context, provider) => _getFilteredAchievements(
                    provider.player, AchievementData.achievements),
                shouldRebuild: (previous, next) =>
                    !listEquals(previous, next),
                builder: (context, achievementsToDisplay, child) {
                  return ListView.builder(
                    itemCount: achievementsToDisplay.length,
                    itemBuilder: (context, index) {
                      final achievement = achievementsToDisplay[index];
                      // Use a Selector for each item to only rebuild what's necessary
                      return Selector<GameProvider, String>(
                        selector: (context, provider) {
                          // Create a unique "signature" of the achievement's state
                          final player = provider.player;
                          final isCompleted = achievement.isCompleted;
                          final isRewardClaimed = achievement.isRewardClaimed;
                          final progress =
                              achievement.progressText?.call(player) ?? '';
                          return '${achievement.id}-$isCompleted-$isRewardClaimed-$progress';
                        },
                        builder: (context, _, child) {
                          final player = gameProvider.player;
                          final isCompleted = achievement.isCompleted;
                          final isRewardClaimed = achievement.isRewardClaimed;
                          final rewardText = achievement.rewards
                              .map((r) => r.description)
                              .join(', ');

                          return Opacity(
                            opacity: isCompleted && isRewardClaimed ? 0.5 : 1.0,
                            child: ListTile(
                              leading: Icon(
                                Icons.star,
                                color: isCompleted && isRewardClaimed
                                    ? Colors.grey
                                    : Colors.yellow,
                              ),
                              title: Text(
                                achievement.name,
                                style: TextStyle(
                                  color: isCompleted && isRewardClaimed
                                      ? Colors.grey
                                      : Colors.white,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    achievement.description,
                                    style: TextStyle(
                                      color: isCompleted && isRewardClaimed
                                          ? Colors.grey[400]
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (achievement.progressText != null)
                                    Text(
                                      '진행도: ${achievement.progressText!(player)}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (rewardText.isNotEmpty)
                                    Text(
                                      '보상: $rewardText',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: _buildTrailingWidget(
                                  achievement, gameProvider),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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

  Widget _buildTrailingWidget(
    Achievement achievement,
    GameProvider gameProvider,
  ) {
    // This widget will be rebuilt by the parent Selector, which is fine.
    final player = gameProvider.player;
    final bool isCompletable =
        achievement.isCompletable(player) && !achievement.isCompleted;

    if (achievement.isCompleted) {
      if (achievement.isRewardClaimed) {
        return const Icon(Icons.check, color: Colors.green);
      } else {
        return ElevatedButton(
          onPressed: () {
            gameProvider.claimAchievementRewards(achievement);
          },
          child: const Text('보상 받기'),
        );
      }
    } else {
      return ElevatedButton(
        onPressed: isCompletable
            ? () {
                gameProvider.completeAndClaimAchievement(achievement);
              }
            : null, // Disabled if not completable
        child: const Text('완료'),
      );
    }
  }
}

