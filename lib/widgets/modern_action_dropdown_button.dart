import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/booking_model.dart';
import 'package:flutter_application_1/utils/app_palette.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:flutter_application_1/widgets/modern_action_button.dart';

class ModernActionDropdownButton extends StatelessWidget {
  final Booking booking;
  final bool compact;
  final bool fullWidth;

  final VoidCallback? onExtend;
  final VoidCallback? onUpdate;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;

  const ModernActionDropdownButton({
    super.key,
    required this.booking,
    required this.compact,
    required this.fullWidth,

    this.onExtend,
    this.onUpdate,
    this.onApprove,
    this.onReject,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More actions',
      color: context.appColors.surface,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (value) {
        switch (value) {
          case 'extend':
            onExtend?.call();
            break;
          case 'update':
            onUpdate?.call();
            break;
          case 'approve':
            onApprove?.call();
            break;
          case 'reject':
            onReject?.call();
            break;
          case 'delete':
            onDelete?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        if (onExtend != null)
          _popupItem(
            context,
            value: 'extend',
            label: 'Extra Time',
            icon: Icons.more_time_rounded,
            color: AppConstants.primary,
          ),

        if (onUpdate != null)
          _popupItem(
            context,
            value: 'update',
            label: 'Edit',
            icon: Icons.edit_rounded,
            color: context.appColors.warning,
          ),

        if (onApprove != null)
          _popupItem(
            context,
            value: 'approve',
            label: 'Approve',
            icon: Icons.check_rounded,
            color: context.appColors.success,
          ),

        if (onReject != null)
          _popupItem(
            context,
            value: 'reject',
            label: 'Reject',
            icon: Icons.close_rounded,
            color: context.appColors.danger,
          ),

        if (onDelete != null)
          _popupItem(
            context,
            value: 'delete',
            label: 'Delete',
            icon: Icons.delete_outline_rounded,
            color: context.appColors.danger,
          ),
      ],
      child: ModernActionButton(
        label: 'More Actions',
        icon: Icons.arrow_downward,
        color: AppConstants.primary,
        compact: compact,
        fullWidth: fullWidth,
        onTap: null,
      ),
    );
  }

  PopupMenuItem<String> _popupItem(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: context.appText.bodyMedium?.copyWith(
              color: context.appColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
