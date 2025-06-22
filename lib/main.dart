import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradika/providers/app_settings_provider.dart';
import 'package:tradika/providers/translation_provider.dart';
import 'package:tradika/screens/history_screen.dart';
import 'package:tradika/screens/home_screen.dart';
import 'package:tradika/screens/settings_screen.dart';
import 'package:tradika/screens/welcome_screen.dart';
import 'package:tradika/app_theme.dart';

void main() {
  runApp(const TradikaApp());
}

class TradikaApp extends StatefulWidget {
  const TradikaApp({super.key});

  @override
  State<TradikaApp> createState() => _TradikaAppState();
}

class _TradikaAppState extends State<TradikaApp> {
  late AppSettingsProvider _appSettingsProvider;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _appSettingsProvider = AppSettingsProvider();
    await _appSettingsProvider.loadSettings();
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _appSettingsProvider),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Tradika',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: const [Locale('fr', 'FR')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (context) => const AppEntryPoint(),
              '/settings': (context) => const SettingsScreen(),
              '/history': (context) => const HistoryScreen(),
            },
          );
        },
      ),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool showWelcome = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  void _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;

    setState(() {
      showWelcome = isFirstLaunch;
      _initialized = true;
    });
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => showWelcome = false);
    await prefs.setBool('first_launch', false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return showWelcome
        ? WelcomeScreen(onComplete: _completeOnboarding)
        : const HomeScreen();
  }
}
