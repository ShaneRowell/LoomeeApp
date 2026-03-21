import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/try_on_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loomee_logo.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/animated_tab_header.dart';
import '../../widgets/try_on/try_on_status_badge.dart';

class TryOnHistoryScreen extends StatefulWidget {
  const TryOnHistoryScreen({super.key});

  @override
  State<TryOnHistoryScreen> createState() => _TryOnHistoryScreenState();
}

class _TryOnHistoryScreenState extends State<TryOnHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TryOnProvider>().fetchTryOns();
    });
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                const AnimatedTabHeader(title: 'Try Ons'),
                if (canPop)
                  Positioned(
                    top: 22,
                    right: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<TryOnProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) return const LoadingShimmer.list();
                  if (provider.tryOns.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.camera_alt_outlined,
                      title: 'No try-ons yet',
                      subtitle: 'Start a virtual try-on from the catalog',
                      actionLabel: 'Browse Catalog',
                      onAction: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.home,
                        arguments: {'initialTab': 1},
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchTryOns(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: provider.tryOns.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tryOn = provider.tryOns[index];
                        return Dismissible(
                          key: Key(tryOn.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            final success =
                                await provider.deleteTryOn(tryOn.id);
                            if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.error ??
                                      'Failed to delete try-on'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                              await provider.fetchTryOns();
                            }
                          },
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.tryOnResult,
                              arguments: tryOn.id,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.06),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child:
                                        tryOn.clothing?.images.isNotEmpty == true
                                            ? CachedNetworkImage(
                                                imageUrl: tryOn
                                                    .clothing!.images.first,
                                                width: 65,
                                                height: 65,
                                                fit: BoxFit.cover,
                                                errorWidget: (_, __, ___) =>
                                                    _placeholder(),
                                              )
                                            : _placeholder(),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // List item label — rule 2
                                        Text(
                                          tryOn.clothing?.name ??
                                              'Unknown Item',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: scheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Brand name on a card — rule 2
                                        Text(
                                          tryOn.clothing?.brand ?? '',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: scheme.onSurface
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            TryOnStatusBadge(
                                                status: tryOn.status),
                                            const Spacer(),
                                            // Date/timestamp — rule 2
                                            if (tryOn.createdAt != null)
                                              Text(
                                                DateFormat('MMM d')
                                                    .format(tryOn.createdAt!),
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: scheme.onSurface
                                                      .withValues(alpha: 0.4),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 65,
      height: 65,
      color: Theme.of(context).colorScheme.surface,
      child: const LomeeLogo(size: 28, color: Colors.grey),
    );
  }
}
