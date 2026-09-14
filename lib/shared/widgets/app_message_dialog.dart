import 'package:flutter/material.dart';

enum MessageType { error, warning, info }

class AppMessageDialog extends StatelessWidget {
  const AppMessageDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = MessageType.error,
  });

  final String title;
  final String message;
  final MessageType type;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final (color, icon) = switch (type) {
      MessageType.error => (
          dark ? const Color(0xFFFFACA4) : const Color(0xFFB33B35),
          Icons.error_outline_rounded
        ),
      MessageType.warning => (
          dark ? const Color(0xFFFFD281) : const Color(0xFF946000),
          Icons.warning_amber_rounded
        ),
      MessageType.info => (
          dark ? const Color(0xFFA4DFC3) : const Color(0xFF21634E),
          Icons.info_outline_rounded
        ),
    };
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withAlpha(24),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
              ),
              const SizedBox(height: 20),
              Semantics(
                namesRoute: true,
                header: true,
                child: Text(title,
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    )),
              ),
              const SizedBox(height: 10),
              Text(message,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: scheme.onSurfaceVariant,
                  )),
              const SizedBox(height: 26),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      dark ? const Color(0xFFA4DFC3) : const Color(0xFF21634E),
                  foregroundColor:
                      dark ? const Color(0xFF123E3A) : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Got it',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
