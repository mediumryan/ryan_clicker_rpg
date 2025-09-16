
import 'package:ryan_clicker_rpg/models/player.dart';
import 'package:ryan_clicker_rpg/models/reward.dart';

class Achievement {
  final String id;
  final String name;
  final String description;
  final List<Reward> rewards;
  bool isCompleted;
  bool _isRewardClaimed; // Private variable to track reward claim status
  final bool Function(Player player) isCompletable; // Function to check if it can be completed
  final String Function(Player player)? progressText;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.rewards,
    this.isCompleted = false,
    bool isRewardClaimed = false, // Initialize in constructor
    required this.isCompletable,
    this.progressText,
  }) : _isRewardClaimed = isRewardClaimed;

  // Public getter for isRewardClaimed
  bool get isRewardClaimed => _isRewardClaimed;

  // Method to claim the reward
  void claimReward() {
    if (isCompleted && !_isRewardClaimed) {
      _isRewardClaimed = true;
    }
  }
}
