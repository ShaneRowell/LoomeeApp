import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/try_on_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/try_on/fit_analysis_card.dart';
import '../../widgets/try_on/try_on_status_badge.dart';

class TryOnResultScreen extends StatefulWidget {
  final String tryOnId;

  const TryOnResultScreen({super.key, required this.tryOnId});

  @override
  State<TryOnResultScreen> createState() => _TryOnResultScreenState();
}

class _TryOnResultScreenState extends State<TryOnResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TryOnProvider>().fetchTryOnDetail(widget.tryOnId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Try-On Result'),
      body: Consumer<TryOnProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final tryOn = provider.currentTryOn;
          if (tryOn == null) {
            return AppErrorWidget(
              message: provider.error ?? 'Result not found',
              onRetry: () => provider.fetchTryOnDetail(widget.tryOnId),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (tryOn.clothing != null)
                      Expanded(
                        child: Text(
                          tryOn.clothing!.name,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.fontColor,
                          ),
                        ),
                      ),
                    TryOnStatusBadge(status: tryOn.status),
                  ],
                ),
                if (tryOn.clothing != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    tryOn.clothing!.brand,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (tryOn.resultImageUrl != null &&
                    tryOn.resultImageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: tryOn.resultImageUrl!,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        height: 300,
                        color: AppTheme.backgroundColor,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 48),
                        ),
                      ),
                    ),
                  ),
                if (tryOn.recommendedSize != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.straighten,
                            color: AppTheme.successColor),
                        const SizedBox(width: 12),
                        Text(
                          'Recommended Size: ',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        Text(
                          tryOn.recommendedSize!,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (tryOn.aiDescription != null &&
                    tryOn.aiDescription!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'AI Analysis',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.fontColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tryOn.aiDescription!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.fontColor.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ],
                if (tryOn.fitAnalysis != null) ...[
                  const SizedBox(height: 20),
                  FitAnalysisCard(fitAnalysis: tryOn.fitAnalysis!),
                ],
                if (tryOn.status == 'failed' &&
                    tryOn.errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppTheme.errorColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tryOn.errorMessage!,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppTheme.errorColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.tryOnHistory),
                        child: const Text('View History'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, AppRoutes.home),
                        child: const Text('Try Another'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
