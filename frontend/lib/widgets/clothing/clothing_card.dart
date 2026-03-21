import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/clothing.dart';
import '../common/loomee_logo.dart';

class ClothingCard extends StatelessWidget {
  final Clothing clothing;
  final VoidCallback onTap;

  const ClothingCard({
    super.key,
    required this.clothing,
    required this.onTap,
  });

  // Static so the formatter is created once for all cards, not per-build.
  static final _priceFormat =
      NumberFormat.currency(locale: 'en_LK', symbol: 'LKR ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppTheme.fontColor.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppTheme.fontColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.92),
                    Colors.white.withValues(alpha: 0.75),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.80),
                  width: 0.8,
                ),
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    clothing.primaryImage.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: clothing.primaryImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => Container(
                              color: AppTheme.backgroundColor,
                              child: const Center(
                                child: LomeeLogo(size: 40, color: Colors.grey),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: AppTheme.backgroundColor,
                              child: const Center(
                                child: LomeeLogo(size: 40, color: Colors.grey),
                              ),
                            ),
                          )
                        : Container(
                            color: AppTheme.backgroundColor,
                            child: const Center(
                              child: LomeeLogo(size: 40, color: Colors.grey),
                            ),
                          ),
                    // Subtle bottom vignette — softens the image-to-text edge
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 40,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clothing.brand.toUpperCase(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentColor,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      clothing.name,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.fontColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _priceFormat.format(clothing.price),
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.widgetColor,
                            ),
                          ),
                        ),
                        if (clothing.colors.isNotEmpty)
                          Row(
                            children: clothing.colors
                                .take(3)
                                .map((c) => Container(
                                      margin: const EdgeInsets.only(left: 3),
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _parseHex(c.hex),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.fontColor.withValues(alpha: 0.15),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
            ), // BackdropFilter child
          ), // BackdropFilter
        ), // ClipRRect
      ),
    );
  }

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    final buffer = StringBuffer();
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.length == 6) buffer.write('FF');
    buffer.write(hex);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
