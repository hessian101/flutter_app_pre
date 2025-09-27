import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/star_data.dart';

class ApiService {
  static const String _baseUrl = 'https://api.example.com';
  static const String _apiKey = 'your_api_key_here';
  
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('画像選択エラー: $e');
      return null;
    }
  }

  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('カメラ撮影エラー: $e');
      return null;
    }
  }

  Future<List<StarData>> processStarImage(XFile imageFile) async {
    try {
      debugPrint('星座画像解析開始: ${imageFile.path}');
      
      // 実際のAPI呼び出しを試行
      try {
        final apiResponse = await _callStarAnalysisApi(imageFile);
        if (apiResponse != null) {
          debugPrint('API解析完了: ${apiResponse.length}個の星を検出');
          return apiResponse;
        }
      } catch (apiError) {
        debugPrint('API呼び出し失敗、フォールバックデータを使用: $apiError');
      }
      
      // APIが失敗した場合のフォールバック
      await Future.delayed(const Duration(seconds: 1));
      final fallbackData = _getFallbackStarData();
      debugPrint('フォールバック解析完了: ${fallbackData.length}個の星を検出');
      
      return fallbackData;
    } catch (e) {
      debugPrint('画像解析エラー: $e');
      throw ApiException('画像の解析に失敗しました: $e');
    }
  }



  /// 実際のAPI呼び出し（現在はモック）
  Future<List<StarData>?> _callStarAnalysisApi(XFile imageFile) async {
    try {
      // 画像をbase64エンコード
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze-stars'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'image': base64Image,
          'options': {
            'max_stars': 20,
            'sensitivity': 0.8,
            'generate_music': true,
          }
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return _parseApiResponse(data);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('API呼び出しエラー: $e');
      return null;
    }
  }

  /// APIレスポンスをStarDataに変換
  List<StarData> _parseApiResponse(Map<String, dynamic> response) {
    final List<dynamic> starsData = response['stars'] ?? [];
    return starsData.map((star) => StarData(
      x: (star['x'] as num).toDouble(),
      y: (star['y'] as num).toDouble(),
      soundId: star['soundId'] as String? ?? 'note_0',
      timing: (star['timing'] as num).toDouble(),
    )).toList();
  }

  /// APIが利用できない場合のフォールバックデータ
  /// 実際のAPIレスポンス形式に準拠した構造
  List<StarData> _getFallbackStarData() {
    // 実際のAPIから期待されるレスポンス形式のフォールバックデータ
    // constellation: "orion" のような識別子も含めることができる
    return [
      // 4レーン対応のデモデータ（レーン0-3にマッピング）
      StarData(x: 0, y: 0, soundId: 'button1', timing: 2.0),   // レーン0
      StarData(x: 1, y: 0, soundId: 'button2', timing: 2.5),   // レーン1
      StarData(x: 2, y: 0, soundId: 'button3', timing: 3.0),   // レーン2
      StarData(x: 3, y: 0, soundId: 'button4', timing: 3.5),   // レーン3
      
      StarData(x: 0, y: 0, soundId: 'button1', timing: 4.0),   
      StarData(x: 2, y: 0, soundId: 'button3', timing: 4.2),   
      StarData(x: 1, y: 0, soundId: 'button2', timing: 4.5),   
      StarData(x: 3, y: 0, soundId: 'button4', timing: 4.7),   
      
      StarData(x: 0, y: 0, soundId: 'button1', timing: 5.0),   
      StarData(x: 1, y: 0, soundId: 'button2', timing: 5.0),   
      StarData(x: 2, y: 0, soundId: 'button3', timing: 5.2),   
      StarData(x: 3, y: 0, soundId: 'button4', timing: 5.4),   
      
      StarData(x: 2, y: 0, soundId: 'button3', timing: 6.0),   
      StarData(x: 0, y: 0, soundId: 'button1', timing: 6.3),   
      StarData(x: 3, y: 0, soundId: 'button4', timing: 6.5),   
      StarData(x: 1, y: 0, soundId: 'button2', timing: 6.8),   
      
      StarData(x: 1, y: 0, soundId: 'button2', timing: 7.5),   
      StarData(x: 2, y: 0, soundId: 'button3', timing: 8.0),   
      StarData(x: 0, y: 0, soundId: 'button1', timing: 8.3),   
      StarData(x: 3, y: 0, soundId: 'button4', timing: 8.5),   
      
      StarData(x: 0, y: 0, soundId: 'button1', timing: 9.0),   
      StarData(x: 1, y: 0, soundId: 'button2', timing: 9.2),   
      StarData(x: 2, y: 0, soundId: 'button3', timing: 9.4),   
      StarData(x: 3, y: 0, soundId: 'button4', timing: 9.6),
    ]..sort((a, b) => a.timing.compareTo(b.timing));
  }

  Future<bool> validateImage(XFile imageFile) async {
    try {
      final file = File(imageFile.path);
      final size = await file.length();
      
      if (size > 10 * 1024 * 1024) {
        throw ApiException('画像ファイルサイズが大きすぎます（最大10MB）');
      }

      final bytes = await imageFile.readAsBytes();
      if (bytes.isEmpty) {
        throw ApiException('画像ファイルが空です');
      }

      final mimeType = imageFile.mimeType;
      if (mimeType == null || 
          (!mimeType.startsWith('image/jpeg') && 
           !mimeType.startsWith('image/png') && 
           !mimeType.startsWith('image/jpg'))) {
        throw ApiException('サポートされていない画像形式です（JPEG, PNG対応）');
      }

      return true;
    } catch (e) {
      debugPrint('画像検証エラー: $e');
      if (e is ApiException) rethrow;
      throw ApiException('画像の検証に失敗しました');
    }
  }

  Future<Map<String, dynamic>> getApiStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/status'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'status': 'error', 'message': 'API unavailable'};
      }
    } catch (e) {
      debugPrint('API状態確認エラー: $e');
      return {
        'status': 'offline',
        'message': 'デモモードで動作中',
        'demo_mode': true,
      };
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}