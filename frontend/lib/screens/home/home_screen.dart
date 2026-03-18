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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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

  // ── Floating liquid-glass navbar ─────────────────────────────────────
  Widget _buildFloatingNavBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final itemWidth = totalWidth / 5;
              final pillWidth = itemWidth * 0.88;

              final fraction = _navDragFraction ?? _currentIndex.toDouble();
              final pillLeft = (fraction * itemWidth + (itemWidth - pillWidth) / 2)
                  .clamp(0.0, totalWidth - pillWidth);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                // ── Tap ────────────────────────────────────────────
                onTapUp: (details) {
                  final idx =
                      (details.localPosition.dx / itemWidth).floor().clamp(0, 4);
                  if (idx != _currentIndex) HapticFeedback.selectionClick();
                  setState(() {
                    _currentIndex = idx;
                    _navDragFraction = null;
                  });
                },
                // ── Drag ───────────────────────────────────────────
                onHorizontalDragUpdate: (details) {
                  final raw =
                      (details.localPosition.dx / totalWidth) * 5 - 0.5;
                  final clamped = raw.clamp(0.0, 4.0);
                  final newHovered = clamped.round().clamp(0, 4);
                  final oldHovered = _navDragFraction != null
                      ? _navDragFraction!.round().clamp(0, 4)
                      : _currentIndex;
                  if (newHovered != oldHovered) HapticFeedback.selectionClick();
                  setState(() => _navDragFraction = clamped);
                },
                // ── Release ────────────────────────────────────────
                onHorizontalDragEnd: (_) {
                  if (_navDragFraction != null) {
                    setState(() {
                      _currentIndex = _navDragFraction!.round().clamp(0, 4);
                      _navDragFraction = null;
                    });
                  }
                },
                onHorizontalDragCancel: () =>
                    setState(() => _navDragFraction = null),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    // ── Pill indicator ─────────────────────────────
                    AnimatedPositioned(
                      duration: _navDragFraction != null
                          ? Duration.zero
                          : const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      left: pillLeft,
                      top: 0,
                      bottom: 0,
                      width: pillWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                    // ── Nav items ──────────────────────────────────
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
                  LomeeLogo(
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
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
                color: Theme.of(context).colorScheme.onSurface,
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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _currentIndex = 1),
                    child: Text(
                      'View all',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
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
    final scheme = Theme.of(context).colorScheme;
    // Placeholder gradient shown until real hero images are added
    final gradientColors = [
      [scheme.onSurface.withValues(alpha: 0.08), scheme.primary.withValues(alpha: 0.18)],
      [scheme.primary.withValues(alpha: 0.12), scheme.onSurface.withValues(alpha: 0.10)],
      [scheme.onSurface.withValues(alpha: 0.06), scheme.primary.withValues(alpha: 0.14)],
      [scheme.primary.withValues(alpha: 0.10), scheme.onSurface.withValues(alpha: 0.08)],
    ];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors[index % gradientColors.length],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person_outline_rounded,
          size: 90,
          color: scheme.onSurface.withValues(alpha: 0.15),
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
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
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
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
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
