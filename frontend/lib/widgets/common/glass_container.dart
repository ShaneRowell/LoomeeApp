import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Frosted-glass surface that adapts to light and dark themes.
///
/// Light mode (cream scaffold): bright white-gradient card with a
/// crisp top-lit highlight and a subtle shadow to lift it off the page.
///
/// Dark mode (navy scaffold): translucent white overlay with strong
/// backdrop blur, giving the characteristic iOS liquid-glass look.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final List<BoxShadow>? shadow;
  final double blurSigma;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.shadow,
    this.blurSigma = 12,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultShadow = [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.30)
            : AppTheme.fontColor.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.15)
            : AppTheme.fontColor.withValues(alpha: 0.04),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow ?? defaultShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.14),
                        Colors.white.withValues(alpha: 0.06),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.88),
                        Colors.white.withValues(alpha: 0.68),
                      ],
              ),
              border: border ??
                  Border.all(
                    color: Colors.white
                        .withValues(alpha: isDark ? 0.20 : 0.75),
                    width: 0.8,
                  ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
