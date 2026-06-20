import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/date_time_helper.dart';
import 'package:flutter_application_1/widgets/base_network_image.dart';
import 'package:flutter_application_1/widgets/booking_export_menu.dart';
import 'package:flutter_application_1/widgets/modern_action_button.dart';
import 'package:flutter_application_1/widgets/modern_action_dropdown_button.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../models/booking_model.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onShare;
  final bool isAdmin;
  final VoidCallback? onExtend;

  const BookingCard({
    super.key,
    required this.booking,
    this.onUpdate,
    this.onDelete,
    this.onApprove,
    this.onReject,
    this.onShare,
    this.isAdmin = false,
    this.onExtend,
  });

  Color _statusColor(BuildContext context) {
    switch (booking.status.toLowerCase().trim()) {
      case 'approved':
        return context.appColors.success;
      case 'pending':
        return context.appColors.warning;
      case 'rejected':
      case 'cancelled':
        return context.appColors.text;
      case 'cancel_requested':
        return context.appColors.warning;
      case 'completed':
        return AppConstants.primary;
      default:
        return context.appColors.danger;
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
    return onShare != null ||
        onExtend != null ||
        onUpdate != null ||
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

    // 🔥 Convert UTC → LOCAL for display
    final localCreated = createdAt != null
        ? DateTimeHelper.toLocal(createdAt)
        : null;

    final localUpdated = updatedAt != null
        ? DateTimeHelper.toLocal(updatedAt)
        : null;

    if (localCreated != null &&
        localUpdated != null &&
        localUpdated.isAfter(localCreated)) {
      return 'Updated: ${formatter.format(localUpdated)}';
    }

    if (localCreated != null) {
      return 'Created: ${formatter.format(localCreated)}';
    }

    return 'Updated: ${formatter.format(localUpdated!)}';
  }

  @override
  Widget build(BuildContext context) {
    final start = DateTimeHelper.toLocal(booking.startDatetime!);
    final end = DateTimeHelper.toLocal(booking.endDatetime!);

    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('hh:mm a');

    final adminDateText = isAdmin ? _adminDateText() : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final veryCompact = constraints.maxWidth < 315;
        final actionCount = [
          onShare,
          onExtend,
          onUpdate,
          onApprove,
          onReject,
          onDelete,
        ].where((action) => action != null).length;
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

              SchedulePanel(start: start, end: end),

              if (booking.meetingChairman.trim().isNotEmpty) ...[
                const SizedBox(height: 11),
                _InformationRow(
                  icon: Icons.person_outline_rounded,
                  text: 'Meeting Chair: ${booking.meetingChairman}',
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
                      if (onShare != null)
                        BookingExportMenu(bookings: [booking]),
                      if (actionCount > 3)
                        ModernActionDropdownButton(
                          booking: booking,
                          compact: compact,
                          fullWidth: veryCompact,

                          onExtend: onExtend,
                          onUpdate: onUpdate,
                          onApprove: onApprove,
                          onReject: onReject,
                          onDelete: onDelete,
                        )
                      else ...[
                        if (onExtend != null)
                          ModernActionButton(
                            label: 'Extra Time',
                            icon: Icons.more_time_rounded,
                            color: AppConstants.primary,
                            compact: compact,
                            fullWidth: veryCompact,
                            onTap: onExtend!,
                          ),

                        if (onUpdate != null)
                          ModernActionButton(
                            label: 'Edit',
                            icon: Icons.edit_rounded,
                            color: context.appColors.warning,
                            compact: compact,
                            fullWidth: veryCompact,
                            onTap: onUpdate!,
                          ),

                        if (onApprove != null)
                          ModernActionButton(
                            label: 'Approve',
                            icon: Icons.check_rounded,
                            color: context.appColors.success,
                            compact: compact,
                            fullWidth: veryCompact,
                            onTap: onApprove!,
                          ),

                        if (onReject != null)
                          ModernActionButton(
                            label: 'Reject',
                            icon: Icons.close_rounded,
                            color: context.appColors.danger,
                            compact: compact,
                            fullWidth: veryCompact,
                            onTap: onReject!,
                          ),

                        if (onDelete != null)
                          ModernActionButton(
                            label: 'Delete',
                            icon: Icons.delete_outline_rounded,
                            color: context.appColors.danger,
                            compact: compact,
                            fullWidth: veryCompact,
                            onTap: onDelete!,
                          ),
                      ],
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

// class _ExtraTimeOption extends StatelessWidget {
//   final int hours;
//   final DateTime? currentEnd;

//   const _ExtraTimeOption({required this.hours, required this.currentEnd});

//   String _formatTime(BuildContext context, DateTime dateTime) {
//     return MaterialLocalizations.of(context).formatTimeOfDay(
//       TimeOfDay.fromDateTime(dateTime.toLocal()),
//       alwaysUse24HourFormat: false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final newEnd = currentEnd?.add(Duration(hours: hours));

//     return Material(
//       color: context.appColors.primarySoft,
//       borderRadius: BorderRadius.circular(15),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(15),
//         onTap: () {
//           Navigator.pop(context, hours);
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(color: AppConstants.primary.withOpacity(0.14)),
//           ),
//           child: Column(
//             children: [
//               Text(
//                 '+$hours hr',
//                 style: context.appText.titleMedium?.copyWith(
//                   color: AppConstants.primary,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w900,
//                 ),
//               ),
//               const SizedBox(height: 5),
//               Text(
//                 newEnd == null ? '' : _formatTime(context, newEnd),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: context.appText.bodySmall?.copyWith(
//                   color: context.appColors.textMuted,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _BookingHeader extends StatelessWidget {
  final Booking booking;
  final bool compact;

  const _BookingHeader({required this.booking, required this.compact});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 46.0;
    final imageRoom = booking.room!.imageUrl;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        imageRoom.isEmpty
            ? Container(
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
              )
            : BaseNetworkImage(
                imageUrl: imageRoom,
                height: size,
                width: size,
                borderRadius: 10,
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

class SchedulePanel extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;

  const SchedulePanel({this.start, this.end, super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('hh:mm a');

    final localStart = start;
    final localEnd = end;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.bg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.date_range,
              color: AppConstants.primary,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Start
                Text(
                  localStart == null
                      ? 'No schedule'
                      : 'Start: ${dateFormat.format(localStart)} • ${timeFormat.format(localStart)}',
                  style: context.appText.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: AppConstants.radiusSmall,
                  ),
                ),

                const SizedBox(height: 4),

                // End
                Text(
                  localEnd == null
                      ? ''
                      : 'End: ${dateFormat.format(localEnd)} • ${timeFormat.format(localEnd)}',
                  style: context.appText.bodySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: AppConstants.radiusSmall,
                    color: context.appColors.textMuted,
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
