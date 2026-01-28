import 'package:flutter/material.dart';
import '../../models/clothing.dart';
import '../../config/app_routes.dart';
import 'clothing_card.dart';

class ClothingGrid extends StatelessWidget {
  final List<Clothing> items;
  final Future<void> Function()? onRefresh;

  const ClothingGrid({
    super.key,
    required this.items,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final grid = GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final clothing = items[index];
        return ClothingCard(
          clothing: clothing,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.clothingDetail,
            arguments: clothing.id,
          ),
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(onRefresh: onRefresh!, child: grid);
    }
    return grid;
  }
}
