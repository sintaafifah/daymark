
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Referensi dokumen profil berdasarkan UID
  static DocumentReference<Map<String, dynamic>> _userRef(
    String uid,
  ) {
    return _firestore.collection('users').doc(uid);
  }

  // Membuat atau memperbarui profil pengguna
  static Future<void> createOrUpdateUser(User user) async {
    final userRef = _userRef(user.uid);

    final userSnapshot = await userRef.get();

    final Map<String, dynamic> userData = {
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'photoUrl': user.photoURL,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!userSnapshot.exists) {
      userData['createdAt'] = FieldValue.serverTimestamp();
    }

    await userRef.set(userData, SetOptions(merge: true));
  }

  // Mengambil data profil pengguna
  static Future<Map<String, dynamic>?> getUserProfile(
    String uid,
  ) async {
    final snapshot = await _userRef(uid).get();

    return snapshot.data();
  }

  // Memperbarui data profil pengguna
  static Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _userRef(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
