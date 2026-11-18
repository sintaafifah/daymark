
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mascotController;

  @override
  void initState() {
    super.initState();

    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    // Memeriksa status autentikasi Firebase
    final User? user =
        await FirebaseAuth.instance.authStateChanges().first;

    if (!mounted) return;

    final Widget destination = user != null
        ? const DashboardScreen()
        : const LoginScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, animation, secondaryAnimation) {
          return destination;
        },
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );

          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.07),
            end: Offset.zero,
          ).animate(curvedAnimation);

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final isShort = constraints.maxHeight < 700;

            final mascotSize = isWide
                ? 230.0
                : isShort
                    ? 155.0
                    : 190.0;

            final logoWidth = isWide ? 170.0 : 145.0;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'daymark-logo',
                      child: Material(
                        color: Colors.transparent,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: logoWidth,
                          height: 65,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: isWide ? 35 : 24),

                    AnimatedBuilder(
                      animation: _mascotController,
                      builder: (context, child) {
                        final value = _mascotController.value;

                        return Transform.translate(
                          offset: Offset(
                            0,
                            -5 * (1 - (2 * value - 1).abs()),
                          ),
                          child: Transform.rotate(
                            angle: (value - 0.5) * 0.08,
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/maskot.png',
                        width: mascotSize,
                        height: mascotSize,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: isWide ? 28 : 20),

                    Text(
                      'Hari tertata.\nPikiran lebih lega.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isWide ? 24 : 20,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Make Today Count.',
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    SizedBox(height: isWide ? 42 : 34),

                    SizedBox(
                      width: 48,
                      height: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          backgroundColor: isDark
                              ? const Color(0xFF39364D)
                              : const Color(0xFFDCD7F5),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
