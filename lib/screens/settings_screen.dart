import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/room_screen.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';

import 'theme_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _safeName(dynamic user) {
    try {
      final json = (user as dynamic?)?.toJson();
      if (json is Map) {
        final name = json['name']?.toString().trim();
        if (name != null && name.isNotEmpty) return name;
      }
    } catch (_) {}
    return 'StaySelect User';
  }

  String _safePhotoUrl(String name, dynamic user) {
    String? photoUrl;

    try {
      final json = (user as dynamic?)?.toJson();
      if (json is Map) {
        photoUrl = json['photo']?.toString();
      }
    } catch (_) {}

    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      return photoUrl;
    }

    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=006B6F&color=fff';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().user;
    final name = _safeName(user);
    final photoUrl = _safePhotoUrl(name, user);

    return Scaffold(
      backgroundColor: context.appColors.background,

      // ✅ No bottomNavigationBar here
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _SettingsHeader(photoUrl: photoUrl)),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ProfileCard(
                    name: name,
                    photoUrl: photoUrl,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 22),

                  const _SectionTitle('ACCOUNT SETTINGS'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.link_rounded,
                        title: 'Linked Accounts',
                        trailingText: 'Google, Outlook',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const _SectionTitle('BOOKING PREFERENCES'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.timer_outlined,
                        title: 'Default Duration',
                        trailingText: '60 Minutes',
                        trailingIcon: Icons.keyboard_arrow_down_rounded,
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.favorite_border_rounded,
                        title: 'Room Favorites',
                        onTap: () {},
                      ),
                      _SettingsSwitchTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Push Notifications',
                        value: true,
                        onChanged: (value) {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const _SectionTitle('APP SETTINGS'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        trailingText: 'English (US)',
                        showChevron: false,
                        onTap: () {},
                      ),
                      _ThemeTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ThemeSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.data_usage_rounded,
                        title: 'Data Usage',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const _SectionTitle('SUPPORT & INFO'),
                  _SettingsGroup(
                    children: [
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help Center',
                        trailingIcon: Icons.open_in_new_rounded,
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () {},
                      ),
                      _VersionTile(),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String photoUrl;

  const _SettingsHeader({required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: context.appColors.background,
        border: Border(bottom: BorderSide(color: context.appColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: AppConstants.primary,
            iconSize: 22,
            onPressed: () => Navigator.maybePop(context),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Text(
              'Settings',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.appText.titleLarge?.copyWith(
                color: context.appColors.text,
                fontSize: 22,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          CircleAvatar(
            radius: 22,
            backgroundColor: context.appColors.surface,
            backgroundImage: NetworkImage(photoUrl),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String photoUrl;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.name,
    required this.photoUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppConstants.primary.withOpacity(0.12),
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppConstants.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.appColors.surface,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.titleMedium?.copyWith(
                        color: context.appColors.text,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Member • Meeting Room Booking',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.bodySmall?.copyWith(
                        color: context.appColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: context.appColors.textMuted,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Text(
        text,
        style: context.appText.labelMedium?.copyWith(
          color: AppConstants.primary,
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final IconData? trailingIcon;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.trailingIcon,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final iconToShow =
        trailingIcon ?? (showChevron ? Icons.chevron_right_rounded : null);

    return Material(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: context.appColors.border.withOpacity(0.65),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: context.appColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppConstants.primary),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.titleSmall?.copyWith(
                    color: context.appColors.text,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (trailingText != null) ...[
                Flexible(
                  child: Text(
                    trailingText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.appText.bodySmall?.copyWith(
                      color: AppConstants.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],

              if (iconToShow != null)
                Icon(iconToShow, size: 22, color: context.appColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.appColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppConstants.primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: context.appText.titleSmall?.copyWith(
                color: context.appColors.text,
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Transform.scale(
            scale: 0.82,
            child: Switch.adaptive(
              value: value,
              activeColor: AppConstants.primary,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final VoidCallback onTap;

  const _ThemeTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.appColors.border.withOpacity(0.65),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: context.appColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.dark_mode_outlined,
                size: 20,
                color: AppConstants.primary,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                'Theme',
                style: context.appText.titleSmall?.copyWith(
                  color: context.appColors.text,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            Container(
              height: 34,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppConstants.primary.withOpacity(0.10),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Light',
                      style: context.appText.bodySmall?.copyWith(
                        color: AppConstants.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Dark',
                      style: context.appText.bodySmall?.copyWith(
                        color: context.appColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
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

class _VersionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'App Version',
              style: context.appText.bodyMedium?.copyWith(
                color: context.appColors.textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            'v2.4.1',
            style: context.appText.bodyMedium?.copyWith(
              color: context.appColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
