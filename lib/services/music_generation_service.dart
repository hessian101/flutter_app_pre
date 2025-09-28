import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class TapRecord {
  final String soundId;
  final double timestamp;
  final double accuracy; // 0.0-1.0 (0.0=Miss, 0.7=Good, 1.0=Perfect)

  TapRecord({
    required this.soundId,
    required this.timestamp,
    required this.accuracy,
  });
}

class MusicGenerationService {
  final List<TapRecord> _tapRecords = [];

  // 音楽生成パラメータ
  static const int _sampleRate = 44100;
  static const double _noteDuration = 0.5; // 秒
  static const int _bitsPerSample = 16;
  static const int _channels = 1; // モノラル

  // 周波数マッピング
  static const Map<String, double> _frequencyMap = {
    'note_0': 261.63, // C4
    'button1': 261.63, // C4
    'note_2': 329.63, // E4
    'button2': 329.63, // E4
    'note_4': 392.00, // G4
    'button3': 392.00, // G4
    'note_7': 523.25, // C5
    'button4': 523.25, // C5
  };

  // ADSRエンベロープパラメータ
  static const double _attackTime = 0.05; // 5ms
  static const double _decayTime = 0.1; // 10ms
  static const double _sustainLevel = 0.7;
  static const double _releaseTime = 0.2; // 20ms

  // 倍音パラメータ
  static const double _harmonic2Level = 0.3; // 2倍音 30%
  static const double _harmonic3Level = 0.1; // 3倍音 10%

  // 音量正規化レベル
  static const double _maxVolume = 0.8;

  /// タップ記録を追加
  void recordTap(String soundId, double timestamp, double accuracy) {
    _tapRecords.add(
      TapRecord(soundId: soundId, timestamp: timestamp, accuracy: accuracy),
    );
    debugPrint(
      'タップ記録: $soundId at ${timestamp.toStringAsFixed(2)}s, accuracy: ${(accuracy * 100).toStringAsFixed(1)}%',
    );
  }

  /// 記録をクリア
  void clearRecords() {
    _tapRecords.clear();
    debugPrint('タップ記録をクリアしました');
  }

  /// 音楽WAVデータを生成
  Future<Uint8List> generateMusicWav() async {
    if (_tapRecords.isEmpty) {
      debugPrint('タップ記録がありません');
      return Uint8List(0);
    }

    debugPrint('音楽生成開始: ${_tapRecords.length}個のタップ記録');

    // 全体の長さを計算（最後のタップ + ノート長 + リリース時間）
    final double totalDuration =
        _tapRecords
            .map((record) => record.timestamp)
            .reduce((a, b) => a > b ? a : b) +
        _noteDuration +
        _releaseTime;

    final int totalSamples = (totalDuration * _sampleRate).round();
    final List<double> audioBuffer = List.filled(totalSamples, 0.0);

    // 各タップ記録に対して音を生成
    for (final record in _tapRecords) {
      final double frequency = _frequencyMap[record.soundId] ?? 261.63;
      final double volume = _calculateVolume(record.accuracy);
      final int startSample = (record.timestamp * _sampleRate).round();

      _generateNote(audioBuffer, startSample, frequency, volume);
    }

    // 音量正規化
    _normalizeVolume(audioBuffer);

    // WAVヘッダーとPCMデータを結合
    final Uint8List wavData = _createWavFile(audioBuffer);

    debugPrint('音楽生成完了: ${wavData.length} bytes');
    return wavData;
  }

  /// 音量を計算（精度に基づく）
  double _calculateVolume(double accuracy) {
    if (accuracy >= 0.9) return 1.0; // Perfect
    if (accuracy >= 0.7) return 0.7; // Good
    return 0.3; // Miss
  }

  /// 単一の音符を生成
  void _generateNote(
    List<double> audioBuffer,
    int startSample,
    double frequency,
    double volume,
  ) {
    final int noteSamples = (_noteDuration * _sampleRate).round();
    final int endSample = (startSample + noteSamples).clamp(
      0,
      audioBuffer.length,
    );

    for (int i = startSample; i < endSample; i++) {
      if (i >= audioBuffer.length) break;

      final double time = (i - startSample) / _sampleRate;
      final double envelope = _calculateEnvelope(time);

      // 基本波 + 倍音
      final double fundamental = sin(2 * pi * frequency * time);
      final double harmonic2 =
          sin(2 * pi * frequency * 2 * time) * _harmonic2Level;
      final double harmonic3 =
          sin(2 * pi * frequency * 3 * time) * _harmonic3Level;

      final double sample =
          (fundamental + harmonic2 + harmonic3) * envelope * volume;
      audioBuffer[i] += sample;
    }
  }

  /// ADSRエンベロープを計算
  double _calculateEnvelope(double time) {
    if (time < _attackTime) {
      // Attack
      return time / _attackTime;
    } else if (time < _attackTime + _decayTime) {
      // Decay
      final double decayProgress = (time - _attackTime) / _decayTime;
      return 1.0 - (1.0 - _sustainLevel) * decayProgress;
    } else if (time < _noteDuration - _releaseTime) {
      // Sustain
      return _sustainLevel;
    } else {
      // Release
      final double releaseProgress =
          (time - (_noteDuration - _releaseTime)) / _releaseTime;
      return _sustainLevel * (1.0 - releaseProgress).clamp(0.0, 1.0);
    }
  }

  /// 音量正規化
  void _normalizeVolume(List<double> audioBuffer) {
    double maxAmplitude = 0.0;

    // 最大振幅を検出
    for (final sample in audioBuffer) {
      maxAmplitude = max(maxAmplitude, sample.abs());
    }

    if (maxAmplitude > 0.0) {
      final double normalizationFactor = _maxVolume / maxAmplitude;
      for (int i = 0; i < audioBuffer.length; i++) {
        audioBuffer[i] *= normalizationFactor;
      }
    }
  }

  /// WAVファイルを作成
  Uint8List _createWavFile(List<double> audioBuffer) {
    final int dataSize = audioBuffer.length * 2; // 16-bit = 2 bytes per sample
    final int fileSize = 44 + dataSize - 8; // WAV header size + data size - 8

    final ByteData wavData = ByteData(44 + dataSize);

    // WAVヘッダー
    wavData.setUint8(0, 0x52); // 'R'
    wavData.setUint8(1, 0x49); // 'I'
    wavData.setUint8(2, 0x46); // 'F'
    wavData.setUint8(3, 0x46); // 'F'
    wavData.setUint32(4, fileSize, Endian.little);
    wavData.setUint8(8, 0x57); // 'W'
    wavData.setUint8(9, 0x41); // 'A'
    wavData.setUint8(10, 0x56); // 'V'
    wavData.setUint8(11, 0x45); // 'E'
    wavData.setUint8(12, 0x66); // 'f'
    wavData.setUint8(13, 0x6D); // 'm'
    wavData.setUint8(14, 0x74); // 't'
    wavData.setUint8(15, 0x20); // ' '
    wavData.setUint32(16, 16, Endian.little); // fmt chunk size
    wavData.setUint16(20, 1, Endian.little); // audio format (PCM)
    wavData.setUint16(22, _channels, Endian.little);
    wavData.setUint32(24, _sampleRate, Endian.little);
    wavData.setUint32(
      28,
      _sampleRate * _channels * _bitsPerSample ~/ 8,
      Endian.little,
    ); // byte rate
    wavData.setUint16(
      32,
      _channels * _bitsPerSample ~/ 8,
      Endian.little,
    ); // block align
    wavData.setUint16(34, _bitsPerSample, Endian.little);
    wavData.setUint8(36, 0x64); // 'd'
    wavData.setUint8(37, 0x61); // 'a'
    wavData.setUint8(38, 0x74); // 't'
    wavData.setUint8(39, 0x61); // 'a'
    wavData.setUint32(40, dataSize, Endian.little);

    // PCMデータ
    for (int i = 0; i < audioBuffer.length; i++) {
      final int sample = (audioBuffer[i] * 32767).round().clamp(-32768, 32767);
      wavData.setInt16(44 + i * 2, sample, Endian.little);
    }

    return wavData.buffer.asUint8List();
  }

  /// 記録されたタップ数を取得
  int get recordCount => _tapRecords.length;

  /// 記録されたタップデータを取得（デバッグ用）
  List<TapRecord> get records => List.unmodifiable(_tapRecords);
}
