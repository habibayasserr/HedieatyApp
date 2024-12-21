import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'home_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({Key? key}) : super(key: key);

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthViewModel _authViewModel = AuthViewModel();
  bool _isLoading = false;

  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$", // Valid domain structure
  );

  final RegExp _egyptianPhoneRegex =
      RegExp(r'^01[0-2,5]{1}[0-9]{8}$'); // Egyptian phone number

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone number are required.')),
      );
      return;
    }

    if (!_egyptianPhoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid Egyptian phone number.')),
      );
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email format.')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters.')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await _authViewModel.register(email, password, name, phone);

    setState(() => _isLoading = false);

    if (_authViewModel.isSignedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign up.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      key: const Key('sign_up_view_scaffold'),
      appBar: AppBar(
        key: const Key('sign_up_view_app_bar'),
        title: const Text('Sign Up'),
        backgroundColor: const Color(0xFFfeffff),
      ),
      body: _isLoading
          ? const Center(
              key: Key('sign_up_loading_indicator'),
              child: CircularProgressIndicator(color: Color(0xFF005F73)),
            )
          : ResponsiveBuilder(
              builder: (context, sizingInformation) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 400.w, // Constrain width for larger screens
                      ),
                      child: Column(
                        key: const Key('sign_up_column'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Create Account',
                            key: Key('create_account_text'),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005F73),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Sign up to get started',
                            key: Key('sign_up_get_started_text'),
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            key: const Key('name_text_field'),
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: const TextStyle(
                                color: Color(0xFF005F73),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFE5F8FF),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          TextField(
                            key: const Key('phone_text_field'),
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: const TextStyle(
                                color: Color(0xFF005F73),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFE5F8FF),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 15.h),
                          TextField(
                            key: const Key('email_text_field'),
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: const TextStyle(
                                color: Color(0xFF005F73),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFE5F8FF),
                            ),
                            keyboardType: TextInputType.emailAddress,
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
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFE5F8FF),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          TextField(
                            key: const Key('confirm_password_text_field'),
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              labelStyle: const TextStyle(
                                color: Color(0xFF005F73),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFE5F8FF),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton(
                            key: const Key('sign_up_button'),
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005F73),
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              minimumSize: Size(double.infinity, 50.h),
                            ),
                            child: const Text('Sign Up',
                                style: TextStyle(color: Colors.white)),
                          ),
                          SizedBox(height: 20.h),
                          Center(
                            child: TextButton(
                              key: const Key('navigate_to_sign_in_button'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Already have an account? Sign In',
                                style: TextStyle(
                                  color: Color(0xFF005F73),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
