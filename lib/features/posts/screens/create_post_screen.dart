import 'package:service_finder_application/features/posts/widgets/post_image_picker.dart';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:service_finder_application/features/profile/services/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_finder_application/features/posts/widgets/post_form_section.dart';

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

  final _formKey = GlobalKey<FormState>();
  String? selectedLocation;

  List<Uint8List?> images = List<Uint8List?>.filled(4, null);
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
    if (pickedImage == null) return;
    final bytes = await pickedImage.readAsBytes();
    if (mounted) {
      setState(() {
        images[index] = bytes;
      });
    }
  }

  Future<void> postMessage(BuildContext context) async {
    if (isLoading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
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
        imageBytes: List<Uint8List?>.of(images),
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
  void dispose() {
    for (final controller in [
      titleController,
      descriptionController,
      mobile1Controller,
      mobile2Controller,
      addressController,
      whatsappLinkController,
      facebookLinkController,
      websiteLinkController
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF087F88), width: 2)),
      );

  Widget _field(TextEditingController controller, String label,
          {String? hint,
          bool required = false,
          int lines = 1,
          TextInputType keyboard = TextInputType.text}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
            controller: controller,
            maxLines: lines,
            keyboardType: lines > 1 ? TextInputType.multiline : keyboard,
            decoration: _decoration(label, hint: hint),
            validator: required
                ? (value) => value == null || value.trim().isEmpty
                    ? 'Please enter ${label.toLowerCase()}.'
                    : null
                : null),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? const Color(0xFF10292C)
          : const Color(0xFFF3F8F8),
      appBar: AppBar(
          title: const Text('Create a post'),
          backgroundColor: const Color(0xFF087F88),
          foregroundColor: Colors.white,
          elevation: 0),
      body: SafeArea(
          child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Center(
            child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                        isAskPost
                            ? 'What do you need help with?'
                            : 'Let your skills do the talking.',
                        style: const TextStyle(
                            fontSize: 28,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.7)),
                    const SizedBox(height: 10),
                    Text(
                        isAskPost
                            ? 'Tell your community about your project and find the right help.'
                            : 'Share your service so people nearby can discover what you offer.',
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5)),
                    const SizedBox(height: 24),
                    PostFormSection(
                        icon: Icons.edit_note_rounded,
                        title: 'The details',
                        subtitle: 'A clear title helps people find your post.',
                        children: [
                          _field(titleController, 'Title',
                              required: true,
                              hint: isAskPost
                                  ? 'e.g. Need a plumber for a kitchen repair'
                                  : 'e.g. Home plumbing and repairs'),
                          _field(descriptionController, 'Description',
                              lines: 4,
                              hint:
                                  'Include the work involved, availability and anything else people should know.'),
                        ]),
                    PostFormSection(
                        icon: Icons.location_on_outlined,
                        title: 'Location & contact',
                        subtitle:
                            'These contact details will be visible on your post.',
                        children: [
                          DropdownButtonFormField<String>(
                              initialValue: selectedLocation,
                              isExpanded: true,
                              menuMaxHeight: 320,
                              decoration: _decoration('Location'),
                              validator: (value) =>
                                  value == null ? 'Choose a location.' : null,
                              items: locations
                                  .map((location) => DropdownMenuItem(
                                      value: location, child: Text(location)))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => selectedLocation = value)),
                          const SizedBox(height: 16),
                          _field(mobile1Controller, 'Mobile number',
                              required: true, keyboard: TextInputType.phone),
                          _field(mobile2Controller,
                              'Second mobile number (optional)',
                              keyboard: TextInputType.phone),
                          _field(addressController, 'Address (optional)'),
                        ]),
                    PostFormSection(
                        icon: Icons.photo_library_outlined,
                        title: 'Add photos',
                        subtitle:
                            'Optional ? Add up to 4 photos to bring your post to life.',
                        children: [
                          PostImagePicker(
                              images: images,
                              onPick: pickImage,
                              onRemove: (index) =>
                                  setState(() => images[index] = null)),
                        ]),
                    FilledButton.icon(
                        onPressed:
                            isLoading ? null : () => postMessage(context),
                        style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF087F88),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16))),
                        icon: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.publish_rounded),
                        label:
                            Text(isLoading ? 'Publishing?' : 'Publish post')),
                    const SizedBox(height: 24),
                  ])),
        )),
      )),
    );
  }
}
