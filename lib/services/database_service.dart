import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/high_score.dart';
import '../models/saved_song.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'star_music_game.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE HighScore (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        score INTEGER NOT NULL,
        accuracy REAL NOT NULL,
        combo_max INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE SavedSong (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        file_path TEXT NOT NULL,
        score INTEGER NOT NULL,
        accuracy REAL NOT NULL
      )
    ''');
  }

  Future<int> insertHighScore(HighScore highScore) async {
    final db = await database;
    return await db.insert('HighScore', highScore.toMap());
  }

  Future<List<HighScore>> getAllHighScores({bool sortByScore = true}) async {
    final db = await database;
    final String orderBy = sortByScore ? 'score DESC' : 'date DESC';
    final List<Map<String, dynamic>> maps = await db.query(
      'HighScore',
      orderBy: orderBy,
    );

    return List.generate(maps.length, (i) {
      return HighScore.fromMap(maps[i]);
    });
  }

  Future<List<HighScore>> getTopHighScores({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'HighScore',
      orderBy: 'score DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return HighScore.fromMap(maps[i]);
    });
  }

  Future<int> deleteHighScore(int id) async {
    final db = await database;
    return await db.delete(
      'HighScore',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertSavedSong(SavedSong savedSong) async {
    final db = await database;
    return await db.insert('SavedSong', savedSong.toMap());
  }

  Future<List<SavedSong>> getAllSavedSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'SavedSong',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return SavedSong.fromMap(maps[i]);
    });
  }

  Future<int> deleteSavedSong(int id) async {
    final db = await database;
    return await db.delete(
      'SavedSong',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'star_music_game.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}