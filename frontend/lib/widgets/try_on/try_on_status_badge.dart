import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

class TryOnStatusBadge extends StatelessWidget {
  final String status;

  const TryOnStatusBadge({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'completed':
        return AppTheme.successColor;
      case 'processing':
        return const Color(0xFF1976D2);
      case 'pending':
        return Colors.grey;
      case 'failed':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'processing':
        return 'Processing';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _color.withValues(alpha: 0.18),
            _color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        _label,
        style: GoogleFonts.playfairDisplay(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
