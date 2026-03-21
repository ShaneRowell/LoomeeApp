import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../common/glass_container.dart';

class _Stage {
  final double threshold; // progress value at which step becomes "active"
  final String label;
  final IconData icon;
  const _Stage(this.threshold, this.label, this.icon);
}

/// Animated progress card displayed while the AI try-on pipeline is running.
///
/// Pass real server values via [serverProgress] (0.0–1.0) and [serverStage]
/// whenever they are available — the card will drive from those instead of the
/// built-in wall-clock simulation.  [isCompleted] snaps the bar to 100 %.
class TryOnProgressCard extends StatefulWidget {
  final bool isCompleted;

  /// Backend progress as a fraction 0.0–1.0.  When non-null the simulation
  /// ticker is disabled and the bar tracks the server value directly.
  final double? serverProgress;

  /// Backend stage key (e.g. 'analysing_garment', 'generating_tryon').
  /// When provided, overrides the threshold-based active-label lookup.
  final String? serverStage;

  const TryOnProgressCard({
    super.key,
    required this.isCompleted,
    this.serverProgress,
    this.serverStage,
  });

  @override
  State<TryOnProgressCard> createState() => _TryOnProgressCardState();
}

class _TryOnProgressCardState extends State<TryOnProgressCard> {
  // These thresholds mirror the real server milestones so step indicators
  // light up at the right moment whether driven by server data or simulation.
  static const _stages = [
    _Stage(0.00, 'Analysing your garment',   Icons.image_search_outlined),
    _Stage(0.45, 'Running fit analysis',      Icons.straighten_outlined),
    _Stage(0.50, 'Generating virtual try-on', Icons.auto_awesome_outlined),
    _Stage(0.85, 'Finalising your result',    Icons.check_circle_outline),
  ];

  // Simulation constants (only used when server data is unavailable).
  static const _simTotalSeconds = 75.0;
  static const _simMaxProgress  = 0.90;

  // The value TweenAnimationBuilder animates toward.
  double _target = 0.0;

  // Wall-clock simulation ticker — cancelled as soon as server data arrives.
  Timer? _simTicker;
  final _stopwatch = Stopwatch();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (widget.serverProgress != null) {
      // Server data already available on first render — skip simulation.
      _target = widget.serverProgress!.clamp(0.0, 1.0);
    } else {
      // Start wall-clock simulation as a fallback until the first poll lands.
      _stopwatch.start();
      _simTicker = Timer.periodic(const Duration(milliseconds: 300), (_) {
        if (!mounted) return;
        final t = (_stopwatch.elapsed.inMilliseconds / 1000 / _simTotalSeconds)
            .clamp(0.0, 1.0);
        final eased = 1.0 - (1.0 - t) * (1.0 - t) * (1.0 - t);
        final newTarget = eased * _simMaxProgress;
        // Skip setState when the change is negligible — TweenAnimationBuilder
        // already animates at 60 fps so tiny deltas produce no visible difference.
        if ((newTarget - _target).abs() > 0.005) {
          setState(() => _target = newTarget);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant TryOnProgressCard old) {
    super.didUpdateWidget(old);

    // Completion always wins — snap to 100 % regardless of source.
    if (widget.isCompleted && !old.isCompleted) {
      _simTicker?.cancel();
      _simTicker = null;
      setState(() => _target = 1.0);
      return;
    }

    // Server progress arrived or changed — switch off simulation.
    if (widget.serverProgress != null &&
        widget.serverProgress != old.serverProgress) {
      _simTicker?.cancel();
      _simTicker = null;
      _stopwatch.stop();
      _stopwatch.reset();
      final incoming = widget.serverProgress!.clamp(0.0, 1.0);
      // Never move the bar backwards (guards against out-of-order poll responses).
      if (incoming > _target) {
        setState(() => _target = incoming);
      }
    }
  }

  @override
  void dispose() {
    _simTicker?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns the stage whose threshold the current [progress] has passed.
  _Stage _stageForProgress(double progress) {
    for (int i = _stages.length - 1; i >= 0; i--) {
      if (progress >= _stages[i].threshold) return _stages[i];
    }
    return _stages[0];
  }

  /// Maps a backend stage key to the matching [_Stage] object.
  /// Falls back to threshold lookup when the key is unrecognised.
  _Stage _stageForServerKey(String key, double progress) {
    switch (key) {
      case 'analysing_garment':
        return _stages[0];
      case 'running_fit_analysis':
        return _stages[1];
      case 'generating_tryon':
        return _stages[2];
      case 'saving_result':
      case 'finalising':
      case 'completed':
        return _stages[3];
      default:
        return _stageForProgress(progress);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final usingServerData = widget.serverProgress != null;

    return TweenAnimationBuilder<double>(
      // Omitting `begin` reuses the last animated value as the starting point,
      // giving seamless transitions between polling updates.
      tween: Tween<double>(end: _target),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, progress, _) {
        final percent = (progress * 100).round();
        final active = widget.serverStage != null
            ? _stageForServerKey(widget.serverStage!, progress)
            : _stageForProgress(progress);

        return GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Stage label + percentage ───────────────────────────────
              Row(
                children: [
                  Icon(active.icon, color: scheme.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      active.label,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percent%',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: scheme.secondary,
                        ),
                      ),
                      // Live indicator dot — only shown when server data is driving
                      if (usingServerData && !widget.isCompleted) ...[
                        const SizedBox(width: 6),
                        _LiveDot(color: scheme.secondary),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Progress bar ───────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.secondary),
                ),
              ),

              const SizedBox(height: 20),

              // ── Step indicators ────────────────────────────────────────
              ..._stages.map((stage) {
                // A stage is "done" once progress has clearly passed its
                // threshold.  The +0.01 guard avoids a brief flicker where
                // the bar lands exactly on the threshold value.
                // Note: _stages.last is intentionally included — when the
                // job completes (progress → 1.0) all four stages show ✓.
                final done = progress >= stage.threshold + 0.01;
                final isActive = active == stage;

                IconData stepIcon;
                Color stepColor;
                if (done) {
                  stepIcon = Icons.check_circle_rounded;
                  stepColor = AppTheme.successColor;
                } else if (isActive) {
                  stepIcon = Icons.radio_button_checked_rounded;
                  stepColor = scheme.secondary;
                } else {
                  stepIcon = Icons.radio_button_unchecked_rounded;
                  stepColor = scheme.onSurface.withValues(alpha: 0.25);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(stepIcon, size: 16, color: stepColor),
                      const SizedBox(width: 8),
                      Text(
                        stage.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.normal,
                          color: (done || isActive)
                              ? scheme.onSurface
                              : scheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 4),

              // ── Footnote ───────────────────────────────────────────────
              Text(
                usingServerData
                    ? 'Live progress from the AI pipeline.'
                    : 'AI-powered generation — usually takes around 75 seconds.',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: scheme.onSurface.withValues(alpha: 0.4),
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Animated "live" dot ───────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  final Color color;
  const _LiveDot({required this.color});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
