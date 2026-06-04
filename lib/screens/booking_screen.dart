import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/new_booking_screen.dart';
import 'package:flutter_application_1/utils/app_palette.dart';
import 'package:flutter_application_1/utils/app_shimmer.dart';
import 'package:flutter_application_1/widgets/booking_export_menu.dart';
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

  bool _isAdmin(BuildContext context) {
    return _userLevel(context) == 'admin';
  }

  bool _isNormalUser(BuildContext context) {
    final level = _userLevel(context);
    return level == 'user' || level == 'member';
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

  List<Booking> _sortBookings(
    List<Booking> bookings,
    bool isAdmin,
    bool isUser,
    String? status,
  ) {
    final sorted = List<Booking>.from(bookings);

    switch (sortType) {
      case BookingSortType.newest:
        sorted.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1900);
          final bDate = b.createdAt ?? DateTime(1900);

          if (isAdmin) {
            // Admin: pending first, then by oldest
            if (a.status.toLowerCase() == 'pending' &&
                b.status.toLowerCase() != 'pending')
              return -1;
            if (b.status.toLowerCase() == 'pending' &&
                a.status.toLowerCase() != 'pending')
              return 1;
            // Both pending or both non-pending → oldest first
            return aDate.compareTo(bDate);
          } else if (isUser) {
            // Regular user → latest first
            return bDate.compareTo(aDate);
          }
          return 0; // fallback
        });
        break;

      case BookingSortType.oldest:
        sorted.sort(
          (a, b) => (a.createdAt ?? DateTime(1900)).compareTo(
            b.createdAt ?? DateTime(1900),
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

    await context.read<BookingController>().fetchBookings();
  }

  Future<void> _approveBooking(BuildContext context, int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Approve booking',
            style: dialogContext.appText.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text('Are you sure you want to approve this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    final controller = context.read<BookingController>();
    final ok = await controller.approveBooking(bookingId);

    if (!context.mounted) return;

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
              title: Text(
                'Reject booking',
                style: dialogContext.appText.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: TextField(
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reject reason',
                  errorText: errorText,
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dialogContext.appColors.danger,
                  ),
                  child: const Text('Reject'),
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

    final controller = context.read<BookingController>();
    final ok = await controller.rejectBooking(bookingId, result.trim());

    if (!context.mounted) return;

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

  Future<void> _deleteBooking(BuildContext context, int bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Delete booking',
            style: dialogContext.appText.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text('Are you sure you want to delete this booking?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogContext.appColors.danger,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    final controller = context.read<BookingController>();
    final ok = await controller.deleteBooking(bookingId);

    if (!context.mounted) return;

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

  @override
  Widget build(BuildContext context) {
    final isAdmin = _isAdmin(context);
    final isUser = _isNormalUser(context);
    final isStatus = sortType == BookingSortType.status;
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        foregroundColor: context.appColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Bookings',
          style: context.appText.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          BookingExportMenu(
            bookings: context.watch<BookingController>().bookings,
          ),
          PopupMenuButton<BookingSortType>(
            tooltip: 'Sort bookings',
            icon: Icon(Icons.sort, color: context.appColors.text),
            initialValue: sortType,
            onSelected: (value) {
              setState(() {
                sortType = value;
              });
            },
            itemBuilder: (context) {
              return BookingSortType.values.map((type) {
                final selected = sortType == type;

                return PopupMenuItem<BookingSortType>(
                  value: type,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: selected
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: AppConstants.primary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _sortLabel(type),
                        style: context.appText.bodyMedium?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
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
            icon: Icon(Icons.refresh, color: context.appColors.text),
          ),
        ],
      ),
      body: Consumer<BookingController>(
        builder: (context, controller, _) {
          if (controller.loading && controller.bookings.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.pagePadding),
              child: AppShimmerBox(height: 200),
            );
          }

          if (controller.bookings.isEmpty) {
            return RefreshIndicator(
              color: AppConstants.primary,
              onRefresh: controller.fetchBookings,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.pagePadding),
                children: [
                  const SizedBox(height: 190),
                  Icon(
                    Icons.event_busy_outlined,
                    size: 52,
                    color: context.appColors.textMuted,
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Text(
                      'No bookings found',
                      style: context.appText.titleMedium?.copyWith(
                        color: context.appColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedBookings = _sortBookings(
            controller.bookings,
            isAdmin,
            isUser,
            isStatus ? 'pending' : null,
          );

          return RefreshIndicator(
            color: AppConstants.primary,
            onRefresh: controller.fetchBookings,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppConstants.pagePadding,
                8,
                AppConstants.pagePadding,
                24,
              ),
              itemCount: sortedBookings.length,
              itemBuilder: (context, index) {
                final booking = sortedBookings[index];

                return BookingCard(
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
                  onShare: () => context.watch<BookingController>().bookings,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
