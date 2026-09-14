import 'package:flutter/material.dart';
import 'package:service_finder_application/features/auth/widgets/auth_scaffold.dart';

class AuthInput extends StatefulWidget {
  const AuthInput({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.password = false,
    this.keyboardType,
    this.validator,
    this.autofillHints,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool password;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  @override
  State<AuthInput> createState() => _AuthInputState();
}

class _AuthInputState extends State<AuthInput> {
  bool _hidden = true;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none);
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.password && _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      autocorrect: false,
      enableSuggestions: !widget.password,
      style: TextStyle(
          fontSize: 14, color: dark ? Colors.white : const Color(0xFF26383D)),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
            fontSize: 13,
            color: dark ? const Color(0xFFABC3C7) : const Color(0xFF75858A)),
        prefixIcon: Icon(widget.icon,
            size: 20,
            color: dark ? const Color(0xFFABC3C7) : const Color(0xFF8A969B)),
        suffixIcon: widget.password
            ? IconButton(
                tooltip: _hidden ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                    _hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20),
              )
            : null,
        filled: true,
        fillColor: dark ? const Color(0xFF233A3D) : const Color(0xFFF5F6F7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: authAccent, width: 1.5)),
        errorBorder: border.copyWith(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error)),
        focusedErrorBorder: border.copyWith(
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error, width: 1.5)),
        errorMaxLines: 2,
      ),
    );
  }
}

String? validateAuthEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }
  return null;
}
