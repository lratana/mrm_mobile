import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../services/booking_export_service.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';

enum BookingExportAction { copy, share, csv }

class BookingExportMenu extends StatelessWidget {
  final List<Booking> bookings;

  const BookingExportMenu({super.key, required this.bookings});

  Future<void> _handleAction(
    BuildContext context,
    BookingExportAction action,
  ) async {
    switch (action) {
      case BookingExportAction.copy:
        await BookingExportService.copyBookings(
          context: context,
          bookings: bookings,
        );
        break;

      case BookingExportAction.share:
        await BookingExportService.shareBookings(
          context: context,
          bookings: bookings,
        );
        break;

      case BookingExportAction.csv:
        await BookingExportService.exportCsv(
          context: context,
          bookings: bookings,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<BookingExportAction>(
      tooltip: 'Export bookings',
      elevation: 12,
      offset: const Offset(0, 52),
      color: context.appColors.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: context.appColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: context.appColors.border),
      ),
      onSelected: (action) async {
        await _handleAction(context, action);
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem<BookingExportAction>(
            value: BookingExportAction.copy,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: _ExportMenuItem(
              icon: Icons.copy_all_rounded,
              label: 'Copy text',
              subtitle: 'Copy booking details',
              color: AppConstants.primary,
            ),
          ),
          PopupMenuItem<BookingExportAction>(
            value: BookingExportAction.share,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: _ExportMenuItem(
              icon: Icons.ios_share_rounded,
              label: 'Share text',
              subtitle: 'Send booking details',
              color: context.appColors.success,
            ),
          ),
          PopupMenuItem<BookingExportAction>(
            value: BookingExportAction.csv,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: _ExportMenuItem(
              icon: Icons.table_view_rounded,
              label: 'Export CSV',
              subtitle: 'Spreadsheet format',
              color: context.appColors.warning,
            ),
          ),
        ];
      },
      child: _ExportButton(label: bookings.length > 1 ? '' : ''),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;

  const _ExportButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppConstants.primary.withOpacity(context.isDarkMode ? 0.18 : 0.10),
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: AppConstants.primary.withOpacity(
              context.isDarkMode ? 0.28 : 0.14,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.ios_share_rounded,
              size: 17,
              color: AppConstants.primary,
            ),
            // const SizedBox(width: 6),
            Text(
              label,
              style: context.appText.bodySmall?.copyWith(
                color: AppConstants.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            // const SizedBox(width: 3),
            // const Icon(
            //   Icons.keyboard_arrow_down_rounded,
            //   size: 18,
            //   color: AppConstants.primary,
            // ),
          ],
        ),
      ),
    );
  }
}

class _ExportMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  const _ExportMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 218,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(context.isDarkMode ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.bodyMedium?.copyWith(
                    color: context.appColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.bodySmall?.copyWith(
                    color: context.appColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
