import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class BaseNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;
  final Widget? errorWidget;

  const BaseNetworkImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.borderRadius = 10,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    if (imageUrl.trim().isEmpty) {
      return _ImageErrorBox(
        height: height ?? 0,
        width: width ?? 0,
        borderRadius: radius,
        child: errorWidget,
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,

        // Loading shimmer
        placeholder: (context, url) {
          return _ImageShimmerBox(height: height!, width: width!);
        },

        // Error image
        errorWidget: (context, url, error) {
          return _ImageErrorBox(
            height: height ?? 0,
            width: width ?? 0,
            borderRadius: radius,
            child: errorWidget,
          );
        },
      ),
    );
  }
}

class _ImageShimmerBox extends StatelessWidget {
  final double height;
  final double width;

  const _ImageShimmerBox({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(height: height, width: width, color: Colors.white),
    );
  }
}

class _ImageErrorBox extends StatelessWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final Widget? child;

  const _ImageErrorBox({
    required this.height,
    required this.width,
    required this.borderRadius,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius,
      ),
      child:
          child ??
          Icon(
            Icons.image_not_supported_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: width < 80 ? 24 : 34,
          ),
    );
  }
}
