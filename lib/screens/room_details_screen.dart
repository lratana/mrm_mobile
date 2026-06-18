import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/app_palette.dart';

import '../models/room_model.dart';
import '../utils/constants.dart';

class RoomDetailsScreen extends StatefulWidget {
  final Room room;

  const RoomDetailsScreen({super.key, required this.room});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String? _buildImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;

    final cleanPath = path.trim();

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    return '${AppConstants.storageBaseUrl}/$cleanPath';
  }

  IconData _equipmentIcon(String name) {
    final text = name.toLowerCase();

    if (text.contains('wifi') || text.contains('internet')) {
      return Icons.wifi_rounded;
    }

    if (text.contains('projector') || text.contains('screen')) {
      return Icons.present_to_all_rounded;
    }

    if (text.contains('air') || text.contains('condition')) {
      return Icons.ac_unit_rounded;
    }

    if (text.contains('coffee') || text.contains('drink')) {
      return Icons.coffee_rounded;
    }

    if (text.contains('whiteboard') || text.contains('board')) {
      return Icons.draw_rounded;
    }

    if (text.contains('video') || text.contains('camera')) {
      return Icons.videocam_rounded;
    }

    return Icons.check_circle_outline_rounded;
  }

  _RoomStatusMeta _roomStatusMeta(String? rawStatus) {
    final status = rawStatus?.toLowerCase().trim() ?? 'available';

    switch (status) {
      case 'available':
        return _RoomStatusMeta(
          label: 'AVAILABLE',
          backgroundColor: context.appColors.success,
          foregroundColor: context.appColors.background,
          icon: Icons.check_circle_rounded,
          isAvailable: true,
        );

      case 'in_meeting':
      case 'occupied':
        return const _RoomStatusMeta(
          label: 'IN MEETING',
          backgroundColor: Color(0xFFFFEAC6),
          foregroundColor: Color(0xFFB66A00),
          icon: Icons.groups_rounded,
          isAvailable: false,
        );

      case 'maintenance':
        return const _RoomStatusMeta(
          label: 'MAINTENANCE',
          backgroundColor: Color(0xFFFFE4E4),
          foregroundColor: Color(0xFFC53B3B),
          icon: Icons.build_rounded,
          isAvailable: false,
        );

      case 'inactive':
      case 'unavailable':
        return const _RoomStatusMeta(
          label: 'UNAVAILABLE',
          backgroundColor: Color(0xFFFFE4E4),
          foregroundColor: Color(0xFFC53B3B),
          icon: Icons.cancel_outlined,
          isAvailable: false,
        );

      default:
        return const _RoomStatusMeta(
          label: 'UNAVAILABLE',
          backgroundColor: Color(0xFFFFE4E4),
          foregroundColor: Color(0xFFC53B3B),
          icon: Icons.help_outline_rounded,
          isAvailable: false,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    // Adjust these property names only if your Room model uses different names.
    final thumbnailUrl = _buildImageUrl(room.thumbnailPath);

    final imageUrls = <String>[
      if (thumbnailUrl != null) thumbnailUrl,
      ...room.images
          .map((image) => _buildImageUrl(image.imagePath))
          .whereType<String>(),
    ];

    final uniqueImages = imageUrls.toSet().toList();

    final equipment = room.equipment;
    final statusMeta = _roomStatusMeta(room.status);

    return Scaffold(
      backgroundColor: AppConstants.bg,
      appBar: AppBar(
        backgroundColor: AppConstants.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppConstants.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Room Details',
          style: TextStyle(
            color: AppConstants.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          _RoomImageCarousel(
            imageUrls: uniqueImages,
            pageController: _pageController,
            currentIndex: _currentImageIndex,
            statusMeta: statusMeta,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),

          const SizedBox(height: 24),

          Text(
            room.name,
            style: const TextStyle(
              color: AppConstants.text,
              fontSize: AppConstants.radiusLarge,
              height: 1.12,
              fontWeight: FontWeight.w900,
            ),
          ),

          if ((room.location ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppConstants.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    room.location!,
                    style: const TextStyle(
                      color: Color(0xFF4A575A),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          if ((room.description ?? '').trim().isNotEmpty) ...[
            const Text(
              'About This Room',
              style: TextStyle(
                color: AppConstants.text,
                fontSize: AppConstants.radiusLarge,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              room.description!,
              style: const TextStyle(
                color: Color(0xFF556164),
                fontSize: AppConstants.radiusMedium,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
          ],

          const Text(
            'Room Information',
            style: TextStyle(
              color: AppConstants.text,
              fontSize: AppConstants.radiusLarge,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.groups_rounded,
                  label: 'Capacity',
                  value: '${room.capacity} People',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _InfoCard(
                  icon: statusMeta.icon,
                  label: 'Status',
                  value: statusMeta.label,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            'Equipment & Facilities',
            style: TextStyle(
              color: AppConstants.text,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 16),

          if (equipment.isEmpty)
            const _NoEquipmentCard()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: equipment.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.55,
              ),
              itemBuilder: (context, index) {
                final item = equipment[index];

                return _EquipmentCard(
                  icon: _equipmentIcon(item.name),
                  label: item.name,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _RoomStatusMeta {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final bool isAvailable;

  const _RoomStatusMeta({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.isAvailable,
  });
}

class _RoomImageCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final PageController pageController;
  final int currentIndex;
  final _RoomStatusMeta statusMeta;
  final ValueChanged<int> onPageChanged;

  const _RoomImageCarousel({
    required this.imageUrls,
    required this.pageController,
    required this.currentIndex,
    required this.statusMeta,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (imageUrls.isEmpty)
              const _RoomImageFallback()
            else
              PageView.builder(
                controller: pageController,
                itemCount: imageUrls.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return const _RoomImageFallback();
                    },
                  );
                },
              ),

            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusMeta.backgroundColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(
                      statusMeta.icon,
                      size: 19,
                      color: statusMeta.foregroundColor,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      statusMeta.label,
                      style: TextStyle(
                        color: statusMeta.foregroundColor,
                        fontSize: 13,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (imageUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imageUrls.length, (index) {
                    final selected = index == currentIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: selected ? 11 : 8,
                      height: selected ? 11 : 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.white.withOpacity(0.55),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppConstants.primary, size: 27),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF788487),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppConstants.text,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EquipmentCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEBEFF1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppConstants.primary, size: 30),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF3E4A4D),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomImageFallback extends StatelessWidget {
  const _RoomImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8F1F8),
      alignment: Alignment.center,
      child: const Icon(
        Icons.meeting_room_rounded,
        size: 76,
        color: AppConstants.primary,
      ),
    );
  }
}

class _NoEquipmentCard extends StatelessWidget {
  const _NoEquipmentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECEE)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppConstants.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No equipment has been added for this room.',
              style: TextStyle(
                color: Color(0xFF647174),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
