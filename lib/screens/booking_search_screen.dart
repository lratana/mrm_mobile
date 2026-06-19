import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/booking_controller.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';
import 'available_room_screen.dart';

class EquipmentChipItem {
  final String label;
  final IconData icon;

  const EquipmentChipItem({required this.label, required this.icon});
}

final List<EquipmentChipItem> equipmentChipItems = const [
  EquipmentChipItem(label: 'Any', icon: Icons.done_all_rounded),
  EquipmentChipItem(label: 'LCD Projector', icon: Icons.tv_rounded),
  EquipmentChipItem(
    label: 'Video Conference',
    icon: Icons.video_camera_front_rounded,
  ),
  EquipmentChipItem(label: 'Microphone', icon: Icons.mic_rounded),
  EquipmentChipItem(label: 'Speaker Sound', icon: Icons.volume_up_rounded),
  EquipmentChipItem(label: 'Whiteboard', icon: Icons.draw_rounded),
  EquipmentChipItem(label: 'VIP', icon: Icons.workspace_premium_rounded),
];

class _EquipmentChipList extends StatelessWidget {
  final List<EquipmentChipItem> items;
  final List<String> selectedValues;
  final ValueChanged<String> onToggle;

  const _EquipmentChipList({
    required this.items,
    required this.selectedValues,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final selected = selectedValues.contains(item.label);

        return _EquipmentPill(
          icon: item.icon,
          label: item.label,
          selected: selected,
          onTap: () => onToggle(item.label),
        );
      }).toList(),
    );
  }
}

class BookingSearchScreen extends StatefulWidget {
  const BookingSearchScreen({super.key});

  @override
  State<BookingSearchScreen> createState() => _BookingSearchScreenState();
}

class _BookingSearchScreenState extends State<BookingSearchScreen> {
  int participants = 4;

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();

  TimeOfDay selectedStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay selectedEndTime = const TimeOfDay(hour: 11, minute: 0);

  List<String> selectedEquipment = ['Any'];

  String get selectedEquipmentText {
    if (selectedEquipment.isEmpty || selectedEquipment.contains('Any')) {
      return 'any';
    }

    return selectedEquipment.join(',');
  }

  void toggleEquipment(String equipment) {
    setState(() {
      if (equipment == 'Any') {
        selectedEquipment = ['Any'];
        return;
      }

      final updated = List<String>.from(selectedEquipment);

      // If user selects real equipment, remove Any first.
      updated.remove('Any');

      if (updated.contains(equipment)) {
        updated.remove(equipment);
      } else {
        updated.add(equipment);
      }

      // If nothing selected, fallback to Any.
      selectedEquipment = updated.isEmpty ? ['Any'] : updated;
    });
  }

  DateTime get startDateTime {
    return DateTime(
      selectedStartDate.year,
      selectedStartDate.month,
      selectedStartDate.day,
      selectedStartTime.hour,
      selectedStartTime.minute,
    );
  }

  DateTime get endDateTime {
    return DateTime(
      selectedEndDate.year,
      selectedEndDate.month,
      selectedEndDate.day,
      selectedEndTime.hour,
      selectedEndTime.minute,
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? selectedStartDate : selectedEndDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        selectedStartDate = picked;

        if (selectedEndDate.isBefore(selectedStartDate)) {
          selectedEndDate = selectedStartDate;
        }
      } else {
        selectedEndDate = picked;
      }
    });
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? selectedStartTime : selectedEndTime,
    );

    if (picked == null) return;

    setState(() {
      if (isStart) {
        selectedStartTime = picked;
      } else {
        selectedEndTime = picked;
      }
    });
  }

  void _setQuickDuration(int hours) {
    final newEnd = startDateTime.add(Duration(hours: hours));

    setState(() {
      selectedEndDate = DateTime(newEnd.year, newEnd.month, newEnd.day);
      selectedEndTime = TimeOfDay(hour: newEnd.hour, minute: newEnd.minute);
    });
  }

  Future<void> _searchAvailableRooms() async {
    if (!endDateTime.isAfter(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date/time must be after start date/time'),
        ),
      );
      return;
    }

    if (startDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date/time cannot be in the past')),
      );
      return;
    }

    final controller = context.read<BookingController>();

    await controller.fetchAvailableRooms(
      start: startDateTime,
      end: endDateTime,
      participants: participants,
      equipment: selectedEquipment,
    );
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvailableRoomScreen(
          startDateTime: startDateTime,
          endDateTime: endDateTime,
          participants: participants,
          equipment: selectedEquipmentText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<BookingController>().loading;

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppConstants.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Available Rooms',
          style: context.appText.titleLarge?.copyWith(
            color: context.appColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            8,
            AppConstants.pagePadding,
            110,
          ),
          children: [
            // _HeaderCard(
            //   startDateTime: startDateTime,
            //   endDateTime: endDateTime,
            //   participants: participants,
            //   equipment: selectedEquipment,
            // ),
            // const SizedBox(height: 18),
            _StepCard(
              step: '01',
              title: 'Date & Time',
              subtitle: 'Choose the meeting schedule',
              icon: Icons.calendar_month_rounded,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeBox(
                          label: 'Start Date *',
                          value: _formatDate(selectedStartDate),
                          icon: Icons.calendar_today_rounded,
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateTimeBox(
                          label: 'End Date *',
                          value: _formatDate(selectedEndDate),
                          icon: Icons.event_rounded,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeBox(
                          label: 'Start Time *',
                          value: _formatTime(selectedStartTime),
                          icon: Icons.access_time_rounded,
                          onTap: () => _pickTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateTimeBox(
                          label: 'End Time *',
                          value: _formatTime(selectedEndTime),
                          icon: Icons.timelapse_rounded,
                          onTap: () => _pickTime(isStart: false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Quick duration *',
                      style: context.appText.bodyMedium?.copyWith(
                        color: context.appColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _DurationPill(
                          label: '1 hour',
                          onTap: () => _setQuickDuration(1),
                        ),
                        _DurationPill(
                          label: '2 hours',
                          onTap: () => _setQuickDuration(2),
                        ),
                        _DurationPill(
                          label: '4 hours',
                          onTap: () => _setQuickDuration(4),
                        ),
                        _DurationPill(
                          label: 'Full day',
                          onTap: () => _setQuickDuration(8),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _StepCard(
              step: '02',
              title: 'Participants *',
              subtitle: 'How many people will join?',
              icon: Icons.groups_rounded,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CounterButton(
                        icon: Icons.remove_rounded,
                        onTap: participants > 1
                            ? () => setState(() => participants--)
                            : null,
                      ),

                      const SizedBox(width: 30),

                      Column(
                        children: [
                          Text(
                            '$participants',
                            style: context.appText.displaySmall?.copyWith(
                              color: AppConstants.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            participants == 1 ? 'PERSON' : 'GUESTS',
                            style: context.appText.bodySmall?.copyWith(
                              color: context.appColors.textMuted,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 30),

                      _CounterButton(
                        icon: Icons.add_rounded,
                        onTap: () => setState(() => participants++),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: [1, 2, 4, 6, 8, 10, 15, 20].map((value) {
                      return _QuickPeopleChip(
                        label: value == 20 ? '20+' : '$value',
                        selected: participants == value,
                        onTap: () => setState(() => participants = value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _StepCard(
              step: '03',
              title: 'Equipment *',
              subtitle: 'Choose required room facilities',
              icon: Icons.devices_other_rounded,
              child: _EquipmentChipList(
                items: equipmentChipItems,
                selectedValues: selectedEquipment,
                onToggle: toggleEquipment,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.pagePadding,
            12,
            AppConstants.pagePadding,
            14,
          ),
          decoration: BoxDecoration(
            color: context.appColors.background,
            boxShadow: [
              BoxShadow(
                color: context.appColors.shadow,
                blurRadius: 18,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SizedBox(
            height: 58,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : _searchAvailableRooms,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primary,
                disabledBackgroundColor: context.appColors.surfaceSoft,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Check Available Rooms',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12
        ? hour - 12
        : hour == 0
        ? 12
        : hour;

    return '$displayHour:$minute $suffix';
  }
}

class _HeaderCard extends StatelessWidget {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int participants;
  final String equipment;

  const _HeaderCard({
    required this.startDateTime,
    required this.endDateTime,
    required this.participants,
    required this.equipment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.primary,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primary.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.meeting_room_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Find available rooms',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Choose your schedule, participants and equipment.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SummaryChip(
                icon: Icons.groups_rounded,
                text: '$participants people',
              ),
              _SummaryChip(
                icon: Icons.access_time_rounded,
                text:
                    '${_shortTime(startDateTime)} - ${_shortTime(endDateTime)}',
              ),
              _SummaryChip(icon: Icons.devices_other_rounded, text: equipment),
            ],
          ),
        ],
      ),
    );
  }

  static String _shortTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12
        ? hour - 12
        : hour == 0
        ? 12
        : hour;

    return '$displayHour:$minute $suffix';
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SummaryChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _StepCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.appColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppConstants.primary, size: 25),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP $step',
                      style: context.appText.bodySmall?.copyWith(
                        color: AppConstants.primary,
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      style: context.appText.titleMedium?.copyWith(
                        color: context.appColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.appText.bodySmall?.copyWith(
                        color: context.appColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Material(
      color: disabled
          ? context.appColors.surfaceSoft
          : context.appColors.primarySoft,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            icon,
            color: disabled
                ? context.appColors.textMuted
                : AppConstants.primary,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _QuickPeopleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _QuickPeopleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppConstants.primary : context.appColors.primarySoft,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 62,
          height: 48,
          child: Center(
            child: Text(
              label,
              style: context.appText.titleMedium?.copyWith(
                color: selected ? Colors.white : AppConstants.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimeBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surfaceSoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 84,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.appColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppConstants.primary, size: 23),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.bodySmall?.copyWith(
                        color: context.appColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.bodyMedium?.copyWith(
                        color: context.appColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DurationPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: Material(
        color: context.appColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              label,
              style: context.appText.bodySmall?.copyWith(
                color: AppConstants.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EquipmentPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _EquipmentPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppConstants.primary : context.appColors.surfaceSoft,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected ? AppConstants.primary : context.appColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : AppConstants.primary,
              ),
              const SizedBox(width: 7),
              Text(
                selected ? '$label ✓' : label,
                style: context.appText.bodySmall?.copyWith(
                  color: selected ? Colors.white : context.appColors.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
