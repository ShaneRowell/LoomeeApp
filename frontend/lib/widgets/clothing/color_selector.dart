import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../models/clothing.dart';

class ColorSelector extends StatelessWidget {
  final List<ClothingColor> colors;
  final int selectedIndex;
  final ValueChanged<int> onColorSelected;

  const ColorSelector({
    super.key,
    required this.colors,
    required this.selectedIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(colors.length, (index) {
        final color = colors[index];
        final isSelected = index == selectedIndex;
        return GestureDetector(
          onTap: () => onColorSelected(index),
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppTheme.widgetColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _parseHex(color.hex),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.fontColor.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    String cleaned = hex.startsWith('#') ? hex.substring(1) : hex;
    if (cleaned.length == 6) cleaned = 'FF$cleaned';
    return Color(int.parse(cleaned, radix: 16));
  }
}
