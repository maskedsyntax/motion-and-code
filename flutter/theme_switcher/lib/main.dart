import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const ThemeSwitcherApp());
}

class ThemeSwitcherApp extends StatelessWidget {
  const ThemeSwitcherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Theme Switcher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFB84D)),
      ),
      home: const ThemeSwitcherDemo(),
    );
  }
}

class ThemeSwitcherDemo extends StatefulWidget {
  const ThemeSwitcherDemo({super.key});

  @override
  State<ThemeSwitcherDemo> createState() => _ThemeSwitcherDemoState();
}

class _ThemeSwitcherDemoState extends State<ThemeSwitcherDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _demoTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    );

    _demoTimer = Timer(const Duration(milliseconds: 800), _toggle);
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _demoTimer?.cancel();
    final goingDark = _controller.value < 0.5;
    _controller.animateTo(
      goingDark ? 1 : 0,
      duration: const Duration(milliseconds: 1750),
      curve: Curves.easeInOutQuart,
    );
    _demoTimer = Timer(const Duration(milliseconds: 4100), _toggle);
  }

  void _handleDrag(DragUpdateDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    _demoTimer?.cancel();
    _controller.value = (_controller.value + details.delta.dx / width * 1.8)
        .clamp(0.0, 1.0);
  }

  void _handleDragEnd(DragEndDetails details) {
    _controller.animateTo(
      _controller.value > 0.5 ? 1 : 0,
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeOutCubic,
    );
    _demoTimer = Timer(const Duration(milliseconds: 3600), _toggle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggle,
        onHorizontalDragUpdate: _handleDrag,
        onHorizontalDragEnd: _handleDragEnd,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeInOutCubic.transform(_controller.value);
            return Stack(
              children: [
                Positioned.fill(child: SkyScene(progress: t)),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(progress: t),
                        const Spacer(),
                        Center(
                          child: ThemeSwitchControl(
                            progress: t,
                            onTap: _toggle,
                          ),
                        ),
                        const SizedBox(height: 86),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SkyScene extends StatelessWidget {
  const SkyScene({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final top = Color.lerp(
      const Color(0xFF8EC5FF),
      const Color(0xFF111827),
      progress,
    )!;
    final middle = Color.lerp(
      const Color(0xFFFFD6A5),
      const Color(0xFF1F2937),
      progress,
    )!;
    final bottom = Color.lerp(
      const Color(0xFFF8FAFC),
      const Color(0xFF05070B),
      progress,
    )!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, middle, bottom],
          stops: const [0, 0.54, 1],
        ),
      ),
      child: CustomPaint(
        painter: _SkyPainter(progress: progress),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SkyPainter extends CustomPainter {
  const _SkyPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    _paintStars(canvas, size);
    _paintClouds(canvas, size);
    _paintHorizon(canvas, size);
    _paintCelestialBody(canvas, size);
  }

  void _paintStars(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.white.withValues(alpha: progress);
    final stars = const [
      Offset(0.16, 0.16),
      Offset(0.72, 0.12),
      Offset(0.84, 0.24),
      Offset(0.23, 0.32),
      Offset(0.58, 0.30),
      Offset(0.42, 0.20),
      Offset(0.12, 0.48),
      Offset(0.78, 0.44),
    ];

    for (var i = 0; i < stars.length; i++) {
      final twinkle = 0.72 + 0.28 * math.sin(progress * math.pi * 2 + i);
      canvas.drawCircle(
        Offset(stars[i].dx * size.width, stars[i].dy * size.height),
        (1.4 + (i % 3) * 0.7) * progress * twinkle,
        starPaint,
      );
    }
  }

  void _paintClouds(Canvas canvas, Size size) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: (1 - progress) * 0.72);
    final shadowPaint = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: (1 - progress) * 0.1);

    void cloud(double x, double y, double scale) {
      final center = Offset(size.width * x, size.height * y);
      canvas.drawOval(
        Rect.fromCenter(
          center: center + Offset(3, 7),
          width: 112 * scale,
          height: 34 * scale,
        ),
        shadowPaint,
      );
      canvas.drawCircle(
        center + Offset(-32 * scale, 4 * scale),
        18 * scale,
        cloudPaint,
      );
      canvas.drawCircle(
        center + Offset(-8 * scale, -8 * scale),
        27 * scale,
        cloudPaint,
      );
      canvas.drawCircle(
        center + Offset(22 * scale, 2 * scale),
        21 * scale,
        cloudPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + Offset(0, 11 * scale),
            width: 108 * scale,
            height: 28 * scale,
          ),
          Radius.circular(20 * scale),
        ),
        cloudPaint,
      );
    }

    cloud(0.25 + progress * 0.08, 0.22, 0.72);
    cloud(0.78 - progress * 0.1, 0.36, 0.58);
  }

  void _paintHorizon(Canvas canvas, Size size) {
    final groundPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(
                const Color(0xFFE2E8F0),
                const Color(0xFF111827),
                progress,
              )!,
              Color.lerp(
                const Color(0xFFCBD5E1),
                const Color(0xFF05070B),
                progress,
              )!,
            ],
          ).createShader(
            Rect.fromLTWH(
              0,
              size.height * 0.73,
              size.width,
              size.height * 0.27,
            ),
          );

    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * (0.71 + progress * 0.02),
        size.width * 0.58,
        size.height * 0.77,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.82,
        size.width,
        size.height * 0.75,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, groundPaint);
  }

  void _paintCelestialBody(Canvas canvas, Size size) {
    final angle = math.pi * (1.05 + progress * 0.9);
    final orbitCenter = Offset(size.width * 0.5, size.height * 0.62);
    final orbitRadius = size.width * 0.48;
    final bodyCenter = Offset(
      orbitCenter.dx + math.cos(angle) * orbitRadius,
      orbitCenter.dy + math.sin(angle) * orbitRadius,
    );

    final moonProgress = Curves.easeOutCubic.transform(progress);
    final bodyRadius = 44.0;
    final bodyPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFFFFB84D),
        const Color(0xFFF2F5F9),
        moonProgress,
      )!;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Color.lerp(
            const Color(0xFFFFC857).withValues(alpha: 0.38),
            const Color(0xFFE0E7FF).withValues(alpha: 0.13),
            moonProgress,
          )!,
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: bodyCenter, radius: 96));

    canvas.drawCircle(bodyCenter, 96, glowPaint);
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: bodyCenter, radius: bodyRadius));
    canvas.drawCircle(bodyCenter, bodyRadius, bodyPaint);

    if (moonProgress > 0.04) {
      final cutoutColor = Color.lerp(
        const Color(0xFFFFD6A5),
        const Color(0xFF111827),
        moonProgress,
      )!;
      canvas.save();
      canvas.clipPath(moonPath);
      canvas.drawCircle(
        bodyCenter + Offset(24 * moonProgress, -10 * moonProgress),
        42 * moonProgress,
        Paint()..color = cutoutColor,
      );
      canvas.restore();
    }

    if (moonProgress > 0.58) {
      final craterPaint = Paint()
        ..color = const Color(
          0xFFCBD5E1,
        ).withValues(alpha: (moonProgress - 0.58) / 0.42 * 0.38);
      canvas.save();
      canvas.clipPath(moonPath);
      canvas.drawCircle(bodyCenter + const Offset(-13, -13), 4.2, craterPaint);
      canvas.drawCircle(bodyCenter + const Offset(-21, 10), 2.8, craterPaint);
      canvas.drawCircle(bodyCenter + const Offset(2, 17), 3.4, craterPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class ThemeSwitchControl extends StatelessWidget {
  const ThemeSwitchControl({
    required this.progress,
    required this.onTap,
    super.key,
  });

  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width - 72, 292.0);
    final knobSize = 72.0;
    final travel = width - knobSize - 16;
    final x = 8 + travel * progress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 88,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color.lerp(
            const Color(0xFFFFFFFF).withValues(alpha: 0.42),
            const Color(0xFF111827).withValues(alpha: 0.72),
            progress,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Color.lerp(
              Colors.white.withValues(alpha: 0.72),
              Colors.white.withValues(alpha: 0.16),
              progress,
            )!,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16 + progress * 0.22),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 28,
              top: 0,
              bottom: 0,
              child: Icon(
                Icons.wb_sunny_rounded,
                color: Color.lerp(
                  const Color(0xFFFFB84D),
                  Colors.white.withValues(alpha: 0.26),
                  progress,
                ),
                size: 28,
              ),
            ),
            Positioned(
              right: 28,
              top: 0,
              bottom: 0,
              child: Icon(
                Icons.nightlight_round,
                color: Color.lerp(
                  Colors.black.withValues(alpha: 0.2),
                  const Color(0xFFE7EAF0),
                  progress,
                ),
                size: 27,
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 0),
              left: x,
              top: 0,
              bottom: 0,
              child: _SwitchKnob(progress: progress, size: knobSize),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchKnob extends StatelessWidget {
  const _SwitchKnob({required this.progress, required this.size});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SwitchKnobPainter(progress: progress),
      child: SizedBox(width: size, height: size),
    );
  }
}

class _SwitchKnobPainter extends CustomPainter {
  const _SwitchKnobPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final moonProgress = Curves.easeOutCubic.transform(progress);
    final knobPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - 2));
    final bodyColor = Color.lerp(
      const Color(0xFFFFC857),
      const Color(0xFFE5E7EB),
      moonProgress,
    )!;
    final trackCutoutColor = Color.lerp(
      const Color(0xFFEAF2FA),
      const Color(0xFF111827),
      moonProgress,
    )!;

    canvas.drawCircle(
      center + const Offset(0, 8),
      radius - 2,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..color = Color.lerp(
          const Color(0xFFFFD98A).withValues(alpha: 0.36),
          const Color(0xFFFFFFFF).withValues(alpha: 0.18),
          moonProgress,
        )!,
    );

    canvas.drawCircle(center, radius - 2, Paint()..color = bodyColor);

    if (progress < 0.72) {
      final iconPaint = Paint()
        ..color = Colors.white.withValues(alpha: 1 - progress)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 10; i++) {
        final angle = math.pi * 2 * i / 10;
        final start = center + Offset(math.cos(angle), math.sin(angle)) * 17;
        final end = center + Offset(math.cos(angle), math.sin(angle)) * 23;
        canvas.drawLine(start, end, iconPaint);
      }
      canvas.drawCircle(center, 10.5, iconPaint);
    }

    if (moonProgress > 0) {
      canvas.save();
      canvas.clipPath(knobPath);
      canvas.drawCircle(
        center + Offset(20 * moonProgress, -8 * moonProgress),
        34 * moonProgress,
        Paint()..color = trackCutoutColor,
      );
      if (moonProgress > 0.72) {
        final craterPaint = Paint()
          ..color = const Color(
            0xFFCBD5E1,
          ).withValues(alpha: (moonProgress - 0.72) / 0.28 * 0.46);
        canvas.drawCircle(center + const Offset(-12, -13), 3.8, craterPaint);
        canvas.drawCircle(center + const Offset(-19, 9), 2.6, craterPaint);
        canvas.drawCircle(center + const Offset(2, 15), 3.0, craterPaint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SwitchKnobPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          progress < 0.5 ? 'Morning' : 'Midnight',
          style: TextStyle(
            color: Color.lerp(const Color(0xFF172033), Colors.white, progress),
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          progress < 0.5
              ? 'Light mode with atmosphere.'
              : 'Dark mode with a sky.',
          style: TextStyle(
            color: Color.lerp(
              const Color(0xFF64748B),
              const Color(0xFF9CA3AF),
              progress,
            ),
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
