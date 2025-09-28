import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FileSaveService {
  /// 生成された音楽WAVファイルをローカルに保存
  static Future<String?> saveGeneratedMusic(
    Uint8List wavData,
    String fileName,
  ) async {
    try {
      // アプリのドキュメントディレクトリを取得
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String musicDir = '${appDocDir.path}/generated_music';

      // 音楽ディレクトリを作成（存在しない場合）
      final Directory musicDirectory = Directory(musicDir);
      if (!await musicDirectory.exists()) {
        await musicDirectory.create(recursive: true);
      }

      // ファイル名にタイムスタンプを追加
      final DateTime now = DateTime.now();
      final String timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
      final String fullFileName = '${fileName}_$timestamp.wav';
      final String filePath = '$musicDir/$fullFileName';

      // WAVファイルを保存
      final File file = File(filePath);
      await file.writeAsBytes(wavData);

      debugPrint('音楽ファイル保存完了: $filePath (${wavData.length} bytes)');
      return filePath;
    } catch (e) {
      debugPrint('音楽ファイル保存エラー: $e');
      return null;
    }
  }

  /// 保存された音楽ファイルの一覧を取得
  static Future<List<File>> getSavedMusicFiles() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String musicDir = '${appDocDir.path}/generated_music';
      final Directory musicDirectory = Directory(musicDir);

      if (!await musicDirectory.exists()) {
        return [];
      }

      final List<FileSystemEntity> files = await musicDirectory.list().toList();
      final List<File> musicFiles = files
          .where((file) => file is File && file.path.endsWith('.wav'))
          .cast<File>()
          .toList();

      // 作成日時の降順でソート
      musicFiles.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      return musicFiles;
    } catch (e) {
      debugPrint('音楽ファイル一覧取得エラー: $e');
      return [];
    }
  }

  /// 音楽ファイルを削除
  static Future<bool> deleteMusicFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('音楽ファイル削除完了: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('音楽ファイル削除エラー: $e');
      return false;
    }
  }

  /// 音楽ディレクトリのサイズを取得
  static Future<int> getMusicDirectorySize() async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String musicDir = '${appDocDir.path}/generated_music';
      final Directory musicDirectory = Directory(musicDir);

      if (!await musicDirectory.exists()) {
        return 0;
      }

      int totalSize = 0;
      await for (final FileSystemEntity entity in musicDirectory.list(
        recursive: true,
      )) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('音楽ディレクトリサイズ取得エラー: $e');
      return 0;
    }
  }

  /// ファイルサイズを人間が読みやすい形式に変換
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
