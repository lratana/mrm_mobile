import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/notification_model.dart';
import '../utils/app_palette.dart';
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

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes.clamp(1, 59)}m ago';
    }

    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }

    if (diff.inDays == 1) {
      return 'Yesterday';
    }

    if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }

    return DateFormat('MMM d').format(date);
  }

  IconData _icon() {
    final type = notification.type.toLowerCase();

    if (type.contains('booking')) {
      return Icons.check_circle_outline_rounded;
    }

    if (type.contains('reminder')) {
      return Icons.access_time_rounded;
    }

    if (type.contains('cancel')) {
      return Icons.cancel_outlined;
    }

    return Icons.info_outline_rounded;
  }

  Color _iconColor(BuildContext context) {
    final type = notification.type.toLowerCase();

    if (type.contains('cancel')) {
      return context.appColors.danger;
    }

    if (type.contains('reminder')) {
      return context.appColors.warning;
    }

    if (type.contains('booking')) {
      return context.appColors.success;
    }

    return AppConstants.primary;
  }

  Color _iconBackground(BuildContext context) {
    final color = _iconColor(context);

    return color.withOpacity(context.isDarkMode ? 0.18 : 0.12);
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;
    final timeText = _timeText();

    return Dismissible(
      key: ValueKey(notification.id),
      direction: onDelete == null
          ? DismissDirection.none
          : DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: _DeleteBackground(color: context.appColors.danger),
      child: Material(
        color: isUnread
            ? context.appColors.surface
            : context.appColors.surfaceSoft,
        child: InkWell(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 350;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isUnread)
                      Container(width: 4, color: AppConstants.primary),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: compact ? 12 : 16,
                          vertical: compact ? 12 : 15,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: compact ? 44 : 48,
                              height: compact ? 44 : 48,
                              decoration: BoxDecoration(
                                color: _iconBackground(context),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _icon(),
                                color: _iconColor(context),
                                size: compact ? 22 : 24,
                              ),
                            ),

                            SizedBox(width: compact ? 10 : 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (compact)
                                    _CompactTitleSection(
                                      notification: notification,
                                      timeText: timeText,
                                      isUnread: isUnread,
                                    )
                                  else
                                    _StandardTitleSection(
                                      notification: notification,
                                      timeText: timeText,
                                      isUnread: isUnread,
                                    ),

                                  const SizedBox(height: 7),

                                  Text(
                                    notification.message,
                                    maxLines: compact ? 3 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.appText.bodyMedium?.copyWith(
                                      fontSize: compact ? 13 : 14,
                                      height: 1.35,
                                      color: context.appColors.textMuted,
                                      fontWeight: isUnread
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StandardTitleSection extends StatelessWidget {
  final AppNotification notification;
  final String timeText;
  final bool isUnread;

  const _StandardTitleSection({
    required this.notification,
    required this.timeText,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            notification.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appText.titleMedium?.copyWith(
              fontSize: 15,
              color: context.appColors.text,
              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        if (timeText.isNotEmpty) ...[
          const SizedBox(width: 10),
          Text(
            timeText,
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.textMuted,
              fontSize: 11,
              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _CompactTitleSection extends StatelessWidget {
  final AppNotification notification;
  final String timeText;
  final bool isUnread;

  const _CompactTitleSection({
    required this.notification,
    required this.timeText,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          notification.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.appText.titleMedium?.copyWith(
            fontSize: 14,
            color: context.appColors.text,
            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        if (timeText.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            timeText,
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  final Color color;

  const _DeleteBackground({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(context.isDarkMode ? 0.22 : 0.12),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}
