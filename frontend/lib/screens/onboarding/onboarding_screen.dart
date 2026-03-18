import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _requestCameraPermission() async {
    await Permission.camera.request();
    _nextPage();
  }

  Future<void> _requestGalleryPermission() async {
    if (Platform.isIOS) {
      await Permission.photos.request();
    } else {
      await Permission.photos.request();
    }
    _nextPage();
  }

  Future<void> _completeOnboarding() async {
    await StorageService().setOnboardingCompleted();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (_) {},
          children: [
            _buildWelcomePage(),
            _buildCameraPermissionPage(),
            _buildGalleryPermissionPage(),
            _buildAllSetPage(),
          ],
        ),
      ),
    );
  }

  // ── Page 1: Welcome ──────────────────────────────────────────────────

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            'Welcome\nto Loomeé',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
              height: 1.15,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before you continue, we need your permission to access certain features.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    color: AppTheme.fontColor.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'When the permission pop up appears, please tap Allow to continue.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    color: AppTheme.fontColor.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'We only request access that is required for the app to work properly. You can change these permissions later in your device settings if needed.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    color: AppTheme.fontColor.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _nextPage,
              child: Text(
                'Continue',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Page 2: Camera Permission ─────────────────────────────────────────

  Widget _buildCameraPermissionPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            'Welcome\nto Loomeé',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
              height: 1.15,
            ),
          ),
          const Spacer(),
          // Permission card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.fontColor.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 56,
                  color: AppTheme.widgetColor,
                ),
                const SizedBox(height: 20),
                Text(
                  "'Loomeé' would like to access the Camera.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.fontColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Allow camera access to snap a photo and create your virtual avatar. This helps you see how your outfits look on you!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13,
                    color: AppTheme.fontColor.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _nextPage,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            "Don't Allow",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _requestCameraPermission,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Allow',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  // ── Page 3: Gallery Permission ────────────────────────────────────────

  Widget _buildGalleryPermissionPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          Text(
            'Welcome\nto Loomeé',
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
              height: 1.15,
            ),
          ),
          const Spacer(),
          // Permission card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.fontColor.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  size: 56,
                  color: AppTheme.widgetColor,
                ),
                const SizedBox(height: 20),
                Text(
                  "'Loomeé' would like to access your Gallery.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.fontColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We need access to your photo library to let you upload a photo and create your virtual avatar for trying on clothes.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13,
                    color: AppTheme.fontColor.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: _nextPage,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            "Don't Allow",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _requestGalleryPermission,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Allow',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  // ── Page 4: All Set ───────────────────────────────────────────────────

  Widget _buildAllSetPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Checkmark circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.widgetColor.withValues(alpha: 0.2),
                width: 3,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.check_rounded,
                size: 72,
                color: AppTheme.widgetColor.withValues(alpha: 0.6),
              ),
            ),
          ),
          const Spacer(),
          Text(
            'All Set!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome to the loomeé experience!',
            style: GoogleFonts.playfairDisplay(
              fontSize: 15,
              color: AppTheme.fontColor.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              child: Text(
                'Homepage',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
