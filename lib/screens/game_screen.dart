import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import '../models/star_data.dart';
import '../utils/constants.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
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

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: const Duration(minutes: 5),
      vsync: this,
    );
    _audioService = AudioService();
    _apiService = ApiService();
    // _showImageSelectionDialog();
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

  void _useDemoData() {
    Navigator.of(context).pop();
    _generateDemoStarData();
    _initializeGameWithStarData(_starData);
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
        title: Text(title, style: TextStyle(color: Color(AppColors.textColor))),
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

  void _generateDemoStarData() {
    final random = Random();
    _starData = List.generate(20, (index) {
      return StarData(
        x: random.nextDouble() * 300 + 50,
        y: random.nextDouble() * 400 + 100,
        soundId: 'note_${random.nextInt(8)}',
        timing: index * 2.0 + random.nextDouble() * 0.5,
      );
    });
  }

  void _setupGameNotes() {
    _notes = _starData.map((star) {
      return GameNote(
        starData: star,
        appearTime: star.timing - GameConstants.noteAppearTime,
      );
    }).toList();
  }

  void _startGame() {
    _isGameActive = true;
    _startRecording();

    _gameController.forward();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        _gameTime = _gameController.value * 300;
        _updateNotes();
      });
    });
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
      print('録音開始エラー: $e');
    }
  }

  void _stopRecording() async {
    try {
      if (_isRecording) {
        await _audioService?.stopRecording();
        _isRecording = false;
      }
    } catch (e) {
      print('録音停止エラー: $e');
    }
  }

  void _onNoteTap(GameNote note) {
    if (note.isPressed || !_isGameActive) return;

    final timingDifference = (_gameTime - note.starData.timing).abs();
    NoteJudgment judgment;
    int points;

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
        _notes[noteIndex] = note.copyWith(isPressed: true, judgment: judgment);
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
    _isGameActive = false;
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

    Navigator.pushReplacementNamed(context, Routes.result, arguments: result);
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
                  colors: [Colors.indigo.shade900, Colors.black],
                ),
              ),
            ),
            if (_gameSetupComplete) ...[
              _buildStarField(),
              _buildGameNotes(),
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
    return CustomPaint(painter: StarFieldPainter(), size: Size.infinite);
  }

  Widget _buildGameNotes() {
    return Stack(
      children: _notes.map((note) {
        final opacity = _calculateNoteOpacity(note);
        if (opacity <= 0) return const SizedBox.shrink();

        return Positioned(
          left: note.starData.x,
          top: note.starData.y,
          child: GestureDetector(
            onTap: () => _onNoteTap(note),
            child: AnimatedOpacity(
              opacity: opacity,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getNoteColor(note),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _getNoteColor(note).withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
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
          ),
        );
      }).toList(),
    );
  }

  double _calculateNoteOpacity(GameNote note) {
    if (note.isPressed) return 0.3;

    final timeUntilNote = note.starData.timing - _gameTime;
    if (timeUntilNote > GameConstants.noteAppearTime) return 0.0;
    if (timeUntilNote < -GameConstants.goodTiming) return 0.0;

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
