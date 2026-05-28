import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/booking_controller.dart';
import '../controllers/room_controller.dart';
import '../models/booking_model.dart';
import '../utils/constants.dart';
import '../widgets/booking_card.dart';
import 'new_booking_screen.dart';

enum BookingSortType { newest, oldest, status, roomName }

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  BookingSortType sortType = BookingSortType.newest;

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

  bool _canRequestCancel(Booking booking) {
    final status = booking.status.toLowerCase().trim();

    return status == 'approved' || status == 'pending';
  }

  bool _canDelete(Booking booking) {
    final status = booking.status.toLowerCase().trim();

    return status == 'pending';
  }

  Future<void> _requestCancel(BuildContext context, int bookingId) async {
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
                'Request cancellation',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              content: TextField(
                autofocus: true,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Enter cancellation reason',
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
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final trimmedReason = reason.trim();

                    if (trimmedReason.isEmpty) {
                      setDialogState(() {
                        errorText = 'Reason is required';
                      });
                      return;
                    }

                    Navigator.pop(dialogContext, trimmedReason);
                  },
                  child: const Text('Submit'),
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

    final ok = await context.read<BookingController>().requestCancel(
      bookingId,
      result.trim(),
    );

    if (!context.mounted) return;

    final controller = context.read<BookingController>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Cancel request submitted'
              : controller.error ?? 'Failed to request cancellation',
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
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) {
      return;
    }

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

  void _openNewBooking(BuildContext context) {
    final rooms = context.read<RoomController>().availableRooms;

    if (rooms.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No available room loaded')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NewBookingScreen(room: rooms.first)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppConstants.primary,
        onPressed: () => _openNewBooking(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Booking', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<BookingController>(
        builder: (context, controller, _) {
          if (controller.loading && controller.bookings.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppConstants.primary),
            );
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

                return BookingCard(
                  booking: booking,
                  onCancel: _canRequestCancel(booking)
                      ? () => _requestCancel(context, booking.bookingId)
                      : null,
                  onDelete: _canDelete(booking)
                      ? () => _deleteBooking(context, booking.bookingId)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
