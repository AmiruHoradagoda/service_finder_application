import 'package:flutter/material.dart';

class PostFormSection extends StatelessWidget {
  const PostFormSection(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.children});
  final IconData icon;
  final String title, subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 0,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.5))),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Icon(icon, color: const Color(0xFF087F88)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)))
                  ]),
                  const SizedBox(height: 8),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 20),
                  ...children,
                ])),
      );
}
