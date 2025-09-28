import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Color(AppColors.surfaceColor),
        foregroundColor: Color(AppColors.textColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(AppColors.backgroundColor),
              Color(AppColors.surfaceColor),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ゲーム設定カード
            Card(
              color: Color(AppColors.surfaceColor),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.speed,
                      color: Color(AppColors.primaryColor),
                    ),
                    title: Text(
                      'ノート落下速度',
                      style: TextStyle(color: Color(AppColors.textColor)),
                    ),
                    subtitle: Text(
                      '現在: ${GameSettings.getSpeedLevel()}',
                      style: TextStyle(
                        color: Color(AppColors.secondaryTextColor),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildSpeedButton(
                          'ゆっくり',
                          GameConstants.noteAppearTimeSlow,
                        ),
                        _buildSpeedButton(
                          '普通',
                          GameConstants.noteAppearTimeNormal,
                        ),
                        _buildSpeedButton(
                          '速い',
                          GameConstants.noteAppearTimeFast,
                        ),
                        _buildSpeedButton(
                          'とても速い',
                          GameConstants.noteAppearTimeVeryFast,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Color(AppColors.surfaceColor),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.volume_up,
                      color: Color(AppColors.primaryColor),
                    ),
                    title: Text(
                      '音声設定',
                      style: TextStyle(color: Color(AppColors.textColor)),
                    ),
                    subtitle: Text(
                      '音量とオーディオ品質',
                      style: TextStyle(
                        color: Color(AppColors.secondaryTextColor),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Color(AppColors.secondaryTextColor),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('音声設定（未実装）')),
                      );
                    },
                  ),
                  Divider(
                    color: Color(
                      AppColors.secondaryTextColor,
                    ).withValues(alpha: 0.3),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.cloud_download,
                      color: Color(AppColors.primaryColor),
                    ),
                    title: Text(
                      '音源ダウンロード',
                      style: TextStyle(color: Color(AppColors.textColor)),
                    ),
                    subtitle: Text(
                      'Google Driveから音源をダウンロード',
                      style: TextStyle(
                        color: Color(AppColors.secondaryTextColor),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Color(AppColors.secondaryTextColor),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/sound_download');
                    },
                  ),
                  Divider(
                    color: Color(
                      AppColors.secondaryTextColor,
                    ).withValues(alpha: 0.3),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.speed,
                      color: Color(AppColors.primaryColor),
                    ),
                    title: Text(
                      'ゲーム速度',
                      style: TextStyle(color: Color(AppColors.textColor)),
                    ),
                    subtitle: Text(
                      'ノートの落下速度',
                      style: TextStyle(
                        color: Color(AppColors.secondaryTextColor),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Color(AppColors.secondaryTextColor),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ゲーム速度設定（未実装）')),
                      );
                    },
                  ),
                  Divider(
                    color: Color(
                      AppColors.secondaryTextColor,
                    ).withValues(alpha: 0.3),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.accessibility,
                      color: Color(AppColors.primaryColor),
                    ),
                    title: Text(
                      'アクセシビリティ',
                      style: TextStyle(color: Color(AppColors.textColor)),
                    ),
                    subtitle: Text(
                      '視覚・聴覚サポート',
                      style: TextStyle(
                        color: Color(AppColors.secondaryTextColor),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Color(AppColors.secondaryTextColor),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('アクセシビリティ設定（未実装）')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Color(AppColors.surfaceColor),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.storage,
                      color: Color(AppColors.primaryColor),
                    ),
                    title: Text(
                      'データ管理',
                      style: TextStyle(color: Color(AppColors.textColor)),
                    ),
                    subtitle: Text(
                      'ゲームデータとファイル',
                      style: TextStyle(
                        color: Color(AppColors.secondaryTextColor),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Color(AppColors.secondaryTextColor),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('データ管理（未実装）')),
                      );
                    },
                  ),
                  Divider(
                    color: Color(
                      AppColors.secondaryTextColor,
                    ).withValues(alpha: 0.3),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.backup,
                      color: Color(AppColors.primaryColor),
                    ),
                    title: Text(
                      'バックアップ',
                      style: TextStyle(color: Color(AppColors.textColor)),
                    ),
                    subtitle: Text(
                      'スコアと演奏記録',
                      style: TextStyle(
                        color: Color(AppColors.secondaryTextColor),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Color(AppColors.secondaryTextColor),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('バックアップ（未実装）')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Color(AppColors.surfaceColor),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      color: Color(AppColors.primaryColor),
                    ),
                    title: Text(
                      'アプリについて',
                      style: TextStyle(color: Color(AppColors.textColor)),
                    ),
                    subtitle: Text(
                      'バージョン 1.0.0',
                      style: TextStyle(
                        color: Color(AppColors.secondaryTextColor),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Color(AppColors.secondaryTextColor),
                    ),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Star Music Game',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 Star Music Game',
                        children: [
                          Text(
                            '星座画像から音楽を生成するリズムゲームアプリです。',
                            style: TextStyle(color: Color(AppColors.textColor)),
                          ),
                        ],
                      );
                    },
                  ),
                  Divider(
                    color: Color(
                      AppColors.secondaryTextColor,
                    ).withValues(alpha: 0.3),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: Color(AppColors.primaryColor),
                    ),
                    title: Text(
                      'プライバシーポリシー',
                      style: TextStyle(color: Color(AppColors.textColor)),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Color(AppColors.secondaryTextColor),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('プライバシーポリシー（未実装）')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedButton(String label, double speed) {
    final bool isSelected = GameSettings.noteAppearTime == speed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              GameSettings.setNoteAppearTime(speed);
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('ノート落下速度を「$label」に設定しました')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected
                ? Color(AppColors.primaryColor)
                : Color(AppColors.surfaceColor),
            foregroundColor: isSelected
                ? Colors.white
                : Color(AppColors.textColor),
            side: BorderSide(color: Color(AppColors.primaryColor), width: 1),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
