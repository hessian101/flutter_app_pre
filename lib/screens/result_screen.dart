import 'package:flutter/material.dart';
import '../models/star_data.dart';
import '../models/high_score.dart';
import '../models/saved_song.dart';
import '../services/database_service.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';

class ResultScreen extends StatefulWidget {
  final GameResult result;

  const ResultScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isHighScore = false;
  bool _saveDialogShown = false;
  
  final DatabaseService _databaseService = DatabaseService();
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _saveHighScore();
    _checkIfHighScore();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!_saveDialogShown) {
        _showSaveRecordingDialog();
      }
    });
  }

  void _saveHighScore() async {
    try {
      final highScore = HighScore(
        date: DateTime.now().toIso8601String(),
        score: widget.result.score,
        accuracy: widget.result.accuracy,
        comboMax: widget.result.maxCombo,
      );

      await _databaseService.insertHighScore(highScore);
    } catch (e) {
      debugPrint('ハイスコア保存エラー: $e');
    }
  }

  void _checkIfHighScore() async {
    try {
      final topScores = await _databaseService.getTopHighScores(limit: 10);
      if (topScores.isNotEmpty) {
        final highestScore = topScores.first.score;
        _isHighScore = widget.result.score >= highestScore;
      } else {
        _isHighScore = true;
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('ハイスコアチェックエラー: $e');
    }
  }

  void _showSaveRecordingDialog() {
    if (_saveDialogShown) return;
    _saveDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(AppColors.surfaceColor),
        title: Text(
          '演奏を保存しますか？',
          style: TextStyle(color: Color(AppColors.textColor)),
        ),
        content: Text(
          'この演奏の録音をWAVファイルとして保存できます。',
          style: TextStyle(color: Color(AppColors.secondaryTextColor)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _discardRecording();
            },
            child: Text(
              'いいえ',
              style: TextStyle(color: Color(AppColors.secondaryTextColor)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _saveRecording();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.primaryColor),
            ),
            child: Text(
              'はい',
              style: TextStyle(color: Color(AppColors.textColor)),
            ),
          ),
        ],
      ),
    );
  }

  void _saveRecording() async {
    try {
      final filePath = await _audioService.saveRecording();
      if (filePath != null) {
        final savedSong = SavedSong(
          date: DateTime.now().toIso8601String(),
          filePath: filePath,
          score: widget.result.score,
          accuracy: widget.result.accuracy,
        );

        await _databaseService.insertSavedSong(savedSong);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('演奏が保存されました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('録音保存エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('保存に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _discardRecording() async {
    try {
      await _audioService.discardRecording();
    } catch (e) {
      debugPrint('録音破棄エラー: $e');
    }
  }

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
              children: [
                const SizedBox(height: 40),
                if (_isHighScore)
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Color(AppColors.goldColor),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ハイスコア！',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.goldColor),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildResultCard(),
                ),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(AppColors.surfaceColor),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isHighScore ? Color(AppColors.goldColor) : Color(AppColors.primaryColor),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ゲーム結果',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.textColor),
            ),
          ),
          const SizedBox(height: 24),
          _buildResultRow('スコア', widget.result.score.toString()),
          _buildResultRow('正確度', '${widget.result.accuracy.toStringAsFixed(1)}%'),
          _buildResultRow('最大コンボ', widget.result.maxCombo.toString()),
          const SizedBox(height: 16),
          Divider(color: Color(AppColors.secondaryTextColor)),
          const SizedBox(height: 16),
          _buildResultRow('Perfect', widget.result.perfectCount.toString(), Color(AppColors.goldColor)),
          _buildResultRow('Good', widget.result.goodCount.toString(), Colors.green),
          _buildResultRow('Miss', widget.result.missCount.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Color(AppColors.secondaryTextColor),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Color(AppColors.textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.home,
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.primaryColor),
              foregroundColor: Color(AppColors.textColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'ホームに戻る',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.highScore),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(AppColors.textColor),
                  side: BorderSide(color: Color(AppColors.primaryColor)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('ハイスコア'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, Routes.performanceList),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Color(AppColors.textColor),
                  side: BorderSide(color: Color(AppColors.primaryColor)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('演奏記録'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.game,
              (route) => false,
            );
          },
          child: Text(
            'もう一度プレイ',
            style: TextStyle(
              color: Color(AppColors.accentColor),
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}