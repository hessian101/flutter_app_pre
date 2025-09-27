class SavedSong {
  final int? id;
  final String date;
  final String filePath;
  final int score;
  final double accuracy;

  SavedSong({
    this.id,
    required this.date,
    required this.filePath,
    required this.score,
    required this.accuracy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'file_path': filePath,
      'score': score,
      'accuracy': accuracy,
    };
  }

  factory SavedSong.fromMap(Map<String, dynamic> map) {
    return SavedSong(
      id: map['id'],
      date: map['date'],
      filePath: map['file_path'],
      score: map['score'],
      accuracy: map['accuracy'],
    );
  }

  @override
  String toString() {
    return 'SavedSong{id: $id, date: $date, filePath: $filePath, score: $score, accuracy: $accuracy}';
  }
}