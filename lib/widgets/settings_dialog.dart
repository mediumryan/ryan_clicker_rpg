import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ryan_clicker_rpg/providers/game_provider.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  bool _soundOn = true;
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    const Map<String, String> graphicsQualityMap = {
      'Low': '낮음',
      'Medium': '보통',
      'High': '높음',
    };
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('설정', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SwitchListTile(
                  title: const Text(
                    '소리',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _soundOn,
                  onChanged: (bool value) {
                    setState(() {
                      _soundOn = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    '데미지 플로팅',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: game.player.showFloatingDamage,
                  onChanged: (bool value) {
                    game.toggleShowFloatingDamage(value);
                  },
                ),
                SwitchListTile(
                  title: const Text(
                    '알림',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _notificationsOn,
                  onChanged: (bool value) {
                    setState(() {
                      _notificationsOn = value;
                    });
                  },
                ),
                ListTile(
                  title: const Text(
                    '그래픽 품질',
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: DropdownButton<String>(
                    value: game.player.graphicsQuality,
                    dropdownColor: Colors.grey[800],
                    style: const TextStyle(color: Colors.white),
                    items: graphicsQualityMap.keys.map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(graphicsQualityMap[value]!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        game.setGraphicsQuality(newValue);
                      }
                    },
                  ),
                ),
                const Divider(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.grey[850],
                          title: const Text(
                            '게임 초기화',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            '정말로 모든 진행 상황을 초기화하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
                            style: TextStyle(color: Colors.white),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('취소'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('초기화'),
                              onPressed: () {
                                // TODO: Implement game reset logic
                                Navigator.of(
                                  context,
                                ).pop(); // Close confirmation dialog
                                Navigator.of(
                                  context,
                                ).pop(); // Close settings dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('게임 초기화'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
