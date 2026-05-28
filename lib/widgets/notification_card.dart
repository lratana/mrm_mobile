import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../utils/constants.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  String _timeText() {
    final date = notification.createdAt;
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d').format(date);
  }

  IconData _icon() {
    final type = notification.type.toLowerCase();
    if (type.contains('booking')) return Icons.check_circle_outline;
    if (type.contains('reminder')) return Icons.access_time;
    if (type.contains('cancel')) return Icons.cancel_outlined;
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;
    return Dismissible(
      key: ValueKey(notification.id),
      direction: onDelete == null ? DismissDirection.none : DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : const Color(0xFFF0F2FB),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isUnread ? Colors.transparent : AppConstants.border),
            boxShadow: isUnread
                ? [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 14, offset: const Offset(0, 4))]
                : [],
          ),
          child: Row(
            children: [
              if (isUnread)
                Container(
                  width: 5,
                  height: 112,
                  decoration: const BoxDecoration(
                    color: AppConstants.primary,
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(18)),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isUnread ? AppConstants.mint : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_icon(), color: AppConstants.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(notification.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                ),
                                Text(_timeText(), style: const TextStyle(color: AppConstants.text, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(notification.message, style: const TextStyle(fontSize: 15, height: 1.35, color: AppConstants.text)),
                          ],
                        ),
                      ),
                    ],
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
