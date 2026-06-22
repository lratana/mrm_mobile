import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/app_palette.dart';

class ModernActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool compact;
  final bool fullWidth;
  final VoidCallback? onTap;

  const ModernActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.compact,
    required this.fullWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: color.withOpacity(context.isDarkMode ? 0.18 : 0.11),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: fullWidth
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.bodySmall?.copyWith(
                    color: color,
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
