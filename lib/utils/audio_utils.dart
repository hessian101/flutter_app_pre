import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AudioUtils {
  static Future<String> getAudioRecordingsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final audioDir = Directory(path.join(directory.path, 'audio_recordings'));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }

  static String generateFileName({String? prefix}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final prefixString = prefix != null ? '${prefix}_' : '';
    return '${prefixString}recording_$timestamp.wav';
  }

  static Future<String> getFullFilePath(String fileName) async {
    final audioDir = await getAudioRecordingsDirectory();
    return path.join(audioDir, fileName);
  }

  static Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting audio file: $e');
      return false;
    }
  }

  static Future<List<String>> getAllAudioFiles() async {
    try {
      final audioDir = await getAudioRecordingsDirectory();
      final directory = Directory(audioDir);
      final files = await directory.list().toList();
      
      return files
          .where((file) => file is File && file.path.endsWith('.wav'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      debugPrint('Error getting audio files: $e');
      return [];
    }
  }

  static double calculateTimingAccuracy(double expectedTime, double actualTime) {
    final difference = (expectedTime - actualTime).abs();
    return 1.0 - (difference / 1.0).clamp(0.0, 1.0);
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  static Future<int> getFileSizeInBytes(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}