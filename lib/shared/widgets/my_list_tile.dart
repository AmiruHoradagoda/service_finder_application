import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? leadingImage;
  final String? avatarImage;
  final Widget? trailing; // Optional trailing widget

  const MyListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingImage,
    this.avatarImage,
    this.trailing, // Accept trailing widget
  });

  @override
  Widget build(BuildContext context) {
    if (avatarImage != null) {
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (leadingImage != null)
              Image(
                image: _image(leadingImage!),
                height: 170,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                    height: 170,
                    child: Icon(Icons.image_not_supported_outlined)),
              ),
            ListTile(
              leading: CircleAvatar(backgroundImage: _image(avatarImage!)),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: trailing,
            ),
          ],
        ),
      );
    }
    return ListTile(
      leading: leadingImage != null
          ? Image(
              image: _image(leadingImage!),
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

  ImageProvider _image(String path) => path.startsWith('assets/')
      ? AssetImage(path)
      : NetworkImage(path) as ImageProvider;
}
