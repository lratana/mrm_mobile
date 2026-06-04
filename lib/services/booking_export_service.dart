import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:to_csv/to_csv.dart' as export_csv;

import '../models/booking_model.dart';

class BookingExportService {
  const BookingExportService._();

  static String _meetingTitle(Booking booking) {
    final title = booking.meetingTitle.trim();

    return title.isEmpty ? 'No Title' : title;
  }

  static String _roomName(Booking booking) {
    return booking.room?.name ?? 'Room #${booking.roomId}';
  }

  static String _status(Booking booking) {
    return booking.status.replaceAll('_', ' ').toUpperCase();
  }

  static String _date(DateTime? date) {
    if (date == null) return '-';

    return DateFormat('yyyy-MM-dd').format(date.toLocal());
  }

  static String _time(DateTime? date) {
    if (date == null) return '-';

    return DateFormat('hh:mm a').format(date.toLocal());
  }

  static String _dateTime(DateTime? date) {
    if (date == null) return '-';

    return DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal());
  }

  static String buildShareText(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return 'No bookings available.';
    }

    final buffer = StringBuffer();

    buffer.writeln('ROOM BOOKING LIST');
    buffer.writeln(
      'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
    );
    buffer.writeln('Total: ${bookings.length}');
    buffer.writeln('');

    for (int index = 0; index < bookings.length; index++) {
      final booking = bookings[index];

      buffer.writeln('${index + 1}. ${_meetingTitle(booking)}');
      buffer.writeln('Room: ${_roomName(booking)}');
      buffer.writeln('Date: ${_date(booking.startDatetime)}');
      buffer.writeln(
        'Time: ${_time(booking.startDatetime)} - '
        '${_time(booking.endDatetime)}',
      );
      buffer.writeln(
        'Chairman: ${booking.meetingChairman.trim().isEmpty ? '-' : booking.meetingChairman}',
      );
      buffer.writeln('Status: ${_status(booking)}');

      if (index < bookings.length - 1) {
        buffer.writeln('');
      }
    }

    return buffer.toString().trim();
  }

  static List<String> csvHeaders() {
    return [
      'No.',
      'Booking ID',
      'Meeting Title',
      'Room',
      'Date',
      'Start Time',
      'End Time',
      'Chairman',
      'Status',
      'Created At',
      'Updated At',
    ];
  }

  static List<List<String>> csvRows(List<Booking> bookings) {
    return List.generate(bookings.length, (index) {
      final booking = bookings[index];

      return [
        '${index + 1}',
        booking.bookingId.toString(),
        _meetingTitle(booking),
        _roomName(booking),
        _date(booking.startDatetime),
        _time(booking.startDatetime),
        _time(booking.endDatetime),
        booking.meetingChairman.trim().isEmpty
            ? '-'
            : booking.meetingChairman.trim(),
        _status(booking),
        _dateTime(booking.createdAt),
        _dateTime(booking.updatedAt),
      ];
    });
  }

  static Future<void> copyBookings({
    required BuildContext context,
    required List<Booking> bookings,
  }) async {
    if (bookings.isEmpty) {
      _showMessage(context, 'No bookings to copy');
      return;
    }

    try {
      await FlutterClipboard.copy(buildShareText(bookings));

      if (!context.mounted) return;

      _showMessage(context, 'Booking list copied');
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(context, 'Copy failed: $e');
    }
  }

  static Future<void> shareBookings({
    required BuildContext context,
    required List<Booking> bookings,
  }) async {
    if (bookings.isEmpty) {
      _showMessage(context, 'No bookings to share');
      return;
    }

    try {
      await Share.share(buildShareText(bookings), subject: 'Room Booking List');
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(context, 'Share failed: $e');
    }
  }

  static Future<void> exportCsv({
    required BuildContext context,
    required List<Booking> bookings,
  }) async {
    if (bookings.isEmpty) {
      _showMessage(context, 'No bookings to export');
      return;
    }

    try {
      final fileName =
          'room-bookings-${DateFormat('yyyy-MM-dd').format(DateTime.now())}';

      await export_csv.myCSV(
        csvHeaders(),
        csvRows(bookings),
        fileName: fileName,
        sharing: true,
        setHeadersInFirstRow: true,
        includeNoRow: false,
      );

      if (!context.mounted) return;

      _showMessage(context, 'CSV file prepared');
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(context, 'CSV export failed: $e');
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  static Future<void> copySingleBooking({
    required BuildContext context,
    required Booking booking,
  }) async {
    await copyBookings(context: context, bookings: [booking]);
  }

  static Future<void> shareSingleBooking({
    required BuildContext context,
    required Booking booking,
  }) async {
    await shareBookings(context: context, bookings: [booking]);
  }

  static Future<void> exportSingleBookingCsv({
    required BuildContext context,
    required Booking booking,
  }) async {
    try {
      final fileName =
          'booking-${booking.bookingId}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}';

      await export_csv.myCSV(
        csvHeaders(),
        csvRows([booking]),
        fileName: fileName,
        sharing: true,
        setHeadersInFirstRow: true,
        includeNoRow: false,
      );

      if (!context.mounted) return;

      _showMessage(context, 'Booking #${booking.bookingId} exported to CSV');
    } catch (e) {
      if (!context.mounted) return;

      _showMessage(context, 'CSV export failed: $e');
    }
  }
}
