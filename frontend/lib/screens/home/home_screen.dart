import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../try_on/try_on_history_screen.dart';
import '../measurements/measurements_screen.dart';
import '../preset_images/preset_images_screen.dart';

// Hero carousel slide definitions
const List<Map<String, dynamic>> _kHeroSlides = [
  {
    'colors': [Color(0xFF1A2338), Color(0xFF2D3F6B)],
    'icon': Icons.layers_outlined,
    'tag': 'TRY-ONS',
    'title': 'Your Recent\nLooks',
    'tab': 4,
  },
  {
    'colors': [Color(0xFF0D1B2A), Color(0xFF1A3A4A)],
    'icon': Icons.explore_outlined,
    'tag': 'TRENDING',
    'title': 'Trending\nStyles',
    'tab': 1,
  },
  {
    'colors': [Color(0xFF121212), Color(0xFF1E1E2E)],
    'icon': Icons.favorite_border,
    'tag': 'CURATED',
    'title': 'Picked\nfor You',
    'tab': 1,
  },
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchFocused = false;

  // Deep charcoal card colour
  static const Color _cardColor = Color(0xFF1A1A1A);

  // ── Entrance animation ─────────────────────────────────────────────
  late AnimationController _entranceCtrl;
  late Animation<double> _welcomeFade;
  late Animation<Offset> _welcomeSlide;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _quickFade;
  late Animation<Offset> _quickSlide;

  // ── Hero carousel ──────────────────────────────────────────────────
  late PageController _heroPageCtrl;
  int _heroPage = 0;
  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();

    // Entrance animations – staggered via Interval curves
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _welcomeFade = CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.00, 0.55, curve: Curves.easeOut));
    _welcomeSlide = Tween<Offset>(
            begin: const Offset(0, 0.22), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.00, 0.55, curve: Curves.easeOutCubic)));

    _heroFade = CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.18, 0.72, curve: Curves.easeOut));
    _heroSlide = Tween<Offset>(
            begin: const Offset(0, 0.22), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.18, 0.72, curve: Curves.easeOutCubic)));

    _quickFade = CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.36, 1.00, curve: Curves.easeOut));
    _quickSlide = Tween<Offset>(
            begin: const Offset(0, 0.22), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.36, 1.00, curve: Curves.easeOutCubic)));

    _entranceCtrl.forward();
    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
    });

    // Hero carousel
    _heroPageCtrl = PageController();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_heroPage + 1) % _kHeroSlides.length;
      _heroPageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().fetchClothing();
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _heroPageCtrl.dispose();
    _heroTimer?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
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
            child: const Text('Log out',
                style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (route) => false);
      }
    }
  }

  void _showProfileSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: AppTheme.white,
      builder: (ctx) => Consumer<AuthProvider>(
        builder: (_, auth, __) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.fontColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: _cardColor),
                child: const Icon(Icons.person_outline_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              if (auth.user?.name != null)
                Text(auth.user!.name,
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.fontColor)),
              if (auth.user?.email != null)
                Text(auth.user!.email,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: AppTheme.fontColor.withValues(alpha: 0.45))),
              const SizedBox(height: 24),
              Divider(color: AppTheme.fontColor.withValues(alpha: 0.1)),
              const SizedBox(height: 4),
              ListTile(
                leading: const Icon(Icons.logout_rounded,
                    color: AppTheme.errorColor, size: 20),
                title: Text('Log out',
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.errorColor)),
                onTap: () {
                  Navigator.pop(ctx);
                  _logout();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
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
          const PresetImagesScreen(),  // index 2 — Upload (centre FAB)
          const MeasurementsScreen(),  // index 3
          const TryOnHistoryScreen(),  // index 4
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Bottom navigation ──────────────────────────────────────────────

  Widget _buildBottomNav() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.white.withValues(alpha: 0.82),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(
                color: AppTheme.fontColor.withValues(alpha: 0.05),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.fontColor.withValues(alpha: 0.06),
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
                  _buildNavItem(
                      Icons.home_outlined, Icons.home_rounded, 'Home', 0),
                  _buildNavItem(Icons.explore_outlined, Icons.explore_rounded,
                      'Explore', 1),
                  // Centre Upload FAB with 45° rotation animation
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _currentIndex = 2);
                      },
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
                            child: AnimatedRotation(
                              turns: _currentIndex == 2 ? 0.125 : 0.0,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutBack,
                              child: const Icon(Icons.add_rounded,
                                  color: AppTheme.white, size: 26),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildNavItem(
                      Icons.straighten_rounded,
                      Icons.straighten_rounded,
                      'Measure',
                      3),
                  _buildNavItem(Icons.layers_outlined, Icons.layers_rounded,
                      'Try-Ons', 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData outlinedIcon, IconData filledIcon,
      String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = index);
        },
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
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
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

  // ── Home Tab ───────────────────────────────────────────────────────

  Widget _buildHomeTab() {
    return SafeArea(
      child: Stack(
        children: [
          // Scrollable content — padded top so it starts below the floating header
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 72, 20, 24),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final name = auth.user?.name ?? 'there';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome — slide in first
                    FadeTransition(
                      opacity: _welcomeFade,
                      child: SlideTransition(
                        position: _welcomeSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $name.',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.fontColor,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Text(
                              'What shall we design today?',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: AppTheme.fontColor
                                    .withValues(alpha: 0.45),
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Hero carousel — slide in second
                    FadeTransition(
                      opacity: _heroFade,
                      child: SlideTransition(
                        position: _heroSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('RECENT TRY-ONS'),
                            const SizedBox(height: 10),
                            _buildHeroCarousel(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick access — slide in third
                    FadeTransition(
                      opacity: _quickFade,
                      child: SlideTransition(
                        position: _quickSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionLabel('QUICK ACCESS'),
                            const SizedBox(height: 10),
                            _buildQuickAccessCards(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Floating glassmorphic header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: AppTheme.backgroundColor.withValues(alpha: 0.82),
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
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
                        icon: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.fontColor.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person_outline_rounded,
                                  size: 20, color: AppTheme.fontColor),
                            ),
                            Positioned(
                              top: -1,
                              right: -1,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppTheme.backgroundColor,
                                      width: 1.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
        color: AppTheme.fontColor.withValues(alpha: 0.38),
        letterSpacing: 1.3,
      ),
    );
  }

  // ── Hero carousel with glassmorphism overlay ───────────────────────

  Widget _buildHeroCarousel() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: PageView.builder(
              controller: _heroPageCtrl,
              itemCount: _kHeroSlides.length,
              onPageChanged: (p) => setState(() => _heroPage = p),
              itemBuilder: (_, i) => _buildHeroSlide(_kHeroSlides[i]),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_kHeroSlides.length, (i) {
            final active = i == _heroPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.fontColor
                    : AppTheme.fontColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeroSlide(Map<String, dynamic> slide) {
    final colors = slide['colors'] as List<Color>;
    final tabDest = slide['tab'] as int;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = tabDest),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
          // Decorative icon
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              slide['icon'] as IconData,
              size: 190,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          // Frosted glass content overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.28),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                slide['tag'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.65),
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              slide['title'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.15,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick access cards ─────────────────────────────────────────────

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
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: Colors.white.withValues(alpha: 0.85)),
            const SizedBox(height: 20),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.4))),
          ],
        ),
      ),
    );
  }

  // ── Catalog / Explore Tab ──────────────────────────────────────────

  Widget _buildCatalogTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glassmorphic header
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor.withValues(alpha: 0.88),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28)),
                ),
                child: Text('Loomeé',
                    style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.fontColor,
                        letterSpacing: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Search bar with focus shadow + border animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: _searchFocused
                    ? [
                        BoxShadow(
                          color: AppTheme.fontColor.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: _searchFocused
                          ? AppTheme.white.withValues(alpha: 0.95)
                          : AppTheme.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _searchFocused
                            ? AppTheme.fontColor.withValues(alpha: 0.2)
                            : AppTheme.fontColor.withValues(alpha: 0.07),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: (v) {
                        context.read<CatalogProvider>().setSearchQuery(v);
                        setState(() {});
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
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                ),
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
          // Grid with ripple transition on category change
          Expanded(
            child: Consumer<CatalogProvider>(
              builder: (context, catalog, _) {
                Widget content;
                if (catalog.isLoading) {
                  content =
                      const LoadingShimmer.card(key: ValueKey('shimmer'));
                } else if (catalog.error != null) {
                  content = AppErrorWidget(
                    key: const ValueKey('error'),
                    message: catalog.error!,
                    onRetry: () => catalog.fetchClothing(),
                  );
                } else if (catalog.clothingItems.isEmpty) {
                  content =
                      _buildMosaicEmptyState(key: const ValueKey('empty'));
                } else {
                  content = ClothingGrid(
                    key: ValueKey(catalog.selectedCategory),
                    items: catalog.clothingItems,
                    onRefresh: () => catalog.fetchClothing(),
                  );
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: animation, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  ),
                  child: content,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosaicEmptyState({Key? key}) {
    const List<List<Color>> tiles = [
      [Color(0xFF1A2338), Color(0xFF2D3F6B)],
      [Color(0xFF0D1B2A), Color(0xFF1A3A4A)],
      [Color(0xFFB76E79), Color(0xFF8B4E57)],
      [Color(0xFF121212), Color(0xFF2D2D2D)],
      [Color(0xFF1E3A2E), Color(0xFF2D5A3A)],
      [Color(0xFF2D1B3A), Color(0xFFB76E79)],
      [Color(0xFF1A2338), Color(0xFFB76E79)],
      [Color(0xFF2D3A1A), Color(0xFF1A2D14)],
      [Color(0xFF1A2338), Color(0xFF283752)],
    ];
    return Stack(
      key: key,
      fit: StackFit.expand,
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.75,
          ),
          itemCount: tiles.length,
          itemBuilder: (_, i) => Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: tiles[i],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                color: AppTheme.backgroundColor.withValues(alpha: 0.62),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.fontColor.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.checkroom_outlined,
                    size: 40,
                    color: AppTheme.fontColor.withValues(alpha: 0.4)),
                const SizedBox(height: 12),
                Text(
                  'No clothing found',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.fontColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Try adjusting your filters\nor search query',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    color: AppTheme.fontColor.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
