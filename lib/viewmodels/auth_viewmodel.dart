import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthViewModel {
  final AuthService _authService = AuthService();
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  // Sign In
  Future<void> signIn(String email, String password) async {
    final user = await _authService.signIn(email, password);
    _isSignedIn = user != null;
  }

  // Register with additional user details
  Future<void> register(
      String email, String password, String name, String phone) async {
    final user = await _authService.register(email, password);
    if (user != null) {
      _isSignedIn = true;
      // Update user profile with name
      await user.updateDisplayName(name);
      await user.reload(); // Refresh user instance

      // Optionally store phone number in Firestore
      // You will need Firestore setup for this part
      await _authService.saveAdditionalUserData(user.uid, name, phone);
    } else {
      _isSignedIn = false;
    }
  }

  // Sign Out
  void signOut() {
    _authService.signOut();
    _isSignedIn = false;
  }
}
