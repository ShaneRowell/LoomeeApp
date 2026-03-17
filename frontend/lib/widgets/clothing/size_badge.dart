import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

class SizeBadge extends StatelessWidget {
  final String size;
  final bool isSelected;
  final int? fitScore;
  final int stock;
  final VoidCallback? onTap;

  const SizeBadge({
    super.key,
    required this.size,
    this.isSelected = false,
    this.fitScore,
    this.stock = 0,
    this.onTap,
  });

  Color get _fitColor {
    if (fitScore == null) return AppTheme.fontColor;
    if (fitScore! >= 90) return AppTheme.successColor;
    if (fitScore! >= 75) return const Color(0xFF66BB6A);
    if (fitScore! >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  @override
  Widget build(BuildContext context) {
    final outOfStock = stock <= 0;
    return GestureDetector(
      onTap: outOfStock ? null : onTap,
      child: Opacity(
        opacity: outOfStock ? 0.4 : 1.0,
        child: Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.widgetColor : AppTheme.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppTheme.widgetColor
                  : fitScore != null
                      ? _fitColor.withValues(alpha: 0.5)
                      : AppTheme.fontColor.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                size,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.white : AppTheme.fontColor,
                ),
              ),
              if (fitScore != null) ...[
                const SizedBox(height: 2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppTheme.white : _fitColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
