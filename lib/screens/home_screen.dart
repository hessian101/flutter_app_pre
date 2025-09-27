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
                    color: Colors.lightBlue.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.lightBlue.withValues(alpha: 0.05),
                  Colors.lightBlue.withValues(alpha: 0.2),
                  Colors.lightBlue.withValues(alpha: 0.05),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: Colors.lightBlue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, Routes.howToPlay),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.help_outline, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.lightBlue.withValues(alpha: 0.05),
                  Colors.lightBlue.withValues(alpha: 0.2),
                  Colors.lightBlue.withValues(alpha: 0.05),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: Colors.lightBlue.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, Routes.settings),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.settings, size: 24),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.lightBlue.withValues(alpha: 0.05),
            Colors.lightBlue.withValues(alpha: 0.2),
            Colors.lightBlue.withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: Colors.lightBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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