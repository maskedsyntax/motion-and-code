import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const AppStoreDownloadApp());
}

class AppStoreDownloadApp extends StatelessWidget {
  const AppStoreDownloadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Store Download Button',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),
      home: const DownloadButtonDemo(),
    );
  }
}

class DownloadButtonDemo extends StatefulWidget {
  const DownloadButtonDemo({super.key});

  @override
  State<DownloadButtonDemo> createState() => _DownloadButtonDemoState();
}

class _DownloadButtonDemoState extends State<DownloadButtonDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  Timer? _sequenceTimer;
  DownloadState _state = DownloadState.get;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _sequenceTimer = Timer(const Duration(milliseconds: 900), _runSequence);
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _runSequence() async {
    _sequenceTimer?.cancel();
    _progressController
      ..stop()
      ..reset();

    setState(() => _state = DownloadState.get);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() => _state = DownloadState.loading);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() => _state = DownloadState.progress);
    await _progressController.forward();
    if (!mounted) return;

    setState(() => _state = DownloadState.installed);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;

    setState(() => _state = DownloadState.open);
    _sequenceTimer = Timer(const Duration(milliseconds: 2200), _runSequence);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _runSequence,
        child: ColoredBox(
          color: const Color(0xFFF5F5F7),
          child: SafeArea(
            child: _AppStoreLayout(
              state: _state,
              progressController: _progressController,
            ),
          ),
        ),
      ),
    );
  }
}

enum DownloadState { get, loading, progress, installed, open }

class _AppStoreLayout extends StatelessWidget {
  const _AppStoreLayout({
    required this.state,
    required this.progressController,
  });

  final DownloadState state;
  final AnimationController progressController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _StoreHeader(),
                      const SizedBox(height: 20),
                      _ProductHeader(
                        state: state,
                        progressController: progressController,
                      ),
                      const SizedBox(height: 24),
                      const _StatsRow(),
                      const SizedBox(height: 24),
                      const _PreviewStrip(),
                      const SizedBox(height: 24),
                      const _DescriptionBlock(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StoreHeader extends StatelessWidget {
  const _StoreHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            'Apps',
            style: TextStyle(
              color: Color(0xFF1D1D1F),
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ),
        CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFD7E8FF),
          child: Icon(Icons.person_rounded, color: Color(0xFF007AFF), size: 21),
        ),
      ],
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.state, required this.progressController});

  final DownloadState state;
  final AnimationController progressController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _AppIcon(),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FrameLab',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF1D1D1F),
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  height: 1.08,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Design motion faster',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF6E6E73),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    '4+',
                    style: TextStyle(
                      color: Color(0xFF8A8A8E),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Productivity',
                    style: TextStyle(
                      color: Color(0xFF8A8A8E),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        DownloadButton(state: state, progressController: progressController),
      ],
    );
  }
}

class DownloadButton extends StatelessWidget {
  const DownloadButton({
    required this.state,
    required this.progressController,
    super.key,
  });

  final DownloadState state;
  final AnimationController progressController;

  @override
  Widget build(BuildContext context) {
    final isCompact = switch (state) {
      DownloadState.loading ||
      DownloadState.progress ||
      DownloadState.installed => true,
      DownloadState.get || DownloadState.open => false,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubicEmphasized,
      width: isCompact ? 34 : 72,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFE9F2FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: switch (state) {
          DownloadState.get => const _ButtonLabel(
            key: ValueKey('get'),
            text: 'GET',
          ),
          DownloadState.loading => const _LoadingGlyph(
            key: ValueKey('loading'),
          ),
          DownloadState.progress => _ProgressGlyph(
            key: const ValueKey('progress'),
            progressController: progressController,
          ),
          DownloadState.installed => const _InstalledGlyph(
            key: ValueKey('installed'),
          ),
          DownloadState.open => const _ButtonLabel(
            key: ValueKey('open'),
            text: 'OPEN',
          ),
        },
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF007AFF),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _LoadingGlyph extends StatefulWidget {
  const _LoadingGlyph({super.key});

  @override
  State<_LoadingGlyph> createState() => _LoadingGlyphState();
}

class _LoadingGlyphState extends State<_LoadingGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _controller,
        child: CustomPaint(
          size: const Size.square(19),
          painter: _SpinnerPainter(),
        ),
      ),
    );
  }
}

class _ProgressGlyph extends StatelessWidget {
  const _ProgressGlyph({required this.progressController, super.key});

  final AnimationController progressController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: progressController,
        builder: (context, _) {
          return CustomPaint(
            size: const Size.square(22),
            painter: _ProgressPainter(progress: progressController.value),
          );
        },
      ),
    );
  }
}

class _InstalledGlyph extends StatelessWidget {
  const _InstalledGlyph({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 430),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: const Icon(
          Icons.check_rounded,
          color: Color(0xFF007AFF),
          size: 22,
        ),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [Color(0x00007AFF), Color(0xFF007AFF)],
        stops: [0.15, 1],
      ).createShader(rect);

    canvas.drawArc(rect.deflate(2), -math.pi / 2, math.pi * 1.55, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressPainter extends CustomPainter {
  const _ProgressPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = const Color(0xFF007AFF).withValues(alpha: 0.16);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF007AFF);

    canvas.drawOval(rect.deflate(2.4), trackPaint);
    canvas.drawArc(
      rect.deflate(2.4),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: rect.center, width: 6.6, height: 6.6),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF007AFF),
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF202124), Color(0xFF3C4043)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -0.22,
            child: Container(
              width: 34,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF4B5563),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
            ),
          ),
          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatItem(
            label: '4.8',
            value: '12K ratings',
            icon: Icons.star_rounded,
          ),
        ),
        _StatDivider(),
        Expanded(
          child: _StatItem(
            label: 'No. 7',
            value: 'Productivity',
            icon: Icons.workspace_premium_rounded,
          ),
        ),
        _StatDivider(),
        Expanded(
          child: _StatItem(
            label: '4+',
            value: 'Age',
            icon: Icons.person_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF8A8A8E),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF6E6E73),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Icon(icon, color: const Color(0xFF8A8A8E), size: 16),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 38, color: const Color(0xFFDADADF));
  }
}

class _PreviewStrip extends StatelessWidget {
  const _PreviewStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _PreviewTile(
            accent: [
              const Color(0xFF007AFF),
              const Color(0xFF34C759),
              const Color(0xFFFF9F0A),
            ][index],
          );
        },
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E2E7)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 82,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1D1F),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _SkeletonLine(width: 74, color: accent),
              const SizedBox(height: 8),
              const _SkeletonLine(width: 96, color: Color(0xFFE5E5EA)),
              const SizedBox(height: 6),
              const _SkeletonLine(width: 58, color: Color(0xFFE5E5EA)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A focused canvas for building interface motion, exporting clips, and testing tiny interactions before they ship.',
          style: TextStyle(
            color: Color(0xFF1D1D1F),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _InfoRow(label: 'Version', value: '2.4'),
            ),
            Expanded(
              child: _InfoRow(label: 'Size', value: '48 MB'),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8A8E),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1D1D1F),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
