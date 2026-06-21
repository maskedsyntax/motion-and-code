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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF735C),
          brightness: Brightness.dark,
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
      colors: [Color(0xFF163C3A), Color(0xFF4FD6A4), Color(0xFFE6FF8A)],
      accent: Color(0xFFE8FF9A),
      icon: Icons.auto_awesome_rounded,
    ),
    CarouselItem(
      title: 'Lunar',
      category: 'Quiet orbit',
      number: '02',
      colors: [Color(0xFF15172A), Color(0xFF5156A7), Color(0xFFD5CAFF)],
      accent: Color(0xFFE2DCFF),
      icon: Icons.nightlight_round,
    ),
    CarouselItem(
      title: 'Ember',
      category: 'After glow',
      number: '03',
      colors: [Color(0xFF3D1712), Color(0xFFD6492D), Color(0xFFFFC266)],
      accent: Color(0xFFFFD08A),
      icon: Icons.local_fire_department_rounded,
    ),
    CarouselItem(
      title: 'Tidal',
      category: 'Deep current',
      number: '04',
      colors: [Color(0xFF071F32), Color(0xFF087E8B), Color(0xFF7DFFE7)],
      accent: Color(0xFF8DFFEE),
      icon: Icons.water_rounded,
    ),
    CarouselItem(
      title: 'Petal',
      category: 'Soft bloom',
      number: '05',
      colors: [Color(0xFF32152C), Color(0xFFB83B73), Color(0xFFFFB4CC)],
      accent: Color(0xFFFFC6D8),
      icon: Icons.local_florist_rounded,
    ),
  ];

  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = _initialPage;

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
    _autoPlayTimer = Timer(const Duration(milliseconds: 2200), _advance);
  }

  void _advance() {
    if (!_pageController.hasClients) {
      _scheduleAutoPlay();
      return;
    }
    _pageController
        .nextPage(
          duration: const Duration(milliseconds: 780),
          curve: Curves.easeInOutCubic,
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
    final selectedItem = _items[_currentPage % _items.length];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.25),
            radius: 1.05,
            colors: [Color(0xFF242129), Color(0xFF0D0C11), Color(0xFF07070A)],
            stops: [0, 0.62, 1],
          ),
        ),
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
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4.2,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Carousel',
                          style: TextStyle(
                            color: Colors.white,
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
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: const Icon(Icons.all_inclusive_rounded, size: 22),
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
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
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
                          final scale = 1 - distance * 0.14;

                          return Opacity(
                            opacity: 1 - distance * 0.32,
                            child: Transform.translate(
                              offset: Offset(0, 22 * distance),
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.0012)
                                  ..rotateY(offset * -0.17)
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.12),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _ItemDetails(
                    key: ValueKey(selectedItem.title),
                    item: selectedItem,
                    selectedIndex: _currentPage % _items.length,
                    itemCount: _items.length,
                  ),
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
    required this.colors,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String category;
  final String number;
  final List<Color> colors;
  final Color accent;
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.colors,
            stops: const [0, 0.58, 1],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: item.colors[1].withValues(alpha: 0.28),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CardPatternPainter(accent: item.accent),
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
                          color: Colors.black.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 21),
                      ),
                      Text(
                        item.number,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
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
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
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
  const _CardPatternPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [accent.withValues(alpha: 0.55), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.7, size.height * 0.39),
              radius: size.width * 0.62,
            ),
          );
    canvas.drawRect(Offset.zero & size, glowPaint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
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

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.4);
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
    return oldDelegate.accent != accent;
  }
}

class _ItemDetails extends StatelessWidget {
  const _ItemDetails({
    required this.item,
    required this.selectedIndex,
    required this.itemCount,
    super.key,
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
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category}  ·  Swipe to explore',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
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
                            : Colors.white.withValues(alpha: 0.2),
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
              color: Colors.white.withValues(alpha: 0.2),
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
