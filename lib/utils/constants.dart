class GameConstants {
  static const double perfectTiming = 0.05;
  static const double goodTiming = 0.15;

  static const int perfectScore = 100;
  static const int goodScore = 50;
  static const int missScore = 0;

  static const double gameSpeed = 0.5;

  // ノート落下速度の設定（秒）
  static const double noteAppearTimeSlow = 3.0; // ゆっくり
  static const double noteAppearTimeNormal = 2.0; // 普通
  static const double noteAppearTimeFast = 1.5; // 速い
  static const double noteAppearTimeVeryFast = 1.0; // とても速い

  // デフォルトの落下速度
  static const double noteAppearTime = noteAppearTimeNormal;

  static const String audioRecordingsDir = 'audio_recordings';
  static const String audioFormat = 'wav';
}

// ゲーム設定を管理するクラス
class GameSettings {
  static double _noteAppearTime = GameConstants.noteAppearTimeNormal;

  // ノート落下速度の設定
  static double get noteAppearTime => _noteAppearTime;

  static void setNoteAppearTime(double time) {
    _noteAppearTime = time.clamp(0.5, 5.0); // 0.5秒〜5秒の範囲で制限
  }

  // プリセット設定
  static void setSlowSpeed() =>
      setNoteAppearTime(GameConstants.noteAppearTimeSlow);
  static void setNormalSpeed() =>
      setNoteAppearTime(GameConstants.noteAppearTimeNormal);
  static void setFastSpeed() =>
      setNoteAppearTime(GameConstants.noteAppearTimeFast);
  static void setVeryFastSpeed() =>
      setNoteAppearTime(GameConstants.noteAppearTimeVeryFast);

  // 速度レベルを取得
  static String getSpeedLevel() {
    if (_noteAppearTime >= GameConstants.noteAppearTimeSlow) return 'ゆっくり';
    if (_noteAppearTime >= GameConstants.noteAppearTimeNormal) return '普通';
    if (_noteAppearTime >= GameConstants.noteAppearTimeFast) return '速い';
    return 'とても速い';
  }
}

class AppColors {
  static const int primaryColor = 0xFF1976D2;
  static const int accentColor = 0xFFFF4081;
  static const int backgroundColor = 0xFF121212;
  static const int surfaceColor = 0xFF1E1E1E;
  static const int textColor = 0xFFFFFFFF;
  static const int secondaryTextColor = 0xFFB0B0B0;
  static const int goldColor = 0xFFFFD700;
}

class Routes {
  static const String startup = '/startup';
  static const String home = '/';
  static const String game = '/game';
  static const String result = '/result';
  static const String highScore = '/highscore';
  static const String performanceList = '/performance_list';
  static const String settings = '/settings';
  static const String howToPlay = '/how_to_play';
}
