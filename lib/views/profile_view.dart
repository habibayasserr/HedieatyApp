import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_in_view.dart';
import 'pledged_gifts_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool notificationsEnabled = false; // Static for now
  bool isEditing = false; // Toggle edit mode

  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  // Initialize text fields with current user data
  void _initializeFields() {
    _nameController.text = currentUser?.displayName ?? '';
    _emailController.text = currentUser?.email ?? '';
    _phoneController.text = ''; // Placeholder, phone isn't in Firebase directly
  }

  // Function to update user profile
  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    // Perform profile update
    try {
      await currentUser?.updateDisplayName(_nameController.text);
      await currentUser?.updateEmail(_emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() => isEditing = false); // Exit edit mode
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: ${e.message}')),
      );
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: inputType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: !enabled,
            fillColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.orange,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => isEditing = true),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image and Info
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 50),
                    ),
                    if (isEditing)
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.orange,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          onPressed: () {
                            // Placeholder for image picker
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Image upload not implemented')),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Editable Fields
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
                enabled: isEditing,
                inputType: TextInputType.emailAddress,
              ),

              // Save Button
              if (isEditing)
                Center(
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              const Divider(height: 30, thickness: 1),

              // Notifications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enable Notifications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
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

              // Pledged Gifts
              ListTile(
                title: const Text(
                  'My Pledged Gifts',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PledgedGiftsView()),
                  ); */
                },
              ),
              const Divider(height: 30, thickness: 1),

              // Sign Out Button
              Center(
                child: ElevatedButton(
                  onPressed: _signOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
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
