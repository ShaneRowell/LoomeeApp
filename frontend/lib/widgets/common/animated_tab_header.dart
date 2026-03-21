import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

/// Reusable header used across all main tabs.
/// Terracotta background with wave bottom.
/// Uses viewPaddingOf so the correct status-bar height is always read,
/// even when an ancestor SafeArea(top: true) has consumed padding.top.
/// Wraps in AnnotatedRegion so the OS status bar becomes transparent and
/// its icons are white (readable on the terracotta background).
class AnimatedTabHeader extends StatelessWidget {
  final String title;

  const AnimatedTabHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // viewPadding.top = physical notch/status-bar inset, never zeroed out
    // by a parent SafeArea — unlike padding.top which can be consumed.
    final topPad = MediaQuery.viewPaddingOf(context).top;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Base content area scales slightly on wider tablets/foldables.
    final baseHeight = screenWidth > 600 ? 120.0 : 108.0;
    final totalHeight = baseHeight + topPad;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Make the status bar transparent so the terracotta header fills
      // right behind the clock/icons with no coloured strip.
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // white icons (Android)
        statusBarBrightness: Brightness.dark,       // light icons (iOS)
      ),
      child: SizedBox(
        width: double.infinity,
        height: totalHeight,
        child: Stack(
          children: [
            // Background — fills 100 % of the SizedBox, including the
            // status-bar slot so there is no visible gap.
            Positioned.fill(
              child: Container(color: AppTheme.accentColor),
            ),
            // Subtle top-left sheen for depth.
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
            // Wave — pinned to bottom; uses scaffold colour so it blends
            // with both light (cream) and dark (navy) backgrounds.
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
            // Title — centred in the content area, below the status bar.
            Positioned(
              top: topPad + 18,
              left: 0,
              right: 0,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: screenWidth > 600 ? 32.0 : 26.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
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
