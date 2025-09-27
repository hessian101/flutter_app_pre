import 'package:flutter/material.dart';
import '../utils/constants.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      appBar: AppBar(
        title: const Text('遊び方'),
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
            _buildSection(
              '🎵 ゲームの目的',
              '星座画像から生成された音楽に合わせてタップし、\n高スコアを目指しましょう！',
            ),
            _buildSection(
              '⭐ 星座画像のアップロード',
              '1. ゲーム開始ボタンをタップ\n2. 星座の画像を選択してアップロード\n3. AIが星の位置を解析して音楽を生成',
            ),
            _buildSection(
              '🎯 ゲームプレイ',
              '• 画面に現れる音符をタイミングよくタップ\n• Perfect: 完璧なタイミング (100点)\n• Good: 良いタイミング (50点)\n• Miss: タイミングを外した (0点)',
            ),
            _buildSection(
              '🏆 スコアリング',
              '• 連続してヒットするとコンボが増加\n• 10コンボ以上でスコアが2倍\n• 正確度 = (Perfect + Good) ÷ 総ノート数',
            ),
            _buildSection(
              '🎤 録音機能',
              '• ゲーム中の演奏は自動で録音\n• ゲーム終了後に保存するか選択可能\n• 保存したファイルはWAV形式で出力',
            ),
            _buildSection(
              '📊 記録の管理',
              '• ハイスコア: 過去の最高記録を確認\n• 演奏記録: 保存した演奏の再生・削除\n• データは端末内に安全に保存',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(AppColors.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(AppColors.primaryColor),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Color(AppColors.primaryColor),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'コツ',
                        style: TextStyle(
                          color: Color(AppColors.primaryColor),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 星が多い画像ほど複雑な音楽が生成されます\n• 音を聴きながらタイミングを覚えましょう\n• 連続でプレイして感覚を身につけましょう',
                    style: TextStyle(
                      color: Color(AppColors.textColor),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.game),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(AppColors.primaryColor),
                  foregroundColor: Color(AppColors.textColor),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ゲームを開始',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(AppColors.surfaceColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(AppColors.textColor),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Color(AppColors.secondaryTextColor),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}