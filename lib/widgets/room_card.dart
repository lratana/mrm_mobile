import 'package:flutter/material.dart';

import '../models/room_model.dart';
import '../utils/constants.dart';

class RoomImageBox extends StatelessWidget {
  final String url;
  final double height;
  final double width;
  final BorderRadius borderRadius;

  const RoomImageBox({
    super.key,
    required this.url,
    this.height = 160,
    this.width = double.infinity,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (url.trim().isEmpty) {
      child = const _ImagePlaceholder();
    } else {
      child = Image.network(
        url.trim(),
        fit: BoxFit.cover,
        width: width,
        height: height,
        loadingBuilder: (context, imageChild, loadingProgress) {
          if (loadingProgress == null) return imageChild;

          return const _ImagePlaceholder(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return const _ImagePlaceholder();
        },
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(height: height, width: width, child: child),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final Widget? child;

  const _ImagePlaceholder({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child:
          child ??
          const Icon(
            Icons.image_not_supported_outlined,
            color: AppConstants.muted,
          ),
    );
  }
}

class FeatureChip extends StatelessWidget {
  final String text;

  const FeatureChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.chipBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppConstants.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
        ),
      ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  final double rating;

  const RatingBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .95),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppConstants.primary, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppConstants.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedHeroRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onBook;

  const FeaturedHeroRoomCard({
    super.key,
    required this.room,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final isBookable = room.isBookable;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              RoomImageBox(
                url: room.imageUrl,
                height: 230,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              Positioned(
                right: 18,
                top: 18,
                child: RatingBadge(rating: room.rating),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppConstants.muted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        room.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          color: AppConstants.muted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _InfoPill(
                      icon: Icons.groups,
                      text: '${room.capacity} People',
                    ),
                    const _InfoPill(icon: Icons.wifi, text: 'Fiber Internet'),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isBookable ? onBook : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primary,
                      disabledBackgroundColor: AppConstants.softBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      isBookable ? 'Book Now' : 'Currently Busy',
                      style: TextStyle(
                        fontSize: 22,
                        color: isBookable ? Colors.white : AppConstants.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppConstants.softBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppConstants.primary, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppConstants.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompactRoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onBook;

  const CompactRoomCard({super.key, required this.room, required this.onBook});

  @override
  Widget build(BuildContext context) {
    final isBookable = room.isBookable;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstants.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          RoomImageBox(
            url: room.imageUrl,
            width: 92,
            height: 92,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppConstants.muted,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        room.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppConstants.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.groups,
                      size: 18,
                      color: AppConstants.muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${room.capacity} People',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppConstants.muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: isBookable ? onBook : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primary,
              disabledBackgroundColor: AppConstants.softBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            child: Text(
              isBookable ? 'Book' : 'Busy',
              style: TextStyle(
                color: isBookable ? Colors.white : AppConstants.muted,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedRoomListCard extends StatelessWidget {
  final Room room;
  final VoidCallback? onBook;

  const FeaturedRoomListCard({
    super.key,
    required this.room,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !room.isBookable;

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              RoomImageBox(
                url: room.imageUrl,
                height: 210,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: RatingBadge(rating: room.rating),
              ),
              if (disabled)
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      room.status ?? 'Busy',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.primaryDark,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.groups,
                      size: 16,
                      color: AppConstants.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${room.capacity}',
                      style: const TextStyle(
                        color: AppConstants.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: AppConstants.muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        room.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppConstants.text),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (room.featureNames.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: room.featureNames
                          .take(3)
                          .map((name) => FeatureChip(name))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: disabled ? null : onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primary,
                      disabledBackgroundColor: AppConstants.softBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      disabled ? 'Booked' : 'Book Now',
                      style: TextStyle(
                        color: disabled ? AppConstants.muted : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
