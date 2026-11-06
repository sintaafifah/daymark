
import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const DaymarkApp());
}

class DaymarkApp extends StatelessWidget {
  const DaymarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daymark',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
