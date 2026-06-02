import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/display_settings_controller.dart';
import '../controllers/theme_controller.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  late final TextEditingController _meetingTitleController;
  late final TextEditingController _dateTimeController;

  @override
  void initState() {
    super.initState();

    final displayController = context.read<DisplaySettingsController>();

    _meetingTitleController = TextEditingController(
      text: displayController.meetingTitleLabel,
    );

    _dateTimeController = TextEditingController(
      text: displayController.dateTimeLabel,
    );
  }

  @override
  void dispose() {
    _meetingTitleController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveLabels() async {
    await context.read<DisplaySettingsController>().saveBookingLabels(
      meetingTitleLabel: _meetingTitleController.text,
      dateTimeLabel: _dateTimeController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Display settings saved')));
  }

  Future<void> _resetLabels() async {
    final controller = context.read<DisplaySettingsController>();

    await controller.resetBookingLabels();

    _meetingTitleController.text = controller.meetingTitleLabel;
    _dateTimeController.text = controller.dateTimeLabel;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking labels restored to default')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final displayController = context.watch<DisplaySettingsController>();

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        title: Text(
          'Appearance',
          style: context.appText.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          _SettingsTitle(
            title: 'Theme',
            description: 'Choose the appearance of the application.',
          ),

          const SizedBox(height: 16),

          _ThemeOption(
            title: 'System default',
            subtitle: 'Follow your phone appearance setting',
            icon: Icons.settings_suggest_outlined,
            selected: themeController.themeMode == ThemeMode.system,
            onTap: () {
              themeController.setThemeMode(ThemeMode.system);
            },
          ),

          const SizedBox(height: 10),

          _ThemeOption(
            title: 'Light mode',
            subtitle: 'Always use the light appearance',
            icon: Icons.light_mode_outlined,
            selected: themeController.themeMode == ThemeMode.light,
            onTap: () {
              themeController.setThemeMode(ThemeMode.light);
            },
          ),

          const SizedBox(height: 10),

          _ThemeOption(
            title: 'Dark mode',
            subtitle: 'Always use the dark appearance',
            icon: Icons.dark_mode_outlined,
            selected: themeController.themeMode == ThemeMode.dark,
            onTap: () {
              themeController.setThemeMode(ThemeMode.dark);
            },
          ),

          const SizedBox(height: 32),

          _SettingsTitle(
            title: 'Font Size',
            description: 'Change the text size throughout the application.',
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.appColors.border),
            ),
            child: SegmentedButton<AppFontSize>(
              segments: const [
                ButtonSegment<AppFontSize>(
                  value: AppFontSize.small,
                  icon: Icon(Icons.text_decrease),
                  label: Text('Small'),
                ),
                ButtonSegment<AppFontSize>(
                  value: AppFontSize.normal,
                  icon: Icon(Icons.text_fields),
                  label: Text('Default'),
                ),
                ButtonSegment<AppFontSize>(
                  value: AppFontSize.large,
                  icon: Icon(Icons.text_increase),
                  label: Text('Large'),
                ),
              ],
              selected: {displayController.fontSize},
              onSelectionChanged: (selected) {
                displayController.setFontSize(selected.first);
              },
              showSelectedIcon: false,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: context.appColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Preview text size: ${displayController.fontSizeName}',
              style: context.appText.bodyMedium?.copyWith(
                color: context.appColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // _SettingsTitle(
          //   title: 'Booking Form Labels',
          //   description:
          //       'Customize the headings displayed on the booking form.',
          // ),

          // const SizedBox(height: 16),

          // _SettingsTextField(
          //   controller: _dateTimeController,
          //   label: 'Date and Time Heading',
          //   icon: Icons.schedule_outlined,
          // ),

          // const SizedBox(height: 12),

          // _SettingsTextField(
          //   controller: _meetingTitleController,
          //   label: 'Meeting Title Heading',
          //   icon: Icons.title_rounded,
          // ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetLabels,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.appColors.text,
                    side: BorderSide(color: context.appColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveLabels,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SettingsTitle extends StatelessWidget {
  final String title;
  final String description;

  const _SettingsTitle({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.appText.titleLarge?.copyWith(
            color: context.appColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: context.appText.bodyMedium?.copyWith(
            color: context.appColors.textMuted,
          ),
        ),
      ],
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
    return Material(
      color: selected
          ? context.appColors.primarySoft
          : context.appColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppConstants.primary : context.appColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppConstants.primary),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.appText.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: context.appText.bodySmall?.copyWith(
                        color: context.appColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: AppConstants.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _SettingsTextField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: context.appText.bodyMedium?.copyWith(
        color: context.appColors.text,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppConstants.primary),
      ),
    );
  }
}
