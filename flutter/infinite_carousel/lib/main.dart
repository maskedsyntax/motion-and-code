import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const InfiniteCarouselApp());
}

class InfiniteCarouselApp extends StatelessWidget {
  const InfiniteCarouselApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Infinite Carousel',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F1E9),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF276B61),
          brightness: Brightness.light,
        ),
      ),
      home: const InfiniteCarouselDemo(),
    );
  }
}

class InfiniteCarouselDemo extends StatefulWidget {
  const InfiniteCarouselDemo({super.key});

  @override
  State<InfiniteCarouselDemo> createState() => _InfiniteCarouselDemoState();
}

class _InfiniteCarouselDemoState extends State<InfiniteCarouselDemo> {
  static const _initialPage = 1000;
  static const _items = [
    CarouselItem(
      title: 'Aurora',
      category: 'Northern light',
      number: '01',
      surface: Color(0xFFCBE7D8),
      accent: Color(0xFF56A889),
      ink: Color(0xFF173A32),
      motif: CardMotif.ribbon,
    ),
    CarouselItem(
      title: 'Lunar',
      category: 'Quiet orbit',
      number: '02',
      surface: Color(0xFFD9D6ED),
      accent: Color(0xFF8982BE),
      ink: Color(0xFF302D53),
      motif: CardMotif.orbit,
    ),
    CarouselItem(
      title: 'Ember',
      category: 'After glow',
      number: '03',
      surface: Color(0xFFF2D2BC),
      accent: Color(0xFFD97950),
      ink: Color(0xFF5A2E21),
      motif: CardMotif.flame,
    ),
    CarouselItem(
      title: 'Tidal',
      category: 'Deep current',
      number: '04',
      surface: Color(0xFFC5E1E4),
      accent: Color(0xFF4E9DA5),
      ink: Color(0xFF163E46),
      motif: CardMotif.wave,
    ),
    CarouselItem(
      title: 'Petal',
      category: 'Soft bloom',
      number: '05',
      surface: Color(0xFFEBCED8),
      accent: Color(0xFFC46E8D),
      ink: Color(0xFF542D3D),
      motif: CardMotif.petal,
    ),
  ];

  late final PageController _pageController;
  Timer? _autoPlayTimer;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.72,
    );
    _scheduleAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _scheduleAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer(const Duration(milliseconds: 2800), _advance);
  }

  void _advance() {
    if (!_pageController.hasClients) {
      _scheduleAutoPlay();
      return;
    }
    _pageController
        .nextPage(
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeInOutQuart,
        )
        .whenComplete(_scheduleAutoPlay);
  }

  void _pauseAutoPlay() {
    _autoPlayTimer?.cancel();
  }

  void _resumeAutoPlay() {
    _scheduleAutoPlay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ColoredBox(
        color: const Color(0xFFF5F1E9),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INFINITE',
                          style: TextStyle(
                            color: Color(0xFF232125),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4.2,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Carousel',
                          style: TextStyle(
                            color: Color(0xFF232125),
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFDCD5CA)),
                      ),
                      child: const Icon(
                        Icons.all_inclusive_rounded,
                        color: Color(0xFF302E32),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                flex: 7,
                child: Listener(
                  onPointerDown: (_) => _pauseAutoPlay(),
                  onPointerUp: (_) => _resumeAutoPlay(),
                  onPointerCancel: (_) => _resumeAutoPlay(),
                  child: PageView.builder(
                    key: const Key('infinite-carousel'),
                    controller: _pageController,
                    clipBehavior: Clip.none,
                    physics: const PageScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemBuilder: (context, index) {
                      final item = _items[index % _items.length];
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          final page = _pageController.hasClients
                              ? (_pageController.page ??
                                    _initialPage.toDouble())
                              : _initialPage.toDouble();
                          final offset = (index - page).clamp(-1.0, 1.0);
                          final distance = offset.abs();
                          final scale = 1 - distance * 0.08;

                          return Opacity(
                            opacity: 1 - distance * 0.18,
                            child: Transform.translate(
                              offset: Offset(0, 10 * distance),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0012)
                                  ..rotateY(offset * -0.07)
                                  ..scaleByDouble(scale, scale, 1, 1),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: CarouselCard(item: item),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: _CarouselDetails(
                  pageController: _pageController,
                  initialPage: _initialPage,
                  items: _items,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CarouselItem {
  const CarouselItem({
    required this.title,
    required this.category,
    required this.number,
    required this.surface,
    required this.accent,
    required this.ink,
    required this.motif,
  });

  final String title;
  final String category;
  final String number;
  final Color surface;
  final Color accent;
  final Color ink;
  final CardMotif motif;
}

enum CardMotif { ribbon, orbit, flame, wave, petal }

class CarouselCard extends StatelessWidget {
  const CarouselCard({required this.item, super.key});

  final CarouselItem item;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.69,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          color: item.surface,
          border: Border.all(color: item.ink.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF413B35).withValues(alpha: 0.1),
              blurRadius: 36,
              spreadRadius: -4,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CardPatternPainter(
                  accent: item.accent,
                  ink: item.ink,
                  motif: item.motif,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: item.ink.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          'M / C',
                          style: TextStyle(
                            color: item.ink,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      Text(
                        'STUDY  ${item.number}',
                        style: TextStyle(
                          color: item.ink.withValues(alpha: 0.58),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: item.ink,
                  ),
                  Text(
                    item.category.toUpperCase(),
                    style: TextStyle(
                      color: item.ink.withValues(alpha: 0.62),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: item.ink,
                      fontSize: 38,
                      height: 1,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  const _CardPatternPainter({
    required this.accent,
    required this.ink,
    required this.motif,
  });

  final Color accent;
  final Color ink;
  final CardMotif motif;

  @override
  void paint(Canvas canvas, Size size) {
    final panel = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.2,
        size.width * 0.8,
        size.height * 0.47,
      ),
      const Radius.circular(24),
    );
    canvas.drawRRect(
      panel,
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    canvas.drawRRect(
      panel,
      Paint()
        ..color = ink.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    switch (motif) {
      case CardMotif.ribbon:
        _paintRibbon(canvas, size);
      case CardMotif.orbit:
        _paintOrbit(canvas, size);
      case CardMotif.flame:
        _paintFlame(canvas, size);
      case CardMotif.wave:
        _paintWave(canvas, size);
      case CardMotif.petal:
        _paintPetal(canvas, size);
    }
  }

  void _paintRibbon(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.31 + i * 0.062);
      final path = Path()
        ..moveTo(size.width * 0.18, y)
        ..cubicTo(
          size.width * 0.35,
          y - 38,
          size.width * 0.57,
          y + 38,
          size.width * 0.82,
          y - 4,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = i.isEven ? ink.withValues(alpha: 0.72) : accent
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 7 - i * 0.7,
      );
    }
  }

  void _paintOrbit(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.43);
    final orbitPaint = Paint()
      ..color = ink.withValues(alpha: 0.62)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, size.width * 0.12, Paint()..color = accent);
    for (final angle in [-0.48, 0.18, 0.72]) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * 0.58,
          height: size.width * 0.2,
        ),
        orbitPaint,
      );
      canvas.restore();
    }
    canvas.drawCircle(
      center + Offset(size.width * 0.25, 0),
      6,
      Paint()..color = ink,
    );
  }

  void _paintFlame(Canvas canvas, Size size) {
    final centerX = size.width * 0.5;
    for (var i = 0; i < 3; i++) {
      final inset = i * size.width * 0.075;
      final path = Path()
        ..moveTo(centerX, size.height * (0.27 + i * 0.055))
        ..quadraticBezierTo(
          size.width * 0.77 - inset,
          size.height * 0.45,
          centerX,
          size.height * (0.61 - i * 0.025),
        )
        ..quadraticBezierTo(
          size.width * 0.23 + inset,
          size.height * 0.45,
          centerX,
          size.height * (0.27 + i * 0.055),
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = i == 0
              ? ink.withValues(alpha: 0.78)
              : accent.withValues(alpha: 0.88 - i * 0.18),
      );
    }
  }

  void _paintWave(Canvas canvas, Size size) {
    for (var row = 0; row < 6; row++) {
      final path = Path();
      for (var step = 0; step <= 48; step++) {
        final x = size.width * (0.16 + step / 48 * 0.68);
        final y =
            size.height * (0.31 + row * 0.052) +
            math.sin(step / 48 * math.pi * 3 + row * 0.52) * 13;
        if (step == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = row == 2 ? accent : ink.withValues(alpha: 0.56)
          ..style = PaintingStyle.stroke
          ..strokeWidth = row == 2 ? 5 : 2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintPetal(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.43);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    for (var i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 3);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, -size.width * 0.13),
          width: size.width * 0.18,
          height: size.width * 0.34,
        ),
        Paint()
          ..color = i.isEven
              ? accent.withValues(alpha: 0.9)
              : ink.withValues(alpha: 0.68),
      );
      canvas.restore();
    }
    canvas.drawCircle(Offset.zero, 15, Paint()..color = surfaceTint);
    canvas.restore();
  }

  Color get surfaceTint => Color.lerp(accent, Colors.white, 0.6)!;

  @override
  bool shouldRepaint(covariant _CardPatternPainter oldDelegate) {
    return oldDelegate.accent != accent ||
        oldDelegate.ink != ink ||
        oldDelegate.motif != motif;
  }
}

class _CarouselDetails extends StatelessWidget {
  const _CarouselDetails({
    required this.pageController,
    required this.initialPage,
    required this.items,
  });

  final PageController pageController;
  final int initialPage;
  final List<CarouselItem> items;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final page = pageController.hasClients
            ? (pageController.page ?? initialPage.toDouble())
            : initialPage.toDouble();
        final lowerPage = page.floor();
        final progress = page - lowerPage;
        final lowerIndex = lowerPage % items.length;
        final upperIndex = (lowerPage + 1) % items.length;

        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1 - progress,
              child: Transform.translate(
                offset: Offset(-14 * progress, 0),
                child: _ItemDetails(
                  item: items[lowerIndex],
                  selectedIndex: lowerIndex,
                  itemCount: items.length,
                ),
              ),
            ),
            Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(14 * (1 - progress), 0),
                child: _ItemDetails(
                  item: items[upperIndex],
                  selectedIndex: upperIndex,
                  itemCount: items.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ItemDetails extends StatelessWidget {
  const _ItemDetails({
    required this.item,
    required this.selectedIndex,
    required this.itemCount,
  });

  final CarouselItem item;
  final int selectedIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF242126),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category}  ·  Swipe to explore',
                  style: TextStyle(
                    color: const Color(0xFF242126).withValues(alpha: 0.56),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(itemCount, (index) {
                    final active = index == selectedIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: active ? 22 : 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 7),
                      decoration: BoxDecoration(
                        color: active
                            ? item.accent
                            : const Color(0xFF242126).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Text(
            '${selectedIndex + 1}'.padLeft(2, '0'),
            style: TextStyle(
              color: const Color(0xFF242126).withValues(alpha: 0.16),
              fontSize: 46,
              height: 1,
              fontWeight: FontWeight.w200,
            ),
          ),
        ],
      ),
    );
  }
}
