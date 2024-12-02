import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final Color? color; // New color parameter

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
    this.color, 
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color ??
              Theme.of(context)
                  .colorScheme
                  .primary, // Use passed color or default to primary
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white, // White text for contrast
            ),
          ),
        ),
      ),
    );
  }
}
