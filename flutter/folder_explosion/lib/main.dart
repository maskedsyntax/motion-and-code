import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const FolderExplosionApp());
}

class FolderExplosionApp extends StatelessWidget {
  const FolderExplosionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Folder Explosion',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDE8B3A),
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
          ),
          headlineSmall: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      home: const FolderExplosionDemo(),
    );
  }
}

class FolderExplosionDemo extends StatefulWidget {
  const FolderExplosionDemo({super.key});

  @override
  State<FolderExplosionDemo> createState() => _FolderExplosionDemoState();
}

class _FolderExplosionDemoState extends State<FolderExplosionDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1180),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    final target = _controller.value < 0.5 ? 1.0 : 0.0;
    _controller.animateTo(
      target,
      duration: Duration(milliseconds: target > _controller.value ? 1180 : 880),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = Curves.easeInOutCubic.transform(_controller.value);
          final open = progress > 0.5;

          return Stack(
            children: [
              Positioned.fill(child: _ExplosionBackdrop(progress: progress)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Folder Explosion',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontSize: 34,
                                        color: const Color(0xFF241A11),
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the folder to scatter the files.',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: const Color(0xFF6E6358),
                                        height: 1.3,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          _StatusChip(open: open),
                        ],
                      ),
                      const Spacer(),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 760,
                            maxHeight: 390,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return _FolderStage(
                                progress: progress,
                                open: open,
                                size: constraints.biggest,
                                onTap: _toggle,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        open
                            ? 'Open state: files are spread across the canvas.'
                            : 'Closed state: all files are tucked into the folder.',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: const Color(0xFF6E6358)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FolderStage extends StatelessWidget {
  const _FolderStage({
    required this.progress,
    required this.open,
    required this.size,
    required this.onTap,
  });

  final double progress;
  final bool open;
  final Size size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final center = Offset(size.width * 0.5, size.height * 0.56);
    final stageWidth = math.max(size.width, 360.0);
    final stageHeight = math.max(size.height, 320.0);

    return GestureDetector(
      key: const Key('folder-explosion-toggle'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: stageWidth,
        height: stageHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ExplosionRaysPainter(progress: progress),
              ),
            ),
            ..._folderCards.map(
              (card) => _ExplosionCard(
                key: Key('folder-card-${card.id}'),
                card: card,
                progress: progress,
                center: center,
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: _FolderShell(progress: progress, open: open),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderShell extends StatelessWidget {
  const _FolderShell({required this.progress, required this.open});

  final double progress;
  final bool open;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(290, 220),
            painter: _FolderPainter(progress: progress),
          ),
          Positioned(
            left: 48,
            right: 48,
            bottom: 22,
            child: AnimatedOpacity(
              opacity: open ? 0.95 : 0.82,
              duration: const Duration(milliseconds: 180),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    open ? 'EXPANDED' : 'CLOSED',
                    key: const Key('folder-shell-state'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      letterSpacing: 2.2,
                      color: const Color(0xFF5F4D39),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Project Files',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      color: const Color(0xFF281D13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplosionCard extends StatelessWidget {
  const _ExplosionCard({
    super.key,
    required this.card,
    required this.progress,
    required this.center,
  });

  final _FolderCardSpec card;
  final double progress;
  final Offset center;

  @override
  Widget build(BuildContext context) {
    final cardProgress = _cardProgress(progress, card.delay);
    final eased = Curves.easeOutCubic.transform(cardProgress);
    final radius = lerpDouble(16, card.radius, eased)!;
    final drift = Offset(
      math.cos(card.angle) * radius,
      math.sin(card.angle) * radius * 0.78,
    );
    final offset = Offset.lerp(card.closedOffset, drift, eased)!;
    final rotation = lerpDouble(card.closedRotation, card.rotation, eased)!;
    final scale = lerpDouble(0.88, 1.0, eased)!;
    final opacity = lerpDouble(
      0.12,
      1.0,
      Curves.easeOut.transform(cardProgress),
    )!;
    final cardSize = Size.lerp(card.closedSize, card.openSize, eased)!;

    return Positioned(
      left: center.dx + offset.dx - cardSize.width / 2,
      top: center.dy + offset.dy - cardSize.height / 2,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: _FileCardWidget(
                card: card,
                size: cardSize,
                progress: eased,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FileCardWidget extends StatelessWidget {
  const _FileCardWidget({
    required this.card,
    required this.size,
    required this.progress,
  });

  final _FolderCardSpec card;
  final Size size;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: card.color.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          const BoxShadow(
            color: Color(0x1A2C2014),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: CustomPaint(
          painter: _FileCardPainter(card: card, progress: progress),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 130,
                height: 92,
                child: _FileCardFace(card: card),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FileCardFace extends StatelessWidget {
  const _FileCardFace({required this.card});

  final _FolderCardSpec card;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: card.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(card.icon, size: 16, color: card.color),
            ),
            const Spacer(),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: card.color.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          card.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 16,
            color: const Color(0xFF22180F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          card.detail,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: const Color(0xFF6C6258)),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: open ? const Color(0xFFF8DFAE) : const Color(0xFFE5ECF5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: open ? const Color(0xFFE5B95E) : const Color(0xFFCBD6E2),
        ),
      ),
      child: Text(
        open ? 'OPEN' : 'CLOSED',
        key: const Key('folder-status-text'),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          letterSpacing: 1.6,
          color: const Color(0xFF50371A),
        ),
      ),
    );
  }
}

class _ExplosionBackdrop extends StatelessWidget {
  const _ExplosionBackdrop({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final glow = Color.lerp(
      const Color(0xFFF7EFE0),
      const Color(0xFFFDF4EA),
      progress,
    )!;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFF7F1E7), glow, const Color(0xFFF0ECE2)],
          stops: const [0, 0.52, 1],
        ),
      ),
      child: CustomPaint(
        painter: _BackdropPainter(progress: progress),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final haze = [
      _Orb(
        center: Offset(size.width * 0.12, size.height * 0.18),
        radius: size.shortestSide * 0.24,
        color: const Color(0xFFCCE6F4).withValues(alpha: 0.34),
      ),
      _Orb(
        center: Offset(size.width * 0.84, size.height * 0.18),
        radius: size.shortestSide * 0.22,
        color: const Color(0xFFF6D4B7).withValues(alpha: 0.30),
      ),
      _Orb(
        center: Offset(size.width * 0.84, size.height * 0.82),
        radius: size.shortestSide * 0.20,
        color: const Color(0xFFD9E9D7).withValues(alpha: 0.24),
      ),
    ];

    for (final orb in haze) {
      paint.shader = RadialGradient(
        colors: [orb.color, orb.color.withValues(alpha: 0)],
      ).createShader(Rect.fromCircle(center: orb.center, radius: orb.radius));
      canvas.drawCircle(orb.center, orb.radius, paint);
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFB7A28A).withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const spacing = 42.0;
    for (var x = 0.0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final dotPaint = Paint()
      ..color = const Color(0xFF8D7662).withValues(alpha: 0.08);
    for (var i = 0; i < 40; i++) {
      final dx = (i * 37.0) % size.width;
      final dy = (i * 61.0) % size.height;
      canvas.drawCircle(Offset(dx, dy), 1.2 + (i % 3) * 0.4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ExplosionRaysPainter extends CustomPainter {
  const _ExplosionRaysPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.56);
    final rays = Paint()
      ..color = const Color(0xFFD8A15B).withValues(alpha: 0.18 * progress)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    for (var i = 0; i < 10; i++) {
      final angle = -math.pi * 0.8 + (math.pi * 1.6 / 9) * i;
      final length = lerpDouble(
        18,
        180,
        Curves.easeOutCubic.transform(progress),
      )!;
      final start = center + Offset(math.cos(angle) * 14, math.sin(angle) * 14);
      final end =
          center + Offset(math.cos(angle) * length, math.sin(angle) * length);
      canvas.drawLine(start, end, rays);
    }

    final sparkPaint = Paint()
      ..color = const Color(0xFFE8B56E).withValues(alpha: 0.55 * progress);
    for (var i = 0; i < 16; i++) {
      final t = i / 16;
      final angle = -math.pi + t * math.pi * 2;
      final radius = lerpDouble(6, 166, Curves.easeOut.transform(progress))!;
      final offset =
          center +
          Offset(math.cos(angle) * radius, math.sin(angle) * radius * 0.72);
      canvas.drawCircle(offset, 1.6 + (i % 4) * 0.3, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExplosionRaysPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _FolderPainter extends CustomPainter {
  const _FolderPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyRect = Rect.fromLTWH(28, 72, size.width - 56, size.height - 94);
    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(26),
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFF4C66D),
          Color.lerp(
            const Color(0xFFE9A93E),
            const Color(0xFFD98B31),
            progress,
          )!,
        ],
      ).createShader(bodyRect);

    final shadowPaint = Paint()
      ..color = const Color(0xFF8F5A1D).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawRRect(bodyRRect.shift(const Offset(0, 8)), shadowPaint);
    canvas.drawRRect(bodyRRect, bodyPaint);

    final lipPath = Path()
      ..moveTo(40, 90)
      ..lineTo(112, 90)
      ..lineTo(130, 68)
      ..lineTo(size.width - 40, 68)
      ..lineTo(size.width - 40, 106)
      ..lineTo(40, 106)
      ..close();
    final lipPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFF8D98B),
          Color.lerp(
            const Color(0xFFE8B34F),
            const Color(0xFFD98C32),
            progress,
          )!,
        ],
      ).createShader(Rect.fromLTWH(40, 68, size.width - 80, 38));
    canvas.drawPath(lipPath, lipPaint);

    final flapPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFDE2A7),
          Color.lerp(
            const Color(0xFFF0BB63),
            const Color(0xFFE39D3B),
            progress,
          )!,
        ],
      ).createShader(Rect.fromLTWH(40, 52, size.width - 90, 46));
    canvas.save();
    canvas.translate(58, 70);
    canvas.rotate(
      lerpDouble(0.0, -0.42, Curves.easeInOutCubic.transform(progress))!,
    );
    canvas.translate(-58, -70);
    final flapPath = Path()
      ..moveTo(40, 76)
      ..lineTo(118, 76)
      ..lineTo(136, 54)
      ..lineTo(size.width - 62, 54)
      ..lineTo(size.width - 48, 90)
      ..lineTo(40, 90)
      ..close();
    canvas.drawShadow(flapPath, const Color(0xAA8F5A1D), 10, false);
    canvas.drawPath(flapPath, flapPaint);
    canvas.restore();

    final insetPaint = Paint()
      ..color = const Color(0xFF9F6C1F).withValues(alpha: 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(44, 114, size.width - 88, size.height - 142),
        const Radius.circular(18),
      ),
      insetPaint,
    );

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(40, 78, size.width - 120, 16),
        const Radius.circular(8),
      ),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FolderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _FileCardPainter extends CustomPainter {
  const _FileCardPainter({required this.card, required this.progress});

  final _FolderCardSpec card;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paperPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          card.color.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(22)),
      paperPaint,
    );

    final foldPaint = Paint()..color = card.color.withValues(alpha: 0.24);
    final fold = Path()
      ..moveTo(size.width - 26, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, 26)
      ..close();
    canvas.drawPath(fold, foldPaint);

    final linesPaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = card.color.withValues(alpha: 0.26);

    final lineCount = 3 + (progress * 2).floor();
    for (var i = 0; i < lineCount; i++) {
      final y = 44.0 + i * 12.0;
      canvas.drawLine(
        Offset(16, y),
        Offset(size.width * (0.56 + i * 0.06), y),
        linesPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FileCardPainter oldDelegate) {
    return oldDelegate.card != card || oldDelegate.progress != progress;
  }
}

double _cardProgress(double progress, double delay) {
  final started = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
  return Curves.easeOutCubic.transform(started);
}

class _FolderCardSpec {
  const _FolderCardSpec({
    required this.id,
    required this.name,
    required this.detail,
    required this.color,
    required this.icon,
    required this.angle,
    required this.radius,
    required this.rotation,
    required this.delay,
    required this.closedOffset,
    required this.closedRotation,
    required this.closedSize,
    required this.openSize,
  });

  final String id;
  final String name;
  final String detail;
  final Color color;
  final IconData icon;
  final double angle;
  final double radius;
  final double rotation;
  final double delay;
  final Offset closedOffset;
  final double closedRotation;
  final Size closedSize;
  final Size openSize;
}

class _Orb {
  const _Orb({required this.center, required this.radius, required this.color});

  final Offset center;
  final double radius;
  final Color color;
}

const List<_FolderCardSpec> _folderCards = [
  _FolderCardSpec(
    id: 'assets',
    name: 'Assets',
    detail: '12 files',
    color: Color(0xFF2F8F8A),
    icon: Icons.image_outlined,
    angle: -2.5,
    radius: 170,
    rotation: -0.18,
    delay: 0.00,
    closedOffset: Offset(-26, -10),
    closedRotation: -0.04,
    closedSize: Size(110, 80),
    openSize: Size(120, 86),
  ),
  _FolderCardSpec(
    id: 'drafts',
    name: 'Drafts',
    detail: '6 docs',
    color: Color(0xFFD6577D),
    icon: Icons.edit_note_outlined,
    angle: -1.7,
    radius: 192,
    rotation: -0.06,
    delay: 0.06,
    closedOffset: Offset(-6, -18),
    closedRotation: 0.02,
    closedSize: Size(120, 84),
    openSize: Size(126, 90),
  ),
  _FolderCardSpec(
    id: 'invoice',
    name: 'Invoice.pdf',
    detail: '1.4 MB',
    color: Color(0xFFE16E4B),
    icon: Icons.description_outlined,
    angle: -0.8,
    radius: 176,
    rotation: 0.16,
    delay: 0.12,
    closedOffset: Offset(20, -14),
    closedRotation: 0.05,
    closedSize: Size(112, 84),
    openSize: Size(120, 88),
  ),
  _FolderCardSpec(
    id: 'photos',
    name: 'Photos',
    detail: '24 items',
    color: Color(0xFF4AA3D3),
    icon: Icons.photo_outlined,
    angle: 0.3,
    radius: 202,
    rotation: 0.22,
    delay: 0.18,
    closedOffset: Offset(14, 2),
    closedRotation: -0.03,
    closedSize: Size(124, 88),
    openSize: Size(132, 94),
  ),
  _FolderCardSpec(
    id: 'archive',
    name: 'Archive.zip',
    detail: '241 MB',
    color: Color(0xFF7A5CFF),
    icon: Icons.archive_outlined,
    angle: 1.25,
    radius: 180,
    rotation: -0.12,
    delay: 0.24,
    closedOffset: Offset(-10, 14),
    closedRotation: 0.04,
    closedSize: Size(116, 84),
    openSize: Size(124, 90),
  ),
  _FolderCardSpec(
    id: 'notes',
    name: 'Notes.md',
    detail: '2 KB',
    color: Color(0xFFB45BEA),
    icon: Icons.notes_outlined,
    angle: 2.05,
    radius: 168,
    rotation: 0.14,
    delay: 0.30,
    closedOffset: Offset(26, 10),
    closedRotation: -0.05,
    closedSize: Size(110, 80),
    openSize: Size(118, 86),
  ),
];
