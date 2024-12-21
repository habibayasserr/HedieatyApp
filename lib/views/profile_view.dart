import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'sign_in_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileViewModel _viewModel = ProfileViewModel();
  bool notificationsEnabled = false;
  bool isEditing = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final userData = await _viewModel.fetchUserData();
    if (userData != null) {
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        _emailController.text = userData['email'] ?? '';
      });
    }
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    if (!phone.startsWith('01') || phone.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Invalid phone number. Must be 11 digits and start with "01".'),
        ),
      );
      return;
    }

    final success = await _viewModel.updateUserProfile(
      name: name,
      phone: phone,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      setState(() => isEditing = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  void _signOut() async {
    await _viewModel.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInView()),
      (route) => false,
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType inputType = TextInputType.text,
  }) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005F73),
              ),
            ),
            SizedBox(height: 5.h),
            IgnorePointer(
              ignoring: !enabled,
              child: TextField(
                controller: controller,
                keyboardType: inputType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: !enabled,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),
            SizedBox(height: 15.h),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      key: const Key('profile_view_scaffold'),
      appBar: AppBar(
        key: const Key('profile_view_app_bar'),
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFe5f8ff),
        actions: [
          if (!isEditing)
            IconButton(
              key: const Key('edit_profile_button'),
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),
      body: Padding(
        key: const Key('profile_view_body'),
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          key: const Key('profile_scroll_view'),
          child: Column(
            key: const Key('profile_view_column'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                key: const Key('profile_picture_section'),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      key: const Key('profile_picture_avatar'),
                      radius: 50.r,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 50),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              _buildEditableField(
                label: 'Name',
                controller: _nameController,
                enabled: isEditing,
              ),
              _buildEditableField(
                label: 'Phone Number',
                controller: _phoneController,
                enabled: isEditing,
                inputType: TextInputType.phone,
              ),
              _buildEditableField(
                label: 'Email',
                controller: _emailController,
                enabled: false,
                inputType: TextInputType.emailAddress,
              ),
              if (isEditing)
                Center(
                  child: ElevatedButton(
                    key: const Key('save_profile_changes_button'),
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005F73),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              const Divider(height: 30, thickness: 1),
              Row(
                key: const Key('notification_toggle_row'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enable Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF005F73),
                    ),
                  ),
                  Switch(
                    key: const Key('enable_notifications_switch'),
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              const Divider(height: 30, thickness: 1),
              ListTile(
                key: const Key('my_pledged_gifts_tile'),
                title: const Text(
                  'My Pledged Gifts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF005F73),
                  ),
                ),
                trailing:
                    const Icon(Icons.arrow_forward, color: Color(0xFF005F73)),
                onTap: () {
                  Navigator.pushNamed(context, '/pledged');
                },
              ),
              const Divider(height: 30, thickness: 1),
              Center(
                child: ElevatedButton(
                  key: const Key('sign_out_button'),
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF0F72),
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
