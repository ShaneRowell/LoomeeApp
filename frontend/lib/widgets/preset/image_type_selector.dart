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
    return Row(
      children: types.map((type) {
        final isSelected = type == selectedType;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(
              type[0].toUpperCase() + type.substring(1),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isSelected ? AppTheme.white : AppTheme.fontColor,
              ),
            ),
            selected: isSelected,
            selectedColor: AppTheme.widgetColor,
            onSelected: (_) => onTypeSelected(type),
          ),
        );
      }).toList(),
    );
  }
}
