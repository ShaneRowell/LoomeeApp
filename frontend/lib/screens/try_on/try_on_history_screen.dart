import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/try_on_provider.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/try_on/try_on_status_badge.dart';

class TryOnHistoryScreen extends StatefulWidget {
  const TryOnHistoryScreen({super.key});

  @override
  State<TryOnHistoryScreen> createState() => _TryOnHistoryScreenState();
}

class _TryOnHistoryScreenState extends State<TryOnHistoryScreen>
    with SingleTickerProviderStateMixin {
  String? _statusFilter;
  late AnimationController _particleCtrl;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    final rng = math.Random(17);
    _particles = List.generate(32, (_) => _Particle(
      baseX: rng.nextDouble(),
      baseY: rng.nextDouble(),
      amplitude: 8 + rng.nextDouble() * 18,
      phase: rng.nextDouble() * 2 * math.pi,
      frequency: 0.35 + rng.nextDouble() * 0.9,
      radius: 1.5 + rng.nextDouble() * 3.2,
      opacity: 0.08 + rng.nextDouble() * 0.22,
      useAccent: rng.nextBool(),
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TryOnProvider>().fetchTryOns();
    });
  }

  @override
  void dispose() {
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              'Try-On History',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.fontColor,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _filterChip('All', null),
                const SizedBox(width: 8),
                _filterChip('Completed', 'completed'),
                const SizedBox(width: 8),
                _filterChip('Processing', 'processing'),
                const SizedBox(width: 8),
                _filterChip('Failed', 'failed'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<TryOnProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const LoadingShimmer.list();
                if (provider.tryOns.isEmpty) {
                  return _buildParticleEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () => provider.fetchTryOns(status: _statusFilter),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.tryOns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tryOn = provider.tryOns[index];
                      return Dismissible(
                        key: Key(tryOn.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => provider.deleteTryOn(tryOn.id),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.tryOnResult,
                            arguments: tryOn.id,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.fontColor.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: tryOn.clothing?.images.isNotEmpty == true
                                      ? CachedNetworkImage(
                                          imageUrl: tryOn.clothing!.images.first,
                                          width: 65,
                                          height: 65,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) => _placeholder(),
                                        )
                                      : _placeholder(),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tryOn.clothing?.name ?? 'Unknown Item',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.fontColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tryOn.clothing?.brand ?? '',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300,
                                          color: AppTheme.fontColor.withValues(alpha: 0.5),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          TryOnStatusBadge(status: tryOn.status),
                                          const Spacer(),
                                          if (tryOn.createdAt != null)
                                            Text(
                                              DateFormat('MMM d').format(tryOn.createdAt!),
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: AppTheme.fontColor.withValues(alpha: 0.4),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppTheme.fontColor.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Particle empty state ───────────────────────────────────────────

  Widget _buildParticleEmptyState() {
    return Stack(
      children: [
        // Particle background
        AnimatedBuilder(
          animation: _particleCtrl,
          builder: (_, __) => CustomPaint(
            painter: _ParticlePainter(
              animation: _particleCtrl,
              particles: _particles,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        // Content overlay
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "Try-On of the Day" blurred placeholder card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: _buildTodayCard(),
              ),
              const SizedBox(height: 36),
              Text(
                'No try-ons yet',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.fontColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Start a virtual try-on from the catalog',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: AppTheme.fontColor.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepNavy,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                  ),
                  child: Text(
                    'Browse Catalog',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodayCard() {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.deepNavy, Color(0xFF2D3F6B)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepNavy.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative icon
            Positioned(
              right: -12,
              bottom: -12,
              child: Icon(
                Icons.checkroom_outlined,
                size: 120,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'TRY-ON OF THE DAY',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.65),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Start creating\nyour look',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
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

  // ── Filter chips ───────────────────────────────────────────────────

  Widget _filterChip(String label, String? status) {
    final isSelected = _statusFilter == status;
    return GestureDetector(
      onTap: () {
        setState(() => _statusFilter = status);
        context.read<TryOnProvider>().fetchTryOns(status: status);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.deepNavy : AppTheme.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.deepNavy
                : AppTheme.fontColor.withValues(alpha: 0.15),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppTheme.white : AppTheme.fontColor,
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 65,
      height: 65,
      color: AppTheme.backgroundColor,
      child: const Icon(Icons.checkroom, size: 28, color: Colors.grey),
    );
  }
}

// ── Particle data ──────────────────────────────────────────────────────

class _Particle {
  final double baseX;
  final double baseY;
  final double amplitude;
  final double phase;
  final double frequency;
  final double radius;
  final double opacity;
  final bool useAccent;

  const _Particle({
    required this.baseX,
    required this.baseY,
    required this.amplitude,
    required this.phase,
    required this.frequency,
    required this.radius,
    required this.opacity,
    required this.useAccent,
  });
}

// ── Particle painter ───────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<_Particle> particles;

  _ParticlePainter({required this.animation, required this.particles})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    for (final p in particles) {
      // Smooth orbital floating — x and y use different frequency factors
      // so each particle traces a slightly elliptical, never-repeating path
      final x = p.baseX * size.width +
          math.cos(t * 2 * math.pi * p.frequency + p.phase) * p.amplitude;
      final y = p.baseY * size.height +
          math.sin(t * 2 * math.pi * p.frequency * 0.7 + p.phase + math.pi / 3) *
              p.amplitude;

      // Opacity breathes slightly with time
      final alpha = (p.opacity *
              (0.55 +
                  0.45 *
                      math.sin(
                          t * 2 * math.pi * p.frequency * 1.4 + p.phase)))
          .clamp(0.04, 0.45);

      final color = p.useAccent ? AppTheme.accentColor : AppTheme.deepNavy;
      canvas.drawCircle(
        Offset(x, y),
        p.radius,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => false;
}
