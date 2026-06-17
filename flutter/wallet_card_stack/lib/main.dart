import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const WalletCardStackApp());
}

class WalletCardStackApp extends StatelessWidget {
  const WalletCardStackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wallet Card Stack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F1117)),
        scaffoldBackgroundColor: const Color(0xFF0A0B0F),
      ),
      home: const WalletCardStackDemo(),
    );
  }
}

class WalletCardStackDemo extends StatefulWidget {
  const WalletCardStackDemo({super.key});

  @override
  State<WalletCardStackDemo> createState() => _WalletCardStackDemoState();
}

class _WalletCardStackDemoState extends State<WalletCardStackDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;
  Timer? _demoTimer;
  bool _expanded = false;
  int? _selectedIndex;

  static const _cards = [
    WalletCardData(
      bank: 'Motion Bank',
      holder: 'AFTAAB',
      last4: '4821',
      balance: '\$8,420.18',
      network: 'VISA',
      gradient: [Color(0xFF101114), Color(0xFF23252B), Color(0xFF3A3D46)],
      accent: Color(0xFFD5B46A),
    ),
    WalletCardData(
      bank: 'Pixel Credit',
      holder: 'MOTION & CODE',
      last4: '1049',
      balance: '\$2,180.40',
      network: 'MC',
      gradient: [Color(0xFF1D2A24), Color(0xFF2F4A3B), Color(0xFF52745E)],
      accent: Color(0xFFB8D8C0),
    ),
    WalletCardData(
      bank: 'Studio Pass',
      holder: 'CREATOR',
      last4: '7720',
      balance: '\$640.90',
      network: 'AMEX',
      gradient: [Color(0xFF1E2533), Color(0xFF344258), Color(0xFF7087A5)],
      accent: Color(0xFFC8D4E3),
    ),
    WalletCardData(
      bank: 'Travel Miles',
      holder: 'BOARDING',
      last4: '0931',
      balance: '84,200 mi',
      network: 'PLUS',
      gradient: [Color(0xFF351D20), Color(0xFF65353D), Color(0xFFA76D73)],
      accent: Color(0xFFE6B6B9),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _demoTimer = Timer(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => _expanded = true);
    });
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _shineController.dispose();
    super.dispose();
  }

  void _toggleStack() {
    setState(() {
      if (_selectedIndex != null) {
        _selectedIndex = null;
      } else {
        _expanded = !_expanded;
      }
    });
  }

  void _openCard(int index) {
    setState(() {
      _selectedIndex = index;
      _expanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = math.min(constraints.maxWidth - 32, 420.0);
          final cardHeight = maxWidth * 0.62;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleStack,
            child: Stack(
              children: [
                const Positioned.fill(child: _WalletBackdrop()),
                SafeArea(
                  child: Center(
                    child: SizedBox(
                      width: maxWidth,
                      height: constraints.maxHeight,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 650),
                            curve: Curves.easeInOutCubicEmphasized,
                            top: _selectedIndex == null ? 34 : 18,
                            left: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 260),
                              opacity: _selectedIndex == null ? 1 : 0,
                              child: const _Header(),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 740),
                            curve: Curves.easeInOutCubicEmphasized,
                            top: _selectedIndex == null
                                ? (_expanded ? 116 : 238)
                                : 28,
                            left: 0,
                            right: 0,
                            height: _selectedIndex == null
                                ? (_expanded
                                      ? cardHeight + 96 * (_cards.length - 1)
                                      : cardHeight + 28 * (_cards.length - 1))
                                : cardHeight + 286,
                            child: WalletStack(
                              cards: _cards,
                              expanded: _expanded,
                              selectedIndex: _selectedIndex,
                              cardHeight: cardHeight,
                              shineController: _shineController,
                              onCardTap: _openCard,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WalletStack extends StatelessWidget {
  const WalletStack({
    required this.cards,
    required this.expanded,
    required this.selectedIndex,
    required this.cardHeight,
    required this.shineController,
    required this.onCardTap,
    super.key,
  });

  final List<WalletCardData> cards;
  final bool expanded;
  final int? selectedIndex;
  final double cardHeight;
  final AnimationController shineController;
  final ValueChanged<int> onCardTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var index = cards.length - 1; index >= 0; index--)
          _PositionedWalletCard(
            key: ValueKey(cards[index].last4),
            data: cards[index],
            index: index,
            cardCount: cards.length,
            expanded: expanded,
            selectedIndex: selectedIndex,
            cardHeight: cardHeight,
            shineController: shineController,
            onTap: () => onCardTap(index),
          ),
        if (selectedIndex != null)
          Positioned(
            left: 0,
            right: 0,
            top: cardHeight + 24,
            child: _CardDetails(data: cards[selectedIndex!]),
          ),
      ],
    );
  }
}

class _PositionedWalletCard extends StatelessWidget {
  const _PositionedWalletCard({
    required this.data,
    required this.index,
    required this.cardCount,
    required this.expanded,
    required this.selectedIndex,
    required this.cardHeight,
    required this.shineController,
    required this.onTap,
    super.key,
  });

  final WalletCardData data;
  final int index;
  final int cardCount;
  final bool expanded;
  final int? selectedIndex;
  final double cardHeight;
  final AnimationController shineController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = selectedIndex == index;
    final detailMode = selectedIndex != null;
    final hiddenBehindDetail = detailMode && !selected;
    final compactOffset = index * 28.0;
    final expandedOffset = index * 96.0;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 600 + index * 42),
      curve: Curves.easeInOutCubicEmphasized,
      left: selected ? 0 : (hiddenBehindDetail ? 18 + index * 5 : 0),
      right: selected ? 0 : (hiddenBehindDetail ? 18 + index * 5 : 0),
      top: selected
          ? 0
          : hiddenBehindDetail
          ? 26 + index * 8
          : (expanded ? expandedOffset : compactOffset),
      height: cardHeight,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        opacity: hiddenBehindDetail ? 0 : 1,
        child: AnimatedScale(
          duration: Duration(milliseconds: 560 + index * 28),
          curve: Curves.easeInOutCubicEmphasized,
          scale: selected
              ? 1
              : hiddenBehindDetail
              ? 0.92
              : (expanded ? 1 : 1 - (cardCount - index - 1) * 0.035),
          child: AnimatedRotation(
            duration: Duration(milliseconds: 620 + index * 30),
            curve: Curves.easeInOutCubicEmphasized,
            turns: selected || expanded ? 0 : (index - 1.5) * 0.004,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: WalletCard(
                data: data,
                shineController: shineController,
                emphasized: selected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WalletCard extends StatelessWidget {
  const WalletCard({
    required this.data,
    required this.shineController,
    required this.emphasized,
    super.key,
  });

  final WalletCardData data;
  final AnimationController shineController;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shineController,
      builder: (context, _) {
        final sweep = (shineController.value * 2.2) - 0.6;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: data.gradient.last.withValues(alpha: 0.14),
                blurRadius: emphasized ? 34 : 20,
                offset: Offset(0, emphasized ? 22 : 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: emphasized ? 28 : 16,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: data.gradient,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: CustomPaint(painter: _CardPattern())),
                Positioned.fill(
                  child: FractionalTranslation(
                    translation: Offset(sweep, 0),
                    child: Transform.rotate(
                      angle: -0.55,
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 84,
                          height: 380,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.075),
                                Colors.white.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Chip(color: data.accent),
                          const Spacer(),
                          Text(
                            data.network,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        data.balance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data.bank,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.76),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                          Text(
                            '•••• ${data.last4}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CardDetails extends StatelessWidget {
  const _CardDetails({required this.data});

  final WalletCardData data;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DetailPill(
                  label: 'Available',
                  value: data.balance,
                  icon: Icons.account_balance_wallet_rounded,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _DetailPill(
                  label: 'This week',
                  value: '\$218',
                  icon: Icons.trending_up_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _TransactionsList(),
        ],
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  const _TransactionsList();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.065),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
      ),
      child: const Column(
        children: [
          _TransactionRow(
            title: 'Figma',
            subtitle: 'Design subscription',
            amount: '-\$12.00',
            icon: Icons.grid_view_rounded,
          ),
          _Divider(),
          _TransactionRow(
            title: 'Coffee Studio',
            subtitle: 'Today, 9:41 AM',
            amount: '-\$4.80',
            icon: Icons.local_cafe_rounded,
          ),
          _Divider(),
          _TransactionRow(
            title: 'Client payout',
            subtitle: 'Yesterday',
            amount: '+\$480.00',
            icon: Icons.arrow_downward_rounded,
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.54),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Cards and passes',
                style: TextStyle(
                  color: Color(0xFF9A9AA2),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 18,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.09),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(11),
              bottomRight: Radius.circular(11),
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletBackdrop extends StatelessWidget {
  const _WalletBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C1C1E), Color(0xFF101113), Color(0xFF090A0C)],
        ),
      ),
      child: CustomPaint(painter: _BackdropPainter()),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.055),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.5, size.height * 0.18),
              radius: size.width * 0.72,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.18),
      size.width * 0.72,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardPattern extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.045);

    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCircle(
        center: Offset(size.width * (0.78 + i * 0.07), size.height * 0.08),
        radius: size.width * (0.24 + i * 0.055),
      );
      canvas.drawOval(rect, paint);
    }

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.025);

    for (var y = size.height * 0.18; y < size.height; y += 22) {
      canvas.drawLine(
        Offset(size.width * 0.58, y),
        Offset(size.width, y + 28),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WalletCardData {
  const WalletCardData({
    required this.bank,
    required this.holder,
    required this.last4,
    required this.balance,
    required this.network,
    required this.gradient,
    required this.accent,
  });

  final String bank;
  final String holder;
  final String last4;
  final String balance;
  final String network;
  final List<Color> gradient;
  final Color accent;
}
