import 'package:flutter/material.dart';

/// Lightweight service-card illustration, painted without an image dependency.
class AuthIllustration extends StatelessWidget {
  const AuthIllustration({super.key});
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(painter: _ServiceIllustrationPainter()),
      );
}

class _ServiceIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate((size.width - 300) / 2, 4);
    final paint = Paint();
    paint.color = const Color(0xFF77DADE);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    canvas.drawCircle(const Offset(269, 32), 35, paint);
    canvas.drawCircle(const Offset(24, 99), 25, paint);
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF0A909C);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(131, 22, 129, 119), const Radius.circular(18)),
        paint);
    paint.color = const Color(0xFFE3FAF8);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(122, 14, 129, 125), const Radius.circular(18)),
        paint);
    paint.color = const Color(0xFF9DE8E4);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(160, 7, 52, 16), const Radius.circular(6)),
        paint);
    for (var i = 0; i < 3; i++) {
      final y = 44.0 + i * 27;
      paint.color = const Color(0xFFB6ECE7);
      canvas.drawCircle(Offset(143, y), 7, paint);
      paint.color = const Color(0xFF188C94);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawPath(
          Path()
            ..moveTo(139, y)
            ..lineTo(142, y + 3)
            ..lineTo(148, y - 3),
          paint);
      paint.style = PaintingStyle.fill;
      paint.color = const Color(0xFFB6ECE7);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(160, y - 4, i == 1 ? 48 : 67, 7),
              const Radius.circular(4)),
          paint);
    }
    paint.color = const Color(0xFF82DFDD);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(34, 45, 103, 79), const Radius.circular(16)),
        paint);
    paint.color = const Color(0xFFF2FFFC);
    canvas.drawPath(
        Path()
          ..moveTo(53, 82)
          ..lineTo(85, 57)
          ..lineTo(117, 82)
          ..lineTo(110, 82)
          ..lineTo(110, 109)
          ..lineTo(60, 109)
          ..lineTo(60, 82)
          ..close(),
        paint);
    paint.color = const Color(0xFF25B7BF);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(79, 87, 15, 22), const Radius.circular(3)),
        paint);
    paint.color = const Color(0xFFFFDE91);
    canvas.drawCircle(const Offset(268, 96), 15, paint);
    paint.color = const Color(0xFF8B6B23);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.5;
    canvas.drawPath(
        Path()
          ..moveTo(261, 96)
          ..lineTo(266, 101)
          ..lineTo(276, 90),
        paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ServiceIllustrationPainter oldDelegate) =>
      false;
}
