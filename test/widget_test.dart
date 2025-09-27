import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_sample/main.dart';
import 'package:flutter_sample/services/audio_service.dart';

void main() {
  testWidgets('Star Music Game app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final audioService = AudioService();
    await tester.pumpWidget(StarMusicGameApp(audioService: audioService));

    // Verify that the home screen is displayed
    expect(find.text('Star Music Game'), findsOneWidget);
    expect(find.text('ゲーム開始'), findsOneWidget);
    expect(find.text('ハイスコア'), findsOneWidget);
    expect(find.text('演奏記録'), findsOneWidget);
    expect(find.text('遊び方'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });
}