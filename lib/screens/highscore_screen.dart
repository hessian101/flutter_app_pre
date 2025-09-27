import 'package:flutter/material.dart';
import '../models/high_score.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class HighScoreScreen extends StatefulWidget {
  const HighScoreScreen({super.key});

  @override
  State<HighScoreScreen> createState() => _HighScoreScreenState();
}

class _HighScoreScreenState extends State<HighScoreScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<HighScore> _highScores = [];
  bool _isLoading = true;
  bool _sortByScore = true;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
  }

  void _loadHighScores() async {
    try {
      final scores = await _databaseService.getAllHighScores(sortByScore: _sortByScore);
      setState(() {
        _highScores = scores;
        _isLoading = false;
      });
    } catch (e) {
      print('ハイスコア読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleSort() {
    setState(() {
      _sortByScore = !_sortByScore;
    });
    _loadHighScores();
  }

  void _showDeleteDialog(HighScore score) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(AppColors.surfaceColor),
        title: Text(
          'スコアを削除',
          style: TextStyle(color: Color(AppColors.textColor)),
        ),
        content: Text(
          'このスコアを削除しますか？',
          style: TextStyle(color: Color(AppColors.secondaryTextColor)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'キャンセル',
              style: TextStyle(color: Color(AppColors.secondaryTextColor)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteScore(score);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _deleteScore(HighScore score) async {
    try {
      if (score.id != null) {
        await _databaseService.deleteHighScore(score.id!);
        _loadHighScores();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('スコアを削除しました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('スコア削除エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('削除に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      appBar: AppBar(
        title: const Text('ハイスコア'),
        backgroundColor: Color(AppColors.surfaceColor),
        foregroundColor: Color(AppColors.textColor),
        actions: [
          IconButton(
            onPressed: _toggleSort,
            icon: Icon(_sortByScore ? Icons.trending_down : Icons.access_time),
            tooltip: _sortByScore ? '日付順で並び替え' : 'スコア順で並び替え',
          ),
        ],
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _highScores.isEmpty
                ? _buildEmptyState()
                : _buildScoreList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 80,
            color: Color(AppColors.secondaryTextColor),
          ),
          const SizedBox(height: 16),
          Text(
            'まだスコアがありません',
            style: TextStyle(
              fontSize: 18,
              color: Color(AppColors.secondaryTextColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ゲームをプレイしてスコアを記録しましょう',
            style: TextStyle(
              fontSize: 14,
              color: Color(AppColors.secondaryTextColor),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, Routes.game),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.primaryColor),
              foregroundColor: Color(AppColors.textColor),
            ),
            child: const Text('ゲームを開始'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                _sortByScore ? Icons.trending_down : Icons.access_time,
                color: Color(AppColors.secondaryTextColor),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _sortByScore ? 'スコア順' : '日付順',
                style: TextStyle(
                  color: Color(AppColors.secondaryTextColor),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${_highScores.length}件のスコア',
                style: TextStyle(
                  color: Color(AppColors.secondaryTextColor),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _highScores.length,
            itemBuilder: (context, index) {
              final score = _highScores[index];
              final rank = _sortByScore ? index + 1 : null;
              
              return Card(
                color: Color(AppColors.surfaceColor),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: rank != null
                      ? CircleAvatar(
                          backgroundColor: _getRankColor(rank),
                          child: Text(
                            '$rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.calendar_today,
                          color: Color(AppColors.secondaryTextColor),
                        ),
                  title: Row(
                    children: [
                      Text(
                        '${score.score}',
                        style: TextStyle(
                          color: Color(AppColors.textColor),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Color(AppColors.primaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${score.accuracy.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '最大コンボ: ${score.comboMax}',
                        style: TextStyle(
                          color: Color(AppColors.secondaryTextColor),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(score.date),
                        style: TextStyle(
                          color: Color(AppColors.secondaryTextColor),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _showDeleteDialog(score),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Color(AppColors.secondaryTextColor),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Color(AppColors.goldColor);
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown;
      default:
        return Color(AppColors.primaryColor);
    }
  }
}