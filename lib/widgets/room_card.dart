import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
    final imageUrl = url.trim();

    Widget child;

    if (imageUrl.isEmpty) {
      child = const _ImagePlaceholder();
    } else if (imageUrl.startsWith('http')) {
      child = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: width,
        height: height,
        placeholder: (context, url) {
          return const _ImagePlaceholder(
            child: SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorWidget: (context, url, error) {
          return const _ImagePlaceholder();
        },
      );
    } else if (imageUrl.startsWith('/')) {
      child = Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
      );
    } else {
      child = Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
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
    return _roomIsUnavailableNow(room);
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
                  child: _RoomStatusBadge(
                    status: _roomCurrentStatus(room),
                    compact: compact,
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

class _RoomStatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const _RoomStatusBadge({required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final value = status.toLowerCase().trim();

    late final Color color;
    late final IconData icon;
    late final String text;

    if (value == 'occupied' ||
        value == 'in_meeting' ||
        value == 'in meeting' ||
        value == 'booked' ||
        value == 'busy') {
      color = context.appColors.danger;
      icon = Icons.event_busy_rounded;
      text = 'In Meeting';
    } else if (value == 'upcoming' || value == 'approved') {
      color = context.appColors.warning;
      icon = Icons.schedule_rounded;
      text = 'Upcoming';
    } else {
      color = context.appColors.success;
      icon = Icons.check_circle_rounded;
      text = 'Available';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.94),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.24),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 9 : 10,
              height: 1,
              fontWeight: FontWeight.w900,
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

String _roomCurrentStatus(Room room) {
  final value = room.status?.toLowerCase().trim();

  if (value == null || value.isEmpty) {
    return 'available';
  }

  if (value == 'ismeeting' ||
      value == 'is_meeting' ||
      value == 'inmeeting' ||
      value == 'in_meeting' ||
      value == 'occupied') {
    return 'in_meeting';
  }

  if (value == 'approved' || value == 'upcoming') {
    return 'upcoming';
  }

  return value;
}

bool _roomIsUnavailableNow(Room room) {
  final status = _roomCurrentStatus(room);

  return status == 'in_meeting' ||
      status == 'occupied' ||
      status == 'in meeting' ||
      status == 'booked' ||
      status == 'busy' ||
      status == 'unavailable' ||
      status == 'reserved' ||
      status == 'maintenance';
}

String _roomTitle(Room room) {
  final dynamic r = room;

  try {
    final value = r.name;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  } catch (_) {}

  try {
    final value = r.title;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  } catch (_) {}

  return 'Meeting Room';
}

String _roomLocation(Room room) {
  final dynamic r = room;

  try {
    final value = r.location;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  } catch (_) {}

  try {
    final value = r.address;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  } catch (_) {}

  try {
    final value = r.building;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  } catch (_) {}

  return 'Office Location';
}

String _roomImage(Room room) {
  final dynamic r = room;

  try {
    final value = r.imageUrl;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  } catch (_) {}

  try {
    final value = r.image;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  } catch (_) {}

  try {
    final value = r.photo;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  } catch (_) {}

  try {
    final value = r.thumbnail;
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString();
    }
  } catch (_) {}

  return '';
}

double _roomRating(Room room) {
  final dynamic r = room;

  try {
    final value = r.rating;
    if (value is num) return value.toDouble();

    final parsed = double.tryParse(value.toString());
    if (parsed != null) return parsed;
  } catch (_) {}

  return 4.9;
}

int _roomCapacity(Room room) {
  final dynamic r = room;

  try {
    final value = r.capacity;
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  } catch (_) {}

  try {
    final value = r.seats;
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  } catch (_) {}

  try {
    final value = r.maxCapacity;
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  } catch (_) {}

  return 0;
}

List<String> _roomTags(Room room) {
  // ✅ Get from API equipment first
  if (room.equipment.isNotEmpty) {
    return room.equipment
        .map((equipment) => equipment.name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  // Fallback: if backend later sends amenities
  final dynamic r = room;

  try {
    final value = r.amenities;
    if (value is Iterable) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  } catch (_) {}

  try {
    final value = r.facilities;
    if (value is Iterable) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  } catch (_) {}

  try {
    final value = r.tags;
    if (value is Iterable) {
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
  } catch (_) {}

  return ['No Equipment'];
}

class FeaturedSpaceCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const FeaturedSpaceCard({super.key, required this.room, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = _roomTitle(room);
    final location = _roomLocation(room);
    final imageUrl = _roomImage(room);
    // final rating = _roomRating(room);
    final capacity = _roomCapacity(room);
    final tags = _roomTags(room).take(2).toList();
    final currentStatus = _roomCurrentStatus(room);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 11,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  _RoomThumbnail(imageUrl: imageUrl),

                  // Positioned(
                  //   top: 6,
                  //   right: 6,
                  //   child: _RatingBadge(rating: rating),
                  // ),
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: _RoomStatusBadge(
                      status: currentStatus,
                      compact: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.titleMedium?.copyWith(
                        color: context.appColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: context.appColors.text,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.appText.bodySmall?.copyWith(
                              color: context.appColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags
                          .map((tag) => _MiniAmenityChip(text: tag))
                          .toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_alt_outlined,
                    size: 17,
                    color: context.appColors.text,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$capacity',
                    style: context.appText.bodySmall?.copyWith(
                      color: context.appColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomThumbnail extends StatelessWidget {
  final String imageUrl;

  const _RoomThumbnail({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 88,
      height: 100,
      decoration: BoxDecoration(
        color: context.appColors.primarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.meeting_room_outlined,
        color: AppConstants.primary,
        size: 34,
      ),
    );

    if (imageUrl.trim().isEmpty) {
      return placeholder;
    }

    Widget image;

    if (imageUrl.startsWith('http')) {
      image = Image.network(
        imageUrl,
        width: 88,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else if (imageUrl.startsWith('/')) {
      image = Image.file(
        File(imageUrl),
        width: 88,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    } else {
      image = Image.asset(
        imageUrl,
        width: 88,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    return ClipRRect(borderRadius: BorderRadius.circular(8), child: image);
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.orange, size: 13),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.text,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniAmenityChip extends StatelessWidget {
  final String text;

  const _MiniAmenityChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: context.appColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: context.appText.bodySmall?.copyWith(
          color: AppConstants.primary,
          fontSize: 8,
          letterSpacing: .8,
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
    final currentStatus = _roomCurrentStatus(room);
    final disabled = onBook == null || _roomIsUnavailableNow(room);
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

              // Positioned(
              //   top: 12,
              //   right: 12,
              //   child: RatingBadge(rating: room.rating),
              // ),
              Positioned(
                left: 12,
                top: 12,
                child: _RoomStatusBadge(status: currentStatus),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Room name and capacity
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

                // Location
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

                // Features
                // ✅ Equipment section
                if (room.featureNames.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Equipment:',
                    style: context.appText.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: context.appColors.text,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: room.featureNames
                        .take(3)
                        .map((name) => FeatureChip(name))
                        .toList(),
                  ),
                ],

                // // ✅ Equipment section
                // if (room.equipment.isNotEmpty) ...[
                //   const SizedBox(height: 12),
                //   Text(
                //     'Equipment:',
                //     style: context.appText.bodyMedium?.copyWith(
                //       fontWeight: FontWeight.w700,
                //       color: context.appColors.text,
                //     ),
                //   ),
                //   const SizedBox(height: 6),
                //   Wrap(
                //     spacing: 8,
                //     runSpacing: 8,
                //     children: room.equipment
                //         .map(
                //           (equipment) => Chip(
                //             label: Text(equipment.name),
                //             backgroundColor: Colors.blue.shade50,
                //             labelStyle: TextStyle(color: Colors.blue.shade800),
                //           ),
                //         )
                //         .toList(),
                //   ),
                // ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    // _RoomStatusBadge(status: currentStatus, compact: true),

                    // const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: disabled ? null : onBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                context.appColors.surfaceSoft,
                            disabledForegroundColor:
                                context.appColors.textMuted,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            disabled ? 'Unavailable' : 'Book Now',
                            style: context.appText.labelLarge?.copyWith(
                              color: disabled
                                  ? context.appColors.textMuted
                                  : Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
