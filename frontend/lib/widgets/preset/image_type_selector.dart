import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

class ImageTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  const ImageTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static const types = ['front', 'side', 'back', 'custom'];

  @override
  Widget build(BuildContext context) {
    // Wrap instead of Row so chips reflow onto a second line inside
    // constrained containers (e.g. AlertDialog) without overflowing.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map((type) {
        final isSelected = type == selectedType;
        return ChoiceChip(
          label: Text(
            type[0].toUpperCase() + type.substring(1),
            style: GoogleFonts.playfairDisplay(
              fontSize: 13,
              color: isSelected ? AppTheme.white : AppTheme.fontColor,
            ),
          ),
          selected: isSelected,
          selectedColor: AppTheme.widgetColor,
          onSelected: (_) => onTypeSelected(type),
        );
      }).toList(),
    );
  }
}
