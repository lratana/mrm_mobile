// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/controllers/auth_controller.dart';
// import 'package:flutter_application_1/controllers/notification_controller.dart';
// import 'package:flutter_application_1/controllers/room_controller.dart';
// import 'package:flutter_application_1/screens/notification_screen.dart';
// import 'package:flutter_application_1/screens/room_screen.dart';
// import 'package:flutter_application_1/screens/theme_settings_screen.dart';
// import 'package:flutter_application_1/utils/app_palette.dart';
// import 'package:flutter_application_1/utils/constants.dart';
// import 'package:provider/provider.dart';


// class _TopToolbar extends StatelessWidget {
//   final RoomController controller;
//   final VoidCallback onMenuTap;

//   const _TopToolbar({
//     required this.controller,
//     required this.onMenuTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final unreadCount = context.watch<NotificationController>().unreadCount;
//     final user = context.watch<AuthController>().user;

//     String name = 'User';
//     String? photoUrl;

//     try {
//       final json = (user as dynamic?)?.toJson();

//       if (json is Map) {
//         name = json['name']?.toString() ?? 'User';
//         photoUrl =
//             json['photo']?.toString() ??
//             json['profile_image']?.toString() ??
//             json['avatar']?.toString();
//       }
//     } catch (_) {}

//     final safePhotoUrl = photoUrl != null && photoUrl!.trim().isNotEmpty
//         ? photoUrl!
//         : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=004D57&color=fff';

//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 8,
//         left: 18,
//         right: 18,
//         bottom: 14,
//       ),
//       decoration: BoxDecoration(
//         color: context.appColors.background,
//         boxShadow: [
//           BoxShadow(
//             color: context.appColors.shadow,
//             blurRadius: 14,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(12),
//             onTap: onMenuTap,
//             child: const Padding(
//               padding: EdgeInsets.all(8),
//               child: Icon(
//                 Icons.menu_rounded,
//                 color: AppConstants.primary,
//                 size: 26,
//               ),
//             ),
//           ),

//           const SizedBox(width: 10),

//           Expanded(
//             child: Text(
//               'Meeting Rooms',
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: context.appText.titleLarge?.copyWith(
//                 color: AppConstants.primary,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//           ),

//           InkWell(
//             borderRadius: BorderRadius.circular(999),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const ProfileScreen()),
//               );
//             },
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 CircleAvatar(
//                   radius: 18,
//                   backgroundColor: context.appColors.primarySoft,
//                   backgroundImage: NetworkImage(safePhotoUrl),
//                 ),

//                 if (unreadCount > 0)
//                   Positioned(
//                     top: -8,
//                     right: -8,
//                     child: Container(
//                       constraints: const BoxConstraints(
//                         minWidth: 20,
//                         minHeight: 20,
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 5,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: context.appColors.danger,
//                         borderRadius: BorderRadius.circular(999),
//                         border: Border.all(
//                           color: context.appColors.background,
//                           width: 2,
//                         ),
//                       ),
//                       alignment: Alignment.center,
//                       child: Text(
//                         unreadCount > 99 ? '99+' : '$unreadCount',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 10,
//                           height: 1,
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HomeShortcutGrid extends StatelessWidget {
//   final int unreadCount;

//   const _HomeShortcutGrid({
//     required this.unreadCount,
//   });

//   void _openPage(BuildContext context, Widget page) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => page),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(
//         AppConstants.pagePadding,
//         22,
//         AppConstants.pagePadding,
//         0,
//       ),
//       decoration: BoxDecoration(
//         color: context.appColors.surface,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: context.appColors.border),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: _ShortcutTile(
//                   icon: Icons.home_outlined,
//                   label: 'Home',
//                   onTap: () {},
//                 ),
//               ),
//               _VerticalDividerLine(),
//               Expanded(
//                 child: _ShortcutTile(
//                   icon: Icons.calendar_month_outlined,
//                   label: 'Bookings',
//                   onTap: () {
//                     _openPage(
//                       context,
//                       const _SimplePage(
//                         title: 'Bookings',
//                         subtitle: 'Reservations',
//                         icon: Icons.calendar_month_outlined,
//                         description:
//                             'View and manage your meeting room bookings.',
//                         details: [
//                           _PageDetail(
//                             icon: Icons.event_available_outlined,
//                             title: 'Upcoming Bookings',
//                             description: 'Check your scheduled reservations',
//                           ),
//                           _PageDetail(
//                             icon: Icons.edit_calendar_outlined,
//                             title: 'Manage Booking',
//                             description: 'Update or cancel reservations',
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               _VerticalDividerLine(),
//               Expanded(
//                 child: _ShortcutTile(
//                   icon: Icons.notifications_none_rounded,
//                   label: 'Notification',
//                   badgeCount: unreadCount,
//                   onTap: () {
//                     _openPage(context, const NotificationScreen());
//                   },
//                 ),
//               ),
//             ],
//           ),

//           Divider(height: 1, color: context.appColors.border),

//           Row(
//             children: [
//               Expanded(
//                 child: _ShortcutTile(
//                   icon: Icons.calendar_today_outlined,
//                   label: 'Calendar',
//                   onTap: () {
//                     _openPage(
//                       context,
//                       const _SimplePage(
//                         title: 'Calendar',
//                         subtitle: 'Schedule',
//                         icon: Icons.calendar_today_outlined,
//                         description:
//                             'Review room booking schedules and availability.',
//                         details: [
//                           _PageDetail(
//                             icon: Icons.today_outlined,
//                             title: 'Daily View',
//                             description: 'See bookings by date',
//                           ),
//                           _PageDetail(
//                             icon: Icons.access_time_outlined,
//                             title: 'Time Slots',
//                             description: 'Check available booking times',
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               _VerticalDividerLine(),
//               Expanded(
//                 child: _ShortcutTile(
//                   icon: Icons.support_agent_rounded,
//                   label: 'Help Desk',
//                   onTap: () {
//                     _openPage(context, const HelpScreen());
//                   },
//                 ),
//               ),
//               _VerticalDividerLine(),
//               Expanded(
//                 child: _ShortcutTile(
//                   icon: Icons.settings_outlined,
//                   label: 'Settings',
//                   onTap: () {
//                     _openPage(context, const ThemeSettingsScreen());
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ShortcutTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final int badgeCount;
//   final VoidCallback onTap;

//   const _ShortcutTile({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.badgeCount = 0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: SizedBox(
//         height: 104,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   icon,
//                   color: AppConstants.primary,
//                   size: 27,
//                 ),
//                 const SizedBox(height: 11),
//                 Text(
//                   label,
//                   textAlign: TextAlign.center,
//                   style: context.appText.bodySmall?.copyWith(
//                     color: context.appColors.text,
//                     fontSize: 12,
//                     letterSpacing: .6,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),

//             if (badgeCount > 0)
//               Positioned(
//                 top: 15,
//                 right: 16,
//                 child: Container(
//                   constraints: const BoxConstraints(
//                     minWidth: 20,
//                     minHeight: 20,
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 5,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: context.appColors.danger,
//                     borderRadius: BorderRadius.circular(999),
//                   ),
//                   alignment: Alignment.center,
//                   child: Text(
//                     badgeCount > 99 ? '99+' : '$badgeCount',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w900,
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _VerticalDividerLine extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 1,
//       height: 104,
//       color: context.appColors.border,
//     );
//   }
// }