import '../services/auth_service.dart';

class AuthViewModel {
  final AuthService _authService = AuthService();

  Future<void> signIn(String email, String password) async {
    final user = await _authService.signIn(email, password);
    if (user != null) {
      print("User signed in: ${user.email}");
    } else {
      print("Sign in failed.");
    }
  }

  Future<void> register(String email, String password) async {
    final user = await _authService.register(email, password);
    if (user != null) {
      print("User registered: ${user.email}");
    } else {
      print("Registration failed.");
    }
  }

  void signOut() {
    _authService.signOut();
    print("User signed out.");
  }
}
