import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/new_booking_screen.dart';
import 'package:flutter_application_1/utils/app_shimmer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../controllers/booking_controller.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';
import '../widgets/booking_card.dart';

enum BookingSortType { newest, oldest, status, roomName }

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  BookingSortType sortType = BookingSortType.newest;

  String _userLevel(BuildContext context) {
    final user = context.watch<AuthController>().user;

    if (user == null) return '';

    try {
      final json = (user as dynamic).toJson();

      if (json is Map) {
        return (json['level'] ?? json['role'] ?? json['user_level'] ?? '')
            .toString()
            .toLowerCase()
            .trim();
      }
    } catch (_) {}

    try {
      return ((user as dynamic).level ?? '').toString().toLowerCase().trim();
    } catch (_) {
      return '';
    }
  }

  Future<void> _openUpdateBooking(BuildContext context, Booking booking) async {
    if (booking.room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room data missing. Cannot update booking.'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewBookingScreen(room: booking.room!, booking: booking),
      ),
    );

    if (!context.mounted) return;

    context.read<BookingController>().fetchBookings();
  }

  bool _isAdmin(BuildContext context) {
    return _userLevel(context) == 'admin';
  }

  bool _isNormalUser(BuildContext context) {
    final level = _userLevel(context);
    return level == 'user' || level == 'member';
  }

  String _apiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  List<Booking> _sortBookings(List<Booking> bookings) {
    final sorted = List<Booking>.from(bookings);

    switch (sortType) {
      case BookingSortType.newest:
        sorted.sort(
          (a, b) => (b.startDatetime ?? DateTime(1900)).compareTo(
            a.startDatetime ?? DateTime(1900),
          ),
        );
        break;

      case BookingSortType.oldest:
        sorted.sort(
          (a, b) => (a.startDatetime ?? DateTime(1900)).compareTo(
            b.startDatetime ?? DateTime(1900),
          ),
        );
        break;

      case BookingSortType.status:
        sorted.sort(
          (a, b) => a.status.toLowerCase().compareTo(b.status.toLowerCase()),
        );
        break;

      case BookingSortType.roomName:
        sorted.sort(
          (a, b) => (a.room?.name ?? '').toLowerCase().compareTo(
            (b.room?.name ?? '').toLowerCase(),
          ),
        );
        break;
    }

    return sorted;
  }

  String _sortLabel(BookingSortType type) {
    switch (type) {
      case BookingSortType.newest:
        return 'Newest';
      case BookingSortType.oldest:
        return 'Oldest';
      case BookingSortType.status:
        return 'Status';
      case BookingSortType.roomName:
        return 'Room Name';
    }
  }

  bool _canApprove(Booking booking, bool isAdmin) {
    final status = booking.status.toLowerCase().trim();
    return isAdmin && status == 'pending';
  }

  bool _canReject(Booking booking, bool isAdmin) {
    final status = booking.status.toLowerCase().trim();
    return isAdmin && status == 'pending';
  }

  bool _canUpdate(Booking booking, bool isAdmin, bool isUser) {
    final status = booking.status.toLowerCase().trim();

    if (isAdmin) {
      return status == 'pending' ||
          status == 'approved' ||
          status == 'cancel_requested';
    }

    if (isUser) {
      return status == 'pending';
    }

    return false;
  }

  bool _canDelete(Booking booking, bool isUser) {
    final status = booking.status.toLowerCase().trim();
    return isUser && status == 'pending';
  }

  Future<void> _approveBooking(BuildContext context, int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Approve booking',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('Are you sure you want to approve this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primary,
              ),
              child: const Text(
                'Approve',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    final ok = await context.read<BookingController>().approveBooking(
      bookingId,
    );

    if (!context.mounted) return;

    final controller = context.read<BookingController>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Booking approved'
              : controller.error ?? 'Failed to approve booking',
        ),
      ),
    );
  }

  Future<void> _rejectBooking(BuildContext context, int bookingId) async {
    String reason = '';
    String? errorText;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Reject booking',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: TextField(
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reject reason',
                  errorText: errorText,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  reason = value;

                  if (errorText != null && value.trim().isNotEmpty) {
                    setDialogState(() {
                      errorText = null;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final trimmedReason = reason.trim();

                    if (trimmedReason.isEmpty) {
                      setDialogState(() {
                        errorText = 'Reject reason is required';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, trimmedReason);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    'Reject',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null || result.trim().isEmpty || !context.mounted) {
      return;
    }

    final ok = await context.read<BookingController>().rejectBooking(
      bookingId,
      result.trim(),
    );

    if (!context.mounted) return;

    final controller = context.read<BookingController>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Booking rejected'
              : controller.error ?? 'Failed to reject booking',
        ),
      ),
    );
  }

  Future<void> _updateBooking(BuildContext context, Booking booking) async {
    final titleController = TextEditingController(text: booking.meetingTitle);
    final chairmanController = TextEditingController(
      text: booking.meetingChairman,
    );

    String? errorText;

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Update booking',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Meeting Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: chairmanController,
                    decoration: InputDecoration(
                      labelText: 'Meeting Chairman',
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (errorText != null && value.trim().isNotEmpty) {
                        setDialogState(() {
                          errorText = null;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final chairman = chairmanController.text.trim();

                    if (chairman.isEmpty) {
                      setDialogState(() {
                        errorText = 'Chairman is required';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'meeting_title': titleController.text.trim(),
                      'meeting_chairman': chairman,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primary,
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    chairmanController.dispose();

    if (result == null || !context.mounted) return;

    final recurrenceType = booking.recurrenceType.trim().isEmpty
        ? 'none'
        : booking.recurrenceType.trim();

    final payload = <String, dynamic>{
      'room_id': booking.roomId,
      if (booking.startDatetime != null)
        'start_datetime': _apiDate(booking.startDatetime!),
      if (booking.endDatetime != null)
        'end_datetime': _apiDate(booking.endDatetime!),
      'recurrence_type': recurrenceType,
      if (recurrenceType == 'weekly') 'recurrence_days': booking.recurrenceDays,
      if (recurrenceType != 'none')
        'recurrence_period': booking.recurrencePeriod ?? 1,
      if (recurrenceType != 'none' && booking.recurrenceUntil != null)
        'recurrence_until': DateFormat(
          'yyyy-MM-dd',
        ).format(booking.recurrenceUntil!),
      'meeting_title': result['meeting_title']!.isEmpty
          ? null
          : result['meeting_title'],
      'meeting_chairman': result['meeting_chairman'],
      'snack_required': booking.snackRequired ? 1 : 0,
      'snack_note': booking.snackRequired ? booking.snackNote : null,
      'technician_required': booking.technicianRequired ? 1 : 0,
      'technician_note': booking.technicianRequired
          ? booking.technicianNote
          : null,
    };

    final ok = await context.read<BookingController>().updateBooking(
      booking.bookingId,
      payload,
    );

    if (!context.mounted) return;

    final controller = context.read<BookingController>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Booking updated'
              : controller.error ?? 'Failed to update booking',
        ),
      ),
    );
  }

  Future<void> _deleteBooking(BuildContext context, int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete booking',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('Are you sure you want to delete this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    final ok = await context.read<BookingController>().deleteBooking(bookingId);

    if (!context.mounted) return;

    final controller = context.read<BookingController>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Booking deleted'
              : controller.error ?? 'Failed to delete booking',
        ),
      ),
    );
  }

  Widget _roleActionButtons({
    required BuildContext context,
    required Booking booking,
    required bool isAdmin,
    required bool isUser,
  }) {
    final actions = <Widget>[];

    if (_canApprove(booking, isAdmin)) {
      actions.add(
        _ActionButton(
          label: 'Approve',
          icon: Icons.check_circle_outline,
          color: AppConstants.primary,
          onTap: () => _approveBooking(context, booking.bookingId),
        ),
      );
    }

    if (_canReject(booking, isAdmin)) {
      actions.add(
        _ActionButton(
          label: 'Reject',
          icon: Icons.cancel_outlined,
          color: Colors.red,
          onTap: () => _rejectBooking(context, booking.bookingId),
        ),
      );
    }

    if (_canUpdate(booking, isAdmin, isUser)) {
      actions.add(
        _ActionButton(
          label: 'Update',
          icon: Icons.edit_outlined,
          color: Colors.orange,
          onTap: () => _updateBooking(context, booking),
        ),
      );
    }

    if (_canDelete(booking, isUser)) {
      actions.add(
        _ActionButton(
          label: 'Delete',
          icon: Icons.delete_outline,
          color: Colors.red,
          onTap: () => _deleteBooking(context, booking.bookingId),
        ),
      );
    }

    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      child: Wrap(spacing: 8, runSpacing: 8, children: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _isAdmin(context);
    final isUser = _isNormalUser(context);

    return Scaffold(
      backgroundColor: AppConstants.bg,
      appBar: AppBar(
        backgroundColor: AppConstants.bg,
        elevation: 0,
        foregroundColor: AppConstants.primaryDark,
        title: const Text(
          'Bookings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          PopupMenuButton<BookingSortType>(
            tooltip: 'Sort bookings',
            icon: const Icon(Icons.sort),
            initialValue: sortType,
            onSelected: (value) {
              setState(() {
                sortType = value;
              });
            },
            itemBuilder: (context) {
              return BookingSortType.values.map((type) {
                return PopupMenuItem<BookingSortType>(
                  value: type,
                  child: Row(
                    children: [
                      if (sortType == type)
                        const Icon(
                          Icons.check,
                          size: 18,
                          color: AppConstants.primary,
                        )
                      else
                        const SizedBox(width: 18),
                      const SizedBox(width: 8),
                      Text(_sortLabel(type)),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<BookingController>().fetchBookings();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<BookingController>(
        builder: (context, controller, _) {
          if (controller.loading && controller.bookings.isEmpty) {
            return const AppShimmerBox(height: 200);
          }

          if (controller.bookings.isEmpty) {
            return RefreshIndicator(
              color: AppConstants.primary,
              onRefresh: () => controller.fetchBookings(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 260),
                  Center(
                    child: Text(
                      'No bookings found',
                      style: TextStyle(
                        color: AppConstants.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedBookings = _sortBookings(controller.bookings);

          return RefreshIndicator(
            color: AppConstants.primary,
            onRefresh: () => controller.fetchBookings(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              itemCount: sortedBookings.length,
              itemBuilder: (context, index) {
                final booking = sortedBookings[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BookingCard(
                      booking: booking,
                      onUpdate: _canUpdate(booking, isAdmin, isUser)
                          ? () => _openUpdateBooking(context, booking)
                          : null,
                      onDelete: _canDelete(booking, isUser)
                          ? () => _deleteBooking(context, booking.bookingId)
                          : null,
                      onApprove: _canApprove(booking, isAdmin)
                          ? () => _approveBooking(context, booking.bookingId)
                          : null,
                      onReject: _canReject(booking, isAdmin)
                          ? () => _rejectBooking(context, booking.bookingId)
                          : null,
                      isAdmin: isAdmin,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
