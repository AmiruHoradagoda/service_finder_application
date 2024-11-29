import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? leadingImage; 

  const MyListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingImage, 
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leadingImage != null
          ? Image.network(
              leadingImage!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            )
          : const Icon(Icons.image_not_supported), 
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
