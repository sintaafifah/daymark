
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      body: Stack(
        children: [
          Positioned(
            top: -35,
            left: -35,
            child: Container(
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                color: Color(0xFFE7EAFF),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            right: -35,
            top: 190,
            child: Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                color: Color(0xFFDDF8EE),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 90,
                    height: 90,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Daymark',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF20345B),
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'Make Today Count.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7890B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
