import 'package:service_finder_application/features/profile/widgets/profile_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:service_finder_application/features/profile/services/profile_service.dart';
import 'package:service_finder_application/features/profile/models/user_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final UserProfile? profile;
  const EditProfilePage({Key? key, this.profile}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ProfileService _profiles = ProfileService();
  File? _profileImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.profile?.username ?? '';
    emailController.text = widget.profile?.email ?? '';
    _uploadedImageUrl = widget.profile?.profileImage;
  }

  // Method to pick an image from gallery
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && mounted) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Method to update profile
  void _updateProfile() async {
    try {
      await _profiles.updateProfile(
        username: usernameController.text,
        email: emailController.text,
        password: passwordController.text,
        image: _profileImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image Picker
            ProfileImagePicker(
                image: _profileImage,
                imageUrl: _uploadedImageUrl,
                onPick: _pickProfileImage),
            const SizedBox(height: 20),
            // Username TextField
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 10),
            // Email TextField
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            // Password TextField
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
            const SizedBox(height: 20),
            // Update Button
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
