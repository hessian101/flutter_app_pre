import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as path;
import '../utils/audio_utils.dart';
import 'download_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final Record _recorder = Record();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentRecordingPath;
  final List<TapSound> _recordedSounds = [];
  DateTime? _recordingStartTime;

  VoidCallback? _playbackCompleteCallback;

  Future<void> initialize() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.game,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ),
    );
  }

  Future<void> startRecording() async {
    try {
      if (_isRecording) return;

      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        throw Exception('録音権限がありません');
      }

      await _recorder.start();

      _isRecording = true;
      _recordedSounds.clear();
      _recordingStartTime = DateTime.now();

      print('録音開始');
    } catch (e) {
      print('録音開始エラー: $e');
      rethrow;
    }
  }

  Future<void> stopRecording() async {
    try {
      if (!_isRecording) return;

      final recordPath = await _recorder.stop();
      _currentRecordingPath = recordPath;
      _isRecording = false;
      print('録音停止: $_currentRecordingPath');
    } catch (e) {
      print('録音停止エラー: $e');
      rethrow;
    }
  }

  void recordTapSound(String soundId, double timing) {
    if (!_isRecording || _recordingStartTime == null) return;

    final tapSound = TapSound(
      soundId: soundId,
      timing: timing,
      timestamp: DateTime.now(),
    );

    _recordedSounds.add(tapSound);
    print('タップ音記録: $soundId at $timing');
  }

  Future<void> playTapSound(String soundId) async {
    try {
      recordTapSound(soundId, DateTime.now().millisecondsSinceEpoch / 1000.0);

      // 1. まずダウンロード済み音源を確認
      final downloadService = DownloadService();
      final fileName = '$soundId.wav';

      if (await downloadService.isFileDownloaded(
        fileName,
        subfolder: 'sounds',
      )) {
        // ダウンロード済み音源を再生
        final localPath = await downloadService.getLocalFilePath(
          fileName,
          subfolder: 'sounds',
        );
        await _playLocalSound(localPath);
        print('ダウンロード音源再生: $soundId');
        return;
      }

      // 2. アセット音源を再生
      final soundPath = 'assets/sounds/$fileName';
      await _playAssetSound(soundPath);
      print('アセット音源再生: $soundId');
    } catch (e) {
      print('タップ音再生エラー: $e');
      // フォールバック: 周波数情報を表示
      final frequency = _getSoundFrequency(soundId);
      print('フォールバック - 周波数: $frequency Hz');
    }
  }

  Future<void> _playAssetSound(String assetPath) async {
    try {
      // 新しいプレイヤーを作成（同時再生のため）
      final player = AudioPlayer();
      await player.setAsset(assetPath);
      await player.play();

      // 再生完了後にリソースを解放
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
        }
      });
    } catch (e) {
      print('アセット音源再生エラー: $e');
      // アセット音源がない場合でもエラーにしない
    }
  }

  Future<void> _playLocalSound(String filePath) async {
    try {
      // 新しいプレイヤーを作成（同時再生のため）
      final player = AudioPlayer();
      await player.setFilePath(filePath);
      await player.play();

      // 再生完了後にリソースを解放
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          player.dispose();
        }
      });
    } catch (e) {
      print('ローカル音源再生エラー: $e');
    }
  }

  double _getSoundFrequency(String soundId) {
    final frequencies = {
      'note_0': 261.63, // C4
      'note_1': 293.66, // D4
      'note_2': 329.63, // E4
      'note_3': 349.23, // F4
      'note_4': 392.00, // G4
      'note_5': 440.00, // A4
      'note_6': 493.88, // B4
      'note_7': 523.25, // C5
    };

    return frequencies[soundId] ?? 440.0;
  }

  Future<String?> saveRecording() async {
    try {
      if (_currentRecordingPath == null) return null;

      // ファイルの存在確認
      final file = File(_currentRecordingPath!);
      if (!await file.exists()) {
        print('録音ファイルが見つかりません: $_currentRecordingPath');
        return null;
      }

      // より適切な保存場所にコピー
      final audioDir = await AudioUtils.getAudioRecordingsDirectory();
      final fileName = AudioUtils.generateFileName(prefix: 'game');
      final finalPath = path.join(audioDir, fileName);

      await file.copy(finalPath);
      await _synthesizeAudioWithTaps();

      final savedPath = finalPath;
      _currentRecordingPath = null;
      _recordedSounds.clear();

      print('録音保存完了: $savedPath');
      return savedPath;
    } catch (e) {
      print('録音保存エラー: $e');
      return null;
    }
  }

  Future<void> _synthesizeAudioWithTaps() async {
    print('音声合成処理（実装予定）');
    print('記録されたタップ音: ${_recordedSounds.length}個');

    for (final sound in _recordedSounds) {
      print('- ${sound.soundId} at ${sound.timing}');
    }
  }

  Future<void> discardRecording() async {
    try {
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
        _currentRecordingPath = null;
      }
      _recordedSounds.clear();
      print('録音破棄完了');
    } catch (e) {
      print('録音破棄エラー: $e');
    }
  }

  Future<void> playRecording(String filePath) async {
    try {
      if (_isPlaying) {
        await stopPlayback();
      }

      await _player.setFilePath(filePath);
      _isPlaying = true;

      _player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _playbackCompleteCallback?.call();
        }
      });

      await _player.play();
      print('再生開始: $filePath');
    } catch (e) {
      print('再生エラー: $e');
      _isPlaying = false;
      rethrow;
    }
  }

  Future<void> stopPlayback() async {
    try {
      if (_isPlaying) {
        await _player.stop();
        _isPlaying = false;
        print('再生停止');
      }
    } catch (e) {
      print('再生停止エラー: $e');
    }
  }

  void setPlaybackCompleteCallback(VoidCallback callback) {
    _playbackCompleteCallback = callback;
  }

  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;
  List<TapSound> get recordedSounds => List.unmodifiable(_recordedSounds);

  Future<void> dispose() async {
    await stopRecording();
    await stopPlayback();
    await _recorder.dispose();
    await _player.dispose();
  }
}

class TapSound {
  final String soundId;
  final double timing;
  final DateTime timestamp;

  TapSound({
    required this.soundId,
    required this.timing,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'sound_id': soundId,
      'timing': timing,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory TapSound.fromMap(Map<String, dynamic> map) {
    return TapSound(
      soundId: map['sound_id'],
      timing: map['timing']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  @override
  String toString() {
    return 'TapSound{soundId: $soundId, timing: $timing, timestamp: $timestamp}';
  }
}
