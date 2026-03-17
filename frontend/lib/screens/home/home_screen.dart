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
import '../../providers/preset_image_provider.dart';
import '../../widgets/clothing/category_tabs.dart';
import '../../widgets/clothing/clothing_grid.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../try_on/try_on_history_screen.dart';
import '../measurements/measurements_screen.dart';
import '../preset_images/preset_images_screen.dart';
import '../../widgets/common/loomee_logo.dart';
import '../../widgets/common/animated_tab_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Hero carousel images
const List<String> _heroAssets = [
  'assets/images/hero_1.jpeg',
  'assets/images/hero_2.jpeg',
  'assets/images/hero_3.jpeg',
  'assets/images/hero_4.jpeg',
];

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  double? _navDragFraction; // null = resting; 0.0–4.0 = live drag position
  double _pillStretch = 0.0; // px the pill is stretched left/right during drag
  final _searchController = TextEditingController();

  // Hero carousel
  final PageController _heroPageController = PageController();
  int _heroPage = 0;
  Timer? _heroTimer;

  @override
  void initState() {
    super.initState();
    _startHeroAutoScroll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Read optional initialTab argument (e.g. from "Try Another" on result screen)
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['initialTab'] is int) {
        setState(() => _currentIndex = args['initialTab'] as int);
      }
      context.read<CatalogProvider>().fetchClothing();
      context.read<PresetImageProvider>().fetchImages();
    });
  }

  void _startHeroAutoScroll() {
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      // Always go forward — infinite pages, never reverses
      _heroPageController.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageController.dispose();
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
      body: Stack(
        children: [
          // ── Tab content — extends behind floating navbar so glass blurs it ──
          IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeTab(),
              _buildCatalogTab(),
              const MeasurementsScreen(),
              const PresetImagesScreen(),
              const TryOnHistoryScreen(),
            ],
          ),
          // ── Floating glass navbar ────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }

  // ── Floating navbar with glass pill + fluid drag ──────────────────────
  Widget _buildFloatingNavBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final itemWidth = totalWidth / 5;
                  final basePillWidth = itemWidth * 0.92;

                  final fraction = _navDragFraction ?? _currentIndex.toDouble();
                  final centerLeft =
                      fraction * itemWidth + (itemWidth - basePillWidth) / 2;

                  final stretchLeft = _pillStretch < 0 ? _pillStretch : 0.0;
                  final pillLeft = (centerLeft + stretchLeft)
                      .clamp(0.0, totalWidth - basePillWidth);
                  final pillWidth = (basePillWidth + _pillStretch.abs())
                      .clamp(basePillWidth, totalWidth);

                  // ── Morph: leading edge tapers as pill stretches ──────
                  // Trailing side → fully rounded (r = 22)
                  // Leading side → slightly tapered when moving fast
                  const baseR = 22.0;
                  final morphT =
                      (_pillStretch / 20.0).clamp(-1.0, 1.0).abs();
                  final taperedR = baseR * (1.0 - morphT * 0.38);
                  final leftR =
                      _pillStretch < 0 ? taperedR : baseR; // left leads when dragging left
                  final rightR =
                      _pillStretch > 0 ? taperedR : baseR; // right leads when dragging right
                  final pillRadius = BorderRadius.only(
                    topLeft: Radius.circular(leftR),
                    bottomLeft: Radius.circular(leftR),
                    topRight: Radius.circular(rightR),
                    bottomRight: Radius.circular(rightR),
                  );

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    // ── Tap: navigate to tapped tab ──────────────────
                    onTapUp: (details) {
                      final idx =
                          (details.localPosition.dx / itemWidth).floor().clamp(0, 4);
                      setState(() {
                        _currentIndex = idx;
                        _navDragFraction = null;
                        _pillStretch = 0.0;
                      });
                    },
                    // ── Drag: pill follows finger + stretches in motion dir ─
                    onHorizontalDragUpdate: (details) {
                      final raw =
                          (details.localPosition.dx / totalWidth) * 5 - 0.5;
                      final clamped = raw.clamp(0.0, 4.0);
                      final newHovered = clamped.round().clamp(0, 4);
                      final oldHovered = _navDragFraction != null
                          ? _navDragFraction!.round().clamp(0, 4)
                          : _currentIndex;
                      if (newHovered != oldHovered) {
                        HapticFeedback.selectionClick();
                      }
                      // Smooth exponential blend — subtle water-droplet stretch
                      final targetStretch = (details.delta.dx * 2.0).clamp(-20.0, 20.0);
                      setState(() {
                        _navDragFraction = clamped;
                        _pillStretch = _pillStretch * 0.6 + targetStretch * 0.4;
                      });
                    },
                    // ── Release: spring snap, stretch collapses ───────
                    onHorizontalDragEnd: (_) {
                      if (_navDragFraction != null) {
                        setState(() {
                          _currentIndex = _navDragFraction!.round().clamp(0, 4);
                          _navDragFraction = null;
                          _pillStretch = 0.0; // AnimatedPositioned springs this back
                        });
                      }
                    },
                    onHorizontalDragCancel: () => setState(() {
                      _navDragFraction = null;
                      _pillStretch = 0.0;
                    }),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Pill: zero-duration during drag (instant track),
                        // elasticOut spring when snapping back to a tab
                        AnimatedPositioned(
                          duration: _navDragFraction != null
                              ? Duration.zero
                              : const Duration(milliseconds: 380),
                          curve: _navDragFraction != null
                              ? Curves.linear
                              : Curves.easeOutBack,
                          left: pillLeft,
                          top: 0,
                          bottom: 0,
                          width: pillWidth,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius: pillRadius,
                              border: Border.all(
                                color: AppTheme.accentColor.withValues(alpha: 0.20),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                        // ── Nav items ─────────────────────────────────
                        Row(
                          children: [
                            _buildNavItem(Icons.home_rounded, 'Home', 0),
                            _buildNavItem(Icons.explore_rounded, 'Explore', 1),
                            _buildNavItem(Icons.straighten_rounded, 'Measure', 2),
                            _buildNavItem(Icons.camera_alt_rounded, 'Upload', 3),
                            _buildNavItem(Icons.replay_rounded, 'Try ons', 4),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    // During drag, highlight the tab the finger is hovering over
    final displayIndex = _navDragFraction != null
        ? _navDragFraction!.round().clamp(0, 4)
        : _currentIndex;
    final isSelected = displayIndex == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppTheme.fontColor
                  : Colors.white.withValues(alpha: 0.85),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.playfairDisplay(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? AppTheme.fontColor
                    : Colors.white.withValues(alpha: 0.85),
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
      child: SingleChildScrollView(
        // Extra bottom space so last content scrolls fully above the navbar
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 28),
            // Logo + logout row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const LomeeLogo(size: 48),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        final tab = await Navigator.pushNamed(
                            context, AppRoutes.profile);
                        if (tab is int && mounted) {
                          setState(() => _currentIndex = tab);
                        }
                      },
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 26,
                        color: AppTheme.fontColor.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // "Discover your style"
            Text(
              'Discover your style',
              style: GoogleFonts.playfairDisplay(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppTheme.fontColor,
              ),
            ),
            const SizedBox(height: 24),
            // Hero card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHeroCard(),
            ),
            const SizedBox(height: 32),
            // Trending Styles header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Styles',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.fontColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: Text(
                      'View all',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        color: AppTheme.fontColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Trending grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTrendingGrid(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),

    );
  }

  Widget _buildHeroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 420,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Carousel images ──────────────────────────────────────────
            PageView.builder(
              controller: _heroPageController,
              // null = infinite pages; always scrolls forward, never reverses
              itemCount: null,
              onPageChanged: (i) =>
                  setState(() => _heroPage = i % _heroAssets.length),
              itemBuilder: (context, index) {
                return Image.asset(
                  _heroAssets[index % _heroAssets.length],
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, __, ___) => _buildHeroPlaceholder(index),
                );
              },
            ),
            // ── Gradient for readability ─────────────────────────────────
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x30000000)],
                  stops: [0.45, 1.0],
                ),
              ),
            ),
            // ── Bottom liquid glass card + dots ──────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.26),
                            Colors.white.withValues(alpha: 0.10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dot indicators only — no text label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_heroAssets.length, (i) {
                              final active = i == _heroPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 6),
                                width: active ? 20 : 6,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                          // Upload button — full width, tall, prominent
                          GestureDetector(
                            onTap: () => setState(() => _currentIndex = 3),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 17),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.camera_alt_rounded,
                                          size: 18, color: Colors.white),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Upload Photo',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                              ),
                            ),
                          ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPlaceholder(int index) {
    // Placeholder gradient shown until real hero images are added
    final colors = [
      [AppTheme.fontColor.withValues(alpha: 0.08), AppTheme.accentColor.withValues(alpha: 0.18)],
      [AppTheme.accentColor.withValues(alpha: 0.12), AppTheme.fontColor.withValues(alpha: 0.10)],
      [AppTheme.fontColor.withValues(alpha: 0.06), AppTheme.accentColor.withValues(alpha: 0.14)],
      [AppTheme.accentColor.withValues(alpha: 0.10), AppTheme.fontColor.withValues(alpha: 0.08)],
    ];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors[index % colors.length],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: 90,
          color: AppTheme.fontColor.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  Widget _buildTrendingGrid() {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        if (catalog.isLoading) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final items = catalog.clothingItems.take(4).toList();
        if (items.isEmpty) return const SizedBox.shrink();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final imageUrl =
                item.images.isNotEmpty ? item.images.first : null;
            return GestureDetector(
              onTap: () => setState(() => _currentIndex = 1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.fontColor.withValues(alpha: 0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: AppTheme.fontColor.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.fontColor.withValues(alpha: 0.08),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppTheme.fontColor.withValues(alpha: 0.3),
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.fontColor.withValues(alpha: 0.08),
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Catalog/Explore Tab ───────────────────────────────────────────────

  Widget _buildCatalogTab() {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnimatedTabHeader(title: 'Explore'),
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: 110),
                  child: ClothingGrid(
                    items: catalog.clothingItems,
                    onRefresh: () => catalog.fetchClothing(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
