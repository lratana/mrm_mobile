import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool? isAdmin;

  const BookingCard({
    super.key,
    required this.booking,
    this.onUpdate,
    this.onDelete,
    this.onApprove,
    this.onReject,
    this.isAdmin,
  });

  Color get _statusColor {
    switch (booking.status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF16A34A);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return AppConstants.primary;
    }
  }

  IconData get _statusIcon {
    switch (booking.status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('hh:mm a');
    final start = booking.startDatetime;
    final end = booking.endDatetime;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  image: booking.room?.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(booking.room!.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: AppConstants.primary.withOpacity(.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.meeting_room_rounded,
                  color: AppConstants.primary,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.room?.name ?? 'No room',
                      style: const TextStyle(
                        color: AppConstants.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: [
                    Icon(_statusIcon, size: 14, color: _statusColor),
                    const SizedBox(width: 5),
                    Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        color: _statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 20,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 10),

                // Show Created/Updated info only for admin
                Expanded(
                  child: Text(
                    start == null
                        ? 'No schedule'
                        : '${dateFormat.format(start)} • ${timeFormat.format(start)}${end == null ? '' : ' - ${timeFormat.format(end)}'}',
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (booking.meetingChairman.isNotEmpty) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  size: 19,
                  color: Color(0xFF6B7280),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Chairman: ${booking.meetingChairman}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (isAdmin ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      (booking.updatedAt != null &&
                              booking.createdAt != null &&
                              booking.updatedAt!.isAfter(booking.createdAt!))
                          ? Icons.update
                          : Icons.create,
                      size: 19,
                      color: AppConstants.muted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (booking.updatedAt != null &&
                              booking.createdAt != null &&
                              booking.updatedAt!.isAfter(booking.createdAt!))
                          ? 'Updated: ${DateFormat("yyyy-MM-dd HH:mm a").format(booking.updatedAt!.toLocal())}'
                          : 'Created: ${DateFormat("yyyy-MM-dd HH:mm a").format(booking.createdAt!.toLocal())}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.muted,
                      ),
                    ),
                  ],
                ),
              ),
          ],

          if (onUpdate != null ||
              onDelete != null ||
              onApprove != null ||
              onReject != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                if (onUpdate != null)
                  _ModernActionButton(
                    label: 'Edit',
                    icon: Icons.edit_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: onUpdate!,
                  ),
                if (onApprove != null)
                  _ModernActionButton(
                    label: 'Approve',
                    icon: Icons.check_rounded,
                    color: const Color(0xFF16A34A),
                    onTap: onApprove!,
                  ),
                if (onReject != null)
                  _ModernActionButton(
                    label: 'Reject',
                    icon: Icons.close_rounded,
                    color: const Color(0xFFDC2626),
                    onTap: onReject!,
                  ),
                if (onDelete != null)
                  _ModernActionButton(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFDC2626),
                    onTap: onDelete!,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
