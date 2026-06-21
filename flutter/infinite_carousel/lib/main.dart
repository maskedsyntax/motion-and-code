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
      icon: Icons.auto_awesome_rounded,
    ),
    CarouselItem(
      title: 'Lunar',
      category: 'Quiet orbit',
      number: '02',
      surface: Color(0xFFD9D6ED),
      accent: Color(0xFF8982BE),
      ink: Color(0xFF302D53),
      icon: Icons.nightlight_round,
    ),
    CarouselItem(
      title: 'Ember',
      category: 'After glow',
      number: '03',
      surface: Color(0xFFF2D2BC),
      accent: Color(0xFFD97950),
      ink: Color(0xFF5A2E21),
      icon: Icons.local_fire_department_rounded,
    ),
    CarouselItem(
      title: 'Tidal',
      category: 'Deep current',
      number: '04',
      surface: Color(0xFFC5E1E4),
      accent: Color(0xFF4E9DA5),
      ink: Color(0xFF163E46),
      icon: Icons.water_rounded,
    ),
    CarouselItem(
      title: 'Petal',
      category: 'Soft bloom',
      number: '05',
      surface: Color(0xFFEBCED8),
      accent: Color(0xFFC46E8D),
      ink: Color(0xFF542D3D),
      icon: Icons.local_florist_rounded,
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
    required this.icon,
  });

  final String title;
  final String category;
  final String number;
  final Color surface;
  final Color accent;
  final Color ink;
  final IconData icon;
}

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
          border: Border.all(color: item.ink.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF413B35).withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.48),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: item.ink.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(item.icon, color: item.ink, size: 21),
                      ),
                      Text(
                        item.number,
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
  const _CardPatternPainter({required this.accent, required this.ink});

  final Color accent;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final shapePaint = Paint()..color = accent.withValues(alpha: 0.34);
    canvas.drawCircle(
      Offset(size.width * 0.74, size.height * 0.38),
      size.width * 0.38,
      shapePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.96, size.height * 0.12),
      size.width * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );

    final linePaint = Paint()
      ..color = ink.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 5; i++) {
      final radius = size.width * (0.16 + i * 0.11);
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(size.width * 0.72, size.height * 0.4),
          radius: radius,
        ),
        math.pi * 0.72,
        math.pi * 1.36,
        false,
        linePaint,
      );
    }

    final dotPaint = Paint()..color = ink.withValues(alpha: 0.25);
    for (var i = 0; i < 18; i++) {
      final angle = i * 2.4;
      final radius = 10.0 + i * 5.8;
      canvas.drawCircle(
        Offset(
          size.width * 0.7 + math.cos(angle) * radius,
          size.height * 0.4 + math.sin(angle) * radius,
        ),
        i.isEven ? 1.6 : 0.9,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CardPatternPainter oldDelegate) {
    return oldDelegate.accent != accent || oldDelegate.ink != ink;
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
