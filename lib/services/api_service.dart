import 'dart:convert';
import 'dart:io';
import 'dart:math';
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
      print('画像選択エラー: $e');
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
      print('カメラ撮影エラー: $e');
      return null;
    }
  }

  Future<List<StarData>> processStarImage(XFile imageFile) async {
    try {
      print('星座画像解析開始: ${imageFile.path}');
      
      await Future.delayed(const Duration(seconds: 2));
      
      final demoStarData = _generateDemoStarData();
      print('解析完了: ${demoStarData.length}個の星を検出');
      
      return demoStarData;
    } catch (e) {
      print('画像解析エラー: $e');
      throw ApiException('画像の解析に失敗しました: $e');
    }
  }



  List<StarData> _generateDemoStarData() {
    final random = Random();
    final List<StarData> stars = [];

    final patterns = [
      [
        {'x': 100.0, 'y': 150.0},
        {'x': 180.0, 'y': 120.0},
        {'x': 250.0, 'y': 160.0},
        {'x': 200.0, 'y': 220.0},
      ],
      [
        {'x': 80.0, 'y': 300.0},
        {'x': 150.0, 'y': 280.0},
        {'x': 220.0, 'y': 300.0},
        {'x': 150.0, 'y': 350.0},
      ],
      [
        {'x': 300.0, 'y': 200.0},
        {'x': 320.0, 'y': 250.0},
        {'x': 280.0, 'y': 280.0},
        {'x': 340.0, 'y': 300.0},
      ],
    ];

    double currentTiming = 1.0;
    
    for (int patternIndex = 0; patternIndex < patterns.length; patternIndex++) {
      final pattern = patterns[patternIndex];
      
      for (int starIndex = 0; starIndex < pattern.length; starIndex++) {
        final pos = pattern[starIndex];
        final soundId = 'note_${random.nextInt(8)}';
        
        stars.add(StarData(
          x: pos['x']! + random.nextDouble() * 40 - 20,
          y: pos['y']! + random.nextDouble() * 40 - 20,
          soundId: soundId,
          timing: currentTiming,
        ));
        
        currentTiming += 0.5 + random.nextDouble() * 0.5;
      }
      
      currentTiming += 1.0;
    }

    final extraStars = List.generate(8, (index) {
      return StarData(
        x: random.nextDouble() * 300 + 50,
        y: random.nextDouble() * 400 + 100,
        soundId: 'note_${random.nextInt(8)}',
        timing: currentTiming + index * 0.8,
      );
    });
    
    stars.addAll(extraStars);

    stars.sort((a, b) => a.timing.compareTo(b.timing));
    
    return stars;
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
      print('画像検証エラー: $e');
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
      print('API状態確認エラー: $e');
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