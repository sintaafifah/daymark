
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<void>? _initializeGoogleSignIn;

  // Login menggunakan Email dan Password
 static Future<UserCredential> signInWithEmail({
  required String email,
  required String password,
}) async {
  final UserCredential credential =
      await _auth.signInWithEmailAndPassword(
    email: email.trim(),
    password: password,
  );

  final User? user = credential.user;

  if (user != null) {
    await UserService.createOrUpdateUser(user);
  }

  return credential;
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

  final User? user = credential.user;

  if (user != null) {
    await user.updateDisplayName(name.trim());
    await user.reload();

    final User? updatedUser = _auth.currentUser;

    if (updatedUser != null) {
      await UserService.createOrUpdateUser(updatedUser);
    }
  }

  return credential;
}


  // Login menggunakan Google
  static Future<UserCredential> signInWithGoogle() async {
    _initializeGoogleSignIn ??= _googleSignIn.initialize(
      serverClientId:
          '512058753808-uqmek7sd4qfiqt6a69uq5ione623le98.apps.googleusercontent.com',
    );

    await _initializeGoogleSignIn;

    final GoogleSignInAccount googleUser =
        await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Token Google tidak ditemukan.');
    }

    final OAuthCredential credential =
        GoogleAuthProvider.credential(
      idToken: idToken,
    );

    final UserCredential userCredential =
    await _auth.signInWithCredential(credential);

final User? user = userCredential.user;

if (user != null) {
  await UserService.createOrUpdateUser(user);
}

return userCredential;
  }

  // Logout dari akun
  static Future<void> signOut() async {
    await _auth.signOut();

    // Keluar dari sesi Google jika sebelumnya sudah diinisialisasi
    if (_initializeGoogleSignIn != null) {
      await _googleSignIn.signOut();
    }
  }
}
