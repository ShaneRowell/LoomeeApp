import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/preset_image_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeasurementProvider>().fetchMeasurements();
      context.read<PresetImageProvider>().fetchImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final user = auth.user;
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppTheme.widgetColor,
                      child: Text(
                        (user?.name?.isNotEmpty == true ? user!.name! : 'U')[0].toUpperCase(),
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      user?.name ?? 'User',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.fontColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        color: AppTheme.fontColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            _buildMenuTile(
              icon: Icons.straighten,
              title: 'My Measurements',
              subtitle: Consumer<MeasurementProvider>(
                builder: (context, provider, _) {
                  if (provider.hasMeasurements) {
                    final m = provider.measurement!;
                    return Text(
                      '${m.height}cm / ${m.weight}kg',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13,
                        color: AppTheme.fontColor.withValues(alpha: 0.5),
                      ),
                    );
                  }
                  return Text(
                    'Not set',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      color: AppTheme.accentColor,
                    ),
                  );
                },
              ),
              onTap: () => Navigator.pushNamed(context, AppRoutes.measurements),
            ),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.photo_library,
              title: 'My Photos',
              subtitle: Consumer<PresetImageProvider>(
                builder: (context, provider, _) {
                  return Text(
                    '${provider.images.length} photos',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      color: AppTheme.fontColor.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
              onTap: () => Navigator.pushNamed(context, AppRoutes.presetImages),
            ),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.history,
              title: 'Try-On History',
              subtitle: Text(
                'View past try-ons',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 13,
                  color: AppTheme.fontColor.withValues(alpha: 0.5),
                ),
              ),
              onTap: () => Navigator.pushNamed(context, AppRoutes.tryOnHistory),
            ),
            const SizedBox(height: 12),
            _buildMenuTile(
              icon: Icons.style,
              title: 'Complete Outfit',
              subtitle: Text(
                'Get outfit suggestions',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 13,
                  color: AppTheme.fontColor.withValues(alpha: 0.5),
                ),
              ),
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.completeOutfit),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Logout',
                              style: TextStyle(color: AppTheme.errorColor)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                label: const Text('Logout',
                    style: TextStyle(color: AppTheme.errorColor)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.errorColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Widget subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.fontColor.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.widgetColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: AppTheme.widgetColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.fontColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  subtitle,
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.fontColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
