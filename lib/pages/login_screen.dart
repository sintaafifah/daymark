
import 'package:flutter/material.dart';

import 'register_screen.dart';
import 'dashboard_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  bool isGoogleLoading = false;

  void navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }

  Future<void> loginWithEmail() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan kata sandi harus diisi.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await AuthService.signInWithEmail(
        email: emailController.text,
        password: passwordController.text,
      );

      if (!mounted) return;

      if (userCredential.user != null) {
        navigateToDashboard();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> loginWithGoogle() async {
    setState(() => isGoogleLoading = true);

    try {
      final userCredential = await AuthService.signInWithGoogle();

      if (!mounted) return;

      if (userCredential.user != null) {
        navigateToDashboard();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Google gagal: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isGoogleLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return _buildDesktopLayout();
          }

          return _buildCompactLayout(
            screenWidth: screenWidth,
          );
        },
      ),
    );
  }

  // ==========================================
  // DESKTOP / LAPTOP LAYOUT
  // ==========================================

  Widget _buildDesktopLayout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Row(
        children: [
          // PANEL KIRI: BRANDING
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [
                          Color(0xFF292342),
                          Color(0xFF1D1B30),
                        ]
                      : const [
                          Color(0xFFEEEAFE),
                          Color(0xFFF7F5FF),
                        ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -70,
                    left: -60,
                    child: _decorationCircle(
                      size: 230,
                      color: AppTheme.primaryColor.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -90,
                    right: -70,
                    child: _decorationCircle(
                      size: 280,
                      color: AppTheme.primaryColor.withValues(
                        alpha: 0.10,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 55,
                      vertical: 45,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandLogo(
                          isDark: isDark,
                          alignment: MainAxisAlignment.start,
                        ),

                        const Spacer(),

                        Text(
                          'Rencana kecil.\nPencapaian besar.',
                          style: TextStyle(
                            fontSize: 38,
                            height: 1.25,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF302B50),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          'Atur tugas, temukan fokus, dan rayakan '
                          'setiap progresmu bersama Daymark.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF77738F),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Expanded(
                          flex: 5,
                          child: Center(
                            child: Image.asset(
                              'assets/images/maskot.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 150,
                                  color: AppTheme.primaryColor,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          'Make Today Count.',
                          style: TextStyle(
                            fontSize: 13,
                            letterSpacing: 1.2,
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF9691B0),
                          ),
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // PANEL KANAN: FORM LOGIN
          Expanded(
            flex: 6,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 55,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 430,
                    ),
                    child: _buildLoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MOBILE / TABLET LAYOUT
  // ==========================================

  Widget _buildCompactLayout({
    required double screenWidth,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth < 400 ? 24 : 40,
            vertical: 35,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: Column(
              children: [
                _buildBrandLogo(
                  isDark: isDark,
                  alignment: MainAxisAlignment.center,
                ),

                const SizedBox(height: 42),

                _buildLoginForm(),

                const SizedBox(height: 10),

                Text(
                  'Make Today Count.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // BRAND LOGO
  // ==========================================

  Widget _buildBrandLogo({
    required bool isDark,
    required MainAxisAlignment alignment,
  }) {
    return Row(
      mainAxisAlignment: alignment,
      children: [
     Hero(
  tag: 'daymark-logo',
  child: Material(
    color: Colors.transparent,
    child: Image.asset(
      'assets/images/logo.png',
      width: 48,
      height: 48,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(
          Icons.calendar_month_rounded,
          size: 45,
          color: AppTheme.primaryColor,
        );
      },
    ),
  ),
),

        const SizedBox(width: 12),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daymark',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              'Make Today Count.',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // LOGIN FORM
  // ==========================================

  Widget _buildLoginForm() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final secondaryColor = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang kembali!',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Masuk untuk mulai mengatur tugas dan mencapai '
          'target harianmu.',
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: secondaryColor,
          ),
        ),

        const SizedBox(height: 32),

        // EMAIL
        _buildFieldLabel('Email'),

        const SizedBox(height: 9),

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            hintText: 'nama@email.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),

        const SizedBox(height: 22),

        // PASSWORD
        _buildFieldLabel('Kata sandi'),

        const SizedBox(height: 9),

        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => loginWithEmail(),
          decoration: InputDecoration(
            hintText: 'Masukkan kata sandi',
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // LUPA PASSWORD
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'Lupa kata sandi?',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // TOMBOL LOGIN
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading || isGoogleLoading
                ? null
                : loginWithEmail,
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Masuk',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 25),

        // PEMISAH
        Row(
          children: [
            Expanded(
              child: Divider(color: theme.dividerColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'atau masuk dengan',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryColor,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: theme.dividerColor),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // GOOGLE LOGIN
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: isLoading || isGoogleLoading
                ? null
                : loginWithGoogle,
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor,
              side: BorderSide(
                color: theme.dividerColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isGoogleLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'G',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Lanjutkan dengan Google',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 30),

        // REGISTER
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                'Belum punya akun? ',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Daftar sekarang',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FIELD LABEL
  // ==========================================

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  // ==========================================
  // DECORATION
  // ==========================================

  Widget _decorationCircle({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
