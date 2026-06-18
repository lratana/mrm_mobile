import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/controllers/notification_controller.dart';
import 'package:flutter_application_1/screens/booking_screen.dart';
import 'package:flutter_application_1/screens/booking_search_screen.dart';
import 'package:flutter_application_1/screens/calendar_screen.dart';
import 'package:flutter_application_1/screens/notification_screen.dart';
import 'package:flutter_application_1/screens/settings_screen.dart';
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

                if (!widget.showHomeHeader)
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
    final rooms = controller.rooms.isNotEmpty
        ? controller.rooms
        : controller.featuredRooms;

    final unreadCount = context.watch<NotificationController>().unreadCount;

    return [
      SliverToBoxAdapter(child: _HomeShortcutGrid(unreadCount: unreadCount)),

      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.pagePadding,
          22,
          AppConstants.pagePadding,
          14,
        ),
        sliver: SliverToBoxAdapter(
          child: Text(
            'Available Meeting Rooms',
            style: context.appText.headlineSmall?.copyWith(
              color: context.appColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),

      if (rooms.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.pagePadding),
            child: Center(
              child: Text(
                'No rooms found',
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
              final room = rooms[index];
              debugPrint("Room:${room.status}");
              return FeaturedSpaceCard(
                room: room,
                onTap: () {
                  //onTap
                },
              );
            }, childCount: rooms.length),
          ),
        ),

      const SliverToBoxAdapter(child: SizedBox(height: 26)),
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
                    title: 'Settings',
                    onTap: () => _openPage(context, const SettingsScreen()),
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
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? imageUrl;
  File? pickedImage;

  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
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
            json['avatar']?.toString() ??
            json['image']?.toString();
      }
    } catch (_) {
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      imageUrl = null;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _showMessage({required String message, required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: success
              ? Colors.green.shade700
              : Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(
                success
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    _isPickingImage = true;

    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: context.appColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library_rounded,
                      color: AppConstants.primary,
                    ),
                    title: const Text(
                      'Choose from Gallery',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppConstants.primary,
                    ),
                    title: const Text(
                      'Take Photo',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (source == null) return;

      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (picked == null) return;
      if (!mounted) return;

      setState(() {
        pickedImage = File(picked.path);
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage(message: 'Image pick error: $e', success: false);
    } finally {
      _isPickingImage = false;
    }
  }

  ImageProvider? _profileImageProvider() {
    if (pickedImage != null) {
      return FileImage(pickedImage!);
    }

    final url = imageUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }

    return null;
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthController>();

    if (auth.loading) return;

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final ok = await auth.updateProfile(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      imagePath: pickedImage?.path,
    );

    if (!mounted) return;

    if (ok) {
      _showMessage(
        message: auth.successMessage ?? 'Profile updated successfully.',
        success: true,
      );

      setState(() {
        pickedImage = null;
      });

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;

      Navigator.pop(context);
    } else {
      _showMessage(
        message: auth.error ?? 'Failed to update profile.',
        success: false,
      );
    }
  }

  Future<void> _logout() async {
    final auth = context.read<AuthController>();

    if (auth.loading) return;

    await auth.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final imageProvider = _profileImageProvider();

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        foregroundColor: context.appColors.text,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Profile',
          style: context.appText.titleLarge?.copyWith(
            color: context.appColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.circular(22),
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
                        child: Material(
                          color: AppConstants.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: auth.loading ? null : _pickImage,
                            customBorder: const CircleBorder(),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: context.appColors.surface,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
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
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.isEmpty) {
                        return 'Please enter name';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  _ProfileInput(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.isEmpty) {
                        return 'Please enter email';
                      }

                      if (!text.contains('@')) {
                        return 'Please enter valid email';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  _ProfileInput(
                    controller: phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final text = value?.trim() ?? '';

                      if (text.isEmpty) {
                        return 'Please enter phone number';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: auth.loading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: context.appColors.surfaceSoft,
                        disabledForegroundColor: context.appColors.textMuted,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: auth.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text(
                        'Update Profile',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: auth.loading ? null : _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Logout',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _ProfileInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: context.appText.bodyMedium?.copyWith(
        color: context.appColors.text,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstants.primary),
        filled: true,
        fillColor: context.appColors.surfaceSoft,
        labelStyle: context.appText.bodyMedium?.copyWith(
          color: context.appColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.danger, width: 1.4),
        ),
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
    final user = context.watch<AuthController>().user;

    String name = 'User';
    String? photoUrl;

    try {
      final json = (user as dynamic?)?.toJson();

      if (json is Map) {
        name = json['name']?.toString() ?? 'User';
        photoUrl =
            json['photo']?.toString() ??
            json['profile_image']?.toString() ??
            json['avatar']?.toString();
      }
    } catch (_) {}

    final safePhotoUrl = photoUrl != null && photoUrl!.trim().isNotEmpty
        ? photoUrl!
        : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=004D57&color=fff';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 18,
        right: 18,
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: context.appColors.background,
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // InkWell(
          //   borderRadius: BorderRadius.circular(12),
          //   onTap: onMenuTap,
          //   child: const Padding(
          //     padding: EdgeInsets.all(8),
          //     child: Icon(
          //       Icons.menu_rounded,
          //       color: AppConstants.primary,
          //       size: 26,
          //     ),
          //   ),
          // ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Meeting Rooms',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.appText.titleLarge?.copyWith(
                color: AppConstants.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.appColors.primarySoft,
                  backgroundImage: NetworkImage(safePhotoUrl),
                ),

                // if (unreadCount > 0)
                //   Positioned(
                //     top: -8,
                //     right: -8,
                //     child: Container(
                //       constraints: const BoxConstraints(
                //         minWidth: 20,
                //         minHeight: 20,
                //       ),
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 5,
                //         vertical: 2,
                //       ),
                //       decoration: BoxDecoration(
                //         color: context.appColors.danger,
                //         borderRadius: BorderRadius.circular(999),
                //         border: Border.all(
                //           color: context.appColors.background,
                //           width: 2,
                //         ),
                //       ),
                //       alignment: Alignment.center,
                //       child: Text(
                //         unreadCount > 99 ? '99+' : '$unreadCount',
                //         style: const TextStyle(
                //           color: Colors.white,
                //           fontSize: 10,
                //           height: 1,
                //           fontWeight: FontWeight.w900,
                //         ),
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeShortcutGrid extends StatelessWidget {
  final int unreadCount;

  const _HomeShortcutGrid({required this.unreadCount});

  void _openPage(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppConstants.pagePadding,
        22,
        AppConstants.pagePadding,
        0,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'New Booking',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingSearchScreen(),
                      ),
                    );
                  },
                ),
              ),
              _VerticalDividerLine(),
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.event_note_rounded,
                  label: 'Bookings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookingScreen()),
                    );
                    // _openPage(
                    //   context,
                    //   const _SimplePage(
                    //     title: 'Bookings',
                    //     subtitle: 'Reservations',
                    //     icon: Icons.event_note_rounded,
                    //     description:
                    //         'View and manage your meeting room bookings.',
                    //     details: [
                    //       _PageDetail(
                    //         icon: Icons.event_available_rounded,
                    //         title: 'Upcoming Bookings',
                    //         description: 'Check your scheduled reservations',
                    //       ),
                    //       _PageDetail(
                    //         icon: Icons.edit_calendar_rounded,
                    //         title: 'Manage Booking',
                    //         description: 'Update or cancel reservations',
                    //       ),
                    //     ],
                    //   ),
                    // );
                  },
                ),
              ),
              _VerticalDividerLine(),
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.notifications_active_outlined,
                  label: 'Notifications',
                  badgeCount: unreadCount,
                  onTap: () {
                    _openPage(context, const NotificationScreen());
                  },
                ),
              ),
            ],
          ),

          Divider(height: 1, color: context.appColors.border),

          Row(
            children: [
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.calendar_today_outlined,
                  label: 'Calendar',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CalendarScreen()),
                    );
                    // _openPage(
                    //   context,
                    //   const _SimplePage(
                    //     title: 'Calendar',
                    //     subtitle: 'Schedule',
                    //     icon: Icons.calendar_today_outlined,
                    //     description:
                    //         'Review room booking schedules and availability.',
                    //     details: [
                    //       _PageDetail(
                    //         icon: Icons.today_outlined,
                    //         title: 'Daily View',
                    //         description: 'See bookings by date',
                    //       ),
                    //       _PageDetail(
                    //         icon: Icons.access_time_outlined,
                    //         title: 'Time Slots',
                    //         description: 'Check available booking times',
                    //       ),
                    //     ],
                    //   ),
                    // );
                  },
                ),
              ),
              _VerticalDividerLine(),
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.analytics_outlined,
                  label: 'Analytics',
                  onTap: () {
                    _openPage(context, const HelpScreen());
                  },
                ),
              ),
              _VerticalDividerLine(),
              Expanded(
                child: _ShortcutTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    _openPage(context, const SettingsScreen());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final VoidCallback onTap;

  const _ShortcutTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppConstants.primary.withOpacity(0.12),
        highlightColor: AppConstants.primary.withOpacity(0.06),
        child: SizedBox(
          width: double.infinity,
          height: 104,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppConstants.primary, size: 27),
                  const SizedBox(height: 11),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: context.appText.bodySmall?.copyWith(
                      color: context.appColors.text,
                      fontSize: 12,
                      letterSpacing: .6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              if (badgeCount > 0)
                Positioned(
                  top: 15,
                  right: 16,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.danger,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerticalDividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 104, color: context.appColors.border);
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: context.appColors.primarySoft,
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.language_rounded,
              size: 17,
              color: AppConstants.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'EN',
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 3),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 17,
            color: context.appColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final int unreadCount;
  final bool compact;

  const _NotificationButton({required this.unreadCount, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _CircleIcon(
          icon: Icons.notifications_none_rounded,
          compact: compact,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationScreen()),
            );
          },
        ),
        if (unreadCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: context.appColors.danger,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: context.appColors.background,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.appColors.danger.withOpacity(0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
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
    final size = compact ? 46.0 : 50.0;

    return Material(
      color: context.appColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.border),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppConstants.primary,
            size: compact ? 23 : 25,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find a workspace',
            style: context.appText.titleMedium?.copyWith(
              color: context.appColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Search rooms by name, building or facility',
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            onSubmitted: (value) {
              onSubmitted(value.trim());
            },
            textInputAction: TextInputAction.search,
            style: context.appText.bodyMedium?.copyWith(
              color: context.appColors.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'Search workspaces, buildings...',
              hintStyle: context.appText.bodyMedium?.copyWith(
                color: context.appColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Icon(
                  Icons.search_rounded,
                  color: context.appColors.textMuted,
                  size: 22,
                ),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(6),
                child: Material(
                  color: AppConstants.primary,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      onSubmitted(controller.text.trim());
                    },
                    child: const SizedBox(
                      width: 42,
                      height: 42,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              filled: true,
              fillColor: context.appColors.surfaceSoft,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: context.appColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: AppConstants.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'Filters',
                style: context.appText.bodyMedium?.copyWith(
                  color: context.appColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                'Refine results',
                style: context.appText.bodySmall?.copyWith(
                  color: context.appColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  text: 'Sort by',
                  selected: true,
                  icon: Icons.tune_rounded,
                ),
                SizedBox(width: 9),
                _FilterChip(
                  text: 'Capacity',
                  icon: Icons.people_outline_rounded,
                ),
                SizedBox(width: 9),
                _FilterChip(text: 'Rating', icon: Icons.star_outline_rounded),
                SizedBox(width: 9),
                _FilterChip(
                  text: 'Available',
                  icon: Icons.event_available_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
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
    final foregroundColor = selected ? Colors.white : context.appColors.text;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppConstants.primary : context.appColors.surfaceSoft,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: selected ? AppConstants.primary : context.appColors.border,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppConstants.primary.withOpacity(0.18),
                  blurRadius: 9,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foregroundColor, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: context.appText.bodySmall?.copyWith(
              color: foregroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const _SimplePage(
//       title: 'Settings',
//       subtitle: 'Application Preferences',
//       icon: Icons.settings_outlined,
//       description: 'Manage your account preferences and application settings.',
//       details: [
//         _PageDetail(
//           icon: Icons.palette_outlined,
//           title: 'Appearance',
//           description: 'Customize display preferences',
//         ),
//         _PageDetail(
//           icon: Icons.notifications_outlined,
//           title: 'Notifications',
//           description: 'Control booking alerts',
//         ),
//       ],
//     );
//   }
// }

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: 'About App',
      subtitle: 'Application Information',
      icon: Icons.meeting_room_outlined,
      description:
          'A modern meeting room booking application designed for efficient workspace management.',
      details: [
        _PageDetail(
          icon: Icons.verified_outlined,
          title: 'Reliable Booking',
          description: 'Manage rooms with confidence',
        ),
        _PageDetail(
          icon: Icons.devices_outlined,
          title: 'Mobile Ready',
          description: 'Accessible across devices',
        ),
      ],
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: 'Help & Support',
      subtitle: 'Customer Support',
      icon: Icons.support_agent_rounded,
      description:
          'Get support for booking, cancellation, room availability and account issues.',
      details: [
        _PageDetail(
          icon: Icons.calendar_month_outlined,
          title: 'Booking Help',
          description: 'Create or modify reservations',
        ),
        _PageDetail(
          icon: Icons.chat_bubble_outline_rounded,
          title: 'Contact Support',
          description: 'Request assistance',
        ),
      ],
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimplePage(
      title: 'Privacy Policy',
      subtitle: 'Security & Privacy',
      icon: Icons.privacy_tip_outlined,
      description:
          'Review how booking information and account data are securely managed.',
      details: [
        _PageDetail(
          icon: Icons.lock_outline_rounded,
          title: 'Data Protection',
          description: 'Secure account information',
        ),
        _PageDetail(
          icon: Icons.visibility_outlined,
          title: 'Transparency',
          description: 'Understand data usage',
        ),
      ],
    );
  }
}

class _SimplePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String description;
  final List<_PageDetail> details;

  const _SimplePage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.description,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: context.appColors.background,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: context.appColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
                side: BorderSide(color: context.appColors.border),
              ),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppConstants.primary,
              size: 18,
            ),
          ),
        ),
        title: Text(
          title,
          style: context.appText.titleMedium?.copyWith(
            color: context.appColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 25, 22, 23),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.appColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: context.appColors.shadow,
                      blurRadius: 17,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: context.appColors.primarySoft,
                        borderRadius: BorderRadius.circular(21),
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, color: AppConstants.primary, size: 34),
                    ),
                    const SizedBox(height: 17),
                    Text(
                      subtitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: context.appText.bodySmall?.copyWith(
                        color: AppConstants.primary,
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: context.appText.headlineSmall?.copyWith(
                        color: context.appColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: context.appText.bodyMedium?.copyWith(
                        color: context.appColors.textMuted,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...details.map(
                (detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DetailCard(detail: detail),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageDetail {
  final IconData icon;
  final String title;
  final String description;

  const _PageDetail({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _DetailCard extends StatelessWidget {
  final _PageDetail detail;

  const _DetailCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: context.appColors.primarySoft,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Icon(detail.icon, size: 22, color: AppConstants.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.title,
                  style: context.appText.bodyMedium?.copyWith(
                    color: context.appColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail.description,
                  style: context.appText.bodySmall?.copyWith(
                    color: context.appColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: context.appColors.textMuted,
          ),
        ],
      ),
    );
  }
}
