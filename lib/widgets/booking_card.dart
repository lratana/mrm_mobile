import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/booking_model.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool isAdmin;

  const BookingCard({
    super.key,
    required this.booking,
    this.onUpdate,
    this.onDelete,
    this.onApprove,
    this.onReject,
    this.isAdmin = false,
  });

  Color _statusColor(BuildContext context) {
    switch (booking.status.toLowerCase().trim()) {
      case 'approved':
        return context.appColors.success;
      case 'pending':
        return context.appColors.warning;
      case 'rejected':
      case 'cancelled':
        return context.appColors.danger;
      case 'cancel_requested':
        return context.appColors.warning;
      case 'completed':
        return AppConstants.primary;
      default:
        return AppConstants.primary;
    }
  }

  IconData get _statusIcon {
    switch (booking.status.toLowerCase().trim()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'cancel_requested':
        return Icons.warning_amber_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String get _statusLabel {
    return booking.status.replaceAll('_', ' ').toUpperCase();
  }

  bool get _hasActions {
    return onUpdate != null ||
        onDelete != null ||
        onApprove != null ||
        onReject != null;
  }

  String? _adminDateText() {
    final createdAt = booking.createdAt;
    final updatedAt = booking.updatedAt;
    final formatter = DateFormat('yyyy-MM-dd hh:mm a');

    if (createdAt == null && updatedAt == null) {
      return null;
    }

    if (createdAt != null &&
        updatedAt != null &&
        updatedAt.isAfter(createdAt)) {
      return 'Updated: ${formatter.format(updatedAt.toLocal())}';
    }

    if (createdAt != null) {
      return 'Created: ${formatter.format(createdAt.toLocal())}';
    }

    return 'Updated: ${formatter.format(updatedAt!.toLocal())}';
  }

  @override
  Widget build(BuildContext context) {
    final start = booking.startDatetime;
    final end = booking.endDatetime;

    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('hh:mm a');

    final adminDateText = isAdmin ? _adminDateText() : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final veryCompact = constraints.maxWidth < 315;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: EdgeInsets.all(compact ? 14 : 18),
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
              _BookingHeader(booking: booking, compact: compact),

              const SizedBox(height: 12),

              _StatusChip(
                icon: _statusIcon,
                label: _statusLabel,
                color: _statusColor(context),
              ),

              const SizedBox(height: 14),

              _SchedulePanel(
                text: start == null
                    ? 'No schedule'
                    : '${dateFormat.format(start)} • '
                          '${timeFormat.format(start)}'
                          '${end == null ? '' : ' - ${timeFormat.format(end)}'}',
              ),

              if (booking.meetingChairman.trim().isNotEmpty) ...[
                const SizedBox(height: 11),
                _InformationRow(
                  icon: Icons.person_outline_rounded,
                  text: 'Chairman: ${booking.meetingChairman}',
                ),
              ],

              if (adminDateText != null) ...[
                const SizedBox(height: 9),
                _InformationRow(
                  icon: adminDateText.startsWith('Updated')
                      ? Icons.update_rounded
                      : Icons.create_rounded,
                  text: adminDateText,
                  small: true,
                ),
              ],

              if (_hasActions) ...[
                const SizedBox(height: 15),
                Divider(height: 1, color: context.appColors.border),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      if (onUpdate != null)
                        _ModernActionButton(
                          label: 'Edit',
                          icon: Icons.edit_rounded,
                          color: context.appColors.warning,
                          compact: compact,
                          fullWidth: veryCompact,
                          onTap: onUpdate!,
                        ),
                      if (onApprove != null)
                        _ModernActionButton(
                          label: 'Approve',
                          icon: Icons.check_rounded,
                          color: context.appColors.success,
                          compact: compact,
                          fullWidth: veryCompact,
                          onTap: onApprove!,
                        ),
                      if (onReject != null)
                        _ModernActionButton(
                          label: 'Reject',
                          icon: Icons.close_rounded,
                          color: context.appColors.danger,
                          compact: compact,
                          fullWidth: veryCompact,
                          onTap: onReject!,
                        ),
                      if (onDelete != null)
                        _ModernActionButton(
                          label: 'Delete',
                          icon: Icons.delete_outline_rounded,
                          color: context.appColors.danger,
                          compact: compact,
                          fullWidth: veryCompact,
                          onTap: onDelete!,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BookingHeader extends StatelessWidget {
  final Booking booking;
  final bool compact;

  const _BookingHeader({required this.booking, required this.compact});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 46.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: context.appColors.primarySoft,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.meeting_room_rounded,
            color: AppConstants.primary,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.title.trim().isEmpty
                    ? 'Untitled meeting'
                    : booking.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.appText.titleMedium?.copyWith(
                  fontSize: compact ? 15 : 17,
                  fontWeight: FontWeight.w900,
                  color: context.appColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                booking.room?.name ?? 'No room',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.appText.bodySmall?.copyWith(
                  color: AppConstants.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 230),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(context.isDarkMode ? 0.18 : 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.appText.bodySmall?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchedulePanel extends StatelessWidget {
  final String text;

  const _SchedulePanel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: context.appColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.schedule_rounded,
            size: 19,
            color: context.appColors.textMuted,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: context.appText.bodySmall?.copyWith(
                color: context.appColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool small;

  const _InformationRow({
    required this.icon,
    required this.text,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: small ? 18 : 19, color: context.appColors.textMuted),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            softWrap: true,
            maxLines: small ? 2 : null,
            overflow: small ? TextOverflow.ellipsis : null,
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.textMuted,
              fontSize: small ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool compact;
  final bool fullWidth;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.compact,
    required this.fullWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: color.withOpacity(context.isDarkMode ? 0.18 : 0.11),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: fullWidth
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.bodySmall?.copyWith(
                    color: color,
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
