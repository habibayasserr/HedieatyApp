import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  // Register with email and password
  Future<User?> register(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error registering: $e");
      return null;
    }
  }

  Future<void> saveAdditionalUserData(
      String uid, String name, String phone) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'id': uid, // Explicitly set the user ID
        'name': name,
        'phone': phone,
        'email': _auth.currentUser?.email,
        'preferences': {
          'notificationSettings': true, // Default notifications enabled
          'reminderTime': 3, // Default reminder time in days
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
