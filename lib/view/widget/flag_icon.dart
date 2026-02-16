import 'dart:math';

import 'package:flutter/material.dart';

enum FlagType { england, france, algeria }

class FlagIcon extends StatelessWidget {
  const FlagIcon({super.key, required this.type, this.size = 24});

  final FlagType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.68,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: CustomPaint(painter: _FlagPainter(type)),
      ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  _FlagPainter(this.type);

  final FlagType type;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case FlagType.england:
        _paintEngland(canvas, size);
      case FlagType.france:
        _paintFrance(canvas, size);
      case FlagType.algeria:
        _paintAlgeria(canvas, size);
    }
  }

  void _paintEngland(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFCE1124);
    canvas.drawRect(Offset.zero & size, white);
    final crossWidth = size.height * 0.28;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width, height: crossWidth),
      red,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: crossWidth, height: size.height),
      red,
    );
  }

  void _paintFrance(Canvas canvas, Size size) {
    final blue = Paint()..color = const Color(0xFF0055A4);
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFEF4135);
    final stripe = size.width / 3;
    canvas.drawRect(Rect.fromLTWH(0, 0, stripe, size.height), blue);
    canvas.drawRect(Rect.fromLTWH(stripe, 0, stripe, size.height), white);
    canvas.drawRect(Rect.fromLTWH(stripe * 2, 0, stripe, size.height), red);
  }

  void _paintAlgeria(Canvas canvas, Size size) {
    final green = Paint()..color = const Color(0xFF007A3D);
    final white = Paint()..color = Colors.white;
    final red = Paint()..color = const Color(0xFFD21034);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width / 2, size.height), green);
    canvas.drawRect(Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height), white);

    final center = Offset(size.width * 0.52, size.height / 2);
    final outerR = size.height * 0.32;
    final innerR = size.height * 0.26;
    canvas.drawCircle(center, outerR, red);
    canvas.drawCircle(Offset(center.dx + outerR * 0.35, center.dy), innerR, white);

    final starCenter = Offset(size.width * 0.62, size.height / 2);
    _drawStar(canvas, starCenter, size.height * 0.14, red);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const points = 5;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final isOuter = i.isEven;
      final r = isOuter ? radius : radius * 0.45;
      final angle = -pi / 2 + (pi / points) * i;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FlagPainter oldDelegate) => oldDelegate.type != type;
}

