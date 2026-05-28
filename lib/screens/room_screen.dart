import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/room_controller.dart';
import '../models/room_model.dart';
import '../utils/constants.dart';
import '../widgets/room_card.dart';
import 'login_screen.dart';
import 'new_booking_screen.dart';

class RoomScreen extends StatefulWidget {
  final bool showHomeHeader;

  const RoomScreen({super.key, this.showHomeHeader = false});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final TextEditingController searchController = TextEditingController();

  final PageController pageController = PageController(viewportFraction: .92);

  int currentHero = 0;

  @override
  void dispose() {
    searchController.dispose();
    pageController.dispose();
    super.dispose();
  }

  bool _isRoomBooked(Room room) {
    return room.status?.toLowerCase() == 'booked' ||
        room.status?.toLowerCase() == 'busy' ||
        !room.isBookable;
  }

  void _openBooking(Room room) {
    final isBooked = _isRoomBooked(room);

    if (isBooked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This room is already booked')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewBookingScreen(room: room)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoomController>(
      builder: (context, controller, _) {
        final rooms = controller.rooms;

        return RefreshIndicator(
          color: AppConstants.primary,
          onRefresh: () => controller.fetchRooms(refresh: true),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (widget.showHomeHeader)
                SliverToBoxAdapter(child: _TopToolbar(controller: controller))
              else
                const SliverAppBar(
                  pinned: true,
                  backgroundColor: AppConstants.bg,
                  foregroundColor: AppConstants.primaryDark,
                  elevation: 0,
                  title: Text(
                    'Featured Rooms',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.pagePadding,
                  10,
                  AppConstants.pagePadding,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: _SearchAndFilters(
                    controller: searchController,
                    onSubmitted: (q) {
                      controller.fetchRooms(q: q.trim(), refresh: true);
                    },
                  ),
                ),
              ),

              if (controller.loading && rooms.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppConstants.primary,
                    ),
                  ),
                )
              else if (rooms.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No rooms found',
                      style: TextStyle(
                        color: AppConstants.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (widget.showHomeHeader)
                ..._homeSlivers(context, controller)
              else
                SliverPadding(
                  padding: const EdgeInsets.all(AppConstants.pagePadding),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final room = rooms[index];

                      final isBooked = _isRoomBooked(room);

                      return FeaturedRoomListCard(
                        room: room,
                        onBook: isBooked ? null : () => _openBooking(room),
                      );
                    }, childCount: rooms.length),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _homeSlivers(BuildContext context, RoomController controller) {
    final featured = controller.featuredRooms;

    final available = controller.availableRooms.take(4).toList();

    final safeHeroIndex = featured.isEmpty
        ? 0
        : currentHero.clamp(0, featured.length - 1).toInt();

    return [
      SliverToBoxAdapter(
        child: Column(
          children: [
            const SizedBox(height: 22),

            SizedBox(
              height: 470,
              child: featured.isEmpty
                  ? const Center(
                      child: Text(
                        'No featured rooms',
                        style: TextStyle(
                          color: AppConstants.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : PageView.builder(
                      controller: pageController,
                      onPageChanged: (index) {
                        setState(() {
                          currentHero = index;
                        });
                      },
                      itemCount: featured.length,
                      itemBuilder: (context, index) {
                        final room = featured[index];

                        final isBooked = _isRoomBooked(room);

                        return FeaturedHeroRoomCard(
                          room: room,
                          onBook: isBooked ? null : () => _openBooking(room),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            if (featured.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  featured.length > 5 ? 5 : featured.length,
                  (index) {
                    final active = index == safeHeroIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 28 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: active
                            ? AppConstants.primary
                            : AppConstants.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pagePadding,
                42,
                AppConstants.pagePadding,
                20,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Available Rooms',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppConstants.text,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoomScreen()),
                      );
                    },
                    child: const Text(
                      'See More',
                      style: TextStyle(
                        color: AppConstants.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      if (available.isEmpty)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppConstants.pagePadding),
            child: Center(
              child: Text(
                'No available rooms',
                style: TextStyle(
                  color: AppConstants.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.pagePadding,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final room = available[index];

              final isBooked = _isRoomBooked(room);

              return CompactRoomCard(
                room: room,
                onBook: isBooked ? null : () => _openBooking(room),
              );
            }, childCount: available.length),
          ),
        ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }
}

class _TopToolbar extends StatelessWidget {
  final RoomController controller;

  const _TopToolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 28,
        right: 28,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppConstants.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const _CircleIcon(icon: Icons.menu),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppConstants.border),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.language, color: AppConstants.primary),
                SizedBox(width: 8),
                Text('EN 🇺🇸', style: TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(width: 18),
          const Icon(
            Icons.notifications_none,
            color: AppConstants.primary,
            size: 20,
          ),
          const SizedBox(width: 18),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthController>().logout();

              if (!context.mounted) {
                return;
              }

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (_) => false,
              );
            },
            icon: const Icon(Icons.logout, color: AppConstants.primary),
          ),
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;

  const _CircleIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.white,
      child: Icon(icon, color: AppConstants.primary, size: 30),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const _SearchAndFilters({
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search workspaces, buildings...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppConstants.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppConstants.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppConstants.primary,
                width: 1.4,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(text: 'Sort by', selected: true, icon: Icons.tune),
              SizedBox(width: 10),
              _FilterChip(text: 'Price'),
              SizedBox(width: 10),
              _FilterChip(text: 'Capacity'),
              SizedBox(width: 10),
              _FilterChip(text: 'Rating'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String text;
  final bool selected;
  final IconData? icon;

  const _FilterChip({required this.text, this.selected = false, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: selected ? AppConstants.primary : AppConstants.softBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: selected ? Colors.white : AppConstants.text,
              size: 16,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : AppConstants.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
