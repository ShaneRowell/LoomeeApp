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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();

  // Deep charcoal card colour as per design spec
  static const Color _cardColor = Color(0xFF1A1A1A);

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
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Log out',
              style: TextStyle(color: AppTheme.errorColor),
            ),
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

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppTheme.white,
      builder: (ctx) => Consumer<AuthProvider>(
        builder: (_, auth, __) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.fontColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                // Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cardColor,
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 12),
                if (auth.user?.name != null)
                  Text(
                    auth.user!.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.fontColor,
                    ),
                  ),
                if (auth.user?.email != null)
                  Text(
                    auth.user!.email,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.fontColor.withValues(alpha: 0.45),
                    ),
                  ),
                const SizedBox(height: 24),
                Divider(color: AppTheme.fontColor.withValues(alpha: 0.1)),
                const SizedBox(height: 4),
                ListTile(
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  title: Text(
                    'Log out',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.errorColor,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _logout();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
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
          const PresetImagesScreen(),   // index 2 — Upload (centre FAB)
          const MeasurementsScreen(),   // index 3
          const TryOnHistoryScreen(),   // index 4
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fontColor.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.explore_outlined, Icons.explore_rounded, 'Explore', 1),
              // Centre Upload FAB
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _cardColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _cardColor.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppTheme.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildNavItem(Icons.straighten_rounded, Icons.straighten_rounded, 'Measure', 3),
              _buildNavItem(Icons.layers_outlined, Icons.layers_rounded, 'Try-Ons', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              size: 22,
              color: isSelected
                  ? AppTheme.fontColor
                  : AppTheme.fontColor.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.fontColor
                    : AppTheme.fontColor.withValues(alpha: 0.35),
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
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final name = auth.user?.name ?? 'there';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome copy
                      Text(
                        'Hello, $name.',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.fontColor,
                        ),
                      ),
                      Text(
                        'What shall we design today?',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.fontColor.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Recent Try-Ons — hero 16:9
                      _buildSectionLabel('RECENT TRY-ONS'),
                      const SizedBox(height: 10),
                      _buildHeroCard(),
                      const SizedBox(height: 24),

                      // Quick access cards
                      _buildSectionLabel('QUICK ACCESS'),
                      const SizedBox(height: 10),
                      _buildQuickAccessCards(),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Loomeé',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
              letterSpacing: 0.5,
            ),
          ),
          IconButton(
            onPressed: _showProfileSheet,
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.fontColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: AppTheme.fontColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.fontColor.withValues(alpha: 0.4),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildHeroCard() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 4),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Subtle gradient wash
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2C)],
                    ),
                  ),
                ),
                // Decorative background icon
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.checkroom_outlined,
                    size: 180,
                    color: AppTheme.white.withValues(alpha: 0.04),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'TRY-ONS',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.white.withValues(alpha: 0.6),
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Recent\nLooks',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'View All',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.white.withValues(alpha: 0.55),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: AppTheme.white.withValues(alpha: 0.55),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessCards() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickCard(
            icon: Icons.checkroom_outlined,
            label: 'Catalog',
            subtitle: 'Browse styles',
            onTap: () => setState(() => _currentIndex = 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickCard(
            icon: Icons.accessibility_new,
            label: 'My Body',
            subtitle: 'Measurements',
            onTap: () => setState(() => _currentIndex = 3),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 26,
              color: AppTheme.white.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Catalog / Explore Tab ─────────────────────────────────────────────

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
                          context.read<CatalogProvider>().setSearchQuery('');
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
                    icon: Icons.checkroom,
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
