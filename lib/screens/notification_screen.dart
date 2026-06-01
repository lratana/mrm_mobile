import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/notification_controller.dart';
import '../utils/constants.dart';
import '../widgets/notification_card.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<void> _refresh(BuildContext context) async {
    await context.read<NotificationController>().fetchNotifications();
  }

  Future<void> _markAllAsRead(BuildContext context) async {
    final controller = context.read<NotificationController>();

    if (controller.unreadCount == 0) return;

    await controller.markAllAsRead();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> _markAsRead(BuildContext context, String id) async {
    await context.read<NotificationController>().markAsRead(id);
  }

  Future<void> _deleteNotification(BuildContext context, String id) async {
    await context.read<NotificationController>().deleteNotification(id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppConstants.primary),
        ),
        centerTitle: true,
        backgroundColor: AppConstants.bg,
        surfaceTintColor: AppConstants.bg,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FAFD),
      body: Consumer<NotificationController>(
        builder: (context, controller, _) {
          if (controller.loading && controller.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppConstants.primary),
            );
          }

          return SafeArea(
            child: RefreshIndicator(
              color: AppConstants.primary,
              onRefresh: () => _refresh(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // SliverToBoxAdapter(
                  //   child: _GmailHeader(
                  //     unreadCount: controller.unreadCount,
                  //     loading: controller.loading,
                  //     onBack: () => Navigator.maybePop(context),
                  //     onRefresh: () => _refresh(context),
                  //   ),
                  // ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: _InboxTitleRow(
                        unreadCount: controller.unreadCount,
                        onMarkAllRead: controller.unreadCount == 0
                            ? null
                            : () => _markAllAsRead(context),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: _InboxContainer(
                        child: Column(
                          children: [
                            _CategoryRow(
                              icon: Icons.notifications_active_outlined,
                              iconColor: const Color(0xFF1A73E8),
                              iconBackground: const Color(0xFFE8F0FE),
                              title: 'New notifications',
                              subtitle: controller.unreadCount == 0
                                  ? 'No unread updates'
                                  : '${controller.unreadCount} unread update${controller.unreadCount == 1 ? '' : 's'}',
                              count: controller.unreadCount,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 28, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: _SectionLabel(title: 'NEW'),
                    ),
                  ),

                  if (controller.unread.isEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _EmptyMailState(
                          icon: Icons.mark_email_read_outlined,
                          title: 'You’re all caught up',
                          description: 'No new notifications right now.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _InboxContainer(
                          child: Column(
                            children: List.generate(controller.unread.length, (
                              index,
                            ) {
                              final notification = controller.unread[index];

                              return Column(
                                children: [
                                  NotificationCard(
                                    notification: notification,
                                    onTap: () =>
                                        _markAsRead(context, notification.id),
                                    onDelete: () => _deleteNotification(
                                      context,
                                      notification.id,
                                    ),
                                  ),
                                  if (index < controller.unread.length - 1)
                                    const Divider(
                                      height: 1,
                                      indent: 62,
                                      color: Color(0xFFE6E9EE),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),

                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                    sliver: SliverToBoxAdapter(
                      child: _SectionLabel(title: 'EARLIER'),
                    ),
                  ),

                  if (controller.earlier.isEmpty)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _EmptyMailState(
                          icon: Icons.inbox_outlined,
                          title: 'No earlier notifications',
                          description:
                              'Your previous notifications appear here.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: _InboxContainer(
                          child: Column(
                            children: List.generate(controller.earlier.length, (
                              index,
                            ) {
                              final notification = controller.earlier[index];

                              return Column(
                                children: [
                                  NotificationCard(
                                    notification: notification,
                                    onDelete: () => _deleteNotification(
                                      context,
                                      notification.id,
                                    ),
                                  ),
                                  if (index < controller.earlier.length - 1)
                                    const Divider(
                                      height: 1,
                                      indent: 62,
                                      color: Color(0xFFE6E9EE),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 34)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GmailHeader extends StatelessWidget {
  final int unreadCount;
  final bool loading;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const _GmailHeader({
    required this.unreadCount,
    required this.loading,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FB),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: Color(0xFF3C4043),
              ),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                'Search notifications',
                style: TextStyle(
                  color: Color(0xFF5F6368),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(right: 15),
                child: SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppConstants.primary,
                  ),
                ),
              )
            else
              IconButton(
                tooltip: 'Refresh',
                onPressed: onRefresh,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF3C4043),
                ),
              ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 39,
                  height: 39,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: const BoxDecoration(
                    color: AppConstants.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -3,
                    right: 0,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD93025),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFEAF1FB),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        unreadCount > 99 ? '99+' : '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxTitleRow extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onMarkAllRead;

  const _InboxTitleRow({
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Inbox',
            style: TextStyle(
              color: Color(0xFF202124),
              fontSize: 29,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ),
        TextButton(
          onPressed: onMarkAllRead,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          child: Text(
            unreadCount == 0 ? 'All read' : 'Mark all read',
            style: TextStyle(
              color: unreadCount == 0
                  ? const Color(0xFF9AA0A6)
                  : AppConstants.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InboxContainer extends StatelessWidget {
  final Widget child;

  const _InboxContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6E9EE)),
      ),
      child: child,
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final int count;

  const _CategoryRow({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 23, color: iconColor),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF5F6368),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Color(0xFF1967D2),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF5F6368),
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: 0.7,
      ),
    );
  }
}

class _EmptyMailState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyMailState({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return _InboxContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF9AA0A6), size: 33),
            const SizedBox(height: 11),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF202124),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF5F6368), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
