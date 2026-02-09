import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/recommendation_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/empty_state_widget.dart';

class CompleteOutfitScreen extends StatefulWidget {
  const CompleteOutfitScreen({super.key});

  @override
  State<CompleteOutfitScreen> createState() => _CompleteOutfitScreenState();
}

class _CompleteOutfitScreenState extends State<CompleteOutfitScreen> {
  String? _occasion;
  String? _style;
  final _priceFormat =
      NumberFormat.currency(locale: 'en_LK', symbol: 'LKR ', decimalDigits: 0);

  static const occasions = [
    'casual',
    'formal',
    'business',
    'party',
    'date night',
    'outdoor',
  ];
  static const styles = [
    'classic',
    'modern',
    'minimalist',
    'streetwear',
    'elegant',
    'sporty',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationProvider>().fetchCompleteOutfit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Complete Outfit'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _occasion,
                    hint: const Text('Occasion'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: occasions
                        .map((o) => DropdownMenuItem(
                              value: o,
                              child: Text(o[0].toUpperCase() + o.substring(1)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _occasion = val);
                      context.read<RecommendationProvider>().fetchCompleteOutfit(
                            occasion: _occasion,
                            style: _style,
                          );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _style,
                    hint: const Text('Style'),
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: styles
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s[0].toUpperCase() + s.substring(1)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => _style = val);
                      context.read<RecommendationProvider>().fetchCompleteOutfit(
                            occasion: _occasion,
                            style: _style,
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<RecommendationProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.outfits.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.style,
                    title: 'No outfits found',
                    subtitle: 'Try different occasion or style filters',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.outfits.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final outfit = provider.outfits[index];
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppTheme.fontColor.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  outfit.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.fontColor,
                                  ),
                                ),
                              ),
                              Text(
                                _priceFormat.format(outfit.totalPrice),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.widgetColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _tag(outfit.occasion, AppTheme.accentColor),
                              const SizedBox(width: 6),
                              _tag(outfit.style, const Color(0xFF1976D2)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (outfit.items.top != null)
                            _itemRow(Icons.checkroom, 'Top', outfit.items.top!),
                          if (outfit.items.bottom != null)
                            _itemRow(Icons.straighten, 'Bottom',
                                outfit.items.bottom!),
                          if (outfit.items.shoes != null)
                            _itemRow(Icons.directions_walk, 'Shoes',
                                outfit.items.shoes!),
                          if (outfit.items.accessories.isNotEmpty)
                            _itemRow(Icons.watch, 'Accessories',
                                outfit.items.accessories.join(', ')),
                          if (outfit.reasoning.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              outfit.reasoning,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color:
                                    AppTheme.fontColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _itemRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.fontColor.withValues(alpha: 0.4)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.fontColor.withValues(alpha: 0.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  GoogleFonts.inter(fontSize: 13, color: AppTheme.fontColor),
            ),
          ),
        ],
      ),
    );
  }
}
