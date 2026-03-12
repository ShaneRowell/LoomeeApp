import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/recommendation_provider.dart';
import '../../widgets/clothing/color_selector.dart';
import '../../widgets/clothing/size_badge.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';

class ClothingDetailScreen extends StatefulWidget {
  final String clothingId;

  const ClothingDetailScreen({super.key, required this.clothingId});

  @override
  State<ClothingDetailScreen> createState() => _ClothingDetailScreenState();
}

class _ClothingDetailScreenState extends State<ClothingDetailScreen> {
  int _currentImageIndex = 0;
  int _selectedColorIndex = 0;
  final PageController _pageController = PageController();
  final _priceFormat =
      NumberFormat.currency(locale: 'en_LK', symbol: 'LKR ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().fetchClothingDetail(widget.clothingId);
      context
          .read<RecommendationProvider>()
          .fetchSizeRecommendation(widget.clothingId);
      context
          .read<RecommendationProvider>()
          .fetchFashionRecommendations(widget.clothingId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<CatalogProvider>(
        builder: (context, catalog, _) {
          if (catalog.isLoadingDetail) {
            return const LoadingShimmer.detail();
          }
          final clothing = catalog.selectedClothing;
          if (clothing == null) {
            return AppErrorWidget(
              message: catalog.error ?? 'Clothing not found',
              onRetry: () =>
                  catalog.fetchClothingDetail(widget.clothingId),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppTheme.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: AppTheme.widgetColor.withValues(alpha: 0.7),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: clothing.images.isNotEmpty
                      ? Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              itemCount: clothing.images.length,
                              onPageChanged: (i) =>
                                  setState(() => _currentImageIndex = i),
                              itemBuilder: (_, i) => CachedNetworkImage(
                                imageUrl: clothing.images[i],
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: AppTheme.backgroundColor,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: AppTheme.backgroundColor,
                                  child: const Icon(Icons.checkroom, size: 60),
                                ),
                              ),
                            ),
                            if (clothing.images.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    clothing.images.length,
                                    (i) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      width: _currentImageIndex == i ? 20 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _currentImageIndex == i
                                            ? AppTheme.widgetColor
                                            : Colors.white.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          color: AppTheme.backgroundColor,
                          child: const Center(
                            child: Icon(Icons.checkroom, size: 80, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clothing.brand.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentColor,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        clothing.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.fontColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _priceFormat.format(clothing.price),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.widgetColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        clothing.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.fontColor.withValues(alpha: 0.7),
                          height: 1.5,
                        ),
                      ),
                      if (clothing.colors.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Colors',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.fontColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ColorSelector(
                          colors: clothing.colors,
                          selectedIndex: _selectedColorIndex,
                          onColorSelected: (i) =>
                              setState(() => _selectedColorIndex = i),
                        ),
                      ],
                      _buildSizeSection(),
                      if (clothing.material != null) ...[
                        const SizedBox(height: 20),
                        _buildInfoRow('Material', clothing.material!),
                      ],
                      _buildInfoRow('Category',
                          clothing.category.isNotEmpty ? clothing.category[0].toUpperCase() + clothing.category.substring(1) : clothing.category),
                      _buildInfoRow('Gender',
                          clothing.gender.isNotEmpty ? clothing.gender[0].toUpperCase() + clothing.gender.substring(1) : clothing.gender),
                      if (clothing.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: clothing.tags
                              .map((tag) => Chip(
                                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ],
                      _buildFashionRecommendations(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.tryOn,
                              arguments: {
                                'clothingId': clothing.id,
                                'clothingName': clothing.name,
                                'clothingImage': clothing.primaryImage,
                              },
                            );
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Virtual Try-On'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSizeSection() {
    return Consumer<RecommendationProvider>(
      builder: (context, recProvider, _) {
        final sizeRec = recProvider.sizeRecommendation;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'Sizes',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.fontColor,
                  ),
                ),
                if (sizeRec != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Recommended: ${sizeRec.recommendedSize}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            if (sizeRec != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sizeRec.allSizes
                    .map((s) => SizeBadge(
                          size: s.size,
                          fitScore: s.fitScore,
                          stock: s.stock,
                          isSelected: s.size == sizeRec.recommendedSize,
                        ))
                    .toList(),
              )
            else
              Consumer<CatalogProvider>(
                builder: (context, catalog, _) {
                  final clothing = catalog.selectedClothing;
                  if (clothing == null) return const SizedBox.shrink();
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: clothing.sizes
                        .map((s) => SizeBadge(
                              size: s.size,
                              stock: s.stock,
                            ))
                        .toList(),
                  );
                },
              ),
            if (sizeRec != null && sizeRec.advice.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.widgetColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 18, color: AppTheme.accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sizeRec.advice,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.fontColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.fontColor.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.fontColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFashionRecommendations() {
    return Consumer<RecommendationProvider>(
      builder: (context, recProvider, _) {
        final rec = recProvider.fashionRecommendation;
        if (rec == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Style Suggestions',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontColor,
              ),
            ),
            if (rec.outfitSuggestions.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...rec.outfitSuggestions.take(2).map((outfit) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.fontColor.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outfit.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.fontColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          outfit.items.join(' + '),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.fontColor.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            outfit.occasion,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            if (rec.styleTips.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...rec.styleTips.take(3).map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 14, color: AppTheme.accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.fontColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        );
      },
    );
  }
}
