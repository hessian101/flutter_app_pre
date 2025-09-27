import 'package:flutter/foundation.dart';

class AssetManager {
  static const String _soundsPath = 'assets/sounds/';
  static const String _keyboardsPath = 'assets/keyboards/';

  // BGM音源
  static const Map<String, String> bgmAssets = {
    'bgm1': '${_soundsPath}bgm1.mp3',
    'bgm2': '${_soundsPath}bgm2.mp3',
  };

  // ボタン音源（ノーツ音）
  static const Map<String, String> buttonSounds = {
    'button1': '${_soundsPath}button1.mp3',
    'button2': '${_soundsPath}button2.mp3',
    'button3': '${_soundsPath}button3.mp3',
    'button4': '${_soundsPath}button4.mp3',
  };

  // 効果音
  static const Map<String, String> effectSounds = {
    'binta': '${_soundsPath}binta.mp3',
  };

  // キーボード画像
  static const Map<String, String> keyboardAssets = {
    'tap1': '${_keyboardsPath}tap1.png',
  };

  // 全ボタン音をリストで取得
  static List<String> getAllButtonSounds() {
    return buttonSounds.values.toList();
  }

  // 全BGMをリストで取得
  static List<String> getAllBgmSounds() {
    return bgmAssets.values.toList();
  }

  // soundId から実際のアセットパスを取得
  static String? getSoundAssetPath(String soundId) {
    // ボタン音を優先的にチェック
    if (buttonSounds.containsKey(soundId)) {
      return buttonSounds[soundId];
    }
    
    // BGMをチェック
    if (bgmAssets.containsKey(soundId)) {
      return bgmAssets[soundId];
    }
    
    // 効果音をチェック
    if (effectSounds.containsKey(soundId)) {
      return effectSounds[soundId];
    }

    // 従来のsoundIdマッピング（下位互換）
    switch (soundId) {
      case 'piano_c4':
      case 'note_0':
        return buttonSounds['button1'];
      case 'piano_d4':
      case 'note_1':
        return buttonSounds['button2'];
      case 'piano_e4':
      case 'note_2':
        return buttonSounds['button3'];
      case 'piano_f4':
      case 'note_3':
        return buttonSounds['button4'];
      case 'piano_g4':
      case 'note_4':
        return buttonSounds['button1'];
      case 'string_c3':
      case 'note_5':
        return buttonSounds['button2'];
      case 'string_e3':
      case 'note_6':
        return buttonSounds['button3'];
      case 'string_g3':
      case 'note_7':
        return buttonSounds['button4'];
      default:
        debugPrint('未知のsoundId: $soundId, デフォルト音を使用');
        return buttonSounds['button1'];
    }
  }

  // キーボード画像パスを取得
  static String? getKeyboardAssetPath(String keyboardId) {
    return keyboardAssets[keyboardId];
  }

  // アセットファイルの存在確認（デバッグ用）
  static void validateAssets() {
    debugPrint('=== Asset Manager Validation ===');
    debugPrint('BGM Assets: ${bgmAssets.length}');
    for (var entry in bgmAssets.entries) {
      debugPrint('  BGM: ${entry.key} -> ${entry.value}');
    }
    
    debugPrint('Button Sounds: ${buttonSounds.length}');
    for (var entry in buttonSounds.entries) {
      debugPrint('  Button: ${entry.key} -> ${entry.value}');
    }
    
    debugPrint('Effect Sounds: ${effectSounds.length}');
    for (var entry in effectSounds.entries) {
      debugPrint('  Effect: ${entry.key} -> ${entry.value}');
    }
    
    debugPrint('Keyboard Assets: ${keyboardAssets.length}');
    for (var entry in keyboardAssets.entries) {
      debugPrint('  Keyboard: ${entry.key} -> ${entry.value}');
    }
  }
}