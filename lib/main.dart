
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeProvider = ThemeProvider();

  // Memuat tema yang tersimpan
  await themeProvider.loadTheme();

  runApp(DaymarkApp(themeProvider: themeProvider));
}

class DaymarkApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const DaymarkApp({
    super.key,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeProvider,
      builder: (context, child) {
        return ThemeProviderScope(
          provider: themeProvider,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Daymark',

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
