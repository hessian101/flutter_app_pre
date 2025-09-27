import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  /// Google Driveのダイレクトリンクからファイルをダウンロード
  Future<String?> downloadFromGoogleDrive({
    required String driveUrl,
    required String fileName,
    String subfolder = 'downloads',
  }) async {
    try {
      // Google Drive共有リンクを直接ダウンロード用に変換
      final directUrl = _convertToDirectDownloadUrl(driveUrl);
      
      debugPrint('ダウンロード開始: $fileName');
      
      // HTTPリクエストでファイルを取得
      final response = await http.get(Uri.parse(directUrl));
      
      if (response.statusCode == 200) {
        // ローカルストレージに保存
        final filePath = await _saveToLocalStorage(
          response.bodyBytes, 
          fileName, 
          subfolder,
        );
        
        debugPrint('ダウンロード完了: $filePath');
        return filePath;
      } else {
        throw Exception('ダウンロード失敗: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ダウンロードエラー: $e');
      return null;
    }
  }

  /// 複数の音源ファイルを一括ダウンロード
  Future<Map<String, String?>> downloadSoundPack({
    required Map<String, String> soundUrls,
  }) async {
    final Map<String, String?> results = {};
    
    for (final entry in soundUrls.entries) {
      final fileName = entry.key;
      final url = entry.value;
      
      results[fileName] = await downloadFromGoogleDrive(
        driveUrl: url,
        fileName: fileName,
        subfolder: 'sounds',
      );
      
      // 連続ダウンロードの間隔
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return results;
  }

  /// Google Drive共有リンクを直接ダウンロード用URLに変換
  String _convertToDirectDownloadUrl(String shareUrl) {
    // Google Drive共有リンクのパターン:
    // https://drive.google.com/file/d/FILE_ID/view?usp=sharing
    // 直接ダウンロード用:
    // https://drive.google.com/uc?export=download&id=FILE_ID
    
    final regex = RegExp(r'/file/d/([a-zA-Z0-9-_]+)');
    final match = regex.firstMatch(shareUrl);
    
    if (match != null) {
      final fileId = match.group(1);
      return 'https://drive.google.com/uc?export=download&id=$fileId';
    }
    
    // 既に直接ダウンロード形式の場合はそのまま返す
    return shareUrl;
  }

  /// ファイルをローカルストレージに保存
  Future<String> _saveToLocalStorage(
    List<int> bytes, 
    String fileName, 
    String subfolder,
  ) async {
    // iOSの場合: Documents ディレクトリ
    // Androidの場合: External Storage または Internal Storage
    final directory = await getApplicationDocumentsDirectory();
    final subDir = Directory(path.join(directory.path, subfolder));
    
    // サブフォルダが存在しない場合は作成
    if (!await subDir.exists()) {
      await subDir.create(recursive: true);
    }
    
    final filePath = path.join(subDir.path, fileName);
    final file = File(filePath);
    
    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// ダウンロード済みファイルの存在確認
  Future<bool> isFileDownloaded(String fileName, {String subfolder = 'downloads'}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, subfolder, fileName);
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// ローカルファイルパスを取得
  Future<String> getLocalFilePath(String fileName, {String subfolder = 'downloads'}) async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, subfolder, fileName);
  }

  /// ダウンロード済みファイルを削除
  Future<bool> deleteDownloadedFile(String fileName, {String subfolder = 'downloads'}) async {
    try {
      final filePath = await getLocalFilePath(fileName, subfolder: subfolder);
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ファイル削除エラー: $e');
      return false;
    }
  }

  /// ダウンロード済みファイル一覧を取得
  Future<List<String>> getDownloadedFiles({String subfolder = 'downloads'}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final subDir = Directory(path.join(directory.path, subfolder));
      
      if (!await subDir.exists()) {
        return [];
      }
      
      final files = await subDir.list().toList();
      return files
          .whereType<File>()
          .map((file) => path.basename(file.path))
          .toList();
    } catch (e) {
      debugPrint('ファイル一覧取得エラー: $e');
      return [];
    }
  }
}