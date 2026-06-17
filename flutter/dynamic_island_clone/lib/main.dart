import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const DynamicIslandApp());
}

class DynamicIslandApp extends StatelessWidget {
  const DynamicIslandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dynamic Island Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
        fontFamily: 'SF Pro Display',
      ),
      home: const DynamicIslandDemo(),
    );
  }
}

class DynamicIslandDemo extends StatefulWidget {
  const DynamicIslandDemo({super.key});

  @override
  State<DynamicIslandDemo> createState() => _DynamicIslandDemoState();
}

class _DynamicIslandDemoState extends State<DynamicIslandDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  Timer? _initialTimer;
  Timer? _loopTimer;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _initialTimer = Timer(const Duration(milliseconds: 800), _toggleIsland);
    _loopTimer = Timer.periodic(const Duration(milliseconds: 4200), (_) {
      _toggleIsland();
    });
  }

  @override
  void dispose() {
    _initialTimer?.cancel();
    _loopTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleIsland() {
    if (!mounted) {
      return;
    }

    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleIsland,
            child: Stack(
              children: [
                const Positioned.fill(child: _Background()),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 132,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFEEF5FF), Color(0x00EEF5FF)],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: DynamicIsland(
                        expanded: _expanded,
                        maxWidth: math.min(width - 28, 372),
                        pulseController: _pulseController,
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  left: 28,
                  right: 28,
                  bottom: 42,
                  child: _ScreenHint(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DynamicIsland extends StatelessWidget {
  const DynamicIsland({
    required this.expanded,
    required this.maxWidth,
    required this.pulseController,
    super.key,
  });

  final bool expanded;
  final double maxWidth;
  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    final islandWidth = expanded ? maxWidth : 128.0;
    final islandHeight = expanded ? 118.0 : 38.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 680),
      curve: Curves.easeInOutCubicEmphasized,
      width: islandWidth,
      height: islandHeight,
      padding: EdgeInsets.symmetric(
        horizontal: expanded ? 18 : 13,
        vertical: expanded ? 16 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(expanded ? 34 : 28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: expanded ? 0.28 : 0.16),
            blurRadius: expanded ? 34 : 18,
            offset: Offset(0, expanded ? 18 : 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          maxWidth: maxWidth - 36,
          maxHeight: 86,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 360),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
                  child: child,
                ),
              );
            },
            child: expanded
                ? SizedBox(
                    key: const ValueKey('expanded'),
                    width: maxWidth - 36,
                    height: 86,
                    child: _ExpandedIslandContent(
                      pulseController: pulseController,
                    ),
                  )
                : const SizedBox(
                    key: ValueKey('compact'),
                    width: 102,
                    height: 22,
                    child: _CompactIslandContent(),
                  ),
          ),
        ),
      ),
    );
  }
}

class _CompactIslandContent extends StatelessWidget {
  const _CompactIslandContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF31D158),
            shape: BoxShape.circle,
          ),
        ),
        const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 18),
      ],
    );
  }
}

class _ExpandedIslandContent extends StatelessWidget {
  const _ExpandedIslandContent({required this.pulseController});

  final AnimationController pulseController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                final pulse = math.sin(pulseController.value * math.pi * 2);

                return Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF007AFF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF007AFF,
                        ).withValues(alpha: 0.34 + pulse.abs() * 0.18),
                        blurRadius: 14 + pulse.abs() * 8,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: const Icon(
                Icons.flight_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Flight tracking',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'SFO to NYC - boarding now',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFFB8BCC7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const _LiveBadge(),
          ],
        ),
        Row(
          children: [
            const Text(
              'Gate 42',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: TweenAnimationBuilder<double>(
                  key: UniqueKey(),
                  tween: Tween(begin: 0, end: 0.72),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      minHeight: 6,
                      value: value,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF31D158),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '18m',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF31D158).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Color(0xFF31D158),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F7FB), Color(0xFFE8F0FF), Color(0xFFF9FAFC)],
        ),
      ),
      child: CustomPaint(painter: _FlightPathPainter()),
    );
  }
}

class _FlightPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pathPaint = Paint()
      ..color = const Color(0xFF007AFF).withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF007AFF).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.64)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.44,
        size.width * 0.65,
        size.height * 0.58,
        size.width * 0.84,
        size.height * 0.33,
      );

    canvas.drawPath(path, pathPaint);

    for (final point in [
      Offset(size.width * 0.16, size.height * 0.64),
      Offset(size.width * 0.42, size.height * 0.51),
      Offset(size.width * 0.84, size.height * 0.33),
    ]) {
      canvas.drawCircle(point, 6, dotPaint);
      canvas.drawCircle(point, 2.5, Paint()..color = const Color(0xFF007AFF));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScreenHint extends StatelessWidget {
  const _ScreenHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.76),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.airplanemode_active_rounded,
            color: Color(0xFF007AFF),
            size: 34,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Dynamic Lagoon',
          style: TextStyle(
            color: Color(0xFF111827),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap anywhere to replay the island transition.',
          style: TextStyle(
            color: Color(0xFF5B6472),
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
