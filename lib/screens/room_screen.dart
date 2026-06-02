import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/notification_controller.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/screens/theme_settings_screen.dart';
import 'package:flutter_application_1/utils/app_palette.dart';
import 'package:flutter_application_1/utils/app_shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/booking_controller.dart';
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
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = TextEditingController();
  final PageController pageController = PageController(viewportFraction: .92);

  int currentHero = 0;

  bool availabilityFilterEnabled = false;
  DateTime filterDate = DateTime.now();
  TimeOfDay filterStartTime = const TimeOfDay(hour: 9, minute: 0);
  int filterDurationHours = 2;

  @override
  void dispose() {
    searchController.dispose();
    pageController.dispose();
    super.dispose();
  }

  DateTime get filterStartDateTime {
    return DateTime(
      filterDate.year,
      filterDate.month,
      filterDate.day,
      filterStartTime.hour,
      filterStartTime.minute,
    );
  }

  DateTime get filterEndDateTime {
    return filterStartDateTime.add(Duration(hours: filterDurationHours));
  }

  bool _isRoomBooked(Room room) {
    final status = room.status.toString().toLowerCase().trim();

    return status == 'booked' ||
        status == 'busy' ||
        status == 'unavailable' ||
        status == 'reserved' ||
        !room.isBookable;
  }

  void _openBooking(Room room) {
    if (_isRoomBooked(room)) {
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

  Future<void> _filterAvailableRooms() async {
    setState(() {
      availabilityFilterEnabled = true;
    });

    await context.read<BookingController>().fetchAvailableRooms(
      start: filterStartDateTime,
      end: filterEndDateTime,
    );
  }

  Future<void> _clearAvailabilityFilter() async {
    setState(() {
      availabilityFilterEnabled = false;
    });

    await context.read<RoomController>().fetchRooms(refresh: true);
  }

  void _openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: context.appColors.background,
      drawer: const _AppDrawer(),
      body: Consumer2<RoomController, BookingController>(
        builder: (context, roomController, bookingController, _) {
          final rooms = availabilityFilterEnabled
              ? bookingController.availableRooms
              : roomController.rooms;

          final loading = availabilityFilterEnabled
              ? bookingController.loading
              : roomController.loading;

          return RefreshIndicator(
            color: AppConstants.primary,
            onRefresh: () async {
              if (availabilityFilterEnabled) {
                await _filterAvailableRooms();
              } else {
                await roomController.fetchRooms(refresh: true);
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (widget.showHomeHeader)
                  SliverToBoxAdapter(
                    child: _TopToolbar(
                      controller: roomController,
                      onMenuTap: _openDrawer,
                    ),
                  )
                else
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: context.appColors.background,
                    foregroundColor: context.appColors.text,
                    surfaceTintColor: Colors.transparent,
                    elevation: 0,
                    title: Text(
                      'Featured Rooms',
                      style: context.appText.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
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
                        setState(() {
                          availabilityFilterEnabled = false;
                        });

                        roomController.fetchRooms(q: q.trim(), refresh: true);
                      },
                    ),
                  ),
                ),

                if (loading && rooms.isEmpty)
                  SliverToBoxAdapter(
                    child: RoomScreenShimmer(
                      showHomeHeader: widget.showHomeHeader,
                    ),
                  )
                else if (rooms.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        availabilityFilterEnabled
                            ? 'No available rooms for selected date and time'
                            : 'No rooms found',
                        textAlign: TextAlign.center,
                        style: context.appText.bodyMedium?.copyWith(
                          color: context.appColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else if (widget.showHomeHeader && !availabilityFilterEnabled)
                  ..._homeSlivers(context, roomController)
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(AppConstants.pagePadding),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final room = rooms[index];

                        return FeaturedRoomListCard(
                          room: room,
                          onBook: () => _openBooking(room),
                        );
                      }, childCount: rooms.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.pagePadding,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final double heroHeight;

                  if (width < 330) {
                    heroHeight = 290;
                  } else if (width < 380) {
                    heroHeight = 275;
                  } else if (width < 500) {
                    heroHeight = 260;
                  } else {
                    heroHeight = 280;
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: heroHeight,
                    child: featured.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: context.appColors.surface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: context.appColors.border,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'No featured rooms',
                              style: context.appText.bodyMedium?.copyWith(
                                color: context.appColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : PageView.builder(
                            controller: pageController,
                            itemCount: featured.length,
                            onPageChanged: (index) {
                              setState(() {
                                currentHero = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final room = featured[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: FeaturedHeroRoomCard(
                                  room: room,
                                  onBook: () => _openBooking(room),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

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
                            : context.appColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pagePadding,
                34,
                AppConstants.pagePadding,
                20,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 350;

                  return Text(
                    'Available Rooms',
                    style: context.appText.displaySmall?.copyWith(
                      fontSize: compact ? 24 : 30,
                      fontWeight: FontWeight.w900,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      if (available.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: Center(
              child: Text(
                'No available rooms',
                style: context.appText.bodyMedium?.copyWith(
                  color: context.appColors.textMuted,
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

              return CompactRoomCard(
                room: room,
                onBook: () => _openBooking(room),
              );
            }, childCount: available.length),
          ),
        ),

      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  Future<void> _logout(BuildContext context) async {
    Navigator.pop(context);

    await context.read<AuthController>().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.pop(context);

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;

    String name = 'User';
    String email = '';
    String? photoUrl;

    try {
      final json = (user as dynamic?)?.toJson();

      if (json is Map) {
        name = json['name']?.toString() ?? 'User';
        email = json['email']?.toString() ?? '';
        photoUrl = json['photo']?.toString();
      }
    } catch (_) {}

    final safePhotoUrl = photoUrl != null && photoUrl.trim().isNotEmpty
        ? photoUrl
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=0D8ABC&color=fff';

    return Drawer(
      backgroundColor: context.appColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(color: AppConstants.primary),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _openPage(context, const ProfileScreen()),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(safePhotoUrl),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 23,
                            width: 23,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppConstants.primary,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    title: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    onTap: () => _openPage(context, const ProfileScreen()),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: 'Appearance',
                    onTap: () =>
                        _openPage(context, const ThemeSettingsScreen()),
                  ),
                  Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: const Icon(
                        Icons.more_horiz,
                        color: AppConstants.primary,
                      ),
                      iconColor: AppConstants.primary,
                      collapsedIconColor: context.appColors.textMuted,
                      title: Text(
                        'Other',
                        style: context.appText.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      childrenPadding: const EdgeInsets.only(left: 18),
                      children: [
                        _DrawerItem(
                          icon: Icons.info_outline,
                          title: 'About App',
                          onTap: () => _openPage(context, const AboutScreen()),
                        ),
                        _DrawerItem(
                          icon: Icons.help_outline,
                          title: 'Help & Support',
                          onTap: () => _openPage(context, const HelpScreen()),
                        ),
                        _DrawerItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () =>
                              _openPage(context, const PrivacyScreen()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: context.appColors.border),

            _DrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              color: context.appColors.danger,
              onTap: () => _logout(context),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? imageUrl;
  File? pickedImage;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthController>().user;

    try {
      final json = (user as dynamic?)?.toJson();

      if (json is Map) {
        nameController.text = json['name']?.toString() ?? '';
        emailController.text = json['email']?.toString() ?? '';
        phoneController.text =
            json['phone_number']?.toString() ?? json['phone']?.toString() ?? '';

        imageUrl =
            json['photo']?.toString() ??
            json['profile_image']?.toString() ??
            json['avatar']?.toString();
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool _isPickingImage = false;

  Future<void> _pickImage() async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return; // user canceled

      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (picked != null && mounted) {
        setState(() {
          pickedImage = File(picked.path);
        });
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    } finally {
      if (mounted) _isPickingImage = false;
    }
  }

  ImageProvider? _profileImageProvider() {
    if (pickedImage != null) {
      return FileImage(pickedImage!);
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    }

    return null;
  }

  Future<void> _saveProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter name')));
      return;
    }

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter email')));
      return;
    }

    final ok = await context.read<AuthController>().updateProfile(
      name: name,
      email: email,
      phoneNumber: phone,
      imagePath: pickedImage?.path,
    );

    if (!mounted) return;

    final controller = context.read<AuthController>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Profile updated successfully'
              : controller.error ?? 'Failed to update profile',
        ),
      ),
    );

    if (ok) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final imageProvider = _profileImageProvider();

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: context.appText.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: context.appColors.border),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: context.appColors.primarySoft,
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(
                              Icons.person,
                              color: AppConstants.primary,
                              size: 58,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppConstants.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.appColors.surface,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _ProfileInput(
                  controller: nameController,
                  label: 'Name',
                  icon: Icons.person_outline,
                ),

                const SizedBox(height: 14),

                _ProfileInput(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                _ProfileInput(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: auth.loading ? null : _saveProfile,
                    icon: auth.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save_outlined, color: Colors.white),
                    label: const Text('Update Profile'),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: auth.loading
                        ? null
                        : () async {
                            await context.read<AuthController>().logout();

                            if (!context.mounted) return;

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (_) => false,
                            );
                          },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.danger,
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

class _ProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const _ProfileInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: context.appText.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstants.primary),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? context.appColors.text;

    return ListTile(
      leading: Icon(icon, color: color ?? AppConstants.primary),
      title: Text(
        title,
        style: context.appText.bodyMedium?.copyWith(
          color: itemColor,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 18,
        color: context.appColors.textMuted,
      ),
      onTap: onTap,
    );
  }
}

class _TopToolbar extends StatelessWidget {
  final RoomController controller;
  final VoidCallback onMenuTap;

  const _TopToolbar({required this.controller, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<NotificationController>().unreadCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        final veryCompact = constraints.maxWidth < 340;

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            left: compact ? 14 : 28,
            right: compact ? 14 : 28,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: context.appColors.background,
            boxShadow: [
              BoxShadow(
                color: context.appColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _CircleIcon(icon: Icons.menu, onTap: onMenuTap, compact: compact),

              const Spacer(),

              if (!veryCompact) ...[
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 9 : 14,
                    vertical: compact ? 7 : 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.language,
                        size: compact ? 17 : 20,
                        color: AppConstants.primary,
                      ),
                      SizedBox(width: compact ? 4 : 8),
                      Text(
                        compact ? 'EN' : 'EN 🇺🇸',
                        style: context.appText.bodyMedium?.copyWith(
                          fontSize: compact ? 12 : 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: compact ? 6 : 18),
              ],

              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Notifications',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.notifications_none,
                      color: AppConstants.primary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.danger,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.appColors.background,
                          ),
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool compact;

  const _CircleIcon({required this.icon, this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 44.0 : 52.0;

    return Material(
      color: context.appColors.surface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: AppConstants.primary,
            size: compact ? 25 : 30,
          ),
        ),
      ),
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
          style: context.appText.bodyMedium,
          decoration: const InputDecoration(
            hintText: 'Search workspaces, buildings...',
            prefixIcon: Icon(Icons.search),
            contentPadding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        const SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(text: 'Sort by', selected: true, icon: Icons.tune),
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
    final backgroundColor = selected
        ? AppConstants.primary
        : context.appColors.primarySoft;

    final foregroundColor = selected ? Colors.white : context.appColors.text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: selected ? null : Border.all(color: context.appColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foregroundColor, size: 16),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: context.appText.bodyMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: 'Settings',
      icon: Icons.settings_outlined,
      description: 'Manage app preferences and account settings.',
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: 'About App',
      icon: Icons.info_outline,
      description: 'Meeting room booking mobile application.',
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: 'Help & Support',
      icon: Icons.help_outline,
      description: 'Get help for booking, cancellation, and account issues.',
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      description: 'Review privacy and data usage information.',
    );
  }
}

class _SimplePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const _SimplePage({
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(
          title,
          style: context.appText.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(AppConstants.pagePadding),
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.appColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 4),
              Icon(icon, color: AppConstants.primary, size: 54),
              const SizedBox(height: 14),
              Text(
                title,
                style: context.appText.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: context.appText.bodyMedium?.copyWith(
                  color: context.appColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
