import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

class CategoryTabs extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const List<Map<String, dynamic>> categories = [
    {'label': 'All', 'value': '', 'icon': Icons.grid_view_rounded},
    {'label': 'Shirts', 'value': 'shirt', 'icon': Icons.checkroom},
    {'label': 'Pants', 'value': 'pants', 'icon': Icons.straighten},
    {'label': 'Dresses', 'value': 'dress', 'icon': Icons.dry_cleaning},
    {'label': 'Jackets', 'value': 'jacket', 'icon': Icons.layers},
    {'label': 'Skirts', 'value': 'skirt', 'icon': Icons.content_cut},
    {'label': 'Shorts', 'value': 'shorts', 'icon': Icons.airline_seat_legroom_normal},
    {'label': 'Sweaters', 'value': 'sweater', 'icon': Icons.thermostat},
    {'label': 'Suits', 'value': 'suit', 'icon': Icons.business_center},
    {'label': 'Accessories', 'value': 'accessories', 'icon': Icons.watch},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat['value'];
          return GestureDetector(
            onTap: () => onCategorySelected(cat['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.widgetColor : AppTheme.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.widgetColor
                      : AppTheme.fontColor.withValues(alpha: 0.15),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                cat['label'],
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppTheme.white : AppTheme.fontColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
