
import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;

  void navigateToDashboard() {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const DashboardScreen(),
    ),
  );
}

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FF),
      body: Stack(
        children: [
          // Dekorasi lingkaran kiri atas
          Positioned(
            top: -35,
            left: -35,
            child: Container(
              width: 85,
              height: 85,
              decoration: const BoxDecoration(
                color: Color(0xFFE7EAFF),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Dekorasi lingkaran kanan tengah
          Positioned(
            top: 240,
            right: -35,
            child: Container(
              width: 75,
              height: 75,
              decoration: const BoxDecoration(
                color: Color(0xFFDDF8EE),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 45),

                    // Logo Daymark
                    Center(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(14),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Daymark',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF20345B),
                            ),
                          ),

                          const SizedBox(height: 2),

                          const Text(
                            'Make Today Count.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF7890B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 68),

                    // Judul Login
                    const Text(
                      'Masuk ke Daymark',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF29384F),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Masuk untuk mulai mengatur tugasmu.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9AA6B8),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Label Email
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF26354D),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Input Email
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'nama@gmail.com',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA6B5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xFF4D8FEF),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    // Label Password
                    const Text(
                      'Kata sandi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF26354D),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Input Password
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA6B5),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 15,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(9),
                          borderSide: const BorderSide(
                            color: Color(0xFF4D8FEF),
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                                  !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: const Color(0xFF9AA6B8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Lupa Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Lupa kata sandi?',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF3985FF),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Tombol Masuk
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
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
  }
},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF4D8FEF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(11),
                          ),
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Pemisah Google
                    const Center(
                      child: Text(
                        'atau masuk dengan',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9AA6B8),
                        ),
                      ),
                    ),

                    const SizedBox(height: 17),

                    // Tombol Google
                    SizedBox(
                      width: double.infinity,
                      height: 37,
                      child: OutlinedButton(
                        onPressed: () async {
  try {
    final userCredential =
        await AuthService.signInWithGoogle();

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
  }
},
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFE5E8F0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(9),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: const [
                            Text(
                              'G',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF34445E),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Lanjutkan dengan Google',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF26354D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 110),

                    // Link Daftar
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                          ),
                        );
                        },
                        child: const Text(
                          'Belum punya akun? Daftar',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF3985FF),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
