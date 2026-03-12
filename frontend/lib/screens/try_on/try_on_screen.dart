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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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

  Future<void> _startTryOn() async {
    if (widget.clothingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a clothing item first')),
      );
      return;
    }

    final provider = context.read<TryOnProvider>();
    final result = await provider.createTryOn(
      widget.clothingId!,
      presetImageId: _selectedPresetImageId,
    );

    if (result != null && mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.tryOnResult,
        arguments: result.id,
      );
    } else if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Virtual Try-On'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Item',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.fontColor.withValues(alpha: 0.1)),
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
                            errorWidget: (_, __, ___) => _clothingPlaceholder(),
                          )
                        : _clothingPlaceholder(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.clothingName ?? 'Select a clothing item',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.fontColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Your Photo',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.fontColor,
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
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppTheme.fontColor.withValues(alpha: 0.1)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.person_add_alt,
                            size: 48,
                            color: AppTheme.fontColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        const Text('No preset photos found'),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.presetImages),
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
                        onTap: () =>
                            setState(() => _selectedPresetImageId = img.id),
                        child: Container(
                          width: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.accentColor
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
                                color: AppTheme.backgroundColor,
                                child: const Icon(Icons.person, color: Colors.grey),
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
                    label: Text(
                      provider.isProcessing
                          ? 'Analyzing Fit...'
                          : 'Start Try-On',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _clothingPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: AppTheme.backgroundColor,
      child: const LomeeLogo(size: 28, color: Colors.grey),
    );
  }
}
