class StarData {
  final double x;
  final double y;
  final String soundId;
  final double timing;

  StarData({
    required this.x,
    required this.y,
    required this.soundId,
    required this.timing,
  });

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'sound_id': soundId,
      'timing': timing,
    };
  }

  factory StarData.fromMap(Map<String, dynamic> map) {
    return StarData(
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
      soundId: map['sound_id'] ?? '',
      timing: map['timing']?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'StarData{x: $x, y: $y, soundId: $soundId, timing: $timing}';
  }
}

class GameNote {
  final StarData starData;
  final bool isPressed;
  final double appearTime;
  final NoteJudgment? judgment;

  GameNote({
    required this.starData,
    this.isPressed = false,
    required this.appearTime,
    this.judgment,
  });

  GameNote copyWith({
    StarData? starData,
    bool? isPressed,
    double? appearTime,
    NoteJudgment? judgment,
  }) {
    return GameNote(
      starData: starData ?? this.starData,
      isPressed: isPressed ?? this.isPressed,
      appearTime: appearTime ?? this.appearTime,
      judgment: judgment ?? this.judgment,
    );
  }
}

enum NoteJudgment {
  perfect,
  good,
  miss,
}

class GameResult {
  final int score;
  final double accuracy;
  final int maxCombo;
  final int perfectCount;
  final int goodCount;
  final int missCount;

  GameResult({
    required this.score,
    required this.accuracy,
    required this.maxCombo,
    required this.perfectCount,
    required this.goodCount,
    required this.missCount,
  });

  @override
  String toString() {
    return 'GameResult{score: $score, accuracy: $accuracy, maxCombo: $maxCombo, perfect: $perfectCount, good: $goodCount, miss: $missCount}';
  }
}