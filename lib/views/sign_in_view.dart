import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';
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
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      key: const Key('sign_in_view_scaffold'),
      appBar: AppBar(
        key: const Key('sign_in_view_app_bar'),
        title: const Text('Sign In'),
        backgroundColor: const Color(0xFFfeffff),
      ),
      body: _isLoading
          ? const Center(
              key: Key('sign_in_loading_indicator'),
              child: CircularProgressIndicator(color: Color(0xFF005F73)),
            )
          : ResponsiveBuilder(
              builder: (context, sizingInformation) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth:
                            400.w, // Constrain the width for larger screens
                      ),
                      child: Column(
                        key: const Key('sign_in_column'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  'Welcome to Hedieaty!',
                                  key: Key('welcome_back_text'),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF005F73),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Sign in to continue',
                                  key: Key('sign_in_continue_text'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(
                                children: [
                                  TextField(
                                    key: const Key('email_text_field'),
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF005F73),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15.h),
                                  TextField(
                                    key: const Key('password_text_field'),
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF005F73),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  ElevatedButton(
                                    key: const Key('sign_in_button'),
                                    onPressed: _signIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF005F73),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 15.h,
                                      ),
                                      minimumSize: Size(double.infinity, 50.h),
                                    ),
                                    child: const Text(
                                      'Sign In',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(height: 20.h),
                                  Center(
                                    child: TextButton(
                                      key: const Key(
                                          'navigate_to_sign_up_button'),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpView()),
                                        );
                                      },
                                      child: const Text(
                                        'Don\'t have an account? Sign Up',
                                        style: TextStyle(
                                          color: Color(0xFF005F73),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
