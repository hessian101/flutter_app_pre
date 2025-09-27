import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';
import 'screens/highscore_screen.dart';
import 'screens/performance_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/how_to_play_screen.dart';
import 'screens/sound_download_screen.dart';
import 'services/database_service.dart';
import 'services/audio_service.dart';
import 'utils/constants.dart';
import 'models/star_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final audioService = AudioService();
  await audioService.initialize();
  
  runApp(StarMusicGameApp(audioService: audioService));
}

class StarMusicGameApp extends StatelessWidget {
  final AudioService audioService;

  const StarMusicGameApp({
    super.key,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(
          create: (_) => DatabaseService(),
          dispose: (_, db) => db.close(),
        ),
        Provider<AudioService>.value(
          value: audioService,
        ),
      ],
      child: MaterialApp(
        title: 'Star Music Game',
        theme: ThemeData(
          primarySwatch: MaterialColor(
            AppColors.primaryColor,
            const <int, Color>{
              50: Color(0xFFE3F2FD),
              100: Color(0xFFBBDEFB),
              200: Color(0xFF90CAF9),
              300: Color(0xFF64B5F6),
              400: Color(0xFF42A5F5),
              500: Color(AppColors.primaryColor),
              600: Color(0xFF1E88E5),
              700: Color(0xFF1976D2),
              800: Color(0xFF1565C0),
              900: Color(0xFF0D47A1),
            },
          ),
          scaffoldBackgroundColor: Color(AppColors.backgroundColor),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(AppColors.surfaceColor),
            foregroundColor: Color(AppColors.textColor),
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Color(AppColors.surfaceColor),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppColors.primaryColor),
              foregroundColor: Color(AppColors.textColor),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Color(AppColors.textColor)),
            bodyMedium: TextStyle(color: Color(AppColors.textColor)),
            bodySmall: TextStyle(color: Color(AppColors.secondaryTextColor)),
            headlineLarge: TextStyle(color: Color(AppColors.textColor)),
            headlineMedium: TextStyle(color: Color(AppColors.textColor)),
            headlineSmall: TextStyle(color: Color(AppColors.textColor)),
            titleLarge: TextStyle(color: Color(AppColors.textColor)),
            titleMedium: TextStyle(color: Color(AppColors.textColor)),
            titleSmall: TextStyle(color: Color(AppColors.textColor)),
          ),
          useMaterial3: true,
        ),
        initialRoute: Routes.home,
        onGenerateRoute: _onGenerateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case Routes.game:
        return MaterialPageRoute(
          builder: (_) => const GameScreen(),
          settings: settings,
        );
      case Routes.result:
        final result = settings.arguments as GameResult?;
        if (result == null) {
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ResultScreen(result: result),
          settings: settings,
        );
      case Routes.highScore:
        return MaterialPageRoute(
          builder: (_) => const HighScoreScreen(),
          settings: settings,
        );
      case Routes.performanceList:
        return MaterialPageRoute(
          builder: (_) => const PerformanceListScreen(),
          settings: settings,
        );
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case Routes.howToPlay:
        return MaterialPageRoute(
          builder: (_) => const HowToPlayScreen(),
          settings: settings,
        );
      case '/sound_download':
        return MaterialPageRoute(
          builder: (_) => const SoundDownloadScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
    }
  }
}