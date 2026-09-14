import 'package:flutter/material.dart';

class HomeDrawerTile extends StatelessWidget {
  const HomeDrawerTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap,
      this.selected = false,
      this.destructive = false});
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool selected, destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = destructive
        ? scheme.error
        : selected
            ? const Color(0xFF087F88)
            : scheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        selected: selected,
        selectedTileColor: const Color(0xFFE2F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        leading: Icon(icon, color: color, size: 23),
        title: Text(title,
            style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        trailing: destructive
            ? null
            : Icon(Icons.chevron_right_rounded,
                size: 20, color: color.withValues(alpha: 0.55)),
        onTap: onTap,
      ),
    );
  }
}
