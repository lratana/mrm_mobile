import 'dart:typed_data';
import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:to_csv/to_csv.dart' as export_csv;

import '../models/booking_model.dart';

class BookingExportService {
  const BookingExportService._();

  // ---------------- Base datetime formatting ----------------
  static String _date(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String _time(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('HH:mm').format(date);
  }

  static String _dateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String _meetingTitle(Booking booking) {
    final title = booking.meetingTitle?.trim() ?? '';
    return title.isEmpty ? 'No Title' : title;
  }

  static String _roomName(Booking booking) {
    return booking.room?.name ?? 'Room #${booking.roomId}';
  }

  static String _status(Booking booking) {
    return booking.status.replaceAll('_', ' ').toUpperCase();
  }

  // ---------------- Build text for sharing ----------------
  static String buildShareText(List<Booking> bookings) {
    if (bookings.isEmpty) return 'No bookings available.';

    final buffer = StringBuffer();
    buffer.writeln('ROOM BOOKING LIST');
    buffer.writeln('Generated: ${_dateTime(DateTime.now())}');
    buffer.writeln('Total: ${bookings.length}\n');

    for (int index = 0; index < bookings.length; index++) {
      final booking = bookings[index];

      buffer.writeln('${index + 1}. ${_meetingTitle(booking)}');
      buffer.writeln('Room: ${_roomName(booking)}');
      buffer.writeln('Date: ${_date(booking.startDatetime)}');
      buffer.writeln(
        'Time: ${_time(booking.startDatetime)} - ${_time(booking.endDatetime)}',
      );
      buffer.writeln(
        'Chairman: ${booking.meetingChairman?.trim().isEmpty ?? true ? '-' : booking.meetingChairman}',
      );
      buffer.writeln('Status: ${_status(booking)}');

      if (index < bookings.length - 1) buffer.writeln('');
    }

    return buffer.toString().trim();
  }

  // ---------------- CSV Headers ----------------
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

  // ---------------- CSV Rows ----------------
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
        booking.meetingChairman?.trim().isEmpty ?? true
            ? '-'
            : booking.meetingChairman!.trim(),
        _status(booking),
        _dateTime(booking.createdAt),
        _dateTime(booking.updatedAt),
      ];
    });
  }

  // ---------------- Copy / Share ----------------
  static Future<void> copyBookings({
    required BuildContext context,
    required List<Booking> bookings,
  }) async {
    if (bookings.isEmpty) return _showMessage(context, 'No bookings to copy');

    try {
      await FlutterClipboard.copy(buildShareText(bookings));
      _showMessage(context, 'Booking list copied');
    } catch (e) {
      _showMessage(context, 'Copy failed: $e');
    }
  }

  static Future<void> shareBookings({
    required BuildContext context,
    required List<Booking> bookings,
  }) async {
    if (bookings.isEmpty) return _showMessage(context, 'No bookings to share');

    try {
      await Share.share(buildShareText(bookings), subject: 'Room Booking List');
    } catch (e) {
      _showMessage(context, 'Share failed: $e');
    }
  }

  // ---------------- Export CSV using file_saver ----------------
  static Future<void> exportCsv({
    required BuildContext context,
    required List<Booking> bookings,
  }) async {
    if (bookings.isEmpty) return _showMessage(context, 'No bookings to export');

    try {
      final fileName =
          'room-bookings-${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
      final csvContent = export_csv.myCSV(
        csvHeaders(),
        csvRows(bookings),
        setHeadersInFirstRow: true,
        includeNoRow: false,
      );

      final bytes = Uint8List.fromList(utf8.encode(csvContent.toString()));
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        fileExtension: "csv",
        mimeType: MimeType.csv,
      );

      _showMessage(context, 'CSV file exported');
    } catch (e) {
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

  // ---------------- Single booking helpers ----------------
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

      final csvContent = export_csv.myCSV(
        csvHeaders(),
        csvRows([booking]),
        setHeadersInFirstRow: true,
        includeNoRow: false,
      );

      final bytes = Uint8List.fromList(utf8.encode(csvContent.toString()));
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        fileExtension: "csv",
        mimeType: MimeType.csv,
      );

      _showMessage(context, 'Booking #${booking.bookingId} exported to CSV');
    } catch (e) {
      _showMessage(context, 'CSV export failed: $e');
    }
  }
}
