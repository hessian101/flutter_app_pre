import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/home.png'),
            fit: BoxFit.cover,
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
                const SizedBox(height: 16),
                Text(
                  '星座から音楽を生成するリズムゲーム',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(AppColors.secondaryTextColor),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildMenuButton(
                  context,
                  'ゲーム開始',
                  Icons.play_arrow,
                  () => Navigator.pushNamed(context, Routes.game),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  'ハイスコア',
                  Icons.leaderboard,
                  () => Navigator.pushNamed(context, Routes.highScore),
                ),
                const SizedBox(height: 16),
                _buildMenuButton(
                  context,
                  '演奏記録',
                  Icons.music_note,
                  () => Navigator.pushNamed(context, Routes.performanceList),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, Routes.howToPlay),
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(Icons.help_outline, size: 24),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(Icons.settings, size: 24),
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
    return Container(
      width: double.infinity,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
