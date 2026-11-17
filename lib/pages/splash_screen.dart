import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _backgroundColor = Color(0xFFEEEAFC);

  late final AnimationController _mascotController;
  late final AnimationController _loadingController;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Explicitly keep Android system bars visible; edge-to-edge does not
    // trigger the full-screen confirmation shown by immersiveSticky mode.
    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

    // A gentle up-and-down movement keeps the mascot animated without
    // distracting from the original splash-screen design.
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    // The short segment travels across the track continuously.
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..repeat();

    // Keep the splash visible briefly before opening the existing login page.
    _navigationTimer = Timer(const Duration(seconds: 5), _openLogin);
  }

  void _openLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _mascotController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Do not request immersive/full-screen mode here. Android displays a
    // confirmation overlay the first time an app hides its system bars.
    // Keeping the normal system bars visible avoids that overlay altogether.
    const systemUiStyle = SystemUiOverlayStyle(
      statusBarColor: _backgroundColor,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: _backgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: _backgroundColor,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          // The artwork is laid out on its original 345 x 747 canvas, then
          // scaled proportionally to fit the available phone screen area.
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 345,
                height: 747,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/splash_background.png',
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.high,
                      excludeFromSemantics: true,
                    ),

                    // Animated mascot, positioned to match the supplied design.
                    Positioned(
                      left: 48,
                      top: 223,
                      width: 248,
                      height: 224,
                      child: AnimatedBuilder(
                        animation: _mascotController,
                        child: Image.asset(
                          'assets/images/splash_mascot.png',
                          fit: BoxFit.fill,
                          filterQuality: FilterQuality.high,
                          excludeFromSemantics: true,
                        ),
                        builder: (context, child) {
                          final progress = _mascotController.value;
                          final verticalOffset =
                              -5.5 * math.sin(math.pi * progress);
                          final tilt =
                              0.014 * math.sin(2 * math.pi * progress);

                          return Transform.translate(
                            offset: Offset(0, verticalOffset),
                            child: Transform.rotate(
                              angle: tilt,
                              alignment: Alignment.center,
                              child: child,
                            ),
                          );
                        },
                      ),
                    ),

                    // Moving loading segment replaces the original static line.
                    Positioned(
                      left: 128,
                      top: 663,
                      width: 88,
                      height: 4,
                      child: AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _LoadingIndicatorPainter(
                              progress: _loadingController.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingIndicatorPainter extends CustomPainter {
  const _LoadingIndicatorPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final bounds = Offset.zero & size;

    canvas.drawRRect(
      RRect.fromRectAndRadius(bounds, radius),
      Paint()..color = const Color(0xFFD9D2F1),
    );

    const segmentWidth = 30.0;
    final segmentLeft =
        -segmentWidth + (size.width + segmentWidth) * progress;
    final segment = RRect.fromRectAndRadius(
      Rect.fromLTWH(segmentLeft, 0, segmentWidth, size.height),
      radius,
    );

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(bounds, radius));
    canvas.drawRRect(
      segment,
      Paint()..color = const Color(0xFF6B55D6),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LoadingIndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
