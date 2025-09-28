class SavedSong {
  final int? id;
  final String date;
  final String filePath;
  final int score;
  final double accuracy;
  final int maxCombo;
  final int perfectCount;
  final int goodCount;
  final int missCount;
  final String? generatedMusicPath;
  final String? originalImagePath;
  final String? starDataJson;

  SavedSong({
    this.id,
    required this.date,
    required this.filePath,
    required this.score,
    required this.accuracy,
    required this.maxCombo,
    required this.perfectCount,
    required this.goodCount,
    required this.missCount,
    this.generatedMusicPath,
    this.originalImagePath,
    this.starDataJson,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'file_path': filePath,
      'score': score,
      'accuracy': accuracy,
      'max_combo': maxCombo,
      'perfect_count': perfectCount,
      'good_count': goodCount,
      'miss_count': missCount,
      'generated_music_path': generatedMusicPath,
      'original_image_path': originalImagePath,
      'star_data_json': starDataJson,
    };
  }

  factory SavedSong.fromMap(Map<String, dynamic> map) {
    return SavedSong(
      id: map['id'],
      date: map['date'],
      filePath: map['file_path'],
      score: map['score'],
      accuracy: map['accuracy'],
      maxCombo: map['max_combo'] ?? 0,
      perfectCount: map['perfect_count'] ?? 0,
      goodCount: map['good_count'] ?? 0,
      missCount: map['miss_count'] ?? 0,
      generatedMusicPath: map['generated_music_path'],
      originalImagePath: map['original_image_path'],
      starDataJson: map['star_data_json'],
    );
  }

  @override
  String toString() {
    return 'SavedSong{id: $id, date: $date, filePath: $filePath, score: $score, accuracy: $accuracy, maxCombo: $maxCombo, perfectCount: $perfectCount, goodCount: $goodCount, missCount: $missCount}';
  }
}
