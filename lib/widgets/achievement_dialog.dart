
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/models/achievement.dart';
import 'package:ryan_clicker_rpg/data/achievement_data.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';
import 'package:ryan_clicker_rpg/models/player.dart';

enum AchievementFilter { all, completable, completed }

class AchievementDialog extends StatefulWidget {
  const AchievementDialog({super.key});

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> {
  AchievementFilter _selectedFilter = AchievementFilter.all;
  late List<Achievement> _achievements;

  @override
  void initState() {
    super.initState();
    // It's often better to get the source of truth from a provider if it can change,
    // but for this case, we'll work with a local copy from static data.
    _achievements = AchievementData.achievements;
  }

  List<Achievement> _getFilteredAchievements(Player player) {
    switch (_selectedFilter) {
      case AchievementFilter.completable:
        return _achievements
            .where((a) => a.isCompletable(player) && !a.isCompleted)
            .toList();
      case AchievementFilter.completed:
        return _achievements.where((a) => a.isCompleted).toList();
      case AchievementFilter.all:
        return _achievements;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final achievementsToDisplay = _getFilteredAchievements(gameProvider.player);

    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: const Text(
        '업적',
        style: TextStyle(color: Colors.white),
      ),
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
                  child: const Text('모든 업적', style: TextStyle(color: Colors.white)),
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
                  child: const Text('완료 가능', style: TextStyle(color: Colors.white)),
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
                  child: const Text('완료', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: ListView.builder(
                itemCount: achievementsToDisplay.length,
                itemBuilder: (context, index) {
                  final achievement = achievementsToDisplay[index];
                  final bool isCompleted = achievement.isCompleted;
                  final bool isRewardClaimed = achievement.isRewardClaimed;

                  final rewardText = achievement.rewards.map((r) => r.description).join(', ');

                  return Opacity(
                    opacity: isCompleted && isRewardClaimed ? 0.5 : 1.0,
                    child: ListTile(
                      leading: Icon(Icons.star, color: isCompleted && isRewardClaimed ? Colors.grey : Colors.yellow),
                      title: Text(achievement.name, style: TextStyle(color: isCompleted && isRewardClaimed ? Colors.grey : Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(achievement.description, style: TextStyle(color: isCompleted && isRewardClaimed ? Colors.grey[400] : Colors.grey)),
                          if (achievement.progressText != null)
                            Text('진행도: ${achievement.progressText!(gameProvider.player)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          if (rewardText.isNotEmpty)
                            Text('보상: $rewardText', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                        ],
                      ),
                      trailing: _buildTrailingWidget(achievement, gameProvider),
                    ),
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

  Widget _buildTrailingWidget(Achievement achievement, GameProvider gameProvider) {
    final bool isCompletable = achievement.isCompletable(gameProvider.player) && !achievement.isCompleted;

    if (achievement.isCompleted) {
      if (achievement.isRewardClaimed) {
        return const Icon(Icons.check, color: Colors.green);
      } else {
        return ElevatedButton(
          onPressed: () {
            setState(() {
              gameProvider.claimAchievementRewards(achievement);
            });
          },
          child: const Text('보상 받기'),
        );
      }
    } else {
      return ElevatedButton(
        onPressed: isCompletable
            ? () {
                setState(() {
                  achievement.isCompleted = true;
                  // If there are no rewards, claim it immediately
                  if (achievement.rewards.isEmpty) {
                    achievement.claimReward();
                  }
                });
              }
            : null, // Disabled if not completable
        child: const Text('완료'),
      );
    }
  }
}
