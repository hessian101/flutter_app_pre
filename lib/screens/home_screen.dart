import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Star Music Game',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textColor),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '星座から音楽を生成するリズムゲーム',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(AppColors.secondaryTextColor),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                _buildMenuButton(
                  context,
                  'ゲーム開始',
                  Icons.play_arrow,
                  () => Navigator.pushNamed(context, Routes.game),
                ),
                const SizedBox(height: 20),
                _buildMenuButton(
                  context,
                  'ハイスコア',
                  Icons.leaderboard,
                  () => Navigator.pushNamed(context, Routes.highScore),
                ),
                const SizedBox(height: 20),
                _buildMenuButton(
                  context,
                  '演奏記録',
                  Icons.music_note,
                  () => Navigator.pushNamed(context, Routes.performanceList),
                ),
                const SizedBox(height: 20),
                _buildMenuButton(
                  context,
                  '遊び方',
                  Icons.help_outline,
                  () => Navigator.pushNamed(context, Routes.howToPlay),
                ),
                const SizedBox(height: 20),
                _buildMenuButton(
                  context,
                  '設定',
                  Icons.settings,
                  () => Navigator.pushNamed(context, Routes.settings),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppColors.primaryColor),
          foregroundColor: Color(AppColors.textColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}