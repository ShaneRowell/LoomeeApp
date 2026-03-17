import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/app_routes.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/loomee_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // ── Logo: scale from 0.65 → 1.0 with soft bounce + fade ───────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  // ── Title: slide up 28 px + fade ──────────────────────────────────────
  late final Animation<double> _titleOpacity;

  // ── Thin accent line: scale width 0 → 1 + fade ────────────────────────
  late final Animation<double> _lineProgress;

  // ── Subtitle: slide up 18 px + fade ───────────────────────────────────
  late final Animation<double> _subtitleOpacity;

  // ── Spinner: simple fade ───────────────────────────────────────────────
  late final Animation<double> _spinnerOpacity;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.48, curve: Curves.easeOutBack),
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.38, curve: Curves.easeOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.30, 0.58, curve: Curves.easeOut),
      ),
    );

    _lineProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.52, 0.70, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.58, 0.82, curve: Curves.easeOut),
      ),
    );

    _spinnerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.80, 1.00, curve: Curves.easeIn),
      ),
    );

    _ctrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    final authProvider = context.read<AuthProvider>();
    await Future.wait([
      authProvider.tryAutoLogin(),
      // Keep splash visible long enough to complete the full animation
      const Duration(milliseconds: 2800).asFuture(),
    ]);
    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            // Derived slide values (pixels, not fractional)
            final titleDY = (1.0 - _titleOpacity.value) * 28.0;
            final subtitleDY = (1.0 - _subtitleOpacity.value) * 18.0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Logo ─────────────────────────────────────────────────
                Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: const LomeeLogo(size: 84),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Title ─────────────────────────────────────────────────
                Opacity(
                  opacity: _titleOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, titleDY),
                    child: Text(
                      'Loomeé',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.fontColor,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Accent line drawing across ─────────────────────────────
                Opacity(
                  opacity: _lineProgress.value,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 1.0,
                      child: Transform.scale(
                        scaleX: _lineProgress.value,
                        alignment: Alignment.center,
                        child: Container(
                          width: 64,
                          height: 1.5,
                          decoration: BoxDecoration(
                            color: AppTheme.fontColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Subtitle ──────────────────────────────────────────────
                Opacity(
                  opacity: _subtitleOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, subtitleDY),
                    child: Text(
                      'Virtual Fashion Try-On',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        color: AppTheme.fontColor.withValues(alpha: 0.45),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 56),

                // ── Spinner ───────────────────────────────────────────────
                Opacity(
                  opacity: _spinnerOpacity.value,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.fontColor.withValues(alpha: 0.28),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

extension on Duration {
  Future<void> asFuture() => Future.delayed(this);
}
