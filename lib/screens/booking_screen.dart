import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_1/screens/new_booking_screen.dart';
import 'package:flutter_application_1/screens/room_screen.dart';
import 'package:flutter_application_1/services/booking_export_service.dart';
import 'package:flutter_application_1/utils/app_palette.dart';
import 'package:flutter_application_1/utils/app_shimmer.dart';
import 'package:flutter_application_1/utils/date_time_helper.dart';
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

class _ExtraTimeSheet extends StatelessWidget {
  final Booking booking;

  const _ExtraTimeSheet({required this.booking});

  String _formatTime(BuildContext context, DateTime dateTime) {
    final localDateTime = dateTime;

    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(localDateTime),
      alwaysUse24HourFormat: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentEndUtc = booking.endDatetime;

    final currentEndText = currentEndUtc == null
        ? 'Current ending time unavailable'
        : 'Currently ends at ${_formatTime(context, currentEndUtc)}';

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 13, 18, 18),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: context.appColors.border),
          boxShadow: [
            BoxShadow(
              color: context.appColors.shadow,
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: context.appColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            const SizedBox(height: 19),

            Row(
              children: [
                Container(
                  width: 49,
                  height: 49,
                  decoration: BoxDecoration(
                    color: context.appColors.primarySoft,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.more_time_rounded,
                    size: 25,
                    color: AppConstants.primary,
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Extra Time',
                        style: context.appText.titleMedium?.copyWith(
                          color: context.appColors.text,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        'Continue your current meeting',
                        style: context.appText.bodySmall?.copyWith(
                          color: context.appColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: context.appColors.surfaceSoft,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 20,
                    color: context.appColors.textMuted,
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      currentEndText,
                      style: context.appText.bodyMedium?.copyWith(
                        color: context.appColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 17),

            Text(
              'Select additional hours',
              style: context.appText.bodyMedium?.copyWith(
                color: context.appColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 11),

            Row(
              children: [
                Expanded(
                  child: _ExtraTimeOption(hours: 1, currentEnd: currentEndUtc),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: _ExtraTimeOption(hours: 2, currentEnd: currentEndUtc),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: _ExtraTimeOption(hours: 3, currentEnd: currentEndUtc),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: context.appColors.textMuted,
                  size: 17,
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: Text(
                    'Extra time is added immediately when the room remains available.',
                    style: context.appText.bodySmall?.copyWith(
                      color: context.appColors.textMuted,
                      fontSize: 11,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: context.appColors.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtraTimeOption extends StatelessWidget {
  final int hours;
  final DateTime? currentEnd;

  const _ExtraTimeOption({required this.hours, required this.currentEnd});

  String _formatTime(BuildContext context, DateTime dateTime) {
    final localDateTime = dateTime;

    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(localDateTime),
      alwaysUse24HourFormat: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ currentEnd should be UTC from backend/model
    final DateTime? newEndUtc = currentEnd?.add(Duration(hours: hours));

    final bool disabled = newEndUtc == null;

    return Material(
      color: disabled
          ? context.appColors.surfaceSoft
          : context.appColors.primarySoft,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: disabled
            ? null
            : () {
                Navigator.pop(context, hours);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: disabled
                  ? context.appColors.border
                  : AppConstants.primary.withOpacity(0.14),
            ),
          ),
          child: Column(
            children: [
              Text(
                '+$hours hr',
                style: context.appText.titleMedium?.copyWith(
                  color: disabled
                      ? context.appColors.textMuted
                      : AppConstants.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                disabled ? '--:--' : _formatTime(context, newEndUtc),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appText.bodySmall?.copyWith(
                  color: context.appColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingScreenState extends State<BookingScreen> {
  BookingSortType sortType = BookingSortType.newest;
  bool _showBackHomeFab = true;

  void _setBackHomeFabVisible(bool visible) {
    if (_showBackHomeFab == visible || !mounted) return;

    setState(() {
      _showBackHomeFab = visible;
    });
  }

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

  bool _canAddExtraTime(Booking? booking, bool allowedRole) {
    if (booking == null) return false;

    final status = booking.status.toLowerCase().trim();

    final startRaw = booking.actualStartDatetime ?? booking.startDatetime;
    final endRaw = booking.endDatetime;

    if (!allowedRole) return false;
    if (startRaw == null || endRaw == null) return false;

    // ✅ Allow approved OR in_meeting if current time is inside meeting time
    if (status != 'approved' && status != 'in_meeting') {
      return false;
    }

    // ✅ Safe even if model already converted to UTC
    final startUtc = DateTimeHelper.asDate(startRaw);
    final endUtc = DateTimeHelper.asDate(endRaw);
    final nowUtc = DateTime.now().toUtc();

    final hasStarted =
        nowUtc.isAfter(startUtc!) || nowUtc.isAtSameMomentAs(startUtc);

    final notEnded = nowUtc.isBefore(endUtc!);

    debugPrint('========== CAN ADD EXTRA TIME ==========');
    debugPrint('bookingId: ${booking.bookingId}');
    debugPrint('status: $status');
    debugPrint('startRaw isUtc: ${startRaw.isUtc}');
    debugPrint('endRaw isUtc: ${endRaw.isUtc}');
    debugPrint('startUtc: $startUtc');
    debugPrint('endUtc: $endUtc');
    debugPrint('nowUtc: $nowUtc');
    debugPrint('hasStarted: $hasStarted');
    debugPrint('notEnded: $notEnded');
    debugPrint('canAdd: ${hasStarted && notEnded}');
    debugPrint('========================================');

    return hasStarted && notEnded;
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

  Future<void> _openAddExtraTime(BuildContext context, Booking booking) async {
    final selectedHours = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _ExtraTimeSheet(booking: booking);
      },
    );

    if (selectedHours == null || !context.mounted) {
      return;
    }

    final controller = context.read<BookingController>();

    final ok = await controller.addExtraTime(
      id: booking.bookingId,
      extraHours: selectedHours,
    );

    if (ok && context.mounted) {
      await controller.fetchBookings();
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: ok
              ? context.appColors.success
              : context.appColors.danger,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              Icon(
                ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                size: 21,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ok
                      ? 'Meeting extended by $selectedHours hour${selectedHours > 1 ? 's' : ''}.'
                      : controller.error ?? 'Unable to extend meeting time.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // Start Meeting API
  Future<void> _startMeeting(BuildContext context, Booking booking) async {
    final controller = context.read<BookingController>();
    final success = await controller.startMeeting(booking.bookingId);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Meeting started'
              : controller.error ?? 'Failed to start meeting',
        ),
      ),
    );

    if (success) {
      await controller.fetchBookings();
    }
  }

  // Leave Meeting API
  Future<void> _leaveMeeting(BuildContext context, Booking booking) async {
    final controller = context.read<BookingController>();
    final success = await controller.leaveMeeting(booking.bookingId);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Meeting ended'
              : controller.error ?? 'Failed to leave meeting',
        ),
      ),
    );

    if (success) {
      await controller.fetchBookings();
    }
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
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis != Axis.vertical) {
            return false;
          }

          if (notification.metrics.pixels <= 10) {
            _setBackHomeFabVisible(true);
            return false;
          }

          if (notification.direction == ScrollDirection.reverse) {
            _setBackHomeFabVisible(false);
          } else if (notification.direction == ScrollDirection.forward) {
            _setBackHomeFabVisible(true);
          }

          return false;
        },
        child: Consumer<BookingController>(
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
              onRefresh: () async {
                await controller.fetchBookings();
              },
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

                  debugPrint(
                    "booking time UTC => start: ${booking.startDatetime?.toUtc()}, end: ${booking.endDatetime?.toUtc()}",
                  );

                  debugPrint(
                    "booking time LOCAL => start: ${booking.startDatetime?.toLocal()}, end: ${booking.endDatetime?.toLocal()}",
                  );

                  final allowedRole = isUser || isAdmin;

                  final allowedByBooking = _canAddExtraTime(
                    booking,
                    allowedRole,
                  );

                  final canExtend = !controller.submitting && allowedByBooking;

                  return BookingCard(
                    booking: booking,
                    onExtend: canExtend
                        ? () {
                            _openAddExtraTime(context, booking);
                          }
                        : null,
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
                    onShare: () => BookingExportService.shareSingleBooking(
                      context: context,
                      booking: booking,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AnimatedSlide(
        offset: _showBackHomeFab ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _showBackHomeFab ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: IgnorePointer(
            ignoring: !_showBackHomeFab,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 2),
              child: FloatingActionButton.extended(
                heroTag: 'back_to_room_screen',
                elevation: 6,
                highlightElevation: 3,
                backgroundColor: AppConstants.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                icon: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
                label: Text(
                  'Back Home',
                  style: context.appText.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RoomScreen(showHomeHeader: true),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
