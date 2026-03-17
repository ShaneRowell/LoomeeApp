import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/preset_image_provider.dart';
import '../../widgets/preset/preset_image_card.dart';
import '../../widgets/preset/image_type_selector.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PresetImageProvider>().fetchImages();
    });
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;

    String imageType = 'front';
    bool isDefault = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _UploadOptionsDialog(
        initialType: imageType,
        initialDefault: isDefault,
      ),
    );
    if (result == null) return;

    imageType = result['imageType'];
    isDefault = result['isDefault'];

    final provider = context.read<PresetImageProvider>();
    await provider.uploadImage(
      image.path,
      imageType: imageType,
      isDefault: isDefault,
    );

    if (mounted && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: AppTheme.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<PresetImageProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          'Upload Your Image',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.fontColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Take a full body picture and upload it here',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            color: AppTheme.fontColor.withValues(alpha: 0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
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
              color: AppTheme.widgetColor,
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
