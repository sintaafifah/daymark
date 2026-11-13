
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daymark/services/auth_service.dart';
import 'login_screen.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
      const SnackBar(content: Text('Semua kolom wajib diisi.')),
    );
    return;
  }

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok.')),
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

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF263653),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFFA0A8B8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Color(0xFFE7EAF2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Color(0xFFE7EAF2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Color(0xFF4D8CEB)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2860E8),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Buat akun baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF263653),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Biar semua tugas terasa teratur.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFA0A8B8),
                      ),
                    ),

                    const SizedBox(height: 48),

                    _buildInputField(
                      label: 'Nama lengkap',
                      hint: 'Nama Kamu',
                      controller: _nameController,
                    ),

                    const SizedBox(height: 12),

                    _buildInputField(
                      label: 'Email',
                      hint: 'nama@gmail.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 12),

                    _buildInputField(
                      label: 'Kata sandi',
                      hint: '••••••••',
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 18,
                          color: const Color(0xFFA0A8B8),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildInputField(
                      label: 'Konfirmasi kata sandi',
                      hint: 'Ulangi kata sandi',
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 18,
                          color: const Color(0xFFA0A8B8),
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D8CEB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
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
        'Daftar sekarang',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'atau masuk dengan',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFA0A8B8),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 37,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Google Sign-In akan segera dihubungkan.',
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF263653),
                          side: const BorderSide(
                            color: Color(0xFFE7EAF2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        child: const Text(
                          'G  Lanjutkan dengan Google',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ),

                    const SizedBox(height: 70),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFA0A8B8),
                            ),
                            children: [
                              TextSpan(text: 'Sudah punya akun? '),
                              TextSpan(
                                text: 'Masuk',
                                style: TextStyle(
                                  color: Color(0xFF4D8CEB),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
