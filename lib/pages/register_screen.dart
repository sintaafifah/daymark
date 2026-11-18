
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daymark/services/auth_service.dart';

import 'login_screen.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ==========================================
  // REGISTER FIREBASE
  // ==========================================

 
  // ==========================================
  // REGISTER FIREBASE
  // ==========================================

  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom wajib diisi.'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = await AuthService.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (credential.user != null) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email sudah terdaftar.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'weak-password':
          message = 'Kata sandi minimal 6 karakter.';
          break;
        default:
          message = e.message ?? 'Pendaftaran gagal.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ==========================================
  // GOOGLE SIGN-IN
  // ==========================================

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final userCredential = await AuthService.signInWithGoogle();

      if (!mounted) return;

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In gagal: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return _buildDesktopLayout();
          }

          return _buildCompactLayout(
            screenWidth: constraints.maxWidth,
          );
        },
      ),
    );
  }

  // ==========================================
  // DESKTOP / LAPTOP
  // ==========================================

  Widget _buildDesktopLayout() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                      vertical: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBrandLogo(
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

                        const SizedBox(height: 20),

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

                        const SizedBox(height: 18),

                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF201B32)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Satu hari lebih terarah.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? const Color(0xFFB9A9FF)
                                    : AppTheme.primaryColor,
                              ),
                            ),
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

          // PANEL KANAN: FORM REGISTER
          Expanded(
            flex: 6,
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 55,
                    vertical: 35,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 430,
                    ),
                    child: _buildRegisterForm(),
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
  // MOBILE / TABLET
  // ==========================================

  Widget _buildCompactLayout({
    required double screenWidth,
  }) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth < 400 ? 24 : 40,
            vertical: 30,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: Column(
              children: [
                _buildBrandLogo(
                  alignment: MainAxisAlignment.center,
                ),

                const SizedBox(height: 38),

                _buildRegisterForm(),
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
    required MainAxisAlignment alignment,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: alignment,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: 48,
          height: 48,
          fit: BoxFit.contain,
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
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              'Make Today Count.',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // REGISTER FORM
  // ==========================================

  Widget _buildRegisterForm() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final secondaryColor = theme.colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mulai cerita produktifmu.',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),

        const SizedBox(height: 9),

        Text(
          'Buat akun gratis, mulai hari yang lebih teratur.',
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: secondaryColor,
          ),
        ),

        const SizedBox(height: 28),

        // NAMA LENGKAP
        _buildInputField(
          label: 'Nama lengkap',
          hint: 'Nama Kamu',
          controller: _nameController,
          keyboardType: TextInputType.name,
        ),

        const SizedBox(height: 18),

        // EMAIL
        _buildInputField(
          label: 'Email',
          hint: 'nama@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 18),

        // PASSWORD
        _buildInputField(
          label: 'Kata sandi',
          hint: 'Masukkan kata sandi',
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
            icon: Icon(
              _isPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // KONFIRMASI PASSWORD
        _buildInputField(
          label: 'Konfirmasi kata sandi',
          hint: 'Ulangi kata sandi',
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible =
                    !_isConfirmPasswordVisible;
              });
            },
            icon: Icon(
              _isConfirmPasswordVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Dengan mendaftar, kamu menyetujui Syarat & Privasi.',
          style: TextStyle(
            fontSize: 10,
            color: secondaryColor,
          ),
        ),

        const SizedBox(height: 22),

        // TOMBOL REGISTER
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _registerUser,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Buat akun',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 25),

        // PEMISAH GOOGLE
        Row(
          children: [
            Expanded(
              child: Divider(color: theme.dividerColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                'atau lanjutkan dengan',
                style: TextStyle(
                  fontSize: 11,
                  color: secondaryColor,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: theme.dividerColor),
            ),
          ],
        ),

        const SizedBox(height: 20),

       

// GOOGLE REGISTER
SizedBox(
  width: double.infinity,
  height: 50,
  child: OutlinedButton(
    onPressed: _isGoogleLoading ? null : _signInWithGoogle,
    style: OutlinedButton.styleFrom(
      foregroundColor: textColor,
      side: BorderSide(
        color: theme.dividerColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: _isGoogleLoading
        ? const SizedBox(
            width: 22,
            height: 22,
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


        const SizedBox(height: 28),

        // LOGIN
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                'Sudah punya akun? ',
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Masuk',
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
  // INPUT FIELD
  // ==========================================

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),

        const SizedBox(height: 9),

        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // DECORATION CIRCLE
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
