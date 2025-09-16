import 'package:ryan_clicker_rpg/models/achievement.dart';
import 'package:ryan_clicker_rpg/models/reward.dart';
import 'package:ryan_clicker_rpg/models/gacha_box.dart';
import 'package:ryan_clicker_rpg/models/player.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart'; // Import Weapon and Rarity
import 'package:ryan_clicker_rpg/data/weapon_data.dart'; // Import WeaponData

class AchievementData {
  static final Map<int, Rarity> _weaponIdToRarityMap = {}; // New map
  static bool _isInitialized = false; // New flag

  static Future<void> initialize() async {
    if (_isInitialized) return;

    await WeaponData.initialize(); // Ensure WeaponData is initialized
    for (final weapon in WeaponData.getAllWeapons()) {
      _weaponIdToRarityMap[weapon.id] = weapon.rarity;
    }
    _isInitialized = true;
  }

  // Helper function to count acquired weapons of a specific rarity
  static int _countAcquiredWeaponsByRarity(Player player, Rarity targetRarity) {
    if (!_isInitialized) {
      // This should not happen if initialize() is called before accessing achievements
      return 0;
    }
    int count = 0;
    for (final weaponId in player.acquiredWeaponIdsHistory) {
      if (_weaponIdToRarityMap[weaponId] == targetRarity) {
        count++;
      }
    }
    return count;
  }

  static final List<Achievement> achievements = [
    // Monster Kill Achievements
    Achievement(
      id: 'ach_kill_001',
      name: '첫 걸음',
      description: '몬스터 1마리 처치',
      rewards: [
        Reward(type: RewardType.gold, quantity: 1000),
        Reward(type: RewardType.enhancementStone, quantity: 1),
      ],
      isCompletable: (Player player) => player.monstersKilled >= 1,
      progressText: (Player player) => '${player.monstersKilled} / 1',
    ),
    Achievement(
      id: 'ach_kill_002',
      name: '몬스터 헌터',
      description: '몬스터 50마리 처치',
      rewards: [
        Reward(type: RewardType.gold, quantity: 5000),
        Reward(type: RewardType.enhancementStone, quantity: 3),
      ],
      isCompletable: (Player player) => player.monstersKilled >= 50,
      progressText: (Player player) => '${player.monstersKilled} / 50',
    ),
    Achievement(
      id: 'ach_kill_003',
      name: '몬스터 헌터 II',
      description: '몬스터 1000마리 처치',
      rewards: [
        Reward(type: RewardType.gold, quantity: 200000),
        Reward(type: RewardType.enhancementStone, quantity: 20),
      ],
      isCompletable: (Player player) => player.monstersKilled >= 1000,
      progressText: (Player player) => '${player.monstersKilled} / 1000',
    ),
    Achievement(
      id: 'ach_kill_004',
      name: '몬스터 헌터 III',
      description: '몬스터 2500마리 처치',
      rewards: [
        Reward(type: RewardType.gold, quantity: 500000),
        Reward(type: RewardType.enhancementStone, quantity: 100),
      ],
      isCompletable: (Player player) => player.monstersKilled >= 2500,
      progressText: (Player player) => '${player.monstersKilled} / 2500',
    ),
    Achievement(
      id: 'ach_kill_005',
      name: '몬스터 헌터 IIII',
      description: '몬스터 5000마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_kill_005-reward',
            boxType: WeaponBoxType.guaranteedEpic,
            stageLevel:
                500, // Fixed stage level as 'player' is not available here
          ),
        ),
      ],
      isCompletable: (Player player) => player.monstersKilled >= 5000,
      progressText: (Player player) => '${player.monstersKilled} / 5000',
    ),

    // Boss Kill Achievements
    Achievement(
      id: 'ach_boss_kill_crab_1',
      name: '맛있는 식재료 I',
      description: '거대 게 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_crab_1-reward',
            boxType: WeaponBoxType.rare, // 희귀한 무기상자
            stageLevel: 50,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_50'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_50'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_crab_10',
      name: '맛있는 식재료 II',
      description: '거대 게 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_crab_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 50,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_50'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_50'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_crab_50',
      name: '맛있는 식재료 III',
      description: '거대 게 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_crab_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 100,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_50'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_50'] ?? 0} / 50',
    ),
    Achievement(
      id: 'ach_boss_kill_boar_1',
      name: '마을의 골칫거리 I',
      description: '정신나간 멧돼지 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_boar_1-reward',
            boxType: WeaponBoxType.rare, // 희귀한 무기상자
            stageLevel: 100,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_100'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_100'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_boar_10',
      name: '마을의 골칫거리 II',
      description: '정신나간 멧돼지 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_boar_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 100,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_100'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_100'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_boar_50',
      name: '마을의 골칫거리 III',
      description: '정신나간 멧돼지 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_boar_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 150,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_100'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_100'] ?? 0} / 50',
    ),
    Achievement(
      id: 'ach_boss_kill_timberwolf_1',
      name: '설산의 정상 I',
      description: '팀버울프 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_timberwolf_1-reward',
            boxType: WeaponBoxType.rare, // 희귀한 무기상자
            stageLevel: 150,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_150'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_150'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_timberwolf_10',
      name: '설산의 정상 II',
      description: '팀버울프 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_timberwolf_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 150,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_150'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_150'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_timberwolf_50',
      name: '설산의 정상 III',
      description: '팀버울프 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_timberwolf_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 200,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_150'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_150'] ?? 0} / 50',
    ),
    Achievement(
      id: 'ach_boss_kill_plaguebat_1',
      name: '감염 대책 I',
      description: '역병박쥐 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_plaguebat_1-reward',
            boxType: WeaponBoxType.rare, // 희귀한 무기상자
            stageLevel: 200,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_200'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_200'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_plaguebat_10',
      name: '감염 대책 II',
      description: '역병박쥐 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_plaguebat_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 200,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_200'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_200'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_plaguebat_50',
      name: '감염 대책 III',
      description: '역병박쥐 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_plaguebat_50-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 250,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_200'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_200'] ?? 0} / 50',
    ),
    Achievement(
      id: 'ach_boss_kill_stagbeetle_1',
      name: '이건 못키우겠는데.. I',
      description: '거대한 사슴벌레 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_stagbeetle_1-reward',
            boxType: WeaponBoxType.rare, // 희귀한 무기상자
            stageLevel: 250,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_250'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_250'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_stagbeetle_10',
      name: '이건 못키우겠는데.. II',
      description: '거대한 사슴벌레 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_stagbeetle_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 250,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_250'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_250'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_stagbeetle_50',
      name: '이건 못키우겠는데.. III',
      description: '거대한 사슴벌레 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_stagbeetle_50-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 300,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_250'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_250'] ?? 0} / 50',
    ),
    Achievement(
      id: 'ach_boss_kill_beaver_1',
      name: '집 부수러 왔습니다 I',
      description: '육식 비버 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_beaver_1-reward',
            boxType: WeaponBoxType.rare, // 희귀한 무기상자
            stageLevel: 300,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_300'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_300'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_beaver_10',
      name: '집 부수러 왔습니다 II',
      description: '육식 비버 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_beaver_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 300,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_300'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_300'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_beaver_50',
      name: '집 부수러 왔습니다 III',
      description: '육식 비버 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_beaver_50-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 350,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_300'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_300'] ?? 0} / 50',
    ),
    Achievement(
      id: 'ach_boss_kill_goblinleader_1',
      name: '고블린 퇴치 I',
      description: '고블린 리더 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_goblinleader_1-reward',
            boxType: WeaponBoxType.rare, // 희귀한 무기상자
            stageLevel: 350,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_350'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_350'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_goblinleader_10',
      name: '고블린 퇴치 II',
      description: '고블린 리더 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_goblinleader_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 350,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_350'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_350'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_goblinleader_50',
      name: '고블린 퇴치 III',
      description: '고블린 리더 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_goblinleader_50-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 400,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_350'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_350'] ?? 0} / 50',
    ),
    Achievement(
      id: 'ach_boss_kill_dwarfleader_1',
      name: '걸리버 여행기 I',
      description: '소인족 리더 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_dwarfleader_1-reward',
            boxType: WeaponBoxType.rare, // 희귀한 무기상자
            stageLevel: 400,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_400'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_400'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_dwarfleader_10',
      name: '걸리버 여행기 II',
      description: '소인족 리더 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_dwarfleader_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 400,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_400'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_400'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_dwarfleader_50',
      name: '걸리버 여행기 III',
      description: '소인족 리더 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_dwarfleader_50-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 450,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_400'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_400'] ?? 0} / 50',
    ), // Lizardman Leader (Stage 450)
    Achievement(
      id: 'ach_boss_kill_lizardman_1',
      name: '도마뱀 사냥꾼 I',
      description: '리자드맨 리더 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_lizardman_1-reward',
            boxType: WeaponBoxType.rare, // 희귀한 무기상자
            stageLevel: 450,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_450'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_450'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_lizardman_10',
      name: '도마뱀 사냥꾼 II',
      description: '리자드맨 리더 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_lizardman_10-reward',
            boxType: WeaponBoxType.shiny, // 빛나는 무기상자
            stageLevel: 450,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_450'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_450'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_lizardman_50',
      name: '도마뱀 사냥꾼 III',
      description: '리자드맨 리더 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_lizardman_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 500,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_450'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_450'] ?? 0} / 50',
    ),

    // Rock Mountain Bone Collector (Stage 500)
    Achievement(
      id: 'ach_boss_kill_bonecollector_1',
      name: '뼈 수집가 I',
      description: '바위산 뼈수집가 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_bonecollector_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 500,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_500'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_500'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_bonecollector_10',
      name: '뼈 수집가 II',
      description: '바위산 뼈수집가 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_bonecollector_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 500,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_500'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_500'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_bonecollector_50',
      name: '뼈 수집가 III',
      description: '바위산 뼈수집가 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_bonecollector_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 550,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_500'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_500'] ?? 0} / 50',
    ),

    // Shadow of Death (Stage 550)
    Achievement(
      id: 'ach_boss_kill_deathshadow_1',
      name: '죽음의 추적자 I',
      description: '죽음의 그림자 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_deathshadow_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 550,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_550'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_550'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_deathshadow_10',
      name: '죽음의 추적자 II',
      description: '죽음의 그림자 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_deathshadow_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 550,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_550'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_550'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_deathshadow_50',
      name: '죽음의 추적자 III',
      description: '죽음의 그림자 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_deathshadow_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 600,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_550'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_550'] ?? 0} / 50',
    ), // The Form of Death (Stage 600)
    Achievement(
      id: 'ach_boss_kill_formofdeath_1',
      name: '죽음의 형상 I',
      description: '죽음의 형태 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_formofdeath_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 600,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_600'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_600'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_formofdeath_10',
      name: '죽음의 형상 II',
      description: '죽음의 형태 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_formofdeath_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 600,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_600'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_600'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_formofdeath_50',
      name: '죽음의 형상 III',
      description: '죽음의 형태 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_formofdeath_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 650,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_600'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_600'] ?? 0} / 50',
    ),

    // Strange Village Elder (Stage 650)
    Achievement(
      id: 'ach_boss_kill_strangevillager_1',
      name: '수상한 증언 I',
      description: '이상한 마을 촌장 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_strangevillager_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 650,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_650'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_650'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_strangevillager_10',
      name: '수상한 증언 II',
      description: '이상한 마을 촌장 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_strangevillager_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 650,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_650'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_650'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_strangevillager_50',
      name: '수상한 증언 III',
      description: '이상한 마을 촌장 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_strangevillager_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 700,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_650'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_650'] ?? 0} / 50',
    ),

    // Elf Elder (Stage 700)
    Achievement(
      id: 'ach_boss_kill_elfelder_1',
      name: '숲의 수호자 I',
      description: '엘프 촌장 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_elfelder_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 700,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_700'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_700'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_elfelder_10',
      name: '숲의 수호자 II',
      description: '엘프 촌장 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_elfelder_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 700,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_700'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_700'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_elfelder_50',
      name: '숲의 수호자 III',
      description: '엘프 촌장 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_elfelder_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 750,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_700'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_700'] ?? 0} / 50',
    ), // Ghostly Tree Spirit (Stage 750)
    Achievement(
      id: 'ach_boss_kill_treespririt_1',
      name: '숲의 침묵 I',
      description: '귀신들린 나무정령 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_treespririt_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 750,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_750'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_750'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_treespririt_10',
      name: '숲의 침묵 II',
      description: '귀신들린 나무정령 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_treespririt_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 750,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_750'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_750'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_treespririt_50',
      name: '숲의 침묵 III',
      description: '귀신들린 나무정령 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_treespririt_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 800,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_750'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_750'] ?? 0} / 50',
    ),

    // Druid (Stage 800)
    Achievement(
      id: 'ach_boss_kill_druid_1',
      name: '자연의 지배자 I',
      description: '드루이드 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_druid_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 800,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_800'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_800'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_druid_10',
      name: '자연의 지배자 II',
      description: '드루이드 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_druid_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 800,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_800'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_800'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_druid_50',
      name: '자연의 지배자 III',
      description: '드루이드 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_druid_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 850,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_800'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_800'] ?? 0} / 50',
    ),

    // Fire Elemental (Stage 850)
    Achievement(
      id: 'ach_boss_kill_fireelemental_1',
      name: '타오르는 불꽃 I',
      description: '불의 정령 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_fireelemental_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 850,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_850'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_850'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_fireelemental_10',
      name: '타오르는 불꽃 II',
      description: '불의 정령 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_fireelemental_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 850,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_850'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_850'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_fireelemental_50',
      name: '타오르는 불꽃 III',
      description: '불의 정령 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_fireelemental_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 900,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_850'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_850'] ?? 0} / 50',
    ), // Rock Mountain Butcher (Stage 900)
    Achievement(
      id: 'ach_boss_kill_rockmountainbutcher_1',
      name: '바위산의 증오 I',
      description: '바위산 학살자 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_rockmountainbutcher_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 900,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_900'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_900'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_rockmountainbutcher_10',
      name: '바위산의 증오 II',
      description: '바위산 학살자 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_rockmountainbutcher_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 900,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_900'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_900'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_rockmountainbutcher_50',
      name: '바위산의 증오 III',
      description: '바위산 학살자 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_rockmountainbutcher_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 950,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_900'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_900'] ?? 0} / 50',
    ),

    // Cannibal Boar (Stage 950)
    Achievement(
      id: 'ach_boss_kill_cannibalboar_1',
      name: '사냥꾼의 역습 I',
      description: '식인 멧돼지 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_cannibalboar_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 950,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_950'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_950'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_cannibalboar_10',
      name: '사냥꾼의 역습 II',
      description: '식인 멧돼지 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_cannibalboar_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 950,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_950'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_950'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_cannibalboar_50',
      name: '사냥꾼의 역습 III',
      description: '식인 멧돼지 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_cannibalboar_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1000,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_950'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_950'] ?? 0} / 50',
    ),

    // Paladin (Stage 1000)
    Achievement(
      id: 'ach_boss_kill_paladin_1',
      name: '빛의 심판자 I',
      description: '팔라딘 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_paladin_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1000,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1000'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1000'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_paladin_10',
      name: '빛의 심판자 II',
      description: '팔라딘 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_paladin_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1000,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1000'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1000'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_paladin_50',
      name: '빛의 심판자 III',
      description: '팔라딘 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_paladin_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1050,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1000'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1000'] ?? 0} / 50',
    ), // Archbishop of the Holy Nation (Stage 1050)
    Achievement(
      id: 'ach_boss_kill_archbishop_1',
      name: '신앙의 위기 I',
      description: '신성국 대주교 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_archbishop_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1050,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1050'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1050'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_archbishop_10',
      name: '신앙의 위기 II',
      description: '신성국 대주교 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_archbishop_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1050,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1050'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1050'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_archbishop_50',
      name: '신앙의 위기 III',
      description: '신성국 대주교 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_archbishop_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1100,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1050'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1050'] ?? 0} / 50',
    ),

    // Archangel (Stage 1100)
    Achievement(
      id: 'ach_boss_kill_archangel_1',
      name: '타락한 천사 I',
      description: '천사장 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_archangel_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1100,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1100'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1100'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_archangel_10',
      name: '타락한 천사 II',
      description: '천사장 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_archangel_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1100,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1100'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1100'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_archangel_50',
      name: '타락한 천사 III',
      description: '천사장 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_archangel_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1150,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1100'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1100'] ?? 0} / 50',
    ),

    // Brainwashed Elder (Stage 1150)
    Achievement(
      id: 'ach_boss_kill_brainwashedelder_1',
      name: '비극의 시작 I',
      description: '세뇌된 촌장 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_brainwashedelder_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1150,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1150'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1150'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_brainwashedelder_10',
      name: '비극의 시작 II',
      description: '세뇌된 촌장 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_brainwashedelder_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1150,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1150'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1150'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_brainwashedelder_50',
      name: '비극의 시작 III',
      description: '세뇌된 촌장 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_brainwashedelder_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1200,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1150'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1150'] ?? 0} / 50',
    ), // Giant Mummy (Stage 1200)
    Achievement(
      id: 'ach_boss_kill_giantmummy_1',
      name: '영원한 잠 I',
      description: '거대한 미라 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_giantmummy_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1200,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1200'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1200'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_giantmummy_10',
      name: '영원한 잠 II',
      description: '거대한 미라 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_giantmummy_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1200,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1200'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1200'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_giantmummy_50',
      name: '영원한 잠 III',
      description: '거대한 미라 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_giantmummy_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1250,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1200'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1200'] ?? 0} / 50',
    ),

    // Running Zombie (Stage 1250)
    Achievement(
      id: 'ach_boss_kill_runningzombie_1',
      name: '숨 막히는 추격 I',
      description: '뛰는 좀비 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_runningzombie_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1250,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1250'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1250'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_runningzombie_10',
      name: '숨 막히는 추격 II',
      description: '뛰는 좀비 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_runningzombie_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1250,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1250'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1250'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_runningzombie_50',
      name: '숨 막히는 추격 III',
      description: '뛰는 좀비 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_runningzombie_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1300,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1250'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1250'] ?? 0} / 50',
    ),

    // Grave Digger (Stage 1300)
    Achievement(
      id: 'ach_boss_kill_gravedigger_1',
      name: '무덤의 주인 I',
      description: '무덤지기 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_gravedigger_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1300,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1300'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1300'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_gravedigger_10',
      name: '무덤의 주인 II',
      description: '무덤지기 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_gravedigger_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1300,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1300'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1300'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_gravedigger_50',
      name: '무덤의 주인 III',
      description: '무덤지기 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_gravedigger_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1350,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1300'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1300'] ?? 0} / 50',
    ),
    // Sham Ogure (Stage 1350)
    Achievement(
      id: 'ach_boss_kill_shamogure_1',
      name: '샴 쌍둥이 I',
      description: '샴오우거 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_shamogure_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1350,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1350'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1350'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_shamogure_10',
      name: '샴 쌍둥이 II',
      description: '샴오우거 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_shamogure_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1350,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1350'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1350'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_shamogure_50',
      name: '샴 쌍둥이 III',
      description: '샴오우거 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_shamogure_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1400,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1350'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1350'] ?? 0} / 50',
    ),

    // Death Itself (Stage 1400)
    Achievement(
      id: 'ach_boss_kill_deathitself_1',
      name: '죽음의 초월자 I',
      description: '죽음의 그 자체 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_deathitself_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1400,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1400'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1400'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_deathitself_10',
      name: '죽음의 초월자 II',
      description: '죽음의 그 자체 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_deathitself_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1400,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1400'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1400'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_deathitself_50',
      name: '죽음의 초월자 III',
      description: '죽음의 그 자체 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_deathitself_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1450,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1400'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1400'] ?? 0} / 50',
    ),

    // Merman Leader (Stage 1450)
    Achievement(
      id: 'ach_boss_kill_mermanleader_1',
      name: '심해의 지배자 I',
      description: '어인족 리더 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_mermanleader_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1450,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1450'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1450'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_mermanleader_10',
      name: '심해의 지배자 II',
      description: '어인족 리더 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_mermanleader_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1450,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1450'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1450'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_mermanleader_50',
      name: '심해의 지배자 III',
      description: '어인족 리더 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_mermanleader_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1500,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1450'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1450'] ?? 0} / 50',
    ), // Necromancer (Stage 1500)
    Achievement(
      id: 'ach_boss_kill_necromancer_1',
      name: '어둠의 지휘자 I',
      description: '네크로맨서 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_necromancer_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1500,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1500'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1500'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_necromancer_10',
      name: '어둠의 지휘자 II',
      description: '네크로맨서 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_necromancer_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1500,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1500'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1500'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_necromancer_50',
      name: '어둠의 지휘자 III',
      description: '네크로맨서 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_necromancer_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1550,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1500'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1500'] ?? 0} / 50',
    ),

    // Herald of Death (Stage 1550)
    Achievement(
      id: 'ach_boss_kill_heraldofdeath_1',
      name: '심연의 목소리 I',
      description: '죽음의 인도자 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_heraldofdeath_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1550,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1550'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1550'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_heraldofdeath_10',
      name: '심연의 목소리 II',
      description: '죽음의 인도자 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_heraldofdeath_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1550,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1550'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1550'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_heraldofdeath_50',
      name: '심연의 목소리 III',
      description: '죽음의 인도자 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_heraldofdeath_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1600,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1550'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1550'] ?? 0} / 50',
    ),

    // Lesser Demon Servant (Stage 1600)
    Achievement(
      id: 'ach_boss_kill_lesserdemonservant_1',
      name: '악의의 시작 I',
      description: '하급 악마 시종 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_lesserdemonservant_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1600,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1600'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1600'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_lesserdemonservant_10',
      name: '악의의 시작 II',
      description: '하급 악마 시종 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_lesserdemonservant_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1600,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1600'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1600'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_lesserdemonservant_50',
      name: '악의의 시작 III',
      description: '하급 악마 시종 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_lesserdemonservant_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1650,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1600'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1600'] ?? 0} / 50',
    ),
    // Lesser Demon (Stage 1650)
    Achievement(
      id: 'ach_boss_kill_lesserdemon_1',
      name: '어둠의 권속 I',
      description: '하급 악마 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_lesserdemon_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1650,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1650'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1650'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_lesserdemon_10',
      name: '어둠의 권속 II',
      description: '하급 악마 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_lesserdemon_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1650,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1650'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1650'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_lesserdemon_50',
      name: '어둠의 권속 III',
      description: '하급 악마 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_lesserdemon_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1700,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1650'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1650'] ?? 0} / 50',
    ),

    // Evil (Stage 1700)
    Achievement(
      id: 'ach_boss_kill_evil_1',
      name: '절대악의 사자 I',
      description: '악의 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_evil_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1700,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1700'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1700'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_evil_10',
      name: '절대악의 사자 II',
      description: '악의 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_evil_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1700,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1700'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1700'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_evil_50',
      name: '절대악의 사자 III',
      description: '악의 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_evil_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1750,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1700'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1700'] ?? 0} / 50',
    ),

    // Despair (Stage 1750)
    Achievement(
      id: 'ach_boss_kill_despair_1',
      name: '희망의 끝 I',
      description: '절망 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_despair_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1750,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1750'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1750'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_despair_10',
      name: '희망의 끝 II',
      description: '절망 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_despair_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1750,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1750'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1750'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_despair_50',
      name: '희망의 끝 III',
      description: '절망 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_despair_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1800,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1750'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1750'] ?? 0} / 50',
    ), // Demon King (Stage 1800)
    Achievement(
      id: 'ach_boss_kill_demonking_1',
      name: '마계의 지배자 I',
      description: '마왕 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_demonking_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1800,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1800'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1800'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_demonking_10',
      name: '마계의 지배자 II',
      description: '마왕 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_demonking_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1800,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1800'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1800'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_demonking_50',
      name: '마계의 지배자 III',
      description: '마왕 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_demonking_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1850,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1800'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1800'] ?? 0} / 50',
    ),

    // Baby Wyvern (Stage 1850)
    Achievement(
      id: 'ach_boss_kill_babywyvern_1',
      name: '비룡의 후예 I',
      description: '새끼 와이번 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_babywyvern_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1850,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1850'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1850'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_babywyvern_10',
      name: '비룡의 후예 II',
      description: '새끼 와이번 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_babywyvern_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1850,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1850'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1850'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_babywyvern_50',
      name: '비룡의 후예 III',
      description: '새끼 와이번 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_babywyvern_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1900,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1850'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1850'] ?? 0} / 50',
    ),

    // Venom Drake (Stage 1900)
    Achievement(
      id: 'ach_boss_kill_venomdrake_1',
      name: '독기의 군주 I',
      description: '베놈 드레이크 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_venomdrake_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1900,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1900'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1900'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_venomdrake_10',
      name: '독기의 군주 II',
      description: '베놈 드레이크 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_venomdrake_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1900,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1900'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1900'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_venomdrake_50',
      name: '독기의 군주 III',
      description: '베놈 드레이크 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_venomdrake_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1950,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1900'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1900'] ?? 0} / 50',
    ),
    // Red Dragon (Stage 1950)
    Achievement(
      id: 'ach_boss_kill_reddragon_1',
      name: '화염의 심장 I',
      description: '레드 드래곤 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_reddragon_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 1950,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1950'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1950'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_reddragon_10',
      name: '화염의 심장 II',
      description: '레드 드래곤 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_reddragon_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 1950,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1950'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1950'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_reddragon_50',
      name: '화염의 심장 III',
      description: '레드 드래곤 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_reddragon_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 2000,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_1950'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_1950'] ?? 0} / 50',
    ),

    // Gold Dragon (Stage 2000)
    Achievement(
      id: 'ach_boss_kill_golddragon_1',
      name: '용의 왕 I',
      description: '골드 드래곤 1마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_golddragon_1-reward',
            boxType: WeaponBoxType.rare,
            stageLevel: 2000,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_2000'] ?? 0) >= 1,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_2000'] ?? 0} / 1',
    ),
    Achievement(
      id: 'ach_boss_kill_golddragon_10',
      name: '용의 왕 II',
      description: '골드 드래곤 10마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 1,
          item: GachaBox(
            id: 'ach_boss_kill_golddragon_10-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 2000,
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_2000'] ?? 0) >= 10,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_2000'] ?? 0} / 10',
    ),
    Achievement(
      id: 'ach_boss_kill_golddragon_50',
      name: '용의 왕 III',
      description: '골드 드래곤 50마리 처치',
      rewards: [
        Reward(
          type: RewardType.gachaBox,
          quantity: 2,
          item: GachaBox(
            id: 'ach_boss_kill_golddragon_50-reward',
            boxType: WeaponBoxType.shiny,
            stageLevel: 2000, // 최종 보상 스테이지 레벨
          ),
        ),
      ],
      isCompletable: (Player player) =>
          (player.defeatedBosses['boss_stage_2000'] ?? 0) >= 50,
      progressText: (Player player) =>
          '${player.defeatedBosses['boss_stage_2000'] ?? 0} / 50',
    ),

    // Progression Achievements
    Achievement(
      id: 'ach_stage_001',
      name: '탐험가',
      description: '100 스테이지 도달',
      rewards: [Reward(type: RewardType.gold, quantity: 5000)],
      isCompletable: (Player player) => player.highestStageCleared >= 100,
      progressText: (Player player) => '${player.highestStageCleared} / 100',
    ),
    Achievement(
      id: 'ach_stage_002',
      name: '정복자',
      description: '500 스테이지 도달',
      rewards: [Reward(type: RewardType.enhancementStone, quantity: 1000)],
      isCompletable: (Player player) => player.highestStageCleared >= 500,
      progressText: (Player player) => '${player.highestStageCleared} / 500',
    ),

    // Gold Achievements
    Achievement(
      id: 'ach_gold_001',
      name: '부자',
      description: '골드 1,000,000 보유',
      rewards: [Reward(type: RewardType.enhancementStone, quantity: 100)],
      isCompletable: (Player player) => player.gold >= 1000000,
      progressText: (Player player) => '${player.gold.floor()} / 1000000',
    ),
    Achievement(
      id: 'ach_gold_002',
      name: '백만장자',
      description: '총 골드 100,000,000 획득',
      rewards: [Reward(type: RewardType.transcendenceStone, quantity: 10)],
      isCompletable: (Player player) => player.totalGoldEarned >= 100000000,
      progressText: (Player player) =>
          '${player.totalGoldEarned.floor()} / 100000000',
    ),

    // Enhancement & Transcendence Achievements
    Achievement(
      id: 'ach_enhance_001',
      name: '파괴의 신',
      description: '강화 실패로 무기 10회 파괴',
      rewards: [Reward(type: RewardType.enhancementStone, quantity: 1000)],
      isCompletable: (Player player) => player.weaponDestructionCount >= 10,
      progressText: (Player player) => '${player.weaponDestructionCount} / 10',
    ),
    Achievement(
      id: 'ach_transcend_001',
      name: '한계 돌파',
      description: '무기 초월 5회 성공',
      rewards: [Reward(type: RewardType.transcendenceStone, quantity: 50)],
      isCompletable: (Player player) => player.transcendenceSuccessCount >= 5,
      progressText: (Player player) =>
          '${player.transcendenceSuccessCount} / 5',
    ),

    // Collection Achievements
    Achievement(
      id: 'ach_collect_001',
      name: '수집가',
      description: '무기 50종류 수집',
      rewards: [Reward(type: RewardType.gold, quantity: 50000)],
      isCompletable: (Player player) =>
          player.acquiredWeaponIdsHistory.length >= 50,
      progressText: (Player player) =>
          '${player.acquiredWeaponIdsHistory.length} / 50',
    ),
    // Manually defined collection achievements
    Achievement(
      id: 'ach_collect_common_1',
      name: '일반 무기 수집가 I',
      description: '일반 무기 1개 수집',
      rewards: [Reward(type: RewardType.gold, quantity: 100)],
      isCompletable: (Player player) =>
          _countAcquiredWeaponsByRarity(player, Rarity.common) >= 1,
      progressText: (Player player) =>
          '${_countAcquiredWeaponsByRarity(player, Rarity.common)} / 1',
    ),
    Achievement(
      id: 'ach_collect_common_10',
      name: '일반 무기 수집가 II',
      description: '일반 무기 10개 수집',
      rewards: [Reward(type: RewardType.gold, quantity: 1000)],
      isCompletable: (Player player) =>
          _countAcquiredWeaponsByRarity(player, Rarity.common) >= 10,
      progressText: (Player player) =>
          '${_countAcquiredWeaponsByRarity(player, Rarity.common)} / 10',
    ),
    Achievement(
      id: 'ach_collect_uncommon_1',
      name: '고급 무기 수집가 I',
      description: '고급 무기 1개 수집',
      rewards: [Reward(type: RewardType.gold, quantity: 500)],
      isCompletable: (Player player) =>
          _countAcquiredWeaponsByRarity(player, Rarity.uncommon) >= 1,
      progressText: (Player player) =>
          '${_countAcquiredWeaponsByRarity(player, Rarity.uncommon)} / 1',
    ),

    // Click Achievements
    Achievement(
      id: 'ach_click_001',
      name: '클릭의 달인',
      description: '10,000번 클릭',
      rewards: [Reward(type: RewardType.gold, quantity: 10000)],
      isCompletable: (Player player) => player.totalClicks >= 10000,
      progressText: (Player player) => '${player.totalClicks} / 10000',
    ),
  ];
}
