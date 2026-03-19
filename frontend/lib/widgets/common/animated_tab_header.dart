import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

/// Reusable header used across all main tabs.
/// Terracotta background with wave bottom + gentle float animation.
/// Background is pinned so no gap appears at the top during animation.
class AnimatedTabHeader extends StatefulWidget {
  final String title;

  const AnimatedTabHeader({super.key, required this.title});

  @override
  State<AnimatedTabHeader> createState() => _AnimatedTabHeaderState();
}

class _AnimatedTabHeaderState extends State<AnimatedTabHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final totalHeight = 108.0 + topPad;

    // The inner container is 4 px taller than the layout slot.
    // When the float animation moves it up by 4 px, the wave's bottom edge
    // lands exactly at the layout boundary — no gap.
    // When it drifts down, the extra cream wave bleeds a few px below the
    // layout boundary — invisible because the content behind it is the same
    // cream colour.
    const floatMax = 4.0;
    final innerHeight = totalHeight + floatMax;

    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none, // let wave overflow downward
        children: [
          // Pinned solid background — fills the full slot so no gap appears
          // at the top when the float animation drifts the content downward.
          Positioned.fill(
            child: Container(color: AppTheme.accentColor),
          ),
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: child,
            ),
            child: SizedBox(
              width: double.infinity,
              height: innerHeight,
              child: Stack(
                children: [
                  // Background
                  Positioned.fill(
                    child: Container(color: AppTheme.accentColor),
                  ),
                  // Sheen
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Wave — pinned to bottom of the TALLER inner container.
                  // Uses the theme scaffold colour so the cutout matches both
                  // light (cream) and dark (deep navy) backgrounds.
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Builder(
                      builder: (ctx) => CustomPaint(
                        size: const Size(double.infinity, 28),
                        painter: _WaveBottomPainter(
                          color: Theme.of(ctx).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                  // Title — positioned relative to actual status bar
                  Positioned(
                    top: topPad + 18,
                    left: 0,
                    right: 0,
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
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

/// Paints a smooth sine wave in [color] to create the bottom cutout effect.
class _WaveBottomPainter extends CustomPainter {
  final Color color;
  _WaveBottomPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = math.sin((x / size.width) * math.pi) * (size.height * 0.6);
      path.lineTo(x, size.height - y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaveBottomPainter old) => old.color != color;
}
