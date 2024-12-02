import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const EditProfilePage({Key? key, this.userData}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  File? _profileImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    usernameController.text = widget.userData?['username'] ?? '';
    emailController.text = widget.userData?['email'] ?? '';
    _uploadedImageUrl = widget.userData?['profileImage'];
  }

  // Method to pick an image from gallery
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Method to upload image to Firebase Storage and return the URL
  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return null;

    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_images/${currentUser!.uid}');
      final uploadTask = storageReference.putFile(_profileImage!);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error uploading image: $e")));
      return null;
    }
  }

  // Method to update profile
  void _updateProfile() async {
    try {
      String? profileImageUrl;
      // If a new image is selected, upload it
      if (_profileImage != null) {
        profileImageUrl = await _uploadProfileImage();
      }

      // Update Firestore with the new username, email, and profile image (if available)
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.email)
          .update({
        'username': usernameController.text,
        'email': emailController.text,
        if (profileImageUrl != null) 'profileImage': profileImageUrl,
      });

      // If password is updated
      if (passwordController.text.isNotEmpty) {
        await currentUser!.updatePassword(passwordController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")));
      Navigator.pop(context);
    } catch (e) {
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
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (_uploadedImageUrl != null
                            ? NetworkImage(_uploadedImageUrl!)
                            : const AssetImage('assets/images/default_profile.jpg'))
                        as ImageProvider,
              ),
            ),
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
