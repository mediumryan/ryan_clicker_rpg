import 'dart:math';
import 'package:ryan_clicker_rpg/models/monster.dart';

class MonsterData {
  static final List<Map<String, dynamic>> _monsterList = [
    // imageName should correspond to a file in assets/images/monsters/

    // 시작의 마을 (1~50)
    {'name': '병아리', 'imageName': 'chick.gif', 'startStage': 1, 'endStage': 10, 'def': 0},
    {'name': '닭', 'imageName': 'chicken.gif', 'startStage': 11, 'endStage': 20, 'def': 0},
    {'name': '개구리', 'imageName': 'frog.gif', 'startStage': 21, 'endStage': 30, 'def': 0},
    {'name': '두꺼비', 'imageName': 'toad.gif', 'startStage': 31, 'endStage': 40, 'def': 1},
    {'name': '거위', 'imageName': 'goose.gif', 'startStage': 41, 'endStage': 49, 'def': 1},
    {
      'name': '거대 게',
      'imageName': 'giant_crab.gif',
      'startStage': 50,
      'endStage': 50,
      'def': 3,
      'isBoss': true,
    },

    // 시작의 마을 외곽 (51~100)
    {'name': '거북이', 'imageName': 'turtle.gif', 'startStage': 51, 'endStage': 60, 'def': 2},
    {'name': '고양이', 'imageName': 'cat.gif', 'startStage': 61, 'endStage': 70, 'def': 1},
    {'name': '돼지', 'imageName': 'pig.gif', 'startStage': 71, 'endStage': 80, 'def': 2},
    {'name': '스컹크', 'imageName': 'skunk.gif', 'startStage': 81, 'endStage': 90, 'def': 2},
    {'name': '호저', 'imageName': 'porcupine.gif', 'startStage': 91, 'endStage': 99, 'def': 2},
    {
      'name': '정신나간 멧돼지',
      'imageName': 'crazed_boar.gif',
      'startStage': 100,
      'endStage': 100,
      'def': 4,
      'isBoss': true,
    },

    // 설산 입구 (101~150)
    {'name': '호저', 'imageName': 'porcupine.gif', 'startStage': 101, 'endStage': 110, 'def': 2},
    {'name': '정신나간 멧돼지', 'imageName': 'crazed_boar.gif', 'startStage': 111, 'endStage': 120, 'def': 3},
    {'name': '설산여우', 'imageName': 'snow_fox.gif', 'startStage': 121, 'endStage': 130, 'def': 3},
    {'name': '산양', 'imageName': 'mountain_goat.gif', 'startStage': 131, 'endStage': 140, 'def': 3},
    {'name': '설산여우', 'imageName': 'snow_fox.gif', 'startStage': 141, 'endStage': 149, 'def': 4},
    {
      'name': '팀버울프',
      'imageName': 'timber_wolf.gif',
      'startStage': 150,
      'endStage': 150,
      'def': 5,
      'isBoss': true,
    },

    // 어두운 동굴 초입(151~200)
    {'name': '움직이는 번데기', 'imageName': 'moving_pupa.gif', 'startStage': 151, 'endStage': 160, 'def': 3},
    {'name': '굶주린 진드기', 'imageName': 'hungry_tick.gif', 'startStage': 161, 'endStage': 170, 'def': 3},
    {'name': '거대 진드기', 'imageName': 'giant_tick.gif', 'startStage': 171, 'endStage': 180, 'def': 4},
    {'name': '빈대', 'imageName': 'bedbug.gif', 'startStage': 181, 'endStage': 190, 'def': 4},
    {'name': '박쥐', 'imageName': 'bat.gif', 'startStage': 191, 'endStage': 199, 'def': 4},
    {
      'name': '역병박쥐',
      'imageName': 'plague_bat.gif',
      'startStage': 200,
      'endStage': 200,
      'def': 7,
      'isBoss': true,
    },

    // 어두운 동굴 깊은 곳 (201~250)
    {'name': '병정개미', 'imageName': 'soldier_ant.gif', 'startStage': 201, 'endStage': 210, 'def': 5},
    {'name': '맹독개미', 'imageName': 'venom_ant.gif', 'startStage': 211, 'endStage': 220, 'def': 5},
    {'name': '불개미', 'imageName': 'fire_ant.gif', 'startStage': 221, 'endStage': 230, 'def': 5},
    {'name': '바퀴벌레', 'imageName': 'cockroach.gif', 'startStage': 231, 'endStage': 240, 'def': 5},
    {'name': '비틀', 'imageName': 'beetle.gif', 'startStage': 241, 'endStage': 249, 'def': 7},
    {
      'name': '거대한 사슴벌레',
      'imageName': 'giant_stag_beetle.gif',
      'startStage': 250,
      'endStage': 250,
      'def': 9,
      'isBoss': true,
    },

    // 어두운 동굴 깊은 곳II (251~300)
    {'name': '불개미', 'imageName': 'fire_ant.gif', 'startStage': 251, 'endStage': 260, 'def': 6},
    {'name': '역병박쥐', 'imageName': 'plague_bat.gif', 'startStage': 261, 'endStage': 270, 'def': 6},
    {'name': '거대한 사슴벌레', 'imageName': 'giant_stag_beetle.gif', 'startStage': 271, 'endStage': 280, 'def': 6},
    {'name': '역병쥐', 'imageName': 'plague_rat.gif', 'startStage': 281, 'endStage': 290, 'def': 7},
    {'name': '두더쥐', 'imageName': 'mole.gif', 'startStage': 291, 'endStage': 299, 'def': 8},
    {
      'name': '육식 비버',
      'imageName': 'carnivorous_beaver.gif',
      'startStage': 300,
      'endStage': 300,
      'def': 10,
      'isBoss': true,
    },

    // 고블린 영지 (301~350)
    {'name': '고블린 궁병', 'imageName': 'goblin_archer.gif', 'startStage': 301, 'endStage': 310, 'def': 7},
    {'name': '고블린 광신도', 'imageName': 'goblin_zealot.gif', 'startStage': 311, 'endStage': 320, 'def': 7},
    {'name': '고블린 투사', 'imageName': 'goblin_fighter.gif', 'startStage': 321, 'endStage': 330, 'def': 8},
    {'name': '고블린 사제', 'imageName': 'goblin_priest.gif', 'startStage': 331, 'endStage': 340, 'def': 7},
    {'name': '고블린 투사', 'imageName': 'goblin_fighter.gif', 'startStage': 341, 'endStage': 349, 'def': 10},
    {
      'name': '고블린 리더',
      'imageName': 'goblin_leader.gif',
      'startStage': 350,
      'endStage': 350,
      'def': 12,
      'isBoss': true,
    },

    // 소인족 마을 (351~400)
    {'name': '소인족 궁병', 'imageName': 'dwarf_archer.gif', 'startStage': 351, 'endStage': 360, 'def': 7},
    {'name': '소인족 로그', 'imageName': 'dwarf_rogue.gif', 'startStage': 361, 'endStage': 370, 'def': 7},
    {'name': '소인족 사제', 'imageName': 'dwarf_priest.gif', 'startStage': 371, 'endStage': 380, 'def': 7},
    {'name': '소인족 기사', 'imageName': 'dwarf_knight.gif', 'startStage': 381, 'endStage': 390, 'def': 7},
    {'name': '소인족 기사', 'imageName': 'dwarf_knight.gif', 'startStage': 391, 'endStage': 399, 'def': 9},
    {
      'name': '소인족 리더',
      'imageName': 'dwarf_leader.gif',
      'startStage': 400,
      'endStage': 400,
      'def': 15,
      'isBoss': true,
    },

    // 리자드 습지 (401~450)
    {'name': '리자드맨 궁병', 'imageName': 'lizardman_archer.gif', 'startStage': 401, 'endStage': 410, 'def': 8},
    {'name': '리자드맨 정찰병', 'imageName': 'lizardman_scout.gif', 'startStage': 411, 'endStage': 420, 'def': 8},
    {'name': '리자드맨 검투사', 'imageName': 'lizardman_gladiator.gif', 'startStage': 421, 'endStage': 430, 'def': 8},
    {'name': '리자드맨 창병', 'imageName': 'lizardman_spearman.gif', 'startStage': 431, 'endStage': 440, 'def': 9},
    {'name': '리자드맨 검투사', 'imageName': 'lizardman_gladiator.gif', 'startStage': 441, 'endStage': 449, 'def': 10},
    {
      'name': '리자드맨 리더',
      'imageName': 'lizardman_leader.gif',
      'startStage': 450,
      'endStage': 450,
      'def': 18,
      'isBoss': true,
    },

    // 바위산 초입 (451~500)
    {'name': '감시자', 'imageName': 'watcher.gif', 'startStage': 451, 'endStage': 460, 'def': 8},
    {'name': '주시자', 'imageName': 'observer.gif', 'startStage': 461, 'endStage': 470, 'def': 8},
    {'name': '독버섯', 'imageName': 'poison_mushroom.gif', 'startStage': 471, 'endStage': 480, 'def': 8},
    {'name': '광대버섯', 'imageName': 'clown_mushroom.gif', 'startStage': 481, 'endStage': 490, 'def': 9},
    {'name': '변종 독버섯', 'imageName': 'mutant_poison_mushroom.gif', 'startStage': 491, 'endStage': 499, 'def': 10},
    {
      'name': '바위산 뼈수집가',
      'imageName': 'rocky_mountain_bone_collector.gif',
      'startStage': 500,
      'endStage': 500,
      'def': 20,
      'isBoss': true,
    },

    // 바위산 중턱 (501~550)
    {'name': '슬라임', 'imageName': 'slime.gif', 'startStage': 501, 'endStage': 510, 'def': 9},
    {'name': '포이즌 슬라임', 'imageName': 'poison_slime.gif', 'startStage': 511, 'endStage': 520, 'def': 9},
    {'name': '바위산 뼈수집가', 'imageName': 'rocky_mountain_bone_collector.gif', 'startStage': 521, 'endStage': 530, 'def': 9},
    {'name': '오우거', 'imageName': 'ogre.gif', 'startStage': 531, 'endStage': 540, 'def': 11},
    {'name': '샴오우거', 'imageName': 'sham_ogre.gif', 'startStage': 541, 'endStage': 549, 'def': 12},
    {
      'name': '죽음의 그림자',
      'imageName': 'shadow_of_death.gif',
      'startStage': 550,
      'endStage': 550,
      'def': 24,
      'isBoss': true,
    },

    // 바위산 정상 (551~600)
    {'name': '트롤', 'imageName': 'troll.gif', 'startStage': 551, 'endStage': 560, 'def': 12},
    {'name': '바위트롤', 'imageName': 'rock_troll.gif', 'startStage': 561, 'endStage': 570, 'def': 13},
    {'name': '싸이클롭스', 'imageName': 'cyclops.gif', 'startStage': 571, 'endStage': 580, 'def': 13},
    {'name': '죽음의 그림자', 'imageName': 'shadow_of_death.gif', 'startStage': 581, 'endStage': 590, 'def': 15},
    {'name': '싸이클롭스', 'imageName': 'cyclops.gif', 'startStage': 591, 'endStage': 599, 'def': 17},
    {
      'name': '죽음의 형태',
      'imageName': 'form_of_death.gif',
      'startStage': 600,
      'endStage': 600,
      'def': 30,
      'isBoss': true,
    },

    // 이상한 마을 (601~650)
    {'name': '이상한 아이', 'imageName': 'strange_child.gif', 'startStage': 601, 'endStage': 610, 'def': 15},
    {'name': '소리 지르는 아이', 'imageName': 'screaming_child.gif', 'startStage': 611, 'endStage': 620, 'def': 15},
    {'name': '눈 돌아간 청년', 'imageName': 'crazed_youth.gif', 'startStage': 621, 'endStage': 630, 'def': 15},
    {'name': '소리 지르는 아이', 'imageName': 'screaming_child.gif', 'startStage': 631, 'endStage': 640, 'def': 17},
    {'name': '설교하는 자', 'imageName': 'preacher.gif', 'startStage': 641, 'endStage': 649, 'def': 17},
    {
      'name': '이상한 마을 촌장',
      'imageName': 'strange_village_elder.gif',
      'startStage': 650,
      'endStage': 650,
      'def': 30,
      'isBoss': true,
    },

    // 엘프 숲 (651~700)
    {'name': '엘프 정찰병', 'imageName': 'elf_scout.gif', 'startStage': 651, 'endStage': 660, 'def': 17},
    {'name': '엘프 검사', 'imageName': 'elf_swordsman.gif', 'startStage': 661, 'endStage': 670, 'def': 17},
    {'name': '엘프 마법사', 'imageName': 'elf_mage.gif', 'startStage': 671, 'endStage': 680, 'def': 17},
    {'name': '엘프 궁병', 'imageName': 'elf_archer.gif', 'startStage': 681, 'endStage': 690, 'def': 19},
    {'name': '엘프 궁병', 'imageName': 'elf_archer.gif', 'startStage': 691, 'endStage': 699, 'def': 20},
    {
      'name': '엘프 촌장',
      'imageName': 'elf_elder.gif',
      'startStage': 700,
      'endStage': 700,
      'def': 32,
      'isBoss': true,
    },

    // 요정 숲 (701~750)
    {'name': '요정', 'imageName': 'fairy.gif', 'startStage': 701, 'endStage': 710, 'def': 20},
    {'name': '호전적인 요정', 'imageName': 'hostile_fairy.gif', 'startStage': 711, 'endStage': 720, 'def': 20},
    {'name': '위스프', 'imageName': 'wisp.gif', 'startStage': 721, 'endStage': 730, 'def': 20},
    {'name': '나무정령', 'imageName': 'treant.gif', 'startStage': 731, 'endStage': 740, 'def': 21},
    {'name': '위스프', 'imageName': 'wisp.gif', 'startStage': 741, 'endStage': 749, 'def': 22},
    {
      'name': '귀신들린 나무정령',
      'imageName': 'haunted_treant.gif',
      'startStage': 750,
      'endStage': 750,
      'def': 35,
      'isBoss': true,
    },

    // 이상한 숲 (751~800)
    {'name': '미숙한 마법사', 'imageName': 'novice_mage.gif', 'startStage': 751, 'endStage': 760, 'def': 21},
    {'name': '능숙한 마법사', 'imageName': 'adept_mage.gif', 'startStage': 761, 'endStage': 770, 'def': 21},
    {'name': '음침한 마녀', 'imageName': 'gloomy_witch.gif', 'startStage': 771, 'endStage': 780, 'def': 21},
    {'name': '네크로맨서', 'imageName': 'necromancer.gif', 'startStage': 781, 'endStage': 790, 'def': 23},
    {'name': '음침한 마녀', 'imageName': 'gloomy_witch.gif', 'startStage': 791, 'endStage': 799, 'def': 22},
    {
      'name': '드루이드',
      'imageName': 'druid.gif',
      'startStage': 800,
      'endStage': 800,
      'def': 37,
      'isBoss': true,
    },

    // 정령의 숲 (801~850)
    {'name': '땅의 정령', 'imageName': 'earth_elemental.gif', 'startStage': 801, 'endStage': 810, 'def': 23},
    {'name': '아이언 골렘', 'imageName': 'iron_golem.gif', 'startStage': 811, 'endStage': 820, 'def': 23},
    {'name': '물의 정령', 'imageName': 'water_elemental.gif', 'startStage': 821, 'endStage': 830, 'def': 23},
    {'name': '아이스 골렘', 'imageName': 'ice_golem.gif', 'startStage': 831, 'endStage': 840, 'def': 25},
    {'name': '아이언 골렘', 'imageName': 'iron_golem.gif', 'startStage': 841, 'endStage': 849, 'def': 26},
    {
      'name': '불의 정령',
      'imageName': 'fire_elemental.gif',
      'startStage': 850,
      'endStage': 850,
      'def': 40,
      'isBoss': true,
    },

    // 바위산 끝자락 (851~900)
    {'name': '감시자', 'imageName': 'watcher.gif', 'startStage': 851, 'endStage': 860, 'def': 24},
    {'name': '주시자', 'imageName': 'observer.gif', 'startStage': 861, 'endStage': 870, 'def': 24},
    {'name': '독버섯', 'imageName': 'poison_mushroom.gif', 'startStage': 871, 'endStage': 880, 'def': 24},
    {'name': '광대버섯', 'imageName': 'clown_mushroom.gif', 'startStage': 881, 'endStage': 890, 'def': 25},
    {'name': '변종 독버섯', 'imageName': 'mutant_poison_mushroom.gif', 'startStage': 891, 'endStage': 899, 'def': 26},
    {
      'name': '바위산 뼈수집가',
      'imageName': 'rocky_mountain_bone_collector.gif',
      'startStage': 900,
      'endStage': 900,
      'def': 42,
      'isBoss': true,
    },

    // 신성국으로 가는 길 (901~950)
    {'name': '호저', 'imageName': 'porcupine.gif', 'startStage': 901, 'endStage': 910, 'def': 22},
    {'name': '스컹크', 'imageName': 'skunk.gif', 'startStage': 911, 'endStage': 920, 'def': 22},
    {'name': '고양이', 'imageName': 'cat.gif', 'startStage': 921, 'endStage': 930, 'def': 22},
    {'name': '두꺼비', 'imageName': 'toad.gif', 'startStage': 931, 'endStage': 940, 'def': 22},
    {'name': '돼지', 'imageName': 'pig.gif', 'startStage': 941, 'endStage': 949, 'def': 24},
    {
      'name': '정신나간 멧돼지',
      'imageName': 'crazed_boar.gif',
      'startStage': 950,
      'endStage': 950,
      'def': 40,
      'isBoss': true,
    },

    // 신성국 입구 (951~1000)
    {'name': '신성국 경비병', 'imageName': 'holy_kingdom_guard.gif', 'startStage': 951, 'endStage': 960, 'def': 26},
    {'name': '신성국 경비대장', 'imageName': 'holy_kingdom_captain.gif', 'startStage': 961, 'endStage': 970, 'def': 26},
    {'name': '신성국 기사', 'imageName': 'holy_kingdom_knight.gif', 'startStage': 971, 'endStage': 980, 'def': 26},
    {'name': '신성국 경비대장', 'imageName': 'holy_kingdom_captain.gif', 'startStage': 981, 'endStage': 990, 'def': 28},
    {'name': '신성국 기사단장', 'imageName': 'holy_kingdom_knight_commander.gif', 'startStage': 991, 'endStage': 999, 'def': 30},
    {
      'name': '팔라딘',
      'imageName': 'paladin.gif',
      'startStage': 1000,
      'endStage': 1000,
      'def': 50,
      'isBoss': true,
    },

    // 신성국 교회 (1001~1050)
    {'name': '신성국 신자', 'imageName': 'holy_kingdom_believer.gif', 'startStage': 1001, 'endStage': 1010, 'def': 25},
    {'name': '신성국 일등 신자', 'imageName': 'holy_kingdom_first_believer.gif', 'startStage': 1011, 'endStage': 1020, 'def': 25},
    {'name': '신성국 전도사', 'imageName': 'holy_kingdom_missionary.gif', 'startStage': 1021, 'endStage': 1030, 'def': 25},
    {'name': '신성국 주교', 'imageName': 'holy_kingdom_bishop.gif', 'startStage': 1031, 'endStage': 1040, 'def': 25},
    {'name': '신성국 주교', 'imageName': 'holy_kingdom_bishop.gif', 'startStage': 1041, 'endStage': 1049, 'def': 30},
    {
      'name': '신성국 대주교',
      'imageName': 'holy_kingdom_archbishop.gif',
      'startStage': 1050,
      'endStage': 1050,
      'def': 50,
      'isBoss': true,
    },

    // 신성한 제단 (1051~1100)
    {'name': '하급 천사', 'imageName': 'lesser_angel.gif', 'startStage': 1051, 'endStage': 1060, 'def': 40},
    {'name': '중급 천사', 'imageName': 'intermediate_angel.gif', 'startStage': 1061, 'endStage': 1070, 'def': 40},
    {'name': '상급 천사', 'imageName': 'greater_angel.gif', 'startStage': 1071, 'endStage': 1080, 'def': 41},
    {'name': '대천사', 'imageName': 'archangel.gif', 'startStage': 1081, 'endStage': 1090, 'def': 42},
    {'name': '대천사', 'imageName': 'archangel.gif', 'startStage': 1091, 'endStage': 1099, 'def': 45},
    {
      'name': '천사장',
      'imageName': 'seraph.gif',
      'startStage': 1100,
      'endStage': 1100,
      'def': 55,
      'isBoss': true,
    },

    // 세뇌된 마을 (1101~1150)
    {'name': '세뇌된 아이', 'imageName': 'brainwashed_child.gif', 'startStage': 1101, 'endStage': 1110, 'def': 25},
    {'name': '세뇌된 청년', 'imageName': 'brainwashed_youth.gif', 'startStage': 1111, 'endStage': 1120, 'def': 25},
    {'name': '눈 돌아간 청년', 'imageName': 'crazed_youth.gif', 'startStage': 1121, 'endStage': 1130, 'def': 25},
    {'name': '세뇌된 청년', 'imageName': 'brainwashed_youth.gif', 'startStage': 1131, 'endStage': 1140, 'def': 26},
    {'name': '세뇌된 어른', 'imageName': 'brainwashed_adult.gif', 'startStage': 1141, 'endStage': 1149, 'def': 27},
    {
      'name': '세뇌된 촌장',
      'imageName': 'brainwashed_elder.gif',
      'startStage': 1150,
      'endStage': 1150,
      'def': 30,
      'isBoss': true,
    },

    // 마을 공동묘지 입구 (1151~1200)
    {'name': '식인벌레', 'imageName': 'man_eating_bug.gif', 'startStage': 1151, 'endStage': 1160, 'def': 35},
    {'name': '거대 식인벌레', 'imageName': 'giant_man_eating_bug.gif', 'startStage': 1161, 'endStage': 1170, 'def': 35},
    {'name': '상태 안좋은 미라', 'imageName': 'bad_condition_mummy.gif', 'startStage': 1171, 'endStage': 1180, 'def': 35},
    {'name': '미라', 'imageName': 'mummy.gif', 'startStage': 1181, 'endStage': 1190, 'def': 36},
    {'name': '거대 식인벌레', 'imageName': 'giant_man_eating_bug.gif', 'startStage': 1191, 'endStage': 1199, 'def': 37},
    {
      'name': '거대한 미라',
      'imageName': 'giant_mummy.gif',
      'startStage': 1200,
      'endStage': 1200,
      'def': 40,
      'isBoss': true,
    },

    // 마을 공동묘지 (1201~1250)
    {'name': '움직이는 손', 'imageName': 'crawling_hand.gif', 'startStage': 1201, 'endStage': 1210, 'def': 37},
    {'name': '좀비개', 'imageName': 'zombie_dog.gif', 'startStage': 1211, 'endStage': 1220, 'def': 37},
    {'name': '굶주린 좀비', 'imageName': 'hungry_zombie.gif', 'startStage': 1221, 'endStage': 1230, 'def': 37},
    {'name': '기어다니는 좀비', 'imageName': 'crawling_zombie.gif', 'startStage': 1231, 'endStage': 1240, 'def': 38},
    {'name': '기어다니는 좀비', 'imageName': 'crawling_zombie.gif', 'startStage': 1241, 'endStage': 1249, 'def': 39},
    {
      'name': '뛰는 좀비',
      'imageName': 'running_zombie.gif',
      'startStage': 1250,
      'endStage': 1250,
      'def': 45,
      'isBoss': true,
    },

    // 마을 공동묘지 중심부 (1251~1300)
    {'name': '흡혈박쥐', 'imageName': 'vampire_bat.gif', 'startStage': 1251, 'endStage': 1260, 'def': 40},
    {'name': '죽음의 눈', 'imageName': 'eye_of_death.gif', 'startStage': 1261, 'endStage': 1270, 'def': 40},
    {'name': '스켈레톤', 'imageName': 'skeleton.gif', 'startStage': 1271, 'endStage': 1280, 'def': 40},
    {'name': '스켈레톤 아쳐', 'imageName': 'skeleton_archer.gif', 'startStage': 1281, 'endStage': 1290, 'def': 41},
    {'name': '스켈레톤', 'imageName': 'skeleton.gif', 'startStage': 1291, 'endStage': 1299, 'def': 42},
    {
      'name': '무덤지기',
      'imageName': 'gravedigger.gif',
      'startStage': 1300,
      'endStage': 1300,
      'def': 45,
      'isBoss': true,
    },

    // 항구로 가는 길 (1301~1350)
    {'name': '고블린 투사', 'imageName': 'goblin_fighter.gif', 'startStage': 1301, 'endStage': 1310, 'def': 41},
    {'name': '소인족 기사', 'imageName': 'dwarf_knight.gif', 'startStage': 1311, 'endStage': 1320, 'def': 41},
    {'name': '어인족 검사', 'imageName': 'merman_swordsman.gif', 'startStage': 1321, 'endStage': 1330, 'def': 41},
    {'name': '미숙한 마법사', 'imageName': 'novice_mage.gif', 'startStage': 1331, 'endStage': 1340, 'def': 42},
    {'name': '팀버울프', 'imageName': 'timber_wolf.gif', 'startStage': 1341, 'endStage': 1349, 'def': 43},
    {
      'name': '샴오우거',
      'imageName': 'sham_ogre.gif',
      'startStage': 1350,
      'endStage': 1350,
      'def': 50,
      'isBoss': true,
    },

    // 항구로 가는 길 II(1351~1400)
    {'name': '바위트롤', 'imageName': 'rock_troll.gif', 'startStage': 1351, 'endStage': 1360, 'def': 45},
    {'name': '신성국 기사', 'imageName': 'holy_kingdom_knight.gif', 'startStage': 1361, 'endStage': 1370, 'def': 45},
    {'name': '물의 정령', 'imageName': 'water_elemental.gif', 'startStage': 1371, 'endStage': 1380, 'def': 45},
    {'name': '육식 비버', 'imageName': 'carnivorous_beaver.gif', 'startStage': 1381, 'endStage': 1390, 'def': 46},
    {'name': '나무정령', 'imageName': 'treant.gif', 'startStage': 1391, 'endStage': 1399, 'def': 47},
    {
      'name': '죽음의 형태',
      'imageName': 'form_of_death.gif',
      'startStage': 1400,
      'endStage': 1400,
      'def': 55,
      'isBoss': true,
    },

    // 피투성이 해안 (1401~1450)
    {'name': '어인족 정찰병', 'imageName': 'merman_scout.gif', 'startStage': 1401, 'endStage': 1410, 'def': 46},
    {'name': '어인족 검사', 'imageName': 'merman_swordsman.gif', 'startStage': 1411, 'endStage': 1420, 'def': 46},
    {'name': '어인족 마법사', 'imageName': 'merman_mage.gif', 'startStage': 1421, 'endStage': 1430, 'def': 46},
    {'name': '어인족 창병', 'imageName': 'merman_spearman.gif', 'startStage': 1431, 'endStage': 1440, 'def': 47},
    {'name': '어인족 창병', 'imageName': 'merman_spearman.gif', 'startStage': 1441, 'endStage': 1449, 'def': 48},
    {
      'name': '어인족 리더',
      'imageName': 'merman_leader.gif',
      'startStage': 1450,
      'endStage': 1450,
      'def': 58,
      'isBoss': true,
    },

    // 피폐한 항구도시 (1451~1500)
    {'name': '스켈레톤', 'imageName': 'skeleton.gif', 'startStage': 1451, 'endStage': 1460, 'def': 48},
    {'name': '굶주린 좀비', 'imageName': 'hungry_zombie.gif', 'startStage': 1461, 'endStage': 1470, 'def': 48},
    {'name': '죽음의 그림자', 'imageName': 'shadow_of_death.gif', 'startStage': 1471, 'endStage': 1480, 'def': 48},
    {'name': '역병쥐', 'imageName': 'plague_rat.gif', 'startStage': 1481, 'endStage': 1490, 'def': 49},
    {'name': '뛰는 좀비', 'imageName': 'running_zombie.gif', 'startStage': 1491, 'endStage': 1499, 'def': 50},
    {
      'name': '네크로맨서',
      'imageName': 'necromancer.gif',
      'startStage': 1500,
      'endStage': 1500,
      'def': 60,
      'isBoss': true,
    },

    // 항구도시 외곽 (1501~1550)
    {'name': '죽음의 눈', 'imageName': 'eye_of_death.gif', 'startStage': 1501, 'endStage': 1510, 'def': 48},
    {'name': '좀비 바퀴벌레', 'imageName': 'zombie_cockroach.gif', 'startStage': 1511, 'endStage': 1520, 'def': 48},
    {'name': '데쓰 슬라임', 'imageName': 'death_slime.gif', 'startStage': 1521, 'endStage': 1530, 'def': 48},
    {'name': '산송장', 'imageName': 'draugr.gif', 'startStage': 1531, 'endStage': 1540, 'def': 49},
    {'name': '감염된 마녀', 'imageName': 'infected_witch.gif', 'startStage': 1541, 'endStage': 1549, 'def': 50},
    {
      'name': '죽음의 인도자',
      'imageName': 'psychopomp.gif',
      'startStage': 1550,
      'endStage': 1550,
      'def': 60,
      'isBoss': true,
    },

    // 데빌 로드 (1551~1600)
    {'name': '신성국 기사단장', 'imageName': 'holy_kingdom_knight_commander.gif', 'startStage': 1551, 'endStage': 1560, 'def': 50},
    {'name': '소인족 기사', 'imageName': 'dwarf_knight.gif', 'startStage': 1561, 'endStage': 1570, 'def': 50},
    {'name': '리자드맨 창병', 'imageName': 'lizardman_spearman.gif', 'startStage': 1571, 'endStage': 1580, 'def': 50},
    {'name': '팔라딘', 'imageName': 'paladin.gif', 'startStage': 1581, 'endStage': 1590, 'def': 51},
    {'name': '땅의 정령', 'imageName': 'earth_elemental.gif', 'startStage': 1591, 'endStage': 1599, 'def': 52},
    {
      'name': '하급 악마',
      'imageName': 'lesser_demon.gif',
      'startStage': 1600,
      'endStage': 1600,
      'def': 66,
      'isBoss': true,
    },

    // 데빌 로드 II(1601~1650)
    {'name': '드루이드', 'imageName': 'druid.gif', 'startStage': 1601, 'endStage': 1610, 'def': 50},
    {'name': '엘프 촌장', 'imageName': 'elf_elder.gif', 'startStage': 1611, 'endStage': 1620, 'def': 50},
    {'name': '소인족 리더', 'imageName': 'dwarf_leader.gif', 'startStage': 1621, 'endStage': 1630, 'def': 50},
    {'name': '뛰는 좀비', 'imageName': 'running_zombie.gif', 'startStage': 1631, 'endStage': 1640, 'def': 51},
    {'name': '불의 정령', 'imageName': 'fire_elemental.gif', 'startStage': 1641, 'endStage': 1649, 'def': 52},
    {
      'name': '하급 악마',
      'imageName': 'lesser_demon.gif',
      'startStage': 1650,
      'endStage': 1650,
      'def': 66,
      'isBoss': true,
    },

    // 마계 입구 (1651~1700)
    {'name': '도깨비불', 'imageName': 'will_o_wisp.gif', 'startStage': 1651, 'endStage': 1660, 'def': 55},
    {'name': '하급 악귀', 'imageName': 'lesser_fiend.gif', 'startStage': 1661, 'endStage': 1670, 'def': 60},
    {'name': '중급 악귀', 'imageName': 'intermediate_fiend.gif', 'startStage': 1671, 'endStage': 1680, 'def': 62},
    {'name': '상급 악귀', 'imageName': 'greater_fiend.gif', 'startStage': 1681, 'endStage': 1690, 'def': 64},
    {'name': '상급 악귀', 'imageName': 'greater_fiend.gif', 'startStage': 1691, 'endStage': 1699, 'def': 64},
    {
      'name': '악의',
      'imageName': 'malice.gif',
      'startStage': 1700,
      'endStage': 1700,
      'def': 66,
      'isBoss': true,
    },

    // 마계 중심 (1701~1750)
    {'name': '질투', 'imageName': 'envy.gif', 'startStage': 1701, 'endStage': 1710, 'def': 66},
    {'name': '원한', 'imageName': 'grudge.gif', 'startStage': 1711, 'endStage': 1720, 'def': 66},
    {'name': '원망', 'imageName': 'resentment.gif', 'startStage': 1721, 'endStage': 1730, 'def': 66},
    {'name': '공허', 'imageName': 'void.gif', 'startStage': 1731, 'endStage': 1740, 'def': 66},
    {'name': '원망', 'imageName': 'resentment.gif', 'startStage': 1741, 'endStage': 1749, 'def': 66},
    {
      'name': '절망',
      'imageName': 'despair.gif',
      'startStage': 1750,
      'endStage': 1750,
      'def': 66,
      'isBoss': true,
    },

    // 마계 중심부 (1751~1800)
    {'name': '악마의 눈', 'imageName': 'devils_eye.gif', 'startStage': 1751, 'endStage': 1760, 'def': 66},
    {'name': '하급 악마', 'imageName': 'lesser_demon.gif', 'startStage': 1761, 'endStage': 1770, 'def': 66},
    {'name': '중급 악마', 'imageName': 'intermediate_demon.gif', 'startStage': 1771, 'endStage': 1780, 'def': 66},
    {'name': '상급 악마', 'imageName': 'greater_demon.gif', 'startStage': 1781, 'endStage': 1790, 'def': 66},
    {'name': '상급 악마', 'imageName': 'greater_demon.gif', 'startStage': 1791, 'endStage': 1799, 'def': 66},
    {
      'name': '마왕',
      'imageName': 'demon_king.gif',
      'startStage': 1800,
      'endStage': 1800,
      'def': 66,
      'isBoss': true,
    },

    // 드래곤 로드 (1801~1850)
    {'name': '호전적인 요정', 'imageName': 'hostile_fairy.gif', 'startStage': 1801, 'endStage': 1810, 'def': 55},
    {'name': '바위트롤', 'imageName': 'rock_troll.gif', 'startStage': 1811, 'endStage': 1820, 'def': 55},
    {'name': '신성국 기사단장', 'imageName': 'holy_kingdom_knight_commander.gif', 'startStage': 1821, 'endStage': 1830, 'def': 55},
    {'name': '하급 천사', 'imageName': 'lesser_angel.gif', 'startStage': 1831, 'endStage': 1840, 'def': 56},
    {'name': '신성국 대주교', 'imageName': 'holy_kingdom_archbishop.gif', 'startStage': 1841, 'endStage': 1849, 'def': 57},
    {
      'name': '새끼 와이번',
      'imageName': 'young_wyvern.gif',
      'startStage': 1850,
      'endStage': 1850,
      'def': 77,
      'isBoss': true,
    },

    // 드래곤 레어 초입 (1851~1900)
    {'name': '새끼 와이번', 'imageName': 'young_wyvern.gif', 'startStage': 1851, 'endStage': 1860, 'def': 77},
    {'name': '성체 와이번', 'imageName': 'adult_wyvern.gif', 'startStage': 1861, 'endStage': 1870, 'def': 77},
    {'name': '비취석 드레이크', 'imageName': 'jade_drake.gif', 'startStage': 1871, 'endStage': 1880, 'def': 85},
    {'name': '청금석 드레이크', 'imageName': 'lapis_drake.gif', 'startStage': 1881, 'endStage': 1890, 'def': 85},
    {'name': '비취석 드레이크', 'imageName': 'jade_drake.gif', 'startStage': 1891, 'endStage': 1899, 'def': 85},
    {
      'name': '베놈 드레이크',
      'imageName': 'venom_drake.gif',
      'startStage': 1900,
      'endStage': 1900,
      'def': 90,
      'isBoss': true,
    },

    // 드래곤 레어 중심부 (1901~1950)
    {'name': '성체 그린 드래곤', 'imageName': 'adult_green_dragon.gif', 'startStage': 1901, 'endStage': 1910, 'def': 95},
    {'name': '성체 화이트 드래곤', 'imageName': 'adult_white_dragon.gif', 'startStage': 1911, 'endStage': 1920, 'def': 95},
    {'name': '레드 드래곤', 'imageName': 'red_dragon.gif', 'startStage': 1921, 'endStage': 1930, 'def': 99},
    {'name': '성체 그린 드래곤', 'imageName': 'adult_green_dragon.gif', 'startStage': 1931, 'endStage': 1940, 'def': 95},
    {'name': '성체 화이트 드래곤', 'imageName': 'adult_white_dragon.gif', 'startStage': 1941, 'endStage': 1949, 'def': 95},
    {
      'name': '레드 드래곤',
      'imageName': 'red_dragon.gif',
      'startStage': 1950,
      'endStage': 1950,
      'def': 99,
      'isBoss': true,
    },

    // 드래곤 레어 깊은곳 (1951~2000)
    {'name': '새끼 수호룡', 'imageName': 'young_guardian_dragon.gif', 'startStage': 1951, 'endStage': 1960, 'def': 100},
    {'name': '성체 화이트 드래곤', 'imageName': 'adult_white_dragon.gif', 'startStage': 1961, 'endStage': 1970, 'def': 100},
    {'name': '준성체 수호룡', 'imageName': 'subadult_guardian_dragon.gif', 'startStage': 1971, 'endStage': 1980, 'def': 100},
    {'name': '성체 수호룡', 'imageName': 'adult_guardian_dragon.gif', 'startStage': 1981, 'endStage': 1990, 'def': 100},
    {'name': '새끼 황금용', 'imageName': 'young_gold_dragon.gif', 'startStage': 1991, 'endStage': 1999, 'def': 110},
    {
      'name': '용왕',
      'imageName': 'dragon_king.gif',
      'startStage': 2000,
      'endStage': 2000,
      'def': 125,
      'isBoss': true,
    },
  ];

  static Monster getMonsterForStage(int stage) {
    var monsterInfo = _monsterList.firstWhere(
      (m) => stage >= m['startStage'] && stage <= m['endStage'],
      orElse: () => {
        'name': 'Unknown',
        'imageName': 'unknown.gif', // Fallback image
        'startStage': 0,
        'endStage': 0,
        'def': 0,
      },
    );

    bool isBoss = monsterInfo['isBoss'] ?? false;

    const double baseHP = 50;
    const double hpIncrement = 7;
    const double hpGrowthRate = 1.07;

    double hp = (baseHP + hpIncrement * (stage - 1)) * pow(hpGrowthRate, stage - 1);
    int def = monsterInfo['def'];

    if (isBoss) {
      const double bossHpMultiplier = 2.0;
      const double bossDefMultiplier = 1.3;
      hp *= bossHpMultiplier;
      def = (def * bossDefMultiplier).floor();
    }

    return Monster(
      name: monsterInfo['name'],
      imageName: monsterInfo['imageName'], // Pass imageName to constructor
      stage: stage,
      maxHp: hp.floorToDouble(),
      hp: hp.floorToDouble(),
      defense: def,
      isBoss: isBoss,
    );
  }
}
