import 'package:service_finder_application/features/posts/widgets/post_image_picker.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:service_finder_application/features/profile/services/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_finder_application/shared/widgets/my_button.dart';
import 'package:service_finder_application/shared/widgets/my_textfield.dart';
import 'package:service_finder_application/features/posts/services/post_service.dart';
import 'package:service_finder_application/core/constants/locations.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController mobile1Controller = TextEditingController();
  final TextEditingController mobile2Controller = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController whatsappLinkController = TextEditingController();
  final TextEditingController facebookLinkController = TextEditingController();
  final TextEditingController websiteLinkController = TextEditingController();

  String? selectedLocation;

  List<File?> images = List<File?>.filled(4, null);
  final PostService _posts = PostService();
  final ProfileService _profiles = ProfileService();
  bool isAskPost = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkProviderStatus();
  }

  Future<void> _checkProviderStatus() async {
    try {
      final profile = await _profiles.getCurrentProfile();
      if (profile != null && mounted) {
        setState(() => isAskPost = !profile.isProvider);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $error')),
        );
      }
    }
  }

  Future<void> pickImage(int index) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null && mounted) {
      setState(() {
        images[index] = File(pickedImage.path);
      });
    }
  }

  Future<void> postMessage(BuildContext context) async {
    if (isLoading ||
        titleController.text.isEmpty ||
        mobile1Controller.text.isEmpty ||
        selectedLocation == null) {
      return;
    }
    setState(() => isLoading = true);
    try {
      await _posts.addPost(
        message: titleController.text,
        isAsk: isAskPost,
        description: descriptionController.text,
        mobile1: mobile1Controller.text,
        mobile2: mobile2Controller.text,
        address: addressController.text,
        whatsappLink: whatsappLinkController.text,
        facebookLink: facebookLinkController.text,
        websiteLink: websiteLinkController.text,
        location: selectedLocation!,
        imageFiles: List<File?>.of(images),
      );
      if (!mounted || !context.mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAskPost
              ? "Create new 'Ask for Service' post."
              : "Create new 'Provide Service' post.",
          style: const TextStyle(
            fontSize: 20,
          ),
          overflow: TextOverflow
              .ellipsis, // Truncates text with ellipsis if it overflows
          maxLines: 2, // Allows title to wrap to the next line
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              MyTextField(
                hintText: "Title",
                obscureText: false,
                controller: titleController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              MyTextField(
                hintText: "Description",
                obscureText: false,
                controller: descriptionController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedLocation,
                items: locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Select Location",
                ),
              ),
              const SizedBox(height: 20),
              MyTextField(
                hintText: "Mobile Number 1 (required)",
                obscureText: false,
                controller: mobile1Controller,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              MyTextField(
                hintText: "Mobile Number 2 (optional)",
                obscureText: false,
                controller: mobile2Controller,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              MyTextField(
                hintText: "Address (optional)",
                obscureText: false,
                controller: addressController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              PostImagePicker(images: images, onPick: pickImage),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTap: () => postMessage(context),
                      text: "Post",
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
