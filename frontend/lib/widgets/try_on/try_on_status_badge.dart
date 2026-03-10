import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

class TryOnStatusBadge extends StatefulWidget {
  final String status;

  const TryOnStatusBadge({super.key, required this.status});

  @override
  State<TryOnStatusBadge> createState() => _TryOnStatusBadgeState();
}

class _TryOnStatusBadgeState extends State<TryOnStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    if (widget.status == 'processing' || widget.status == 'pending') {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TryOnStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == 'processing' || widget.status == 'pending') {
      if (!_pulseCtrl.isAnimating) _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.status) {
      case 'completed':
        return AppTheme.successColor;
      case 'processing':
        return const Color(0xFF1976D2);
      case 'pending':
        return AppTheme.warningColor;
      case 'failed':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (widget.status) {
      case 'completed':
        return 'Completed';
      case 'processing':
        return 'Processing';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return widget.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive =
        widget.status == 'processing' || widget.status == 'pending';

    if (!isActive) {
      return _buildBadge(borderOpacity: 0, dotOpacity: 0);
    }

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) =>
          _buildBadge(borderOpacity: _pulse.value, dotOpacity: _pulse.value),
    );
  }

  Widget _buildBadge({required double borderOpacity, required double dotOpacity}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _color.withValues(alpha: 0.15 + borderOpacity * 0.65),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotOpacity > 0) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.5 + dotOpacity * 0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            _label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
