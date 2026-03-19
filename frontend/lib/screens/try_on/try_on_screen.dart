import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/preset_image_provider.dart';
import '../../providers/try_on_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loomee_logo.dart';
import '../../widgets/try_on/try_on_progress_card.dart';

class TryOnScreen extends StatefulWidget {
  final String? clothingId;
  final String? clothingName;
  final String? clothingImage;

  const TryOnScreen({
    super.key,
    this.clothingId,
    this.clothingName,
    this.clothingImage,
  });

  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends State<TryOnScreen> {
  String? _selectedPresetImageId;

  /// True once the user taps "Start Try-On" and the backend accepts the job.
  bool _isProcessing = false;

  /// The try-on ID returned by the backend — used for polling and navigation.
  String? _processingTryOnId;

  /// Guard that prevents scheduling more than one navigation to the result screen.
  /// Set to true the first time we detect completion; every subsequent listener
  /// call returns immediately.
  bool _hasNavigated = false;

  /// Cached provider reference — the only safe way to call the provider from
  /// dispose() and listeners, because context.read() is forbidden on a
  /// deactivated element (which is exactly what dispose() runs on).
  late TryOnProvider _tryOnProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache once; ??= prevents overwriting on subsequent dependency changes.
    _tryOnProvider = context.read<TryOnProvider>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<PresetImageProvider>();
      await provider.fetchImages();
      if (!mounted) return;
      if (provider.defaultImage != null) {
        setState(() => _selectedPresetImageId = provider.defaultImage!.id);
      } else if (provider.images.isNotEmpty) {
        setState(() => _selectedPresetImageId = provider.images.first.id);
      }
    });
  }

  @override
  void dispose() {
    // Use the cached reference — context.read() is unsafe here.
    _tryOnProvider.removeListener(_onProviderChange);
    _tryOnProvider.stopPolling();
    super.dispose();
  }

  // ── Provider listener ────────────────────────────────────────────────────
  //
  // This is called by TryOnProvider.notifyListeners() — NOT inside a build
  // method.  Keeping navigation out of builder prevents it from being called
  // multiple times during the route-replacement transition animation, which
  // is what caused the rubberbanding and crash.
  void _onProviderChange() {
    if (!_isProcessing || _hasNavigated || _processingTryOnId == null) return;

    // Use the cached reference — this listener may fire at any time, including
    // while the element is being deactivated.
    final status = _tryOnProvider.currentTryOn?.status;
    if (status != 'completed' && status != 'failed') return;

    // Lock immediately so any further notifyListeners() calls during the
    // transition animation are silently ignored.
    _hasNavigated = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.tryOnResult,
        arguments: _processingTryOnId,
      );
    });
  }

  Future<void> _startTryOn() async {
    if (widget.clothingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a clothing item first')),
      );
      return;
    }

    final provider = _tryOnProvider;
    final result = await provider.createTryOn(
      widget.clothingId!,
      presetImageId: _selectedPresetImageId,
      clothingImageUrl: widget.clothingImage,
    );

    if (!mounted) return;

    if (result != null) {
      // Register the listener BEFORE startPolling so we never miss the first
      // 'completed' notification.
      provider.addListener(_onProviderChange);

      setState(() {
        _isProcessing = true;
        _processingTryOnId = result.id;
      });

      provider.startPolling(result.id);
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.error!),
            backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Virtual Try-On'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Selected clothing item ────────────────────────────────────
            Text(
              'Selected Item',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: scheme.onSurface.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.clothingImage != null &&
                            widget.clothingImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.clothingImage!,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _clothingPlaceholder(),
                          )
                        : _clothingPlaceholder(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.clothingName ?? 'Select a clothing item',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Swap the photo picker + button for the progress card once
            //    processing starts. Navigation is handled by _onProviderChange,
            //    NOT inside this builder, so it fires at most once. ────────
            if (_isProcessing) ...[
              Consumer<TryOnProvider>(
                builder: (context, provider, _) {
                  final tryOn = provider.currentTryOn;
                  final status = tryOn?.status;
                  final isDone = status == 'completed' || status == 'failed';
                  // Pure render — no side effects here.
                  return TryOnProgressCard(
                    isCompleted: isDone,
                    serverProgress: tryOn != null
                        ? (tryOn.progress / 100.0).clamp(0.0, 1.0)
                        : null,
                    serverStage: tryOn?.currentStage,
                  );
                },
              ),
            ] else ...[
              // ── Preset photo selector ─────────────────────────────────
              Text(
                'Your Photo',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Consumer<PresetImageProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.images.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: scheme.onSurface.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.person_add_alt,
                              size: 48,
                              color: scheme.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          const Text('No preset photos found'),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => Navigator.pushNamed(
                                context, AppRoutes.presetImages),
                            child: const Text('Upload Photo'),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    height: 160,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final img = provider.images[index];
                        final isSelected = _selectedPresetImageId == img.id;
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedPresetImageId = img.id),
                          child: Container(
                            width: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? scheme.secondary
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: CachedNetworkImage(
                                imageUrl: img.imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  color: scheme.surface,
                                  child: const Icon(Icons.person,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 36),

              // ── Start Try-On button ───────────────────────────────────
              Consumer<TryOnProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: provider.isProcessing ? null : _startTryOn,
                      icon: provider.isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: const Text('Start Try-On'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _clothingPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: Theme.of(context).colorScheme.surface,
      child: const LomeeLogo(size: 28, color: Colors.grey),
    );
  }
}
