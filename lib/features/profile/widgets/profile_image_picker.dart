import 'package:flutter/material.dart';
import 'dart:io';

class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker(
      {super.key,
      required this.image,
      required this.imageUrl,
      required this.onPick});
  final File? image;
  final String? imageUrl;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPick,
      child: CircleAvatar(
        radius: 60,
        backgroundImage: image != null
            ? FileImage(image!)
            : (imageUrl != null
                    ? NetworkImage(imageUrl!)
                    : const AssetImage('assets/images/default_profile.jpg'))
                as ImageProvider,
      ),
    );
  }
}
