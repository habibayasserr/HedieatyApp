import '../services/auth_service.dart';

class AuthViewModel {
  final AuthService _authService = AuthService();
  bool _isSignedIn = false;

  bool get isSignedIn => _isSignedIn;

  Future<void> signIn(String email, String password) async {
    final user = await _authService.signIn(email, password);
    _isSignedIn = user != null;
  }

  Future<void> register(String email, String password) async {
    final user = await _authService.register(email, password);
    _isSignedIn = user != null;
  }

  void signOut() {
    _authService.signOut();
    _isSignedIn = false;
  }
}
