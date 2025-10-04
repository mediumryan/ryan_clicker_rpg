achievements = [
    {
        "name": "명성 쌓기Ⅰ",
        "count": 1,
        "rewards": [
            {"type": "gold", "quantity": 1000}
        ]
    },
    {
        "name": "명성 쌓기Ⅱ",
        "count": 10,
        "rewards": [
            {"type": "gold", "quantity": 5000},
            {"type": "enhancementStone", "quantity": 5}
        ]
    },
    {
        "name": "명성 쌓기Ⅲ",
        "count": 50,
        "rewards": [
            {"type": "gachaBox", "quantity": 2, "boxType": "rare"}
        ]
    },
    {
        "name": "명성 쌓기Ⅳ",
        "count": 100,
        "rewards": [
            {"type": "gachaBox", "quantity": 1, "boxType": "guaranteedUnique"}
        ]
    },
    {
        "name": "명성 쌓기Ⅴ",
        "count": 200,
        "rewards": [
            {"type": "gachaBox", "quantity": 2, "boxType": "guaranteedUnique"}
        ]
    },
    {
        "name": "명성 쌓기Ⅵ",
        "count": 500,
        "rewards": [
            {"type": "gachaBox", "quantity": 1, "boxType": "guaranteedEpic"}
        ]
    },
    {
        "name": "명성 쌓기Ⅶ",
        "count": 1000,
        "rewards": [
            {"type": "gachaBox", "quantity": 1, "boxType": "guaranteedLegend"}
        ]
    }
]

output = ""

for i, ach in enumerate(achievements):
    rewards_string = []
    for reward in ach["rewards"]:
        if reward["type"] == "gachaBox":
            rewards_string.append('        Reward(type: RewardType.gachaBox, quantity: {}, item: GachaBox(id: \'ach_fame_{}_reward\', boxType: WeaponBoxType.{}, stageLevel: 0))'.format(reward["quantity"], i+1, reward["boxType"]))
        else:
            rewards_string.append('        Reward(type: RewardType.{}, quantity: {})'.format(reward["type"], reward["quantity"]))
    
    rewards_string_joined = "\n".join(rewards_string)

    output += """
    Achievement(
      id: \'ach_fame_{}\',
      name: \'{}\',
      description: \'달성한 업적 {}개\',
      rewards: [
{}
      ],
      isCompletable: (Player player) => player.completedAchievements.length >= {},
      progressText: (Player player) => \'${{player.completedAchievements.length}} / {}\',
    ),""".format(i+1, ach["name"], ach["count"], rewards_string_joined, ach["count"], ach["count"])

with open('assets/data/achievements_fame.txt', 'w', encoding='utf-8') as f:
    f.write(output)

print("Fame achievements generated successfully.")