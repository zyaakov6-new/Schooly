import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/theme.dart';

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2D333B) : const Color(0xFFE8ECF0),
      highlightColor:
          isDark ? const Color(0xFF3D4450) : const Color(0xFFF5F7FA),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class TaskShimmerList extends StatelessWidget {
  final int count;

  const TaskShimmerList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: _TaskShimmer(),
      ),
    );
  }
}

class _TaskShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerBox(width: 44, height: 44, borderRadius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(
                width: double.infinity,
                height: 14,
                borderRadius: 6,
              ),
              const SizedBox(height: 8),
              ShimmerBox(width: 120, height: 12, borderRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ShimmerBox(width: 60, height: 28, borderRadius: 8),
      ],
    );
  }
}

class ChildCardShimmer extends StatelessWidget {
  const ChildCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShimmerBox(width: 64, height: 64, borderRadius: 20),
        const SizedBox(height: 8),
        ShimmerBox(width: 60, height: 12, borderRadius: 6),
        const SizedBox(height: 4),
        ShimmerBox(width: 40, height: 10, borderRadius: 6),
      ],
    );
  }
}

class EventShimmerList extends StatelessWidget {
  final int count;
  const EventShimmerList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              ShimmerBox(width: 4, height: 60, borderRadius: 2),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                        width: double.infinity, height: 14, borderRadius: 6),
                    const SizedBox(height: 6),
                    ShimmerBox(width: 100, height: 12, borderRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ShimmerBox(width: 50, height: 50, borderRadius: 12),
            ],
          ),
        );
      }),
    );
  }
}
