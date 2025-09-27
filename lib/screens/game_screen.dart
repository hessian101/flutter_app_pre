import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../models/star_data.dart';
import '../utils/constants.dart';
import '../utils/asset_manager.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../widgets/game_lane_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _gameController;
  late Timer _gameTimer;
  
  List<GameNote> _notes = [];
  List<StarData> _starData = [];
  
  int _score = 0;
  int _combo = 0;
  int _maxCombo = 0;
  int _perfectCount = 0;
  int _goodCount = 0;
  int _missCount = 0;
  
  bool _isGameActive = false;
  bool _isRecording = false;
  double _gameTime = 0.0;
  
  AudioService? _audioService;
  ApiService? _apiService;
  
  bool _isLoading = false;
  bool _gameSetupComplete = false;
  
  // エフェクト管理
  final List<Widget> _tapEffects = [];
  static const int laneCount = 4;
  static const double judgmentLinePosition = 0.8;

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: const Duration(minutes: 5),
      vsync: this,
    );
    _audioService = AudioService();
    _apiService = ApiService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_gameSetupComplete) {
      _gameSetupComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showImageSelectionDialog();
      });
    }
  }

  void _showImageSelectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Color(AppColors.surfaceColor),
        title: Text(
          '星座画像を選択',
          style: TextStyle(color: Color(AppColors.textColor)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '星座の画像を選択して、音楽ゲームを生成しましょう',
              style: TextStyle(color: Color(AppColors.secondaryTextColor)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('ギャラリー'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _selectImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('カメラ'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _useDemoData(),
              child: Text(
                'デモデータを使用',
                style: TextStyle(color: Color(AppColors.accentColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectImage(ImageSource source) async {
    try {
      Navigator.of(context).pop();
      setState(() {
        _isLoading = true;
      });

      XFile? imageFile;
      if (source == ImageSource.gallery) {
        imageFile = await _apiService!.pickImageFromGallery();
      } else {
        imageFile = await _apiService!.pickImageFromCamera();
      }

      if (imageFile != null) {
        await _apiService!.validateImage(imageFile);
        final starData = await _apiService!.processStarImage(imageFile);
        _initializeGameWithStarData(starData);
      } else {
        _showImageSelectionDialog();
      }
    } catch (e) {
      _showErrorDialog('画像処理エラー', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _useDemoData() async {
    Navigator.of(context).pop();
    
    setState(() {
      _isLoading = true;
    });
    
    // APIサービスからデモデータを取得
    try {
      final demoData = await _apiService!.processStarImage(
        await _createDummyImageFile(),
      );
      
      setState(() {
        _isLoading = false;
      });
      
      _initializeGameWithStarData(demoData);
      
      // BGMを開始
      await _audioService!.playBackgroundMusic('bgm1');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('エラー', 'デモデータの読み込みに失敗しました');
    }
  }
  
  // ダミーの画像ファイルを作成
  Future<XFile> _createDummyImageFile() async {
    return XFile.fromData(
      Uint8List(0),
      name: 'demo.jpg',
      mimeType: 'image/jpeg',
    );
  }

  void _initializeGameWithStarData(List<StarData> starData) {
    setState(() {
      _starData = starData;
      _gameSetupComplete = true;
    });
    _setupGameNotes();
    _startGame();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(AppColors.surfaceColor),
        title: Text(
          title,
          style: TextStyle(color: Color(AppColors.textColor)),
        ),
        content: Text(
          message,
          style: TextStyle(color: Color(AppColors.secondaryTextColor)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showImageSelectionDialog();
            },
            child: Text(
              'もう一度',
              style: TextStyle(color: Color(AppColors.primaryColor)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _useDemoData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.primaryColor),
            ),
            child: const Text('デモで続行'),
          ),
        ],
      ),
    );
  }

  // このメソッドは使用しない（APIサービスで処理）

  void _setupGameNotes() {
    _notes = _starData.map((star) {
      return GameNote(
        starData: star,
        appearTime: star.timing - GameConstants.noteAppearTime,
      );
    }).toList();
    
    debugPrint('ゲームノーツ設定完了: ${_notes.length}個のノーツ');
    for (var note in _notes.take(5)) { // 最初の5個だけログ出力
      debugPrint('ノーツ: soundId=${note.starData.soundId}, timing=${note.starData.timing}, x=${note.starData.x}, y=${note.starData.y}');
    }
  }

  void _startGame() {
    setState(() {
      _isGameActive = true;
      _gameTime = 0.0;
    });
    
    // アセット情報をデバッグ出力
    AssetManager.validateAssets();
    
    _startRecording();
    
    // 5分間のゲーム
    _gameController.reset();
    _gameController.forward();
    
    // 60FPSで更新
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (mounted && _isGameActive) {
        setState(() {
          _gameTime = _gameController.value * 60.0; // 1分間に短縮
          _updateNotes();
        });
        
        // ゲーム終了チェック
        if (_gameTime >= 60.0 || _gameController.isCompleted) {
          _endGame();
        }
      }
    });
    
    debugPrint('ゲーム開始: ${_notes.length}個のノーツ, 最初のノーツタイミング: ${_notes.isNotEmpty ? _notes.first.starData.timing : "N/A"}');
  }

  void _updateNotes() {
    for (var note in _notes) {
      if (!note.isPressed && 
          _gameTime > note.starData.timing + GameConstants.goodTiming) {
        _handleMiss(note);
      }
    }
  }

  void _startRecording() async {
    try {
      await _audioService?.startRecording();
      _isRecording = true;
    } catch (e) {
      debugPrint('録音開始エラー: $e');
    }
  }

  void _stopRecording() async {
    try {
      if (_isRecording) {
        await _audioService?.stopRecording();
        _isRecording = false;
      }
    } catch (e) {
      debugPrint('録音停止エラー: $e');
    }
  }

  void _onNoteTap(GameNote note) {
    if (note.isPressed || !_isGameActive) return;

    final timingDifference = (_gameTime - note.starData.timing).abs();
    NoteJudgment judgment;
    int points;
    
    // レーン位置を計算（エフェクト用）
    final laneIndex = note.starData.x.toInt().clamp(0, laneCount - 1);
    final screenWidth = MediaQuery.of(context).size.width;
    final laneWidth = screenWidth / laneCount;
    final effectX = laneIndex * laneWidth + laneWidth / 2 - 40;

    if (timingDifference <= GameConstants.perfectTiming) {
      judgment = NoteJudgment.perfect;
      points = GameConstants.perfectScore;
      _perfectCount++;
      _combo++;
    } else if (timingDifference <= GameConstants.goodTiming) {
      judgment = NoteJudgment.good;
      points = GameConstants.goodScore;
      _goodCount++;
      _combo++;
    } else {
      judgment = NoteJudgment.miss;
      points = GameConstants.missScore;
      _missCount++;
      _combo = 0;
    }

    setState(() {
      _score += points * (_combo > 10 ? 2 : 1);
      _maxCombo = max(_maxCombo, _combo);
      
      final noteIndex = _notes.indexOf(note);
      if (noteIndex != -1) {
        _notes[noteIndex] = note.copyWith(
          isPressed: true,
          judgment: judgment,
        );
      }
      
      // 成功時のタップエフェクトを追加
      if (judgment != NoteJudgment.miss) {
        _addTapEffect(effectX, MediaQuery.of(context).size.height * judgmentLinePosition - 40, _getNoteColor(note));
      }
    });

    _audioService?.playTapSound(note.starData.soundId);
  }

  void _handleMiss(GameNote note) {
    if (note.isPressed) return;

    setState(() {
      _missCount++;
      _combo = 0;
      
      final noteIndex = _notes.indexOf(note);
      if (noteIndex != -1) {
        _notes[noteIndex] = note.copyWith(
          isPressed: true,
          judgment: NoteJudgment.miss,
        );
      }
    });
  }

  void _endGame() {
    if (!_isGameActive) return; // 重複実行防止
    
    setState(() {
      _isGameActive = false;
    });
    
    _gameController.stop();
    _gameTimer.cancel();
    _stopRecording();

    final totalNotes = _perfectCount + _goodCount + _missCount;
    final accuracy = totalNotes > 0 
        ? ((_perfectCount + _goodCount) / totalNotes) * 100 
        : 0.0;

    final result = GameResult(
      score: _score,
      accuracy: accuracy,
      maxCombo: _maxCombo,
      perfectCount: _perfectCount,
      goodCount: _goodCount,
      missCount: _missCount,
    );

    Navigator.pushReplacementNamed(
      context,
      Routes.result,
      arguments: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.backgroundColor),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.indigo.shade900,
                    Colors.black,
                  ],
                ),
              ),
            ),
            if (_gameSetupComplete) ...[
              _buildStarField(),
              _buildGameLanes(),
              _buildGameNotes(),
              ..._tapEffects,
              _buildUI(),
            ],
            if (_isLoading) _buildLoadingScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              '星座画像を解析中...',
              style: TextStyle(
                color: Color(AppColors.textColor),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '星の位置から音楽を生成しています',
              style: TextStyle(
                color: Color(AppColors.secondaryTextColor),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarField() {
    return CustomPaint(
      painter: StarFieldPainter(),
      size: Size.infinite,
    );
  }
  
  Widget _buildGameLanes() {
    return const GameLaneWidget(
      laneCount: laneCount,
      judgmentLinePosition: judgmentLinePosition,
    );
  }
  
  Widget _buildNoteWidget(GameNote note, int laneIndex) {
    final keyboardPath = AssetManager.getKeyboardAssetPath('tap1');
    debugPrint('ノート表示: keyboardPath = $keyboardPath');
    debugPrint('アセットパス詳細: ${keyboardPath ?? "NULL"}');
    
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getNoteColor(note),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getNoteColor(note).withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: keyboardPath != null
            ? Image.asset(
                keyboardPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('画像読み込みエラー: $error');
                  debugPrint('スタックトレース: $stackTrace');
                  debugPrint('試行したパス: $keyboardPath');
                  return Container(
                    color: Colors.red.withValues(alpha: 0.3),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 16,
                          ),
                          Text(
                            'IMG\nERROR',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _getNoteColor(note).withValues(alpha: 0.8),
                      _getNoteColor(note).withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    note.isPressed ? Icons.check : Icons.music_note,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGameNotes() {
    if (!_isGameActive || _notes.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Stack(
      children: _notes.where((note) {
        final timeUntilNote = note.starData.timing - _gameTime;
        // 時間が来ていないノーツは表示しない
        if (timeUntilNote > GameConstants.noteAppearTime) return false;
        // 過ぎたノーツも非表示
        if (timeUntilNote < -GameConstants.goodTiming * 2) return false;
        return true;
      }).map((note) {
        final timeUntilNote = note.starData.timing - _gameTime;
        final progress = (GameConstants.noteAppearTime - timeUntilNote) / GameConstants.noteAppearTime;
        final opacity = _calculateNoteOpacity(note);
        
        // ノーツの位置を上から下に流す
        final startY = screenHeight * 0.1; // 上から開始
        final endY = screenHeight * 0.8;   // タップエリア
        final currentY = startY + (progress * (endY - startY));
        
        // レーン計算（x座標0-3をレーンインデックスとして使用）
        final laneIndex = note.starData.x.toInt().clamp(0, laneCount - 1);
        final laneWidth = screenWidth / laneCount;
        final noteX = laneIndex * laneWidth + laneWidth / 2 - 30; // ノートサイズの半分
        
        return Positioned(
          left: noteX,
          top: currentY,
          child: GestureDetector(
            onTap: () => _onNoteTap(note),
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 100),
              child: _buildNoteWidget(note, laneIndex),
            ),
          ),
        );
      }).toList(),
    );
  }

  double _calculateNoteOpacity(GameNote note) {
    if (note.isPressed) return 0.3;
    
    final timeUntilNote = note.starData.timing - _gameTime;
    
    // まだ時間ではない
    if (timeUntilNote > GameConstants.noteAppearTime) return 0.0;
    
    // 過ぎたノーツ
    if (timeUntilNote < -GameConstants.goodTiming * 2) return 0.0;
    
    // フェードイン効果
    if (timeUntilNote > GameConstants.noteAppearTime * 0.8) {
      final fadeProgress = (GameConstants.noteAppearTime - timeUntilNote) / (GameConstants.noteAppearTime * 0.2);
      return fadeProgress.clamp(0.0, 1.0);
    }
    
    return 1.0;
  }

  Color _getNoteColor(GameNote note) {
    if (note.judgment != null) {
      switch (note.judgment!) {
        case NoteJudgment.perfect:
          return Color(AppColors.goldColor);
        case NoteJudgment.good:
          return Colors.green;
        case NoteJudgment.miss:
          return Colors.red;
      }
    }
    return Color(AppColors.accentColor);
  }

  Widget _buildUI() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'スコア: $_score',
                    style: TextStyle(
                      color: Color(AppColors.textColor),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'コンボ: $_combo',
                    style: TextStyle(
                      color: Color(AppColors.secondaryTextColor),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isRecording ? Icons.fiber_manual_record : Icons.stop,
                        color: _isRecording ? Colors.red : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isRecording ? '録音中' : '停止',
                        style: TextStyle(
                          color: Color(AppColors.secondaryTextColor),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _endGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ゲーム終了'),
          ),
        ),
      ],
    );
  }

  void _addTapEffect(double x, double y, Color color) {
    // ユニークキーを生成してエフェクトを識別
    final effectKey = UniqueKey();
    
    final effectWidget = TapEffectWidget(
      key: effectKey,
      laneX: x,
      laneY: y,
      effectColor: color,
      onComplete: () {
        setState(() {
          _tapEffects.removeWhere((widget) => widget.key == effectKey);
        });
      },
    );
    
    setState(() {
      _tapEffects.add(effectWidget);
    });
  }

  @override
  void dispose() {
    _gameController.dispose();
    _gameTimer.cancel();
    _stopRecording();
    super.dispose();
  }
}

class StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}