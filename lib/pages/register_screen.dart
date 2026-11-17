import 'package:daymark/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'login_screen.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _background = Color(0xFFF8F7FC);
  static const Color _purple = Color(0xFF6B55D6);
  static const Color _heading = Color(0xFF292640);
  static const Color _muted = Color(0xFF9692A7);
  static const Color _border = Color(0xFFEAE7F1);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi.')),
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
        // Pendaftaran membuat akun terlebih dahulu, lalu pengguna diarahkan
        // ke halaman login seperti alur aplikasi yang sudah ada.
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
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

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final credential = await AuthService.signInWithGoogle();
      if (!mounted) return;
      if (credential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const DashboardScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Google gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildBrand() {
    return Center(
      child: Image.asset(
        'assets/images/daymark_brand.png',
        width: 170,
        height: 71,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffixIcon,
    Iterable<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _heading,
            fontSize: 13,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            autofillHints: autofillHints,
            style: const TextStyle(
              color: _heading,
              fontSize: 14,
              height: 1.2,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              suffixIcon: suffixIcon,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 50,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _border, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _purple, width: 1.3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _heading,
          side: const BorderSide(color: _border, width: 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _purple,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_g.png',
                    width: 19,
                    height: 19,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(width: 7),
                  const Text(
                    'Google',
                    style: TextStyle(
                      color: _heading,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const systemUiStyle = SystemUiOverlayStyle(
      statusBarColor: _background,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: _background,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: _background,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle,
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minContentHeight = (constraints.maxHeight - 40)
                  .clamp(0.0, double.infinity)
                  .toDouble();
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minContentHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrand(),
                          const SizedBox(height: 25),
                          const Text(
                            'Mulai cerita produktifmu.',
                            style: TextStyle(
                              color: _heading,
                              fontSize: 24,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Buat akun gratis, mulai hari yang lebih teratur.',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 25),
                          _buildInputField(
                            label: 'Nama lengkap',
                            controller: _nameController,
                            autofillHints: const [AutofillHints.name],
                          ),
                          const SizedBox(height: 17),
                          _buildInputField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                          ),
                          const SizedBox(height: 17),
                          _buildInputField(
                            label: 'Kata sandi',
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            obscureText: !_isPasswordVisible,
                            autofillHints: const [AutofillHints.newPassword],
                            suffixIcon: IconButton(
                              splashRadius: 20,
                              tooltip: _isPasswordVisible
                                  ? 'Sembunyikan kata sandi'
                                  : 'Tampilkan kata sandi',
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 19,
                                color: const Color(0xFF9995AA),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Dengan mendaftar, kamu menyetujui Syarat & Privasi.',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _registerUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _purple,
                                disabledBackgroundColor:
                                    _purple.withValues(alpha: 0.65),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Buat akun',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 21),
                          const Center(
                            child: Text(
                              'atau lanjutkan dengan',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 11,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 13),
                          _buildGoogleButton(),
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    style: const TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                    children: const [
                                      TextSpan(text: 'Sudah punya akun? '),
                                      TextSpan(
                                        text: 'Masuk',
                                        style: TextStyle(
                                          color: _purple,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
