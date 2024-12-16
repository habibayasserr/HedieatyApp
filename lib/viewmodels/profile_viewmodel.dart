import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch user data from Firestore
  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          // Ensure email is fetched from Firebase Authentication
          data?['email'] = user.email;
          return data;
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  // Update user profile in Firestore and FirebaseAuth
  Future<bool> updateUserProfile({
    required String name,
    required String phone,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      // Update Firebase Authentication (only name as email can't be edited)
      await user.updateDisplayName(name);

      // Update Firestore with name and phone
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'phone': phone,
      }, SetOptions(merge: true));

      await user.reload(); // Ensure updates are reflected immediately
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
