import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const BookingCard({
    super.key,
    required this.booking,
    this.onCancel,
    this.onDelete,
  });

  Color get _statusColor {
    switch (booking.status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return AppConstants.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d • hh:mm a');
    final start = booking.startDatetime;
    final end = booking.endDatetime;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstants.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available, color: AppConstants.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  booking.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (booking.room != null)
            Text(booking.room!.name, style: const TextStyle(color: AppConstants.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 18, color: AppConstants.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  start == null ? 'No time' : '${dateFormat.format(start)}${end == null ? '' : ' - ${DateFormat('hh:mm a').format(end)}'}',
                  style: const TextStyle(color: AppConstants.muted),
                ),
              ),
            ],
          ),
          if (booking.meetingChairman.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: AppConstants.muted),
                const SizedBox(width: 6),
                Text('Chairman: ${booking.meetingChairman}', style: const TextStyle(color: AppConstants.muted)),
              ],
            ),
          ],
          if (onCancel != null || onDelete != null) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Request Cancel'),
                  ),
                if (onDelete != null)
                  TextButton(
                    onPressed: onDelete,
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
