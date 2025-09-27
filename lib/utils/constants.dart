class GameConstants {
  static const double perfectTiming = 0.05;
  static const double goodTiming = 0.15;
  
  static const int perfectScore = 100;
  static const int goodScore = 50;
  static const int missScore = 0;
  
  static const double gameSpeed = 1.0;
  static const double noteAppearTime = 2.0;
  
  static const String audioRecordingsDir = 'audio_recordings';
  static const String audioFormat = 'wav';
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
  static const String home = '/';
  static const String game = '/game';
  static const String result = '/result';
  static const String highScore = '/highscore';
  static const String performanceList = '/performance_list';
  static const String settings = '/settings';
  static const String howToPlay = '/how_to_play';
}