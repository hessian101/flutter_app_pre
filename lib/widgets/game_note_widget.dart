import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/asset_manager.dart';
import '../utils/constants.dart';

class GameNoteWidget extends StatefulWidget {
  final String noteId;
  final double position; // 0.0 (上) から 1.0 (下) までの位置
  final VoidCallback? onTap;
  final bool isActive;
  final String? soundId;

  const GameNoteWidget({
    super.key,
    required this.noteId,
    required this.position,
    this.onTap,
    this.isActive = true,
    this.soundId,
  });

  @override
  State<GameNoteWidget> createState() => _GameNoteWidgetState();
}

class _GameNoteWidgetState extends State<GameNoteWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 2.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isActive || _isTapped) return;

    setState(() {
      _isTapped = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    widget.onTap?.call();

    // 一定時間後にタップ状態をリセット
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isTapped = false;
        });
      }
    });
  }

  Color _getNoteColor() {
    final soundId = widget.soundId ?? 'button1';

    // soundIdに基づいて色を決定
    switch (soundId) {
      case 'button1':
      case 'piano_c4':
      case 'note_0':
        return const Color(0xFFFF6B6B); // 赤
      case 'button2':
      case 'piano_d4':
      case 'note_1':
        return const Color(0xFF4ECDC4); // 青緑
      case 'button3':
      case 'piano_e4':
      case 'note_2':
        return const Color(0xFFFFE66D); // 黄
      case 'button4':
      case 'piano_f4':
      case 'note_3':
        return const Color(0xFFA8E6CF); // 緑
      default:
        return Color(AppColors.primaryColor);
    }
  }

  Widget _buildNoteImage() {
    // キーボード画像を使用する場合
    final keyboardPath = AssetManager.getKeyboardAssetPath('tap1');
    if (keyboardPath != null) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _getNoteColor().withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(_getNoteColor(), BlendMode.modulate),
            child: Image.asset(keyboardPath, fit: BoxFit.cover),
          ),
        ),
      );
    }

    // 画像がない場合はカスタム描画
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [_getNoteColor(), _getNoteColor().withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getNoteColor().withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.music_note, color: Colors.white, size: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 30, // 中央配置
      top: widget.position * (MediaQuery.of(context).size.height - 120) + 60,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedOpacity(
                opacity: widget.isActive ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // メインのノート
                    _buildNoteImage(),

                    // タップエフェクト
                    if (_isTapped)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.8),
                            width: 3,
                          ),
                        ),
                      ),

                    // パーフェクト判定エリアの表示（デバッグ用）
                    if (kDebugMode && widget.position > 0.8)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ノートの判定結果を表す列挙型
enum NoteJudgment { perfect, good, miss }

// ノート判定の設定
class NoteJudgmentConfig {
  static const double perfectThreshold = 0.05; // ±50ms
  static const double goodThreshold = 0.15; // ±150ms

  static NoteJudgment getJudgment(double timingDifference) {
    final absDiff = timingDifference.abs();
    if (absDiff <= perfectThreshold) {
      return NoteJudgment.perfect;
    } else if (absDiff <= goodThreshold) {
      return NoteJudgment.good;
    } else {
      return NoteJudgment.miss;
    }
  }

  static int getScore(NoteJudgment judgment) {
    switch (judgment) {
      case NoteJudgment.perfect:
        return 1000;
      case NoteJudgment.good:
        return 500;
      case NoteJudgment.miss:
        return 0;
    }
  }

  static String getJudgmentText(NoteJudgment judgment) {
    switch (judgment) {
      case NoteJudgment.perfect:
        return 'PERFECT!';
      case NoteJudgment.good:
        return 'GOOD';
      case NoteJudgment.miss:
        return 'MISS';
    }
  }

  static Color getJudgmentColor(NoteJudgment judgment) {
    switch (judgment) {
      case NoteJudgment.perfect:
        return const Color(0xFFFFD700); // ゴールド
      case NoteJudgment.good:
        return const Color(0xFF32CD32); // 緑
      case NoteJudgment.miss:
        return const Color(0xFFFF4444); // 赤
    }
  }
}
