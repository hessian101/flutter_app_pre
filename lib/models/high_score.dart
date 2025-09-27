class HighScore {
  final int? id;
  final String date;
  final int score;
  final double accuracy;
  final int comboMax;

  HighScore({
    this.id,
    required this.date,
    required this.score,
    required this.accuracy,
    required this.comboMax,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'score': score,
      'accuracy': accuracy,
      'combo_max': comboMax,
    };
  }

  factory HighScore.fromMap(Map<String, dynamic> map) {
    return HighScore(
      id: map['id'],
      date: map['date'],
      score: map['score'],
      accuracy: map['accuracy'],
      comboMax: map['combo_max'],
    );
  }

  @override
  String toString() {
    return 'HighScore{id: $id, date: $date, score: $score, accuracy: $accuracy, comboMax: $comboMax}';
  }
}