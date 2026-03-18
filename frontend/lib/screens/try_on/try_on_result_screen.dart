import 'package:flutter/material.dart';
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
      final provider = context.read<TryOnProvider>();
      // Backend is synchronous — result is already complete when we arrive here.
      // Only fetch if we don't already have this try-on loaded.
      if (provider.currentTryOn?.id != widget.tryOnId) {
        provider.fetchTryOnDetail(widget.tryOnId);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Try-On Result'),
      body: Consumer<TryOnProvider>(
        builder: (context, provider, _) {
          final scheme = Theme.of(context).colorScheme;
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
                // Header: clothing name + status badge
                Row(
                  children: [
                    if (tryOn.clothing != null)
                      Expanded(
                        child: Text(
                          tryOn.clothing!.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
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
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Processing state — AI is still generating
                if (tryOn.status == 'processing') ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 48, horizontal: 24),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: scheme.onSurface.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.accentColor,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Generating your virtual try-on...',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Our AI is working on it.\nThis usually takes 60–90 seconds.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            color: scheme.onSurface.withValues(alpha: 0.55),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Completed — show result image (only if URL is absolute)
                if (tryOn.status == 'completed' &&
                    tryOn.resultImageUrl != null &&
                    tryOn.resultImageUrl!.startsWith('http')) ...[
                  AspectRatio(
                    aspectRatio: 3 / 4, // portrait — shows full body correctly
                    child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      tryOn.resultImageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 380,
                          color: scheme.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                  : null,
                              color: AppTheme.accentColor,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, error, __) => Container(
                        height: 380,
                        color: scheme.surface,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.image_not_supported,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: GoogleFonts.playfairDisplay(
                                    fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ), // AspectRatio
                ],

                // No image available (Replicate failed — fit analysis still shows)
                if (tryOn.status == 'completed' &&
                    (tryOn.resultImageUrl == null ||
                        !tryOn.resultImageUrl!.startsWith('http'))) ...[
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: scheme.onSurface.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_outlined,
                            size: 40,
                            color: scheme.onSurface.withValues(alpha: 0.3)),
                        const SizedBox(height: 10),
                        Text(
                          'Virtual try-on image unavailable',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            color: scheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI image generation did not complete',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 11,
                            color: scheme.onSurface.withValues(alpha: 0.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Recommended size
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
                          style: GoogleFonts.playfairDisplay(fontSize: 14),
                        ),
                        Text(
                          tryOn.recommendedSize!,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // AI Analysis description
                if (tryOn.aiDescription != null &&
                    tryOn.aiDescription!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'AI Analysis',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tryOn.aiDescription!,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      color: scheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ],

                // Fit analysis card
                if (tryOn.fitAnalysis != null) ...[
                  const SizedBox(height: 20),
                  FitAnalysisCard(fitAnalysis: tryOn.fitAnalysis!),
                ],

                // Failed state — show error
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
                            style: GoogleFonts.playfairDisplay(
                                fontSize: 13, color: AppTheme.errorColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.home,
                        arguments: {'initialTab': 1}),
                    child: const Text('Try Another'),
                  ),
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
