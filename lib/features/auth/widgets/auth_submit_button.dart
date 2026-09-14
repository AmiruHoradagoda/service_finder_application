import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/widgets/auth_scaffold.dart';

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.busy = false});
  final String label;
  final VoidCallback onPressed;
  final bool busy;
  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: authAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
        ),
        child: Text(busy ? 'Please wait...' : label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      );
}
