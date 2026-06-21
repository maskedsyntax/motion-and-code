import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const GlassMusicPlayerApp());
}

class GlassMusicPlayerApp extends StatelessWidget {
  const GlassMusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glass Music Player',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const GlassMusicPlayerDemo(),
    );
  }
}

class GlassMusicPlayerDemo extends StatefulWidget {
  const GlassMusicPlayerDemo({super.key, this.autoPlay = true});

  final bool autoPlay;

  @override
  State<GlassMusicPlayerDemo> createState() => _GlassMusicPlayerDemoState();
}

class _GlassMusicPlayerDemoState extends State<GlassMusicPlayerDemo>
    with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _progressController;
  late final AnimationController _playPulseController;

  Timer? _loopTimer;
  bool _playing = false;
  bool _manualOverride = false;

  static const _trackDuration = Duration(milliseconds: 16000);
  static const _songDurationSeconds = 217;
  static const _demoPlayTarget = 1.0;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: _trackDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && _playing) {
          setState(() => _playing = false);
          _scheduleLoop(const Duration(milliseconds: 1800));
        }
      });

    _playPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      lowerBound: 0.92,
      upperBound: 1.0,
    );

    if (widget.autoPlay) {
      _loopTimer = Timer(const Duration(milliseconds: 1200), _runLoop);
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _ambientController.dispose();
    _progressController.dispose();
    _playPulseController.dispose();
    super.dispose();
  }

  void _scheduleLoop(Duration delay) {
    _loopTimer?.cancel();
    if (!mounted || _manualOverride || !widget.autoPlay) return;
    _loopTimer = Timer(delay, _runLoop);
  }

  Future<void> _pulsePlayButton() async {
    await _playPulseController.forward(from: 0.92);
    await _playPulseController.reverse();
  }

  Future<void> _runLoop() async {
    _loopTimer?.cancel();
    if (!mounted || _manualOverride) return;

    setState(() => _playing = false);
    _progressController
      ..stop()
      ..reset();

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted || _manualOverride) return;

    setState(() => _playing = true);
    await _pulsePlayButton();
    if (!mounted || _manualOverride) return;

    await _progressController.animateTo(
      _demoPlayTarget,
      duration: Duration(
        milliseconds: (_trackDuration.inMilliseconds * _demoPlayTarget).round(),
      ),
      curve: Curves.easeInOutCubic,
    );

    if (!mounted || _manualOverride) return;
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted || _manualOverride) return;

    setState(() => _playing = false);
    _progressController.stop();
    await _pulsePlayButton();
    _scheduleLoop(const Duration(milliseconds: 1600));
  }

  Future<void> _setPlaying(bool playing) async {
    setState(() => _playing = playing);
    await _pulsePlayButton();
    if (playing) {
      if (_progressController.value >= 1) {
        _progressController.reset();
      }
      _progressController.forward();
    } else {
      _progressController.stop();
    }
  }

  void _togglePlayback() {
    _loopTimer?.cancel();
    _manualOverride = true;
    final next = !_playing;
    _setPlaying(next).then((_) {
      if (!mounted) return;
      _manualOverride = false;
      if (widget.autoPlay && !next) {
        _scheduleLoop(const Duration(milliseconds: 1800));
      }
    });
  }

  String get _elapsedLabel {
    final seconds = (_progressController.value * _songDurationSeconds).round();
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _ambientController,
          _progressController,
          _playPulseController,
        ]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              _LockScreenBackground(
                ambientProgress: _ambientController.value,
                playbackProgress: _progressController.value,
                playing: _playing,
              ),
              SafeArea(
                child: Align(
                  alignment: const Alignment(0, 0.38),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _GlassMiniPlayer(
                      playing: _playing,
                      progress: _progressController.value,
                      elapsedLabel: _elapsedLabel,
                      playScale: _playPulseController.value,
                      onToggle: _togglePlayback,
                    ),
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

class _GlassMiniPlayer extends StatelessWidget {
  const _GlassMiniPlayer({
    required this.playing,
    required this.progress,
    required this.elapsedLabel,
    required this.playScale,
    required this.onToggle,
  });

  final bool playing;
  final double progress;
  final String elapsedLabel;
  final double playScale;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF050817).withValues(alpha: 0.45),
              blurRadius: 42,
              offset: const Offset(0, 24),
            ),
            BoxShadow(
              color: const Color(0xFF92D5FF).withValues(alpha: 0.16),
              blurRadius: 56,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.26),
                          Colors.white.withValues(alpha: 0.10),
                          const Color(0xFF77C8FF).withValues(alpha: 0.10),
                        ],
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const _AlbumArt(size: 76),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '10 Feet Down',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: Colors.white.withValues(alpha: 0.96),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'NF, Ruelle',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.62),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _PlayPauseButton(
                            playing: playing,
                            scale: playScale,
                            onTap: onToggle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _SnakeProgressBar(progress: progress),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            elapsedLabel,
                            key: const Key('glass-player-elapsed'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.58),
                              letterSpacing: 0.4,
                            ),
                          ),
                          const Spacer(),
                          Text(
                          '3:37',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.42),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: const _GlassPanelBorderPainter(),
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

class _GlassPanelBorderPainter extends CustomPainter {
  const _GlassPanelBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.75),
      const Radius.circular(23.25),
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.48),
          Colors.white.withValues(alpha: 0.20),
          Colors.white.withValues(alpha: 0.34),
        ],
        stops: const [0, 0.48, 1],
      ).createShader(rect);
    canvas.drawRRect(rrect, borderPaint);

    final highlightPath = Path()
      ..moveTo(24, 1.5)
      ..lineTo(size.width - 24, 1.5);
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.30);
    canvas.drawPath(highlightPath, highlightPaint);

    final innerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2.2), const Radius.circular(21.8)),
      innerShadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GlassPanelBorderPainter oldDelegate) => false;
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.playing,
    required this.scale,
    required this.onTap,
  });

  final bool playing;
  final double scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('glass-player-toggle'),
      onTap: onTap,
      child: Transform.scale(
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: playing
                  ? [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.78),
                    ]
                  : [
                      const Color(0xFFBE9CFF),
                      const Color(0xFF8B5CF6),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(
                  alpha: playing ? 0.18 : 0.34,
                ),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey<bool>(playing),
              size: 28,
              color: playing ? const Color(0xFF241632) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SnakeProgressBar extends StatelessWidget {
  const _SnakeProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: CustomPaint(
        painter: _SnakeProgressPainter(progress: progress),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SnakeProgressPainter extends CustomPainter {
  const _SnakeProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(4, size.height * 0.58)
      ..cubicTo(
        size.width * 0.10,
        size.height * 0.12,
        size.width * 0.18,
        size.height * 0.92,
        size.width * 0.28,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.38,
        size.height * 0.02,
        size.width * 0.46,
        size.height * 0.96,
        size.width * 0.58,
        size.height * 0.50,
      )
      ..cubicTo(
        size.width * 0.68,
        size.height * 0.12,
        size.width * 0.76,
        size.height * 0.82,
        size.width * 0.86,
        size.height * 0.46,
      )
      ..cubicTo(
        size.width * 0.92,
        size.height * 0.26,
        size.width - 22,
        size.height * 0.64,
        size.width - 4,
        size.height * 0.42,
      );

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5
      ..color = Colors.white.withValues(alpha: 0.16);
    canvas.drawPath(path, trackPaint);

    final metric = path.computeMetrics().first;
    final clamped = progress.clamp(0.0, 1.0);
    final activePath = metric.extractPath(0, metric.length * clamped);
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5.5
      ..shader = const LinearGradient(
        colors: [Color(0xFFE8D9FF), Color(0xFF80E7FF), Color(0xFFFFFFFF)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(activePath, activePaint);

    final tangent = metric.getTangentForOffset(metric.length * clamped);
    if (tangent == null) return;

    canvas.drawCircle(
      tangent.position,
      12,
      Paint()
        ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.drawCircle(
      tangent.position,
      7.2,
      Paint()..color = Colors.white.withValues(alpha: 0.96),
    );
    canvas.drawCircle(
      tangent.position,
      2.6,
      Paint()..color = const Color(0xFF7DD3FC),
    );
  }

  @override
  bool shouldRepaint(covariant _SnakeProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _AlbumArt extends StatelessWidget {
  const _AlbumArt({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1,
            ),
          ),
          child: Image.asset(
            'assets/one_hundred_nf.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _LockScreenBackground extends StatelessWidget {
  const _LockScreenBackground({
    required this.ambientProgress,
    required this.playbackProgress,
    required this.playing,
  });

  final double ambientProgress;
  final double playbackProgress;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _LockWallpaperPainter(
            ambientProgress: ambientProgress,
            playbackProgress: playbackProgress,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: ColoredBox(color: Colors.black.withValues(alpha: 0.08)),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
            child: Column(
              children: [
                const _StatusBar(),
                const SizedBox(height: 52),
                Text(
                  '7:52',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.96),
                    fontSize: 78,
                    height: 0.9,
                    fontWeight: FontWeight.w300,
                    letterSpacing: -4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sunday, 21 June',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 26),
                _NowPlayingPill(
                  playing: playing,
                  waveProgress: ambientProgress,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      _LockShortcut(icon: Icons.flashlight_on_rounded),
                      _LockShortcut(icon: Icons.camera_alt_rounded),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Motion',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.82),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.signal_cellular_4_bar_rounded,
          color: Colors.white.withValues(alpha: 0.84),
          size: 17,
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.wifi_rounded,
          color: Colors.white.withValues(alpha: 0.84),
          size: 17,
        ),
        const SizedBox(width: 6),
        Icon(
          Icons.battery_5_bar_rounded,
          color: Colors.white.withValues(alpha: 0.84),
          size: 19,
        ),
      ],
    );
  }
}

class _NowPlayingPill extends StatelessWidget {
  const _NowPlayingPill({
    required this.playing,
    required this.waveProgress,
  });

  final bool playing;
  final double waveProgress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(18, 16),
                  painter: _NowPlayingWavePainter(
                    progress: waveProgress,
                    active: playing,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Now Playing',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
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

class _NowPlayingWavePainter extends CustomPainter {
  const _NowPlayingWavePainter({
    required this.progress,
    required this.active,
  });

  final double progress;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: active ? 0.82 : 0.62)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.1;

    final phase = progress * math.pi * 2;
    final centerY = size.height / 2;
    const barCount = 5;

    for (var i = 0; i < barCount; i++) {
      final x = size.width * (0.12 + i * 0.19);
      final idle = 0.28 + i * 0.06;
      final beat = 0.34 + 0.66 * (0.5 + 0.5 * math.sin(phase * 2.2 + i * 1.35));
      final heightFactor = active ? beat : idle;
      final barHeight = lerpDouble(4, size.height - 2, heightFactor)!;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NowPlayingWavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.active != active;
  }
}

class _LockShortcut extends StatelessWidget {
  const _LockShortcut({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.86),
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _LockWallpaperPainter extends CustomPainter {
  const _LockWallpaperPainter({
    required this.ambientProgress,
    required this.playbackProgress,
  });

  final double ambientProgress;
  final double playbackProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final drift = ambientProgress * math.pi * 2;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(
            math.cos(drift) * 0.18,
            -0.96,
          ),
          end: Alignment(
            -math.sin(drift) * 0.22,
            0.94,
          ),
          colors: const [
            Color(0xFF07111F),
            Color(0xFF14213D),
            Color(0xFF30235E),
            Color(0xFF07101E),
          ],
          stops: const [0, 0.44, 0.72, 1],
        ).createShader(rect),
    );

    final paint = Paint()..style = PaintingStyle.fill;
    final moonCenter = Offset(size.width * 0.78, size.height * 0.18);
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFFBFE9FF).withValues(alpha: 0.55),
        const Color(0xFF8B5CF6).withValues(alpha: 0.12),
        Colors.transparent,
      ],
      stops: const [0, 0.38, 1],
    ).createShader(
      Rect.fromCircle(center: moonCenter, radius: size.shortestSide * 0.45),
    );
    canvas.drawCircle(moonCenter, size.shortestSide * 0.45, paint);

    final auroraPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF67E8F9).withValues(alpha: 0.18),
          const Color(0xFF8B5CF6).withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(rect);

    final aurora = Path()
      ..moveTo(-size.width * 0.15, size.height * 0.52)
      ..cubicTo(
        size.width * (0.18 + math.sin(drift) * 0.03),
        size.height * 0.38,
        size.width * 0.34,
        size.height * 0.72,
        size.width * 0.62,
        size.height * 0.56,
      )
      ..cubicTo(
        size.width * 0.88,
        size.height * 0.42,
        size.width,
        size.height * 0.58,
        size.width * 1.18,
        size.height * 0.44,
      )
      ..lineTo(size.width * 1.18, size.height * 0.76)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.88,
        size.width * 0.44,
        size.height * 0.70,
        -size.width * 0.15,
        size.height * 0.82,
      )
      ..close();
    canvas.drawPath(aurora, auroraPaint);

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.32);
    for (var i = 0; i < 34; i++) {
      final x = (i * 47.0 + math.sin(drift + i) * 8) % size.width;
      final y = (i * 83.0) % (size.height * 0.58);
      final twinkle = 0.55 + 0.45 * math.sin(drift * 1.8 + i);
      canvas.drawCircle(
        Offset(x, y),
        (0.7 + (i % 3) * 0.35) * twinkle,
        starPaint,
      );
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 0.92 + playbackProgress * 0.04,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.54),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant _LockWallpaperPainter oldDelegate) {
    return oldDelegate.ambientProgress != ambientProgress ||
        oldDelegate.playbackProgress != playbackProgress;
  }
}
