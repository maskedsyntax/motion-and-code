import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

const Cubic _easeOpen = Cubic(0.33, 0.0, 0.18, 1.0);
const Cubic _easeClose = Cubic(0.42, 0.0, 0.58, 1.0);

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
        fontFamily: '.AppleSystemUIFont',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8A84A),
          brightness: Brightness.light,
        ),
      ),
      home: const FolderExplosionDemo(),
    );
  }
}

class FolderExplosionDemo extends StatefulWidget {
  const FolderExplosionDemo({super.key, this.autoPlay = true});

  final bool autoPlay;

  @override
  State<FolderExplosionDemo> createState() => _FolderExplosionDemoState();
}

class _FolderExplosionDemoState extends State<FolderExplosionDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _loopTimer;
  bool _manualOverride = false;

  static const _openDuration = Duration(milliseconds: 2500);
  static const _closeDuration = Duration(milliseconds: 1850);
  static const _holdOpen = Duration(milliseconds: 2800);
  static const _holdClosed = Duration(milliseconds: 2200);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _openDuration,
    );
    if (widget.autoPlay) {
      _loopTimer = Timer(const Duration(milliseconds: 1100), _runLoop);
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runLoop() async {
    _loopTimer?.cancel();
    if (!mounted || _manualOverride) return;

    await _animateTo(1);
    if (!mounted || _manualOverride) return;

    _loopTimer = Timer(_holdOpen, () async {
      if (!mounted || _manualOverride) return;

      await _animateTo(0);
      if (!mounted || _manualOverride) return;

      _loopTimer = Timer(_holdClosed, () {
        if (mounted && !_manualOverride) {
          _runLoop();
        }
      });
    });
  }

  Future<void> _animateTo(double target) {
    final opening = target > _controller.value;
    return _controller.animateTo(
      target,
      duration: opening ? _openDuration : _closeDuration,
      curve: opening ? _easeOpen : _easeClose,
    );
  }

  void _toggle() {
    _loopTimer?.cancel();
    _manualOverride = true;
    final opening = _controller.value < 0.5;
    _animateTo(opening ? 1 : 0).then((_) {
      if (!mounted) return;
      _manualOverride = false;
      _loopTimer = Timer(
        Duration(milliseconds: opening ? _holdOpen.inMilliseconds : 1600),
        _runLoop,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _controller.value;
          final open = progress > 0.52;

          return Stack(
            fit: StackFit.expand,
            children: [
              _DeskBackdrop(progress: progress),
              LayoutBuilder(
                builder: (context, constraints) {
                  return _FolderStage(
                    progress: progress,
                    open: open,
                    size: constraints.biggest,
                    onTap: _toggle,
                  );
                },
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, right: 18),
                    child: _RecordBadge(open: open),
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
    final shortest = math.min(size.width, size.height);
    final scale = (shortest / 680).clamp(0.72, 1.18);
    final maxCardWidth = 134.0 * scale;
    final maxCardHeight = 158.0 * scale;
    final horizontalReach =
        (size.width / 2) - (maxCardWidth / 2) - (24 * scale);
    final verticalReach =
        (size.height / 2) - (maxCardHeight / 2) - (48 * scale);
    final spread = math.min(
      shortest * 0.36,
      math.min(horizontalReach / 1.02, verticalReach / 0.88),
    ).clamp(96.0 * scale, shortest * 0.42);
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final folderOnTop = progress < 0.42;

    final folder = _MacFolder(
      progress: progress,
      open: open,
      scale: scale,
    );

    final sortedCards = [..._folderCards]
      ..sort(
        (a, b) => _cardDepth(a, progress).compareTo(_cardDepth(b, progress)),
      );
    final cards = sortedCards
        .map(
          (card) => _ExplosionCard(
            key: Key('folder-card-${card.id}'),
            card: card,
            progress: progress,
            center: center,
            spread: spread,
            scale: scale,
          ),
        )
        .toList();

    return GestureDetector(
      key: const Key('folder-explosion-toggle'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StageGlowPainter(
                progress: progress,
                center: center,
              ),
            ),
          ),
          if (!folderOnTop) ...[
            Align(child: folder),
            ...cards,
          ] else ...[
            ...cards,
            Align(child: folder),
          ],
        ],
      ),
    );
  }
}

double _cardDepth(_FolderCardSpec card, double progress) {
  final scatter = _cardScatterProgress(progress, card.delay);
  return card.delay + scatter * 0.35;
}

class _MacFolder extends StatelessWidget {
  const _MacFolder({
    required this.progress,
    required this.open,
    required this.scale,
  });

  final double progress;
  final bool open;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final settle = _easeOpen.transform(progress);
    final lift = lerpDouble(0, -14 * scale, settle)!;
    final folderScale = lerpDouble(1, 0.93, Curves.easeOut.transform(progress))!;

    return Transform.translate(
      offset: Offset(0, lift),
      child: Transform.scale(
        scale: folderScale * scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 340,
              height: 268,
              child: CustomPaint(
                size: const Size(340, 268),
                painter: _MacFolderPainter(progress: progress),
              ),
            ),
            SizedBox(height: 10 * scale),
            Opacity(
              opacity: lerpDouble(1, 0.82, progress)!,
              child: Text(
                open ? '6 items' : 'Project Files',
                key: const Key('folder-shell-state'),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: (open ? 13 : 15) * scale.clamp(0.85, 1.0),
                  fontWeight: FontWeight.w600,
                  letterSpacing: open ? 0.1 : -0.2,
                  color: const Color(0xFF3D3018),
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
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
    required this.spread,
    required this.scale,
  });

  final _FolderCardSpec card;
  final double progress;
  final Offset center;
  final double spread;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final scatter = _cardScatterProgress(progress, card.delay);
    final travel = Curves.easeInOutCubic.transform(scatter);
    final settle = Curves.easeInOutCubic.transform(scatter);

    final radius = lerpDouble(6, spread * card.radiusFactor, travel)!;
    final arcLift = math.sin(travel * math.pi) * card.lift * scale;
    final drift = Offset(
      math.cos(card.angle) * radius,
      math.sin(card.angle) * radius * 0.82 - arcLift,
    );
    final offset = Offset.lerp(card.closedOffset * scale, drift, travel)!;
    final rotation = lerpDouble(
      card.closedRotation,
      card.rotation,
      Curves.easeOutCubic.transform(travel),
    )!;
    final cardScale = lerpDouble(0.68, card.openScale, settle)! * scale;
    final opacity = lerpDouble(
      0.06,
      1.0,
      Curves.easeInOutCubic.transform(scatter),
    )!;
    final cardSize = Size.lerp(
      Size(card.closedSize.width * scale, card.closedSize.height * scale),
      Size(card.openSize.width * scale, card.openSize.height * scale),
      travel,
    )!;
    final shadowBlur = lerpDouble(4, 22, travel)! * scale;
    final shadowYOffset = lerpDouble(1, 14, travel)! * scale;

    return Positioned(
      left: center.dx + offset.dx - cardSize.width / 2,
      top: center.dy + offset.dy - cardSize.height / 2,
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: cardScale / scale,
              child: _DocumentCard(
                card: card,
                width: cardSize.width / scale,
                height: cardSize.height / scale,
                progress: travel,
                shadowBlur: shadowBlur / scale,
                shadowYOffset: shadowYOffset / scale,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.card,
    required this.width,
    required this.height,
    required this.progress,
    required this.shadowBlur,
    required this.shadowYOffset,
  });

  final _FolderCardSpec card;
  final double width;
  final double height;
  final double progress;
  final double shadowBlur;
  final double shadowYOffset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A140E).withValues(alpha: 0.16),
              blurRadius: shadowBlur,
              offset: Offset(0, shadowYOffset),
            ),
            BoxShadow(
              color: card.accent.withValues(alpha: 0.12),
              blurRadius: shadowBlur * 0.6,
              offset: Offset(0, shadowYOffset * 0.45),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: const Color(0xFFFAFAF8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: height * 0.68,
                  child: CustomPaint(
                    painter: _DocumentPreviewPainter(
                      kind: card.kind,
                      accent: card.accent,
                      progress: progress,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.15,
                            color: Color(0xFF1C1712),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.detail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF6A6258).withValues(alpha: 0.9),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordBadge extends StatelessWidget {
  const _RecordBadge({required this.open});

  final bool open;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: _easeOpen,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: open ? const Color(0xFFE39D3B) : const Color(0xFF8AA0B8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            open ? 'OPEN' : 'CLOSED',
            key: const Key('folder-status-text'),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: Color(0xFF4A3A28),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeskBackdrop extends StatelessWidget {
  const _DeskBackdrop({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final warm = Curves.easeOutCubic.transform(progress);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(
              const Color(0xFFECE6DC),
              const Color(0xFFF3EBE0),
              warm,
            )!,
            Color.lerp(
              const Color(0xFFD9D0C4),
              const Color(0xFFE4D8C8),
              warm,
            )!,
            const Color(0xFFCFC4B6),
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: CustomPaint(
        painter: _DeskPainter(progress: progress),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DeskPainter extends CustomPainter {
  const _DeskPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final horizon = size.height * 0.68;
    final surfacePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD8CFC2).withValues(alpha: 0.0),
          const Color(0xFFB8AEA0).withValues(alpha: 0.22),
        ],
      ).createShader(Rect.fromLTWH(0, horizon, size.width, size.height - horizon));
    canvas.drawRect(
      Rect.fromLTWH(0, horizon, size.width, size.height - horizon),
      surfacePaint,
    );

    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment(0, 0.2),
        radius: 1.1,
        colors: [
          Colors.transparent,
          const Color(0xFF2A2118).withValues(alpha: 0.08),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _DeskPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StageGlowPainter extends CustomPainter {
  const _StageGlowPainter({required this.progress, required this.center});

  final double progress;
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    final burst = Curves.easeOutCubic.transform(progress);
    final collapse = Curves.easeInCubic.transform(1 - progress);
    final intensity = progress < 0.5 ? burst : collapse;
    if (intensity < 0.02) return;

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF4C66D).withValues(alpha: 0.14 * intensity),
          const Color(0xFFF4C66D).withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: lerpDouble(30, size.shortestSide * 0.34, intensity)!,
        ),
      );
    canvas.drawCircle(
      center,
      lerpDouble(30, size.shortestSide * 0.34, intensity)!,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _StageGlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.center != center;
  }
}

class _MacFolderPainter extends CustomPainter {
  const _MacFolderPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final open = _easeOpen.transform(progress);

    final backRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(34, 58, size.width - 68, size.height - 92),
      const Radius.circular(18),
    );
    final backPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(
            const Color(0xFFF0D278),
            const Color(0xFFE8BC4E),
            open * 0.4,
          )!,
          const Color(0xFFD89E34),
        ],
      ).createShader(backRect.outerRect);
    canvas.drawRRect(backRect.shift(const Offset(0, 4)), backPaint);

    final tabPath = Path()
      ..moveTo(58, 58)
      ..lineTo(118, 58)
      ..lineTo(132, 42)
      ..lineTo(188, 42)
      ..lineTo(202, 58)
      ..lineTo(248, 58)
      ..lineTo(248, 78)
      ..lineTo(58, 78)
      ..close();
    final tabPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF6DE8E), Color(0xFFEAB84A)],
      ).createShader(Rect.fromLTWH(58, 42, 190, 36));
    canvas.drawPath(tabPath, tabPaint);

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(28, 74, size.width - 56, size.height - 98),
      const Radius.circular(22),
    );
    canvas.drawRRect(
      bodyRect.shift(const Offset(0, 12)),
      Paint()
        ..color = const Color(0xFF8F5A1D).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFBE097),
          Color.lerp(
            const Color(0xFFEFB84A),
            const Color(0xFFE39D3B),
            open,
          )!,
          const Color(0xFFD68928),
        ],
        stops: const [0, 0.48, 1],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    final pocketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(46, 112, size.width - 92, size.height - 148),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      pocketRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF8A5A18).withValues(alpha: 0.18),
            const Color(0xFF6E4510).withValues(alpha: 0.34 + open * 0.08),
          ],
        ).createShader(pocketRect.outerRect),
    );

    final flapOpen = Curves.easeInOutCubic.transform(
      (progress / 0.48).clamp(0.0, 1.0),
    );
    final flapClose = _easeClose.transform(
      ((progress - 0.52) / 0.48).clamp(0.0, 1.0),
    );
    final flapProgress = progress < 0.52 ? flapOpen : 1 - flapClose;

    final flapPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFF2C4),
          Color.lerp(
            const Color(0xFFF2C35E),
            const Color(0xFFE39D3B),
            open,
          )!,
        ],
      ).createShader(Rect.fromLTWH(40, 70, size.width - 80, 56));

    canvas.save();
    canvas.translate(72, 88);
    canvas.rotate(lerpDouble(0.04, -0.58, flapProgress)!);
    canvas.translate(-72, -88);
    final flapPath = Path()
      ..moveTo(40, 92)
      ..lineTo(132, 92)
      ..lineTo(152, 66)
      ..lineTo(size.width - 52, 66)
      ..lineTo(size.width - 36, 104)
      ..lineTo(40, 104)
      ..close();
    canvas.drawShadow(flapPath, const Color(0x558F5A1D), 14, false);
    canvas.drawPath(flapPath, flapPaint);
    canvas.restore();

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF9F6C1F).withValues(alpha: 0.16);
    canvas.drawRRect(bodyRect.deflate(0.5), edgePaint);
  }

  @override
  bool shouldRepaint(covariant _MacFolderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

enum _DocumentKind { imageGrid, textDoc, pdf, photoStack, archive, markdown }

class _DocumentPreviewPainter extends CustomPainter {
  const _DocumentPreviewPainter({
    required this.kind,
    required this.accent,
    required this.progress,
  });

  final _DocumentKind kind;
  final Color accent;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.08),
            const Color(0xFFF5F5F2),
          ],
        ).createShader(Offset.zero & size),
    );

    switch (kind) {
      case _DocumentKind.imageGrid:
        _paintImageGrid(canvas, size);
      case _DocumentKind.textDoc:
        _paintTextDoc(canvas, size);
      case _DocumentKind.pdf:
        _paintPdf(canvas, size);
      case _DocumentKind.photoStack:
        _paintPhotoStack(canvas, size);
      case _DocumentKind.archive:
        _paintArchive(canvas, size);
      case _DocumentKind.markdown:
        _paintMarkdown(canvas, size);
    }
  }

  void _paintImageGrid(Canvas canvas, Size size) {
    const gap = 6.0;
    final cellW = (size.width - gap * 4) / 3;
    final cellH = (size.height - gap * 3) / 2;
    final colors = [
      accent.withValues(alpha: 0.55),
      accent.withValues(alpha: 0.35),
      const Color(0xFF88B4C8),
      const Color(0xFFD4A574),
      accent.withValues(alpha: 0.45),
      const Color(0xFF9CB896),
    ];
    for (var i = 0; i < 6; i++) {
      final col = i % 3;
      final row = i ~/ 3;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          gap + col * (cellW + gap),
          gap + row * (cellH + gap),
          cellW,
          cellH,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(rect, Paint()..color = colors[i]);
    }
  }

  void _paintTextDoc(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF2A241E).withValues(alpha: 0.14)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.2;
    for (var i = 0; i < 7; i++) {
      final y = 16 + i * 11.0;
      final width = size.width * (0.78 - (i % 3) * 0.08);
      canvas.drawLine(Offset(14, y), Offset(14 + width, y), linePaint);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(14, 8, 42, 5),
        const Radius.circular(2),
      ),
      Paint()..color = accent.withValues(alpha: 0.65),
    );
  }

  void _paintPdf(Canvas canvas, Size size) {
    _paintTextDoc(canvas, size);
    final badge = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - 46, 10, 32, 14),
      const Radius.circular(3),
    );
    canvas.drawRRect(badge, Paint()..color = const Color(0xFFE04B3A));
    final text = TextPainter(
      text: const TextSpan(
        text: 'PDF',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      Offset(size.width - 40, 12.5),
    );
  }

  void _paintPhotoStack(Canvas canvas, Size size) {
    final frames = [
      (const Offset(18, 18), 0.04),
      (const Offset(28, 12), -0.05),
      (const Offset(38, 20), 0.02),
    ];
    for (final (offset, angle) in frames) {
      canvas.save();
      canvas.translate(offset.dx + 40, offset.dy + 30);
      canvas.rotate(angle);
      final rect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(-36, -28, 72, 56),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = const Color(0xFFFAFAF8),
      );
      canvas.drawRRect(
        rect.deflate(4),
        Paint()..color = accent.withValues(alpha: 0.35),
      );
      canvas.restore();
    }
  }

  void _paintArchive(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.52),
        width: size.width * 0.46,
        height: size.height * 0.42,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(body, Paint()..color = accent.withValues(alpha: 0.22));
    canvas.drawRRect(
      body.deflate(6),
      Paint()..color = const Color(0xFFFAFAF8),
    );
    final zipPaint = Paint()
      ..color = accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.34),
      Offset(size.width * 0.5, size.height * 0.68),
      zipPaint,
    );
    for (var i = 0; i < 4; i++) {
      final y = size.height * 0.4 + i * 8;
      canvas.drawLine(
        Offset(size.width * 0.44, y),
        Offset(size.width * 0.56, y),
        zipPaint..strokeWidth = 1.4,
      );
    }
  }

  void _paintMarkdown(Canvas canvas, Size size) {
    final heading = TextPainter(
      text: TextSpan(
        text: '# Notes',
        style: TextStyle(
          color: accent.withValues(alpha: 0.85),
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    heading.paint(canvas, const Offset(14, 14));

    final linePaint = Paint()
      ..color = const Color(0xFF2A241E).withValues(alpha: 0.12)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    for (var i = 0; i < 5; i++) {
      final y = 38 + i * 10.0;
      canvas.drawLine(
        Offset(14, y),
        Offset(size.width * (0.72 - i * 0.04), y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DocumentPreviewPainter oldDelegate) {
    return oldDelegate.kind != kind ||
        oldDelegate.accent != accent ||
        oldDelegate.progress != progress;
  }
}

double _cardScatterProgress(double progress, double delay) {
  if (progress <= delay) return 0;
  final span = 1 - delay;
  return ((progress - delay) / span).clamp(0.0, 1.0);
}

class _FolderCardSpec {
  const _FolderCardSpec({
    required this.id,
    required this.name,
    required this.detail,
    required this.accent,
    required this.kind,
    required this.angle,
    required this.radiusFactor,
    required this.rotation,
    required this.delay,
    required this.lift,
    required this.openScale,
    required this.closedOffset,
    required this.closedRotation,
    required this.closedSize,
    required this.openSize,
  });

  final String id;
  final String name;
  final String detail;
  final Color accent;
  final _DocumentKind kind;
  final double angle;
  final double radiusFactor;
  final double rotation;
  final double delay;
  final double lift;
  final double openScale;
  final Offset closedOffset;
  final double closedRotation;
  final Size closedSize;
  final Size openSize;
}

const List<_FolderCardSpec> _folderCards = [
  _FolderCardSpec(
    id: 'assets',
    name: 'Assets',
    detail: '12 files',
    accent: Color(0xFF2F8F8A),
    kind: _DocumentKind.imageGrid,
    angle: -2.60,
    radiusFactor: 0.96,
    rotation: -0.14,
    delay: 0.18,
    lift: 36,
    openScale: 1.0,
    closedOffset: Offset(-18, -4),
    closedRotation: -0.04,
    closedSize: Size(108, 132),
    openSize: Size(128, 156),
  ),
  _FolderCardSpec(
    id: 'drafts',
    name: 'Drafts',
    detail: '6 docs',
    accent: Color(0xFFD6577D),
    kind: _DocumentKind.textDoc,
    angle: -1.57,
    radiusFactor: 1.0,
    rotation: -0.07,
    delay: 0.26,
    lift: 40,
    openScale: 1.02,
    closedOffset: Offset(-4, -12),
    closedRotation: 0.02,
    closedSize: Size(112, 136),
    openSize: Size(126, 152),
  ),
  _FolderCardSpec(
    id: 'invoice',
    name: 'Invoice.pdf',
    detail: '1.4 MB',
    accent: Color(0xFFE16E4B),
    kind: _DocumentKind.pdf,
    angle: -0.52,
    radiusFactor: 0.98,
    rotation: 0.12,
    delay: 0.34,
    lift: 34,
    openScale: 0.98,
    closedOffset: Offset(8, -8),
    closedRotation: 0.05,
    closedSize: Size(108, 132),
    openSize: Size(122, 148),
  ),
  _FolderCardSpec(
    id: 'photos',
    name: 'Photos',
    detail: '24 items',
    accent: Color(0xFF4AA3D3),
    kind: _DocumentKind.photoStack,
    angle: 0.52,
    radiusFactor: 0.96,
    rotation: 0.16,
    delay: 0.42,
    lift: 38,
    openScale: 1.04,
    closedOffset: Offset(12, 0),
    closedRotation: -0.03,
    closedSize: Size(116, 140),
    openSize: Size(132, 158),
  ),
  _FolderCardSpec(
    id: 'archive',
    name: 'Archive.zip',
    detail: '241 MB',
    accent: Color(0xFF7A5CFF),
    kind: _DocumentKind.archive,
    angle: 1.57,
    radiusFactor: 0.94,
    rotation: -0.09,
    delay: 0.50,
    lift: 32,
    openScale: 0.97,
    closedOffset: Offset(6, 8),
    closedRotation: 0.04,
    closedSize: Size(110, 134),
    openSize: Size(124, 150),
  ),
  _FolderCardSpec(
    id: 'notes',
    name: 'Notes.md',
    detail: '2 KB',
    accent: Color(0xFFB45BEA),
    kind: _DocumentKind.markdown,
    angle: 2.60,
    radiusFactor: 0.92,
    rotation: 0.11,
    delay: 0.58,
    lift: 30,
    openScale: 0.96,
    closedOffset: Offset(-10, 6),
    closedRotation: -0.05,
    closedSize: Size(106, 130),
    openSize: Size(118, 146),
  ),
];
