import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/recommendation_provider.dart';
import '../../widgets/common/loading_shimmer.dart';

class FashionRecommendationsScreen extends StatefulWidget {
  const FashionRecommendationsScreen({super.key});

  @override
  State<FashionRecommendationsScreen> createState() =>
      _FashionRecommendationsScreenState();
}

class _FashionRecommendationsScreenState
    extends State<FashionRecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().fetchPersonalized();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<RecommendationProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchPersonalized(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Screen hero title — fontSize 24 >= 20, KEEP playfairDisplay
                  Text(
                    'Style Guide',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.fontColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtitle — rule 2
                  Text(
                    'Personalized fashion recommendations',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.fontColor.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (provider.isLoading)
                    const LoadingShimmer.list()
                  else if (provider.personalizedRecommendation != null) ...[
                    _buildSection(
                      'For You',
                      Icons.favorite_rounded,
                      AppTheme.accentColor,
                      provider.personalizedRecommendation!.forYou,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Trending Now',
                      Icons.trending_up_rounded,
                      const Color(0xFF1976D2),
                      provider.personalizedRecommendation!.trendingNow,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      'Build Your Wardrobe',
                      Icons.style_rounded,
                      AppTheme.successColor,
                      provider.personalizedRecommendation!.buildYourWardrobe,
                    ),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Column(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                size: 56,
                                color:
                                    AppTheme.fontColor.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            // Body paragraph — rule 2
                            Text(
                              'Add your measurements for\npersonalized recommendations',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color:
                                    AppTheme.fontColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.completeOutfit,
                      ),
                      icon: const Icon(Icons.style),
                      label: const Text('Get Complete Outfit'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, Color color, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            // Section header — fontSize 18 >= 20? No, 18 < 20 — rule 2
            Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.fontColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.fontColor.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.fontColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
