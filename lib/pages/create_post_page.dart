import 'package:flutter/material.dart';
import 'package:service_finder_application/components/my_button.dart';
import 'package:service_finder_application/components/my_textfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:service_finder_application/database/firestore.dart';
import 'package:service_finder_application/helper/locations.dart';

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
  final FirestoreDatabase database = FirestoreDatabase();
  bool isAskPost = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkProviderStatus();
  }

  Future<void> _checkProviderStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();
      if (userDoc.exists) {
        bool isProvider = userDoc['provider'] ?? false;
        setState(() {
          isAskPost = !isProvider;
        });
      }
    }
  }

  Future<void> pickImage(int index) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        images[index] = File(pickedImage.path);
      });
    }
  }

  Future<List<String>> uploadImages(List<File?> images) async {
    List<String> imageUrls = [];
    FirebaseStorage storage = FirebaseStorage.instance;
    for (File? image in images) {
      if (image != null) {
        try {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageRef = storage.ref().child("post_images/$fileName");
          await storageRef.putFile(image);
          String downloadUrl = await storageRef.getDownloadURL();
          imageUrls.add(downloadUrl);
        } catch (e) {
          // ignore: avoid_print
          print("Error uploading image: $e");
        }
      }
    }
    return imageUrls;
  }

  Future<void> postMessage(BuildContext context) async {
    if (titleController.text.isNotEmpty &&
        mobile1Controller.text.isNotEmpty &&
        selectedLocation != null) {
      setState(() {
        isLoading = true;
      });

      String postId = DateTime.now().millisecondsSinceEpoch.toString();
      String title = titleController.text;
      String description = descriptionController.text;
      String mobile1 = mobile1Controller.text;
      String mobile2 = mobile2Controller.text;
      String address = addressController.text;
      String whatsappLink = whatsappLinkController.text;
      String facebookLink = facebookLinkController.text;
      String websiteLink = websiteLinkController.text;

      List<String> imageUrls = await uploadImages(images);
      String userId = FirebaseAuth.instance.currentUser!.uid;

      await database.addPost(
        postId: postId,
        userId: userId,
        message: title,
        isAsk: isAskPost,
        description: description,
        mobile1: mobile1,
        mobile2: mobile2,
        address: address,
        whatsappLink: whatsappLink,
        facebookLink: facebookLink,
        websiteLink: websiteLink,
        location: selectedLocation!,
        imageUrls: imageUrls,
      );

      setState(() {
        images = List<File?>.filled(4, null);
        isLoading = false;
      });
      Navigator.pop(context);
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
          style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.inversePrimary),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                  hintText: "Select Location",
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
                hintText: "Address",
                obscureText: false,
                controller: addressController,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              if (isAskPost == false) ...[
                MyTextField(
                  hintText: "WhatsApp Link (optional)",
                  obscureText: false,
                  controller: whatsappLinkController,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  hintText: "Facebook Link (optional)",
                  obscureText: false,
                  controller: facebookLinkController,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),
                MyTextField(
                  hintText: "Website Link (optional)",
                  obscureText: false,
                  controller: websiteLinkController,
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 20),
              ],
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => pickImage(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: images[index] != null
                          ? Image.file(
                              images[index]!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Text(
                                "Select Image ${index + 1}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      onTap: () => postMessage(context),
                      text: "Post",
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
