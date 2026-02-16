import 'package:flutter/material.dart';
import 'dart:math';

import 'app_footer.dart';
class AppBackground extends StatefulWidget {
  const AppBackground({super.key, this.showFooter = true});

  final bool showFooter;

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground> with TickerProviderStateMixin {
  late final AnimationController _motionController;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _motionController,
      builder: (context, child) {
        final scheme = Theme.of(context).colorScheme;
        return Stack(
          children: [
            child!,
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: size.height * 0.45,
                child: CustomPaint(
                  painter: _WavePainter(phase: _motionController.value * 2 * pi, baseColor: scheme.primary),
                  size: Size(size.width, size.height * 0.45),
                ),
              ),
            ),
            if (widget.showFooter)
              const Align(
                alignment: Alignment.bottomCenter,
                child: AppFooter(),
              ),
          ],
        );
      },
      child: _LavenderBackground(phase: _motionController.value * 2 * pi),
    );
  }
}

class _LavenderBackground extends StatelessWidget {
  const _LavenderBackground({required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;
    final mid = Color.lerp(scheme.surface, scheme.primaryContainer, 0.55) ?? scheme.primaryContainer;
    final deep = Color.lerp(scheme.primaryContainer, scheme.secondaryContainer, 0.6) ?? scheme.secondaryContainer;
    final dx = sin(phase) * 0.08;
    final dy = cos(phase * 0.9) * 0.12;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(dx, -0.6 + dy),
          radius: 1.2,
          colors: [surface, mid, deep],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.phase, required this.baseColor});

  final double phase;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.2 + i * 0.18) + sin(phase + i) * 6;
      paint
        ..color = baseColor.withValues(alpha: 0.35 - i * 0.06)
        ..strokeWidth = 2.2 - i * 0.2;

      final sway = sin(phase + i * 0.7) * 18;
      final path = Path()
        ..moveTo(-20, y)
        ..cubicTo(size.width * 0.2, y - 30 + sway, size.width * 0.45, y + 20 - sway, size.width * 0.7, y - 10 + sway)
        ..cubicTo(size.width * 0.85, y - 30 - sway, size.width * 1.05, y + 10 + sway, size.width * 1.2, y);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! _WavePainter) {
      return true;
    }
    return oldDelegate.phase != phase || oldDelegate.baseColor != baseColor;
  }
}
