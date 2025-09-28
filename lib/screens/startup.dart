// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import '../voice_greeter.dart';

// class StartupScreen extends StatefulWidget {
//   const StartupScreen({super.key});

//   @override
//   State<StartupScreen> createState() => _StartupScreenState();
// }

// class _StartupScreenState extends State<StartupScreen>
//     with TickerProviderStateMixin {
//   late final AnimationController _twinkle; // 星の瞬き
//   late final List<_FloatSpec> floats;      // キャラのふわふわ

//   @override
//   void initState() {
//     super.initState();
//     _twinkle = AnimationController.unbounded(vsync: this)
//       ..repeat(min: 0, max: 100000, period: const Duration(seconds: 100));

//     // 各キャラごとの「揺れ速度・位相・振幅」をちょっとだけ変える
//     floats = [
//       _FloatSpec('assets/02_箱根.png',  // 紫髪の等身大キャラ
//           align: const Alignment(0.35, 0.05), scale: 0.62, amp: 6, sec: 4.6),
//       _FloatSpec('assets/SD2茜.png',
//           align: const Alignment(-0.35, 0.05), scale: 0.44, amp: 8, sec: 3.8),
//       _FloatSpec('assets/SD2葵.png',
//           align: const Alignment(0.05, 0.25), scale: 0.46, amp: 8, sec: 3.6),

//       // ねこ達（例：アートボード系）
//       // _FloatSpec('assets/アートボード 1.png',
//       //     align: const Alignment(-0.70, 0.65), scale: 0.22, amp: 5, sec: 3.2),
//       // _FloatSpec('assets/アートボード 2.png',
//       //     align: const Alignment(-0.40, 0.72), scale: 0.22, amp: 5, sec: 3.4),
//       // _FloatSpec('assets/アートボード 3.png',
//       //     align: const Alignment(-0.10, 0.75), scale: 0.22, amp: 5, sec: 3.1),
//       // _FloatSpec('assets/アートボード 4.png',
//       //     align: const Alignment(0.20, 0.78), scale: 0.22, amp: 5, sec: 3.5),
//       // _FloatSpec('assets/アートボード 5.png',
//       //     align: const Alignment(0.55, 0.70), scale: 0.22, amp: 5, sec: 3.3),
//       // _FloatSpec('assets/アートボード 6.png',
//       //     align: const Alignment(0.80, 0.65), scale: 0.22, amp: 5, sec: 3.6),
//     ];

//     // Future.microtask(() async {
//     //   // 例: 葵で明るめ（喜び70%）
//     //   await VoiceGreeter.playGreeting(
//     //     text: 'ようこそ！今日も楽しくプレイしてね！',
//     //     speakerName: 'aoi_emo', // ← ハッカソン専用カスタム話者
//     //     styleJson: '{"j":"0.7"}',
//     //     ext: 'aac',
//     //   );
//     // });
//   }

//   @override
//   void dispose() {
//     _twinkle.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 事前読み込み（チラつき防止）
//     for (final f in floats) precacheImage(AssetImage(f.path), context);

//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // 1) 背景
//           Image.asset('assets/home.png', fit: BoxFit.cover),

//           // 2) 星の瞬き（超軽量の CustomPainter）
//           AnimatedBuilder(
//             animation: _twinkle,
//             builder: (_, __) => CustomPaint(
//               painter: _StarTwinklePainter(time: _twinkle.value),
//             ),
//           ),

//           // 3) キャラをレイヤー配置して「ふわふわ + 微小回転」
//           ...floats.map((f) => _FloatingCharacter(spec: f, vsync: this)),
//         ],
//       ),
//     );
//   }
// }

// /// キャラのふわふわ設定
// class _FloatSpec {
//   final String path;
//   final Alignment align;
//   final double scale; // 画面の短辺に対する相対スケール
//   final double amp;   // 上下の振幅(px)
//   final double sec;   // 周期(秒)
//   _FloatSpec(this.path,
//       {required this.align, required this.scale, required this.amp, required this.sec});
// }

// /// 単一キャラのふわふわウィジェット
// class _FloatingCharacter extends StatefulWidget {
//   final _FloatSpec spec;
//   final TickerProvider vsync;
//   const _FloatingCharacter({required this.spec, required this.vsync});

//   @override
//   State<_FloatingCharacter> createState() => _FloatingCharacterState();
// }

// class _FloatingCharacterState extends State<_FloatingCharacter>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _c;

//   @override
//   void initState() {
//     super.initState();
//     _c = AnimationController(vsync: widget.vsync, duration: Duration(milliseconds: (widget.spec.sec * 1000).round()))
//       ..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _c.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: widget.spec.align,
//       child: LayoutBuilder(builder: (context, box) {
//         final size = math.min(box.maxWidth, box.maxHeight) * widget.spec.scale;
//         return AnimatedBuilder(
//           animation: _c,
//           builder: (_, child) {
//             // -1..1 の三角波 → ゆっくり上下 + ほんの少し回転
//             final t = (_c.value * 2 - 1);
//             final dy = t * widget.spec.amp;
//             final rot = t * 0.015; // ラジアン（~0.86度）

//             return Transform.translate(
//               offset: Offset(0, dy),
//               child: Transform.rotate(
//                 angle: rot,
//                 child: SizedBox(
//                   width: size,
//                   child: child,
//                 ),
//               ),
//             );
//           },
//           child: Image.asset(widget.spec.path, filterQuality: FilterQuality.medium),
//         );
//       }),
//     );
//   }
// }

// /// 星の瞬きを描く CustomPainter（アルファだけを周期変化）
// class _StarTwinklePainter extends CustomPainter {
//   final double time;
//   _StarTwinklePainter({required this.time});

//   // ★軽量化：固定の星座点を少数だけ
//   static final _stars = List.generate(70, (i) {
//     final rnd = math.Random(i * 9973);
//     return Offset(rnd.nextDouble(), rnd.nextDouble()); // 0..1 の正規化座標
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;
//     for (var i = 0; i < _stars.length; i++) {
//       final p = _stars[i];
//       final x = p.dx * size.width;
//       final y = p.dy * size.height;
//       // 位相をずらしてチラチラ
//       final phase = i * 0.37;
//       final a = 0.35 + 0.35 * math.sin(time * 0.9 + phase); // 0..0.7
//       paint.color = Colors.white.withOpacity(a.clamp(0.05, 0.75));
//       canvas.drawCircle(Offset(x, y), 0.6 + (i % 3) * 0.4, paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant _StarTwinklePainter oldDelegate) =>
//       oldDelegate.time != time;
// }

import 'dart:math' as math;
import 'package:flutter/material.dart';
// ignore: unused_import
import 'home_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _twinkle; // 星の瞬き
  late final List<_FloatSpec> floats; // キャラのふわふわ

  @override
  void initState() {
    super.initState();
    _twinkle = AnimationController.unbounded(vsync: this)
      ..repeat(min: 0, max: 100000, period: const Duration(seconds: 100));

    floats = [
      _FloatSpec(
        'assets/02_箱根.png',
        align: const Alignment(0.35, 0.05),
        scale: 0.42,
        amp: 6,
        sec: 4.6,
      ),
      _FloatSpec(
        'assets/SD2茜.png',
        align: const Alignment(-0.35, 0.05),
        scale: 0.44,
        amp: 8,
        sec: 3.8,
      ),
      _FloatSpec(
        'assets/SD2葵.png',
        align: const Alignment(0.05, 0.25),
        scale: 0.46,
        amp: 8,
        sec: 3.6,
      ),
      // 猫たちは今は非表示（必要なら戻してください）
    ];

    // 自動遷移を削除（タップで遷移するように変更）

    // 音声挨拶を入れる場合はここに（コメントのまま保持）
    // Future.microtask(() async {
    //   await VoiceGreeter.playGreeting(
    //     text: 'ようこそ！今日も楽しくプレイしてね！',
    //     speakerName: 'aoi_emo',
    //     styleJson: '{"j":"0.7"}',
    //     ext: 'aac',
    //   );
    // });
  }

  @override
  void dispose() {
    _twinkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final f in floats) precacheImage(AssetImage(f.path), context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1) 背景
          Image.asset('assets/home.png', fit: BoxFit.cover),

          // 2) 星の瞬き（超軽量の CustomPainter）
          AnimatedBuilder(
            animation: _twinkle,
            builder: (_, __) =>
                CustomPaint(painter: _StarTwinklePainter(time: _twinkle.value)),
          ),

          // 3) タイトル & サブタイトル（キャラ位置は不変。上部に重ねるだけ）
          SafeArea(
            child: Align(
              alignment: const Alignment(0, -0.88), // 画面上部寄りに表示
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _TitleText('Metoeor Notes'),
                  SizedBox(height: 6),
                  _SubtitleText('星座から音楽を生成するリズムゲーム'),
                ],
              ),
            ),
          ),

          // 4) キャラの"ふわふわ + 微回転"（既存のまま）
          ...floats.map((f) => _FloatingCharacter(spec: f, vsync: this)),

          // 5) タッチ指示（キャラの下に配置）
          SafeArea(
            child: Align(
              alignment: const Alignment(0, 0.7), // キャラの下らへん
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'TOUCH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// タイトル表示（読みやすいように軽いシャドウ）
class _TitleText extends StatelessWidget {
  final String text;
  const _TitleText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: 1.2,
        shadows: [
          Shadow(blurRadius: 8, color: Colors.black54, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}

class _SubtitleText extends StatelessWidget {
  final String text;
  const _SubtitleText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        shadows: [
          Shadow(blurRadius: 6, color: Colors.black45, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}

/// キャラのふわふわ設定
class _FloatSpec {
  final String path;
  final Alignment align;
  final double scale; // 画面の短辺に対する相対スケール
  final double amp; // 上下の振幅(px)
  final double sec; // 周期(秒)
  _FloatSpec(
    this.path, {
    required this.align,
    required this.scale,
    required this.amp,
    required this.sec,
  });
}

/// 単一キャラのふわふわウィジェット
class _FloatingCharacter extends StatefulWidget {
  final _FloatSpec spec;
  final TickerProvider vsync;
  const _FloatingCharacter({required this.spec, required this.vsync});

  @override
  State<_FloatingCharacter> createState() => _FloatingCharacterState();
}

class _FloatingCharacterState extends State<_FloatingCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: widget.vsync,
      duration: Duration(milliseconds: (widget.spec.sec * 1000).round()),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.spec.align,
      child: LayoutBuilder(
        builder: (context, box) {
          final size =
              math.min(box.maxWidth, box.maxHeight) * widget.spec.scale;
          return AnimatedBuilder(
            animation: _c,
            builder: (_, child) {
              final t = (_c.value * 2 - 1); // -1..1
              final dy = t * widget.spec.amp;
              final rot = t * 0.015; // ~0.86度
              return Transform.translate(
                offset: Offset(0, dy),
                child: Transform.rotate(
                  angle: rot,
                  child: SizedBox(width: size, child: child),
                ),
              );
            },
            child: Image.asset(
              widget.spec.path,
              filterQuality: FilterQuality.medium,
            ),
          );
        },
      ),
    );
  }
}

/// 星の瞬きを描く CustomPainter（アルファだけを周期変化）
class _StarTwinklePainter extends CustomPainter {
  final double time;
  _StarTwinklePainter({required this.time});

  static final _stars = List.generate(70, (i) {
    final rnd = math.Random(i * 9973);
    return Offset(rnd.nextDouble(), rnd.nextDouble());
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < _stars.length; i++) {
      final p = _stars[i];
      final x = p.dx * size.width;
      final y = p.dy * size.height;
      final phase = i * 0.37;
      final a = 0.35 + 0.35 * math.sin(time * 0.9 + phase); // 0..0.7
      paint.color = Colors.white.withOpacity(a.clamp(0.05, 0.75));
      canvas.drawCircle(Offset(x, y), 0.6 + (i % 3) * 0.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarTwinklePainter oldDelegate) =>
      oldDelegate.time != time;
}
