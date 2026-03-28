import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;

  const AppShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // We use slightly darker base/highlight colors for dark mode context
    final baseColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.6);
    final highlightColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white, // Color doesn't matter, just needs to be opaque for shimmer mapping
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
    );
  }

  // Common sizes / variants that might be useful:
  static Widget textLine(BuildContext context, {double width = 100, double height = 14}) {
    return AppShimmer(width: width, height: height, borderRadius: 4);
  }
}
