import 'package:flutter/material.dart';
import 'dart:io';

class PostImagePicker extends StatelessWidget {
  const PostImagePicker(
      {super.key, required this.images, required this.onPick});
  final List<File?> images;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
          onTap: () => onPick(index),
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
    );
  }
}
