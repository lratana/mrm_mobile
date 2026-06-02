import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/app_palette.dart';
import 'package:provider/provider.dart';

import '../controllers/theme_controller.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final colors = context.appColors;
    final text = context.appText;

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Theme', style: text.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Choose how the application appears on your device.',
            style: text.bodyMedium?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 20),
          _ThemeOption(
            title: 'System default',
            subtitle: 'Follow your phone appearance setting',
            icon: Icons.settings_suggest_outlined,
            selected: controller.isSystemSelected,
            onTap: controller.useSystemTheme,
          ),
          const SizedBox(height: 12),
          _ThemeOption(
            title: 'Light mode',
            subtitle: 'Always use the light appearance',
            icon: Icons.light_mode_outlined,
            selected: controller.isLightSelected,
            onTap: controller.useLightTheme,
          ),
          const SizedBox(height: 12),
          _ThemeOption(
            title: 'Dark mode',
            subtitle: 'Always use the dark appearance',
            icon: Icons.dark_mode_outlined,
            selected: controller.isDarkSelected,
            onTap: controller.useDarkTheme,
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;

    return Material(
      color: selected ? colors.primarySoft : colors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : colors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: text.bodySmall),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
