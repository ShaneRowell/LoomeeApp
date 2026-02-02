import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  final int itemCount;
  final ShimmerType type;

  const LoadingShimmer({
    super.key,
    this.itemCount = 6,
    this.type = ShimmerType.grid,
  });

  const LoadingShimmer.card({super.key})
      : itemCount = 6,
        type = ShimmerType.grid;

  const LoadingShimmer.list({super.key})
      : itemCount = 5,
        type = ShimmerType.list;

  const LoadingShimmer.detail({super.key})
      : itemCount = 1,
        type = ShimmerType.detail;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (type) {
      case ShimmerType.grid:
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemCount: itemCount,
          itemBuilder: (_, __) => _buildCardPlaceholder(),
        );
      case ShimmerType.list:
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: itemCount,
          itemBuilder: (_, __) => _buildListPlaceholder(),
        );
      case ShimmerType.detail:
        return _buildDetailPlaceholder();
    }
  }

  Widget _buildCardPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 80, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: double.infinity, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 10, width: 120, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 10, width: 80, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPlaceholder() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 300, width: double.infinity, color: Colors.white),
          const SizedBox(height: 16),
          Container(height: 16, width: 100, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 24, width: 250, color: Colors.white),
          const SizedBox(height: 8),
          Container(height: 18, width: 80, color: Colors.white),
          const SizedBox(height: 16),
          Container(height: 12, width: double.infinity, color: Colors.white),
          const SizedBox(height: 6),
          Container(height: 12, width: double.infinity, color: Colors.white),
          const SizedBox(height: 6),
          Container(height: 12, width: 200, color: Colors.white),
        ],
      ),
    );
  }
}

enum ShimmerType { grid, list, detail }
