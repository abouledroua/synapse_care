import 'package:flutter/material.dart';
import 'dart:math';

class SynapseBackground extends StatefulWidget {
  const SynapseBackground({super.key});

  @override
  State<SynapseBackground> createState() => _SynapseBackgroundState();
}

class _SynapseBackgroundState extends State<SynapseBackground> with TickerProviderStateMixin {
  late final AnimationController _motionController;
  late final AnimationController _iconController;
  late final List<Offset> _orbPositions;

  @override
  void initState() {
    super.initState();
    _motionController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _iconController = AnimationController(vsync: this, duration: const Duration(seconds: 24))..repeat();
    final random = Random();
    _orbPositions = List.generate(3, (_) => Offset(random.nextDouble(), random.nextDouble()));
  }

  @override
  void dispose() {
    _motionController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: Listenable.merge([_motionController, _iconController]),
      builder: (context, child) {
        final scheme = Theme.of(context).colorScheme;
        return Stack(
          children: [
            child!,
            _GlowOrbs(
              phase: _motionController.value * 2 * pi,
              iconPhase: _iconController.value,
              size: size,
              positions: _orbPositions,
            ),
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
          ],
        );
      },
      child: const _LavenderBackground(),
    );
  }
}

class _LavenderBackground extends StatelessWidget {
  const _LavenderBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;
    final mid = Color.lerp(scheme.surface, scheme.primaryContainer, 0.55) ?? scheme.primaryContainer;
    final deep = Color.lerp(scheme.primaryContainer, scheme.secondaryContainer, 0.6) ?? scheme.secondaryContainer;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.0, -0.6),
          radius: 1.2,
          colors: [surface, mid, deep],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}

class _GlowOrbs extends StatelessWidget {
  const _GlowOrbs({required this.phase, required this.iconPhase, required this.size, required this.positions});

  final double phase;
  final double iconPhase;
  final Size size;
  final List<Offset> positions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final orb1 = scheme.primary.withValues(alpha: 0.12);
    final orb2 = scheme.secondary.withValues(alpha: 0.12);
    final orb3 = scheme.tertiary.withValues(alpha: 0.18);
    final icons = [
      Icons.monitor_heart,
      Icons.calendar_month_rounded,
      Icons.insert_chart_outlined_rounded,
      Icons.healing,
      Icons.vaccines_outlined,
      Icons.favorite,
    ];
    final iconIndex = (iconPhase * icons.length).floor() % icons.length;
    final topArea = size.height * 0.7;
    final orbDiameter = 110.0;
    const margin = 24.0;
    final leftMax = (size.width * 0.45 - orbDiameter - margin).clamp(margin, size.width);
    final rightMin = (size.width * 0.55).clamp(0.0, size.width);
    final rightMax = (size.width - orbDiameter - margin).clamp(rightMin, size.width);
    final topMax = (topArea * 0.45 - orbDiameter - margin).clamp(margin, topArea);
    final bottomMin = (topArea * 0.6).clamp(0.0, topArea);
    final bottomMax = (topArea - orbDiameter - margin).clamp(bottomMin, topArea);
    Offset placeInRect(Offset fraction, double minX, double maxX, double minY, double maxY) {
      final left = minX + fraction.dx * (maxX - minX);
      final top = minY + fraction.dy * (maxY - minY);
      return Offset(left, top);
    }

    final p1 = placeInRect(positions[0], margin, leftMax, margin, topMax);
    final p2 = placeInRect(positions[1], rightMin, rightMax, margin, topMax);
    final p3 = placeInRect(positions[2], rightMin, rightMax, bottomMin, bottomMax);
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: p1.dx,
            top: p1.dy,
            child: _HealthItem(
              icon: icons[(iconIndex) % icons.length],
              diameter: orbDiameter,
              color: orb1,
              phase: phase,
              phaseOffset: 0.0,
            ),
          ),
          Positioned(
            left: p2.dx,
            top: p2.dy,
            child: _HealthItem(
              icon: icons[(iconIndex + 1) % icons.length],
              diameter: orbDiameter,
              color: orb2,
              phase: phase,
              phaseOffset: 1.7,
            ),
          ),
          Positioned(
            left: p3.dx,
            top: p3.dy,
            child: _HealthItem(
              icon: icons[(iconIndex + 2) % icons.length],
              diameter: orbDiameter,
              color: orb3,
              phase: phase,
              phaseOffset: 3.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthItem extends StatelessWidget {
  const _HealthItem({
    required this.icon,
    required this.diameter,
    required this.color,
    required this.phase,
    required this.phaseOffset,
  });

  final IconData icon;
  final double diameter;
  final Color color;
  final double phase;
  final double phaseOffset;

  @override
  Widget build(BuildContext context) {
    final iconSize = diameter * 0.42;
    final borderPulse = (sin(phase + phaseOffset) + 1) / 2;
    final borderWidth = 1.2 + borderPulse * 2.2;
    final borderColor = Colors.white.withValues(alpha: 0.2 + borderPulse * 0.45);
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [BoxShadow(color: color, blurRadius: 40, spreadRadius: 12)],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation), child: child),
          ),
          child: Icon(icon, key: ValueKey(icon.codePoint), size: iconSize, color: const Color(0xCCFFFFFF)),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
