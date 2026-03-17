import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../providers/preset_image_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/try_on_provider.dart';
import '../../widgets/common/animated_tab_header.dart';
import '../../widgets/common/legal_sheet.dart';

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

  /// Format a measurement value: drop the decimal when it's a whole number.
  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Stack(
              children: [
                const AnimatedTabHeader(title: 'Profile'),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 14,
                  child: IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    _buildAvatar(scheme),
                    const SizedBox(height: 28),
                    _buildStatsRow(scheme),
                    const SizedBox(height: 20),
                    _buildMeasurementsCard(scheme),
                    const SizedBox(height: 16),
                    _buildPreferencesSection(scheme),
                    const SizedBox(height: 16),
                    _buildMenuSection(scheme),
                    const SizedBox(height: 24),
                    _buildLogoutButton(scheme),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar + name + email + member-since ──────────────────────────────
  Widget _buildAvatar(ColorScheme scheme) {
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
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: GoogleFonts.playfairDisplay(
                fontSize: 14,
                color: scheme.onSurface.withValues(alpha: 0.5),
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
  Widget _buildStatsRow(ColorScheme scheme) {
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
                scheme: scheme,
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
                scheme: scheme,
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
                scheme: scheme,
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
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
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
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.playfairDisplay(
              fontSize: 10,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Body measurements snapshot ────────────────────────────────────────
  Widget _buildMeasurementsCard(ColorScheme scheme) {
    return Consumer<MeasurementProvider>(
      builder: (context, provider, _) {
        if (!provider.hasMeasurements) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context, 2);
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.accentColor.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
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
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Get better size recommendations',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 13,
                              color: scheme.onSurface.withValues(alpha: 0.5),
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
          {'label': 'Height', 'value': '${_fmt(m.height)}cm'},
          {'label': 'Weight', 'value': '${_fmt(m.weight)}kg'},
          {'label': 'Chest', 'value': '${_fmt(m.chest)}cm'},
          {'label': 'Waist', 'value': '${_fmt(m.waist)}cm'},
          {'label': 'Hips', 'value': '${_fmt(m.hips)}cm'},
          if (m.shoulderWidth != null)
            {'label': 'Shoulder', 'value': '${_fmt(m.shoulderWidth!)}cm'},
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
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
                        color: scheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context, 2);
                      },
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
                ...List.generate((chips.length / 3).ceil(), (row) {
                  final slice = chips.skip(row * 3).take(3).toList();
                  return Padding(
                    padding: EdgeInsets.only(top: row == 0 ? 0 : 8),
                    child: Row(
                      children: [
                        for (int i = 0; i < slice.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: _buildMeasurementChip(
                                slice[i]['label']!, slice[i]['value']!, scheme),
                          ),
                        ],
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

  Widget _buildMeasurementChip(
      String label, String value, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.playfairDisplay(
              fontSize: 10,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Preferences (dark mode toggle) ────────────────────────────────────
  Widget _buildPreferencesSection(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Preferences', scheme),
          const SizedBox(height: 10),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return _buildToggleTile(
                icon: themeProvider.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: 'Dark Mode',
                subtitle: themeProvider.isDark
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
                value: themeProvider.isDark,
                onChanged: (_) {
                  HapticFeedback.lightImpact();
                  themeProvider.toggle();
                },
                scheme: scheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ColorScheme scheme,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13,
                    color: scheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentColor,
          ),
        ],
      ),
    );
  }

  // ── Menu tiles ────────────────────────────────────────────────────────
  Widget _buildMenuSection(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Activity ──────────────────────────────────────────────────
          _buildSectionLabel('Activity', scheme),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.photo_library_rounded,
            title: 'My Photos',
            subtitle: Consumer<PresetImageProvider>(
              builder: (context, p, _) => Text(
                '${p.images.length} uploaded',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 13,
                  color: scheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context, 3);
            },
            scheme: scheme,
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.replay_rounded,
            title: 'Try-On History',
            subtitle: Text(
              'Browse past virtual try-ons',
              style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context, 4);
            },
            scheme: scheme,
          ),
          const SizedBox(height: 20),

          // ── Legal ──────────────────────────────────────────────────────
          _buildSectionLabel('Legal', scheme),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: Text(
              'Usage rules and your rights',
              style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              _showLegalSheet(context,
                  title: 'Terms of Service',
                  sections: LegalContent.termsOfService);
            },
            scheme: scheme,
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: Text(
              'How we handle your data',
              style: GoogleFonts.playfairDisplay(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            onTap: () {
              HapticFeedback.selectionClick();
              _showLegalSheet(context,
                  title: 'Privacy Policy',
                  sections: LegalContent.privacyPolicy);
            },
            scheme: scheme,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ColorScheme scheme) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.playfairDisplay(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface.withValues(alpha: 0.4),
        letterSpacing: 1.2,
      ),
    );
  }

  void _showLegalSheet(
    BuildContext context, {
    required String title,
    required List<LegalSection> sections,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LegalSheet(title: title, sections: sections),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required Widget subtitle,
    required VoidCallback onTap,
    required ColorScheme scheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  subtitle,
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: scheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────────────────
  Widget _buildLogoutButton(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          HapticFeedback.mediumImpact();
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
                        color: scheme.onSurface),
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
            color: scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.errorColor.withValues(alpha: 0.30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
