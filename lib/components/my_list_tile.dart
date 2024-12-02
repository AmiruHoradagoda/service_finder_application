import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? leadingImage;
  final Widget? trailing; // Optional trailing widget

  const MyListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingImage,
    this.trailing, // Accept trailing widget
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
      trailing: trailing, // Add the trailing widget here
    );
  }
}
