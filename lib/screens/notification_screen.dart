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
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  Future<void> _markAsRead(BuildContext context, String id) async {
    await context.read<NotificationController>().markAsRead(id);
  }

  Future<void> _deleteNotification(BuildContext context, String id) async {
    await context.read<NotificationController>().deleteNotification(id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notification deleted')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bg,
      appBar: AppBar(
        backgroundColor: AppConstants.bg,
        foregroundColor: AppConstants.primaryDark,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _refresh(context),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationController>(
        builder: (context, controller, _) {
          if (controller.loading && controller.notifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppConstants.primary),
            );
          }

          return RefreshIndicator(
            color: AppConstants.primary,
            onRefresh: () => _refresh(context),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Manage\nNotifications',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.unreadCount == 0
                          ? null
                          : () => _markAllAsRead(context),
                      child: Text(
                        'Mark all as\nread',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 20,
                          color: controller.unreadCount == 0
                              ? AppConstants.muted
                              : AppConstants.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    const Text(
                      'NEW',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppConstants.text,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppConstants.primary,
                      child: Text(
                        '${controller.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (controller.unread.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      'No new notifications',
                      style: TextStyle(color: AppConstants.muted),
                    ),
                  )
                else
                  ...controller.unread.map(
                    (notification) => NotificationCard(
                      notification: notification,
                      onTap: () => _markAsRead(context, notification.id),
                      onDelete: () =>
                          _deleteNotification(context, notification.id),
                    ),
                  ),

                const SizedBox(height: 30),

                const Text(
                  'EARLIER',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppConstants.text,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 16),

                if (controller.earlier.isEmpty)
                  const Text(
                    'No earlier notifications',
                    style: TextStyle(color: AppConstants.muted),
                  )
                else
                  ...controller.earlier.map(
                    (notification) => NotificationCard(
                      notification: notification,
                      onDelete: () =>
                          _deleteNotification(context, notification.id),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
