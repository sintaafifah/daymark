
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<void>? _initializeGoogleSignIn;

  // Login menggunakan Email dan Password
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

    // Register menggunakan Email dan Password
  static Future<UserCredential> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.updateDisplayName(name.trim());

    return credential;
  }

  // Login menggunakan Google

static Future<UserCredential> signInWithGoogle() async {
  print('GOOGLE 1: Memulai inisialisasi');

  _initializeGoogleSignIn ??= _googleSignIn.initialize(
    serverClientId:
        '512058753808-uqmek7sd4qfiqt6a69uq5ione623le98.apps.googleusercontent.com',
  );

  await _initializeGoogleSignIn;
  print('GOOGLE 2: Inisialisasi berhasil');

  final GoogleSignInAccount googleUser =
      await _googleSignIn.authenticate();

  print('GOOGLE 3: Akun Google berhasil dipilih');
  print('GOOGLE EMAIL: ${googleUser.email}');

  final GoogleSignInAuthentication googleAuth =
      googleUser.authentication;

  print('GOOGLE 4: Mengambil ID Token');

  final String? idToken = googleAuth.idToken;

  if (idToken == null) {
    throw Exception('Token Google tidak ditemukan.');
  }

  print('GOOGLE 5: ID Token tersedia');
  print('GOOGLE 6: Menghubungkan ke Firebase');

  final OAuthCredential credential =
      GoogleAuthProvider.credential(
    idToken: idToken,
  );

  final result = await _auth.signInWithCredential(credential);

  print('GOOGLE 7: Login Firebase berhasil');
  print('GOOGLE USER: ${result.user?.email}');

  return result;
}
}
