import 'package:flutter/material.dart';
import 'dart:io';
import '../models/saved_song.dart';
import '../services/database_service.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';
import '../utils/audio_utils.dart';

class PerformanceListScreen extends StatefulWidget {
  const PerformanceListScreen({super.key});

  @override
  State<PerformanceListScreen> createState() => _PerformanceListScreenState();
}

class _PerformanceListScreenState extends State<PerformanceListScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final AudioService _audioService = AudioService();

  List<SavedSong> _savedSongs = [];
  bool _isLoading = true;
  String? _currentlyPlayingId;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadSavedSongs();
  }

  void _loadSavedSongs() async {
    try {
      final songs = await _databaseService.getAllSavedSongs();
      setState(() {
        _savedSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      print('演奏記録読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playRecording(SavedSong song) async {
    try {
      if (_currentlyPlayingId == song.id.toString() && _isPlaying) {
        await _audioService.stopPlayback();
        setState(() {
          _isPlaying = false;
          _currentlyPlayingId = null;
        });
        return;
      }

      if (_isPlaying) {
        await _audioService.stopPlayback();
      }

      final file = File(song.filePath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ファイルが見つかりません'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await _audioService.playRecording(song.filePath);
      setState(() {
        _isPlaying = true;
        _currentlyPlayingId = song.id.toString();
      });

      _audioService.setPlaybackCompleteCallback(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentlyPlayingId = null;
          });
        }
      });
    } catch (e) {
      print('再生エラー: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('再生に失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteDialog(SavedSong song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(AppColors.surfaceColor),
        title: Text(
          '演奏記録を削除',
          style: TextStyle(color: Color(AppColors.textColor)),
        ),
        content: Text(
          'この演奏記録とファイルを削除しますか？\n削除すると元に戻せません。',
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
              _deleteSong(song);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _deleteSong(SavedSong song) async {
    try {
      if (song.id != null) {
        await _databaseService.deleteSavedSong(song.id!);
        await AudioUtils.deleteAudioFile(song.filePath);
        _loadSavedSongs();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('演奏記録を削除しました'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('削除エラー: $e');
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

  String _getFileName(String filePath) {
    return filePath.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      appBar: AppBar(
        title: const Text('演奏記録'),
        backgroundColor: Color(AppColors.surfaceColor),
        foregroundColor: Color(AppColors.textColor),
        actions: [
          if (_isPlaying)
            IconButton(
              onPressed: () async {
                await _audioService.stopPlayback();
                setState(() {
                  _isPlaying = false;
                  _currentlyPlayingId = null;
                });
              },
              icon: const Icon(Icons.stop),
              tooltip: '再生停止',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/home.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3)),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _savedSongs.isEmpty
              ? _buildEmptyState()
              : _buildSongList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.music_note_outlined,
            size: 80,
            color: Color(AppColors.secondaryTextColor),
          ),
          const SizedBox(height: 16),
          Text(
            '演奏記録がありません',
            style: TextStyle(
              fontSize: 18,
              color: Color(AppColors.secondaryTextColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ゲームをプレイして演奏を録音・保存しましょう',
            style: TextStyle(
              fontSize: 14,
              color: Color(AppColors.secondaryTextColor),
            ),
            textAlign: TextAlign.center,
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

  Widget _buildSongList() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.library_music,
                color: Color(AppColors.secondaryTextColor),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '保存された演奏',
                style: TextStyle(
                  color: Color(AppColors.secondaryTextColor),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${_savedSongs.length}件',
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
            itemCount: _savedSongs.length,
            itemBuilder: (context, index) {
              final song = _savedSongs[index];
              final isCurrentlyPlaying =
                  _currentlyPlayingId == song.id.toString() && _isPlaying;

              return Card(
                color: Color(AppColors.surfaceColor),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: IconButton(
                    onPressed: () => _playRecording(song),
                    icon: Icon(
                      isCurrentlyPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: isCurrentlyPlaying
                          ? Color(AppColors.accentColor)
                          : Color(AppColors.primaryColor),
                      size: 40,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getFileName(song.filePath),
                          style: TextStyle(
                            color: Color(AppColors.textColor),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentlyPlaying)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Color(AppColors.accentColor),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '再生中',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
                      Row(
                        children: [
                          Text(
                            'スコア: ${song.score}',
                            style: TextStyle(
                              color: Color(AppColors.secondaryTextColor),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Color(
                                AppColors.primaryColor,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${song.accuracy.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Color(AppColors.primaryColor),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(song.date),
                        style: TextStyle(
                          color: Color(AppColors.secondaryTextColor),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _showDeleteDialog(song),
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

  @override
  void dispose() {
    _audioService.stopPlayback();
    super.dispose();
  }
}
