import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'sign_up_view.dart';
import 'home_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({Key? key}) : super(key: key);

  @override
  _SignInViewState createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthViewModel _authViewModel = AuthViewModel();
  bool _isLoading = false;

  Future<void> _signIn() async {
    try {
      setState(() => _isLoading = true);
      await _authViewModel.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      setState(() => _isLoading = false);

      // Navigate to Home if successful
      if (_authViewModel.isSignedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign in')),
        );
      }
    } catch (ex) {
      print(ex.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('sign_in_view_scaffold'),
      appBar: AppBar(
        key: const Key('sign_in_view_app_bar'),
        title: const Text('Sign In'),
      ),
      body: _isLoading
          ? const Center(
              key: Key('sign_in_loading_indicator'),
              child: CircularProgressIndicator(),
            )
          : Padding(
              key: const Key('sign_in_view_body'),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                key: const Key('sign_in_column'),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome Back!',
                    key: Key('welcome_back_text'),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sign in to continue',
                    key: Key('sign_in_continue_text'),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    key: const Key('email_text_field'),
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    key: const Key('password_text_field'),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    key: const Key('sign_in_button'),
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    key: const Key('navigate_to_sign_up_button'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpView()),
                      );
                    },
                    child: const Text('Don\'t have an account? Sign Up'),
                  ),
                ],
              ),
            ),
    );
  }
}
