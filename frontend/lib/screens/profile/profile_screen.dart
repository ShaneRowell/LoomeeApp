import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/preset_image_provider.dart';
import '../../providers/try_on_provider.dart';
import '../../widgets/common/animated_tab_header.dart';

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
      context.read<TryOnProvider>().fetchTryOns();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const AnimatedTabHeader(title: 'Profile'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                children: [
                  const SizedBox(height: 28),
                  _buildAvatar(),
                  const SizedBox(height: 28),
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  _buildMeasurementsCard(),
                  const SizedBox(height: 16),
                  _buildMenuSection(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar + name + email + member-since ──────────────────────────────
  Widget _buildAvatar() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        final initial =
            (user?.name.isNotEmpty == true ? user!.name : 'U')[0].toUpperCase();
        final memberSince = user?.createdAt != null
            ? DateFormat('MMMM yyyy').format(user!.createdAt!)
            : null;

        return Column(
          children: [
            // Terracotta circle with initial
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withValues(alpha: 0.35),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user?.name ?? 'User',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
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
            if (memberSince != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 12, color: AppTheme.accentColor),
                  const SizedBox(width: 5),
                  Text(
                    'Member since $memberSince',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 12,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Consumer<TryOnProvider>(
              builder: (context, p, _) => _buildStatCard(
                icon: Icons.checkroom_rounded,
                value: '${p.tryOns.length}',
                label: 'Try-Ons',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Consumer<PresetImageProvider>(
              builder: (context, p, _) => _buildStatCard(
                icon: Icons.photo_rounded,
                value: '${p.images.length}',
                label: 'Photos',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Consumer<MeasurementProvider>(
              builder: (context, p, _) => _buildStatCard(
                icon: Icons.straighten_rounded,
                value: p.hasMeasurements ? '✓' : '—',
                label: 'Measured',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fontColor.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppTheme.accentColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.playfairDisplay(
              fontSize: 10,
              color: AppTheme.fontColor.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Body measurements snapshot ────────────────────────────────────────
  Widget _buildMeasurementsCard() {
    return Consumer<MeasurementProvider>(
      builder: (context, provider, _) {
        if (!provider.hasMeasurements) {
          // Prompt to add measurements
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.measurements),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.fontColor.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.straighten_rounded,
                          size: 20, color: AppTheme.accentColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add your measurements',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.fontColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Get better size recommendations',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 13,
                              color: AppTheme.fontColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.add_circle_outline_rounded,
                        color: AppTheme.accentColor, size: 22),
                  ],
                ),
              ),
            ),
          );
        }

        final m = provider.measurement!;
        final chips = <Map<String, String>>[
          {'label': 'Height', 'value': '${m.height}cm'},
          {'label': 'Weight', 'value': '${m.weight}kg'},
          {'label': 'Chest', 'value': '${m.chest}cm'},
          {'label': 'Waist', 'value': '${m.waist}cm'},
          {'label': 'Hips', 'value': '${m.hips}cm'},
          if (m.shoulderWidth != null)
            {'label': 'Shoulder', 'value': '${m.shoulderWidth}cm'},
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.fontColor.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.straighten_rounded,
                          size: 18, color: AppTheme.accentColor),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Body Measurements',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.fontColor,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.measurements),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 13,
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Chips in rows of 3
                ...List.generate((chips.length / 3).ceil(), (row) {
                  final slice = chips.skip(row * 3).take(3).toList();
                  return Padding(
                    padding: EdgeInsets.only(
                        top: row == 0 ? 0 : 8),
                    child: Row(
                      children: [
                        for (int i = 0; i < slice.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _buildMeasurementChip(
                              slice[i]['label']!,
                              slice[i]['value']!,
                            ),
                          ),
                        ],
                        // Fill empty slots in last row
                        for (int i = slice.length; i < 3; i++) ...[
                          const SizedBox(width: 8),
                          const Expanded(child: SizedBox()),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeasurementChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.playfairDisplay(
              fontSize: 10,
              color: AppTheme.fontColor.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Menu tiles ────────────────────────────────────────────────────────
  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.photo_library_rounded,
            title: 'My Photos',
            subtitle: Consumer<PresetImageProvider>(
              builder: (context, p, _) => Text(
                '${p.images.length} uploaded',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 13,
                  color: AppTheme.fontColor.withValues(alpha: 0.5),
                ),
              ),
            ),
            onTap: () => Navigator.pushNamed(context, AppRoutes.presetImages),
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.replay_rounded,
            title: 'Try-On History',
            subtitle: Text(
              'Browse past virtual try-ons',
              style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                color: AppTheme.fontColor.withValues(alpha: 0.5),
              ),
            ),
            onTap: () => Navigator.pushNamed(context, AppRoutes.tryOnHistory),
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.style_rounded,
            title: 'Outfit Suggestions',
            subtitle: Text(
              'Complete your look with AI',
              style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                color: AppTheme.fontColor.withValues(alpha: 0.5),
              ),
            ),
            onTap: () => Navigator.pushNamed(context, AppRoutes.completeOutfit),
          ),
        ],
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.fontColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppTheme.accentColor),
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
              Icons.chevron_right_rounded,
              color: AppTheme.fontColor.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(
                'Log out',
                style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.w700),
              ),
              content: Text(
                'Are you sure you want to log out?',
                style: GoogleFonts.playfairDisplay(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.playfairDisplay(
                        color: AppTheme.fontColor),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    'Log out',
                    style: GoogleFonts.playfairDisplay(
                        color: AppTheme.errorColor),
                  ),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (route) => false);
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.errorColor.withValues(alpha: 0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.fontColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded,
                  size: 18, color: AppTheme.errorColor),
              const SizedBox(width: 8),
              Text(
                'Log Out',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
