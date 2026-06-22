import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Reusable animated shimmer wrapper for all loading skeletons in the app.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1250),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      child: widget.child,
      builder: (context, child) {
        final slide = _animationController.value * 3 - 1.5;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(slide - 1, 0),
              end: Alignment(slide + 1, 0),
              colors: const [
                Color(0xFFE7ECF3),
                Color(0xFFF7F9FC),
                Color(0xFFE7ECF3),
              ],
              stops: const [0.25, 0.50, 0.75],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// Base rectangle used to build screen-specific loading skeletons.
class AppShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadiusGeometry borderRadius;

  const AppShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE7ECF3),
        borderRadius: borderRadius,
      ),
    );
  }
}

/// Loading state for [RoomScreen]. It supports the home carousel layout
/// and the featured-room list layout.
class RoomScreenShimmer extends StatelessWidget {
  final bool showHomeHeader;

  const RoomScreenShimmer({super.key, required this.showHomeHeader});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: showHomeHeader
          ? const _HomeRoomsShimmer()
          : const _RoomListShimmer(),
    );
  }
}

class _HomeRoomsShimmer extends StatelessWidget {
  const _HomeRoomsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 22, 0, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: AppShimmerBox(
              height: 470,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: AppShimmerBox(
              width: 68,
              height: 10,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstants.pagePadding,
              40,
              AppConstants.pagePadding,
              20,
            ),
            child: AppShimmerBox(width: 188, height: 32),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.pagePadding),
            child: _CompactRoomSkeleton(),
          ),
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.pagePadding),
            child: _CompactRoomSkeleton(),
          ),
        ],
      ),
    );
  }
}

class _RoomListShimmer extends StatelessWidget {
  const _RoomListShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppConstants.pagePadding),
      child: Column(
        children: [
          _FeaturedRoomSkeleton(),
          SizedBox(height: 14),
          _FeaturedRoomSkeleton(),
          SizedBox(height: 14),
          _FeaturedRoomSkeleton(),
          SizedBox(height: 14),
          _FeaturedRoomSkeleton(),
        ],
      ),
    );
  }
}

class _CompactRoomSkeleton extends StatelessWidget {
  const _CompactRoomSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstants.border),
      ),
      child: const Row(
        children: [
          AppShimmerBox(width: 96, height: 88),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmerBox(width: 150, height: 17),
                SizedBox(height: 9),
                AppShimmerBox(width: 105, height: 12),
                Spacer(),
                AppShimmerBox(width: 80, height: 26),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedRoomSkeleton extends StatelessWidget {
  const _FeaturedRoomSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstants.border),
      ),
      child: const Row(
        children: [
          AppShimmerBox(width: 108, height: 102),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppShimmerBox(width: 170, height: 18),
                SizedBox(height: 10),
                AppShimmerBox(width: 122, height: 12),
                SizedBox(height: 8),
                AppShimmerBox(width: 92, height: 12),
                Spacer(),
                AppShimmerBox(width: 106, height: 27),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
