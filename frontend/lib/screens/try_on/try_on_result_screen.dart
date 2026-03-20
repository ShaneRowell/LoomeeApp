import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/try_on_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/try_on/fit_analysis_card.dart';
import '../../widgets/try_on/try_on_progress_card.dart';
import '../../widgets/try_on/try_on_status_badge.dart';

class TryOnResultScreen extends StatefulWidget {
  final String tryOnId;

  const TryOnResultScreen({super.key, required this.tryOnId});

  @override
  State<TryOnResultScreen> createState() => _TryOnResultScreenState();
}

class _TryOnResultScreenState extends State<TryOnResultScreen> {
  /// Cached provider reference — safe to use in dispose() where
  /// context.read() is forbidden on a deactivated element.
  late TryOnProvider _tryOnProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tryOnProvider = context.read<TryOnProvider>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // Fetch fresh data only when necessary:
      //   • Different try-on ID cached (e.g. navigated from history list), OR
      //   • Clothing relationship not populated (object came from createTryOn
      //     which returns a partial record without the populated clothingId).
      // This avoids a redundant round-trip when the result screen is opened
      // from TryOnScreen, where polling has already fetched full data.
      final cached = _tryOnProvider.currentTryOn;
      if (cached?.id != widget.tryOnId || cached?.clothing == null) {
        await _tryOnProvider.fetchTryOnDetail(widget.tryOnId);
      }

      if (!mounted) return;
      // Always start polling. It stops itself once status is completed/failed.
      _tryOnProvider.startPolling(widget.tryOnId);
    });
  }

  @override
  void dispose() {
    // Use the cached reference — context.read() is unsafe in dispose().
    _tryOnProvider.stopPolling();
    super.dispose();
  }

  /// Converts a raw backend error string into something the user can
  /// actually understand and act on.  Never exposes API quota messages,
  /// JSON payloads, or stack traces.
  String _friendlyError(String? raw) {
    if (raw == null || raw.isEmpty) {
      return 'Something went wrong. Please try again.';
    }
    final lower = raw.toLowerCase();
    if (lower.contains('429') || lower.contains('quota') || lower.contains('rate limit')) {
      return 'Our AI service has reached its daily limit. '
          'Please try again in a few hours — your quota resets at midnight.';
    }
    if (lower.contains('timeout') || lower.contains('timed out')) {
      return 'The AI took too long to respond. '
          'This can happen during busy periods — please try again.';
    }
    if (lower.contains('network') ||
        lower.contains('econnrefused') ||
        lower.contains('fetch')) {
      return 'A network error occurred. '
          'Check your connection and try again.';
    }
    if (lower.contains('replicate') || lower.contains('prediction')) {
      return 'The virtual try-on image could not be generated. '
          'Please try again with a different photo.';
    }
    // Generic fallback — don't show the raw message.
    return 'The try-on could not be completed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Try-On Result'),
      body: Consumer<TryOnProvider>(
        builder: (context, provider, _) {
          final scheme = Theme.of(context).colorScheme;

          final tryOn = provider.currentTryOn;

          // Only show the progress card while the AI pipeline is genuinely
          // in flight.  If we already have a completed/failed result cached
          // (e.g. navigated here from try_on_screen after polling confirmed
          // completion), skip straight to the result view even if isLoading is
          // briefly true while we refresh the detail in the background.
          final alreadyDone = tryOn?.status == 'completed' ||
              tryOn?.status == 'failed';
          final isProcessing = !alreadyDone &&
              (provider.isLoading ||
                  tryOn?.status == 'processing' ||
                  tryOn?.status == 'pending');

          // While loading OR while AI is still running, show the progress card.
          // Never replace the whole screen with a plain spinner — the user needs
          // to see something meaningful during the 60–90 second wait.
          if (isProcessing) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tryOn?.clothing != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tryOn!.clothing!.name,
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
                    const SizedBox(height: 4),
                    Text(
                      tryOn.clothing!.brand,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        color: scheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  TryOnProgressCard(
                    isCompleted: false,
                    serverProgress: tryOn != null
                        ? (tryOn.progress / 100.0).clamp(0.0, 1.0)
                        : null,
                    serverStage: tryOn?.currentStage,
                  ),
                ],
              ),
            );
          }

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
                      color: scheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Completed — show result image (only if URL is absolute)
                if (tryOn.status == 'completed' &&
                    tryOn.resultImageUrl != null &&
                    tryOn.resultImageUrl!.startsWith('http')) ...[
                  AspectRatio(
                    aspectRatio: 3 / 4, // portrait — shows full body correctly
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      // CachedNetworkImage stores the result on disk so
                      // re-opening this screen skips the download entirely.
                      child: CachedNetworkImage(
                        imageUrl: tryOn.resultImageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        placeholder: (_, __) => Container(
                          color: scheme.surface,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: scheme.secondary,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
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
                  ),
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

                // Failed state — show a friendly error (never expose raw API text)
                if (tryOn.status == 'failed') ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppTheme.errorColor.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppTheme.errorColor, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              'Try-On Failed',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.errorColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _friendlyError(tryOn.errorMessage),
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.errorColor.withValues(alpha: 0.85),
                              height: 1.45),
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

