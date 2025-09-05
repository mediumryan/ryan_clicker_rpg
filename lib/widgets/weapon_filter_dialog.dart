import 'package:flutter/material.dart';
import 'package:ryan_clicker_rpg/models/weapon.dart'; // For Rarity and WeaponType enums

class WeaponFilterDialog extends StatefulWidget {
  final Set<Rarity> initialSelectedRarities;
  final Set<WeaponType> initialSelectedWeaponTypes;

  const WeaponFilterDialog({
    super.key,
    required this.initialSelectedRarities,
    required this.initialSelectedWeaponTypes,
  });

  @override
  State<WeaponFilterDialog> createState() => _WeaponFilterDialogState();
}

class _WeaponFilterDialogState extends State<WeaponFilterDialog> {
  late Set<Rarity> _selectedRarities;
  late Set<WeaponType> _selectedWeaponTypes;

  @override
  void initState() {
    super.initState();
    _selectedRarities = Set.from(widget.initialSelectedRarities);
    _selectedWeaponTypes = Set.from(widget.initialSelectedWeaponTypes);
  }

  String _getRarityKoreanName(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return '커먼';
      case Rarity.uncommon:
        return '언커먼';
      case Rarity.rare:
        return '레어';
      case Rarity.unique:
        return '유니크';
      case Rarity.epic:
        return '에픽';
      case Rarity.legend:
        return '레전드';
      case Rarity.demigod:
        return '데미갓';
      case Rarity.god:
        return '갓';
    }
  }

  String _getWeaponTypeKoreanName(WeaponType type) {
    const typeMap = {
      'rapier': '레이피어',
      'katana': '카타나',
      'sword': '검',
      'greatsword': '대검',
      'scimitar': '시미터',
      'dagger': '단검',
      'cleaver': '도축칼',
      'battleAxe': '전투도끼',
      'warhammer': '전투망치',
      'spear': '창',
      'staff': '지팡이',
      'trident': '삼지창',
      'mace': '메이스',
      'scythe': '낫',
      'curvedSword': '곡도',
      'nunchaku': '쌍절곤',
    };
    return typeMap[type.toString().split('.').last] ??
        type.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: const Text('필터 설정', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rarity Filter Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '희귀도',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedRarities.length == Rarity.values.length) {
                          _selectedRarities.clear();
                        } else {
                          _selectedRarities.addAll(Rarity.values);
                        }
                      });
                    },
                    child: Text(
                      _selectedRarities.length == Rarity.values.length
                          ? '모두 해제'
                          : '모두 선택',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: Rarity.values.map((rarity) {
                  return FilterChip(
                    label: Text(
                      _getRarityKoreanName(rarity),
                      style: TextStyle(
                        color: _selectedRarities.contains(rarity)
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    selected: _selectedRarities.contains(rarity),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedRarities.add(rarity);
                        } else {
                          _selectedRarities.remove(rarity);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[700],
                    selectedColor: Colors.blue,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Weapon Type Filter Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '무기 타입',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedWeaponTypes.length ==
                            WeaponType.values.length) {
                          _selectedWeaponTypes.clear();
                        } else {
                          _selectedWeaponTypes.addAll(WeaponType.values);
                        }
                      });
                    },
                    child: Text(
                      _selectedWeaponTypes.length == WeaponType.values.length
                          ? '모두 해제'
                          : '모두 선택',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: WeaponType.values.map((type) {
                  return FilterChip(
                    label: Text(
                      _getWeaponTypeKoreanName(type),
                      style: TextStyle(
                        color: _selectedWeaponTypes.contains(type)
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    selected: _selectedWeaponTypes.contains(type),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedWeaponTypes.add(type);
                        } else {
                          _selectedWeaponTypes.remove(type);
                        }
                      });
                    },
                    backgroundColor: Colors.grey[700],
                    selectedColor: Colors.blue,
                    checkmarkColor: Colors.white,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('취소', style: TextStyle(color: Colors.red)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop({
              'rarities': _selectedRarities,
              'weaponTypes': _selectedWeaponTypes,
            });
          },
          child: const Text('확인', style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }
}
