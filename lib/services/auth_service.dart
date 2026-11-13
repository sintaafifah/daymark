
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<void>? _initializeGoogleSignIn;

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

    return await _auth.signInWithCredential(credential);
  }
}
