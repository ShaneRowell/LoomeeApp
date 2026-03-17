import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/preset_image_provider.dart';
import '../../widgets/preset/preset_image_card.dart';
import '../../widgets/preset/image_type_selector.dart';
import '../../widgets/common/animated_tab_header.dart';

class PresetImagesScreen extends StatefulWidget {
  const PresetImagesScreen({super.key});

  @override
  State<PresetImagesScreen> createState() => _PresetImagesScreenState();
}

class _PresetImagesScreenState extends State<PresetImagesScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<PresetImageProvider>().fetchImages();
      // Recover any image the camera delivered while the process was dead
      // (Samsung and other aggressive Android OEMs kill background processes)
      await _recoverLostCameraData();
    });
  }

  /// Called on app restart after Android killed the process while camera was open.
  /// Retrieves the pending camera result and continues the upload flow.
  Future<void> _recoverLostCameraData() async {
    if (!Platform.isAndroid) return;
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty || !mounted) return;

      if (response.file != null) {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (_) => _UploadOptionsDialog(
            initialType: 'front',
            initialDefault: false,
          ),
        );
        if (result == null || !mounted) return;

        final provider = context.read<PresetImageProvider>();
        final success = await provider.uploadImage(
          response.file!.path,
          imageType: result['imageType'] as String,
          isDefault: result['isDefault'] as bool,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Photo uploaded successfully!' : (provider.error ?? 'Upload failed'),
            ),
            backgroundColor: success ? Colors.green : AppTheme.errorColor,
          ),
        );
      } else if (response.exception != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not recover photo: ${response.exception!.message}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (_) {
      // No lost data — nothing to recover
    }
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    // ── Runtime permission check ─────────────────────────────────────────
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (!mounted) return;
        if (status.isPermanentlyDenied) {
          _showPermissionDialog(
            'Camera Permission',
            'Camera access is required to take photos. Please enable it in Settings.',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission denied.')),
          );
        }
        return;
      }
    } else {
      // Gallery — Android 13+ uses READ_MEDIA_IMAGES, older uses READ_EXTERNAL_STORAGE
      PermissionStatus status = await Permission.photos.request();
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      if (!status.isGranted) {
        if (!mounted) return;
        if (status.isPermanentlyDenied) {
          _showPermissionDialog(
            'Storage Permission',
            'Storage access is required to pick photos. Please enable it in Settings.',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied.')),
          );
        }
        return;
      }
    }

    // ── Pick image ───────────────────────────────────────────────────────
    XFile? image;
    try {
      image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (image == null || !mounted) return;

    // ── Options dialog ───────────────────────────────────────────────────
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UploadOptionsDialog(
        initialType: 'front',
        initialDefault: false,
      ),
    );
    if (result == null || !mounted) return;

    // ── Upload ───────────────────────────────────────────────────────────
    final provider = context.read<PresetImageProvider>();
    final success = await provider.uploadImage(
      image.path,
      imageType: result['imageType'] as String,
      isDefault: result['isDefault'] as bool,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _showPermissionDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600)),
        content: Text(message, style: GoogleFonts.playfairDisplay(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        top: false,
        child: Consumer<PresetImageProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const AnimatedTabHeader(title: 'Upload an image'),
                  const SizedBox(height: 32),
                  // Large circular upload area
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppTheme.widgetColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.widgetColor.withValues(alpha: 0.2),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.accessibility_new,
                          size: 64,
                          color: AppTheme.widgetColor.withValues(alpha: 0.4),
                        ),
                        if (provider.images.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${provider.images.length} photo${provider.images.length == 1 ? '' : 's'}',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 13,
                                color: AppTheme.fontColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildUploadButton(
                            icon: Icons.camera_alt,
                            label: 'Take a Pic',
                            onTap: () => _pickAndUpload(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildUploadButton(
                            icon: Icons.photo_library,
                            label: 'Upload',
                            onTap: () => _pickAndUpload(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Instructions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInstructionItem(
                            '1.',
                            'Upload or choose a full-body or upper-body photo with good lighting.',
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionItem(
                            '2.',
                            "We'll map your body shape so clothes fit naturally.",
                          ),
                          const SizedBox(height: 8),
                          _buildInstructionItem(
                            '3.',
                            'Browse styles and see them overlaid on your image.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Existing photos grid
                  if (provider.images.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Your Photos',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.fontColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: provider.images.length,
                      itemBuilder: (context, index) {
                        final image = provider.images[index];
                        return PresetImageCard(
                          image: image,
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Photo'),
                                content: const Text(
                                    'Are you sure you want to delete this photo?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style: TextStyle(color: AppTheme.errorColor)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) provider.deleteImage(image.id);
                          },
                          onSetDefault: () => provider.setDefault(image.id),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                  // Upload overlay
                  if (provider.isUploading)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Uploading...'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.playfairDisplay(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.fontColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: GoogleFonts.playfairDisplay(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.fontColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.playfairDisplay(
              fontSize: 12,
              color: AppTheme.fontColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadOptionsDialog extends StatefulWidget {
  final String initialType;
  final bool initialDefault;

  const _UploadOptionsDialog({
    required this.initialType,
    required this.initialDefault,
  });

  @override
  State<_UploadOptionsDialog> createState() => _UploadOptionsDialogState();
}

class _UploadOptionsDialogState extends State<_UploadOptionsDialog> {
  late String _imageType;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _imageType = widget.initialType;
    _isDefault = widget.initialDefault;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Photo Options',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Photo Type',
              style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          ImageTypeSelector(
            selectedType: _imageType,
            onTypeSelected: (type) => setState(() => _imageType = type),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Set as default'),
            value: _isDefault,
            onChanged: (val) => setState(() => _isDefault = val),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, {
            'imageType': _imageType,
            'isDefault': _isDefault,
          }),
          child: const Text('Upload'),
        ),
      ],
    );
  }
}
