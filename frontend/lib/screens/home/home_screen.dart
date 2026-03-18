import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/clothing/category_tabs.dart';
import '../../widgets/clothing/clothing_grid.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../try_on/try_on_history_screen.dart';
import '../measurements/measurements_screen.dart';
import '../preset_images/preset_images_screen.dart';
import '../../widgets/common/loomee_logo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().fetchClothing();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
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
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildCatalogTab(),
          const MeasurementsScreen(),
          const PresetImagesScreen(),
          const TryOnHistoryScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.widgetColor,
              borderRadius: BorderRadius.circular(28),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.explore_rounded, 'Explore', 1),
                _buildNavItem(Icons.straighten_rounded, 'Measure', 2),
                _buildNavItem(Icons.camera_alt_rounded, 'Upload', 3),
                _buildNavItem(Icons.replay_rounded, 'Try ons', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? AppTheme.white
                  : AppTheme.white.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.white
                    : AppTheme.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Home Tab ──────────────────────────────────────────────────────────

  Widget _buildHomeTab() {
    return SafeArea(
      child: Column(
        children: [
          // Header banner
          _buildHomeBanner(),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome text
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final name = auth.user?.name ?? 'there';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back, $name!',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.fontColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "What's on your mind today?",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color:
                                  AppTheme.fontColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  // 2x2 action tiles
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.explore,
                          label: 'Catalog',
                          onTap: () => setState(() => _currentIndex = 1),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.accessibility_new,
                          label: 'Body',
                          onTap: () => setState(() => _currentIndex = 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.camera_alt,
                          label: 'Upload',
                          onTap: () => setState(() => _currentIndex = 3),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.replay,
                          label: 'Try ons',
                          onTap: () => setState(() => _currentIndex = 4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Logout button
                  Center(
                    child: TextButton.icon(
                      onPressed: _logout,
                      icon: Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppTheme.fontColor.withValues(alpha: 0.5),
                      ),
                      label: Text(
                        'Log out',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.fontColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.widgetColor.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Loomeé',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
              letterSpacing: 0.5,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.widgetColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: LomeeLogo(size: 24, color: AppTheme.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.widgetColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppTheme.fontColor.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 38, color: AppTheme.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Catalog/Explore Tab ───────────────────────────────────────────────

  Widget _buildCatalogTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: AppTheme.widgetColor.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: Text(
              'Loomeé',
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.fontColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
                context.read<CatalogProvider>().setSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search clothing...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          context
                              .read<CatalogProvider>()
                              .setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<CatalogProvider>(
            builder: (context, catalog, _) {
              return CategoryTabs(
                selectedCategory: catalog.selectedCategory,
                onCategorySelected: (cat) => catalog.setCategory(cat),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<CatalogProvider>(
              builder: (context, catalog, _) {
                if (catalog.isLoading) {
                  return const LoadingShimmer.card();
                }
                if (catalog.error != null) {
                  return AppErrorWidget(
                    message: catalog.error!,
                    onRetry: () => catalog.fetchClothing(),
                  );
                }
                if (catalog.clothingItems.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'No clothing found',
                    subtitle: 'Try adjusting your filters or search query',
                  );
                }
                return ClothingGrid(
                  items: catalog.clothingItems,
                  onRefresh: () => catalog.fetchClothing(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
