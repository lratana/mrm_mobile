import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/app_palette.dart';

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
  final VoidCallback onBook;

  const FeaturedHeroRoomCard({
    super.key,
    required this.room,
    required this.onBook,
  });

  bool get _isUnavailable {
    final status = room.status.toString().toLowerCase().trim();

    return status == 'booked' ||
        status == 'busy' ||
        status == 'unavailable' ||
        status == 'reserved' ||
        !room.isBookable;
  }

  @override
  Widget build(BuildContext context) {
    final String? roomImageUrl = room.imageUrl;
    final hasImage = roomImageUrl != null && roomImageUrl.trim().isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 330;
        final veryCompact = constraints.maxWidth < 290;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.network(
                    roomImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _HeroImageFallback();
                    },
                  )
                else
                  const _HeroImageFallback(),

                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.10),
                        Colors.black.withOpacity(0.18),
                        Colors.black.withOpacity(0.78),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: compact ? 12 : 16,
                  top: compact ? 12 : 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 9 : 11,
                      vertical: compact ? 5 : 7,
                    ),
                    decoration: BoxDecoration(
                      color: _isUnavailable
                          ? Colors.red.withOpacity(0.92)
                          : Colors.green.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _isUnavailable ? 'Booked' : 'Available',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: compact ? 12 : 16,
                  right: compact ? 12 : 16,
                  bottom: compact ? 12 : 16,
                  child: veryCompact
                      ? _CompactHeroContent(
                          room: room,
                          isUnavailable: _isUnavailable,
                          onBook: onBook,
                        )
                      : _StandardHeroContent(
                          room: room,
                          compact: compact,
                          isUnavailable: _isUnavailable,
                          onBook: onBook,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroImageFallback extends StatelessWidget {
  const _HeroImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.primary.withOpacity(0.14),
      alignment: Alignment.center,
      child: const Icon(
        Icons.meeting_room_rounded,
        size: 60,
        color: AppConstants.primary,
      ),
    );
  }
}

class _StandardHeroContent extends StatelessWidget {
  final Room room;
  final bool compact;
  final bool isUnavailable;
  final VoidCallback onBook;

  const _StandardHeroContent({
    required this.room,
    required this.compact,
    required this.isUnavailable,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _HeroRoomInformation(room: room, compact: compact),
        ),
        const SizedBox(width: 10),
        _HeroBookButton(
          compact: compact,
          isUnavailable: isUnavailable,
          onBook: onBook,
        ),
      ],
    );
  }
}

class _CompactHeroContent extends StatelessWidget {
  final Room room;
  final bool isUnavailable;
  final VoidCallback onBook;

  const _CompactHeroContent({
    required this.room,
    required this.isUnavailable,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroRoomInformation(room: room, compact: true),
        const SizedBox(height: 10),
        _HeroBookButton(
          compact: true,
          expand: true,
          isUnavailable: isUnavailable,
          onBook: onBook,
        ),
      ],
    );
  }
}

class _HeroRoomInformation extends StatelessWidget {
  final Room room;
  final bool compact;

  const _HeroRoomInformation({required this.room, required this.compact});

  @override
  Widget build(BuildContext context) {
    final locationText = room.location.toString().trim();
    final capacityText = '${room.capacity} seats';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          room.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 18 : 21,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: Colors.white70,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                locationText.isEmpty ? 'No location' : locationText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.groups_outlined, size: 15, color: Colors.white70),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                capacityText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroBookButton extends StatelessWidget {
  final bool compact;
  final bool expand;
  final bool isUnavailable;
  final VoidCallback onBook;

  const _HeroBookButton({
    required this.compact,
    required this.isUnavailable,
    required this.onBook,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: compact ? 40 : 44,
      child: ElevatedButton(
        onPressed: isUnavailable ? null : onBook,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primary,
          disabledBackgroundColor: Colors.grey.withOpacity(0.85),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: compact ? 11 : 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isUnavailable ? 'Booked' : 'Book Now',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 12 : 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 370;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(compact ? 12 : 14),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.appColors.border),
            boxShadow: [
              BoxShadow(
                color: context.appColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: compact
              ? _CompactRoomVerticalLayout(
                  room: room,
                  isBookable: isBookable,
                  onBook: onBook,
                )
              : _CompactRoomHorizontalLayout(
                  room: room,
                  isBookable: isBookable,
                  onBook: onBook,
                ),
        );
      },
    );
  }
}

class _CompactRoomHorizontalLayout extends StatelessWidget {
  final Room room;
  final bool isBookable;
  final VoidCallback? onBook;

  const _CompactRoomHorizontalLayout({
    required this.room,
    required this.isBookable,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoomImageBox(
          url: room.imageUrl,
          width: 86,
          height: 86,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(width: 14),
        Expanded(child: _CompactRoomInfo(room: room)),
        const SizedBox(width: 10),
        _CompactBookButton(isBookable: isBookable, onBook: onBook),
      ],
    );
  }
}

class _CompactRoomVerticalLayout extends StatelessWidget {
  final Room room;
  final bool isBookable;
  final VoidCallback? onBook;

  const _CompactRoomVerticalLayout({
    required this.room,
    required this.isBookable,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            RoomImageBox(
              url: room.imageUrl,
              width: 74,
              height: 74,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 12),
            Expanded(child: _CompactRoomInfo(room: room, compact: true)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _CompactBookButton(isBookable: isBookable, onBook: onBook),
        ),
      ],
    );
  }
}

class _CompactRoomInfo extends StatelessWidget {
  final Room room;
  final bool compact;

  const _CompactRoomInfo({required this.room, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          room.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.appText.titleMedium?.copyWith(
            color: context.appColors.text,
            fontSize: compact ? 16 : 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        _CompactRoomInfoRow(
          icon: Icons.location_on_outlined,
          text: room.location.trim().isEmpty ? 'No location' : room.location,
        ),
        const SizedBox(height: 5),
        _CompactRoomInfoRow(
          icon: Icons.groups_outlined,
          text: '${room.capacity} People',
        ),
      ],
    );
  }
}

class _CompactRoomInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CompactRoomInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.appColors.textMuted),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactBookButton extends StatelessWidget {
  final bool isBookable;
  final VoidCallback? onBook;

  const _CompactBookButton({required this.isBookable, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isBookable ? onBook : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: context.appColors.surfaceSoft,
        disabledForegroundColor: context.appColors.textMuted,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
      child: Text(
        isBookable ? 'Book' : 'Busy',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.appText.labelLarge?.copyWith(
          color: isBookable ? Colors.white : context.appColors.textMuted,
          fontWeight: FontWeight.w800,
        ),
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
    final statusText = room.status?.trim().isNotEmpty == true
        ? room.status!
        : 'Busy';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      color: context.appColors.surface.withOpacity(0.94),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.appColors.border),
                    ),
                    child: Text(
                      statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.bodySmall?.copyWith(
                        color: context.appColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        room.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appText.titleLarge?.copyWith(
                          color: context.appColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.groups_outlined,
                      size: 16,
                      color: context.appColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${room.capacity}',
                      style: context.appText.bodySmall?.copyWith(
                        color: context.appColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 7),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: context.appColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        room.location.trim().isEmpty
                            ? 'No location'
                            : room.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appText.bodyMedium?.copyWith(
                          color: context.appColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                if (room.featureNames.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: room.featureNames
                        .take(3)
                        .map((name) => FeatureChip(name))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: disabled ? null : onBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: context.appColors.surfaceSoft,
                      disabledForegroundColor: context.appColors.textMuted,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      disabled ? 'Booked' : 'Book Now',
                      style: context.appText.labelLarge?.copyWith(
                        color: disabled
                            ? context.appColors.textMuted
                            : Colors.white,
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
