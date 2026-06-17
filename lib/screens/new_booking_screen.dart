import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/booking_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/booking_controller.dart';
import '../models/booking_model.dart';
import '../models/room_model.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';
import '../widgets/room_card.dart';

class NewBookingScreen extends StatefulWidget {
  final Room room;
  final Booking? booking;

  final DateTime? initialStartDateTime;
  final DateTime? initialEndDateTime;

  const NewBookingScreen({
    super.key,
    required this.room,
    this.booking,
    this.initialStartDateTime,
    this.initialEndDateTime,
  });

  bool get isEdit => booking != null;
  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 11, minute: 0);
  int durationHours = 2;

  bool snackRequired = false;
  bool technicianRequired = false;

  String selectedTimeOption = 'custom';

  String recurrenceType = 'none';
  int recurrencePeriod = 1;
  DateTime? recurrenceUntil;

  final TextEditingController meetingTitle = TextEditingController();
  final TextEditingController chairman = TextEditingController();
  final TextEditingController snackNote = TextEditingController();
  final TextEditingController technicianNote = TextEditingController();

  static const String _noMeetingTitle = 'No Title';
  static const String _customMeetingTitle = 'Other / Custom Title';

  final List<String> meetingTitleOptions = const [
    _noMeetingTitle,
    'Weekly Team Meeting',
    'Monthly Management Meeting',
    'Quarterly Strategy Sync',
    'Project Review Meeting',
    'Client Meeting',
    'Training Session',
    'Workshop',
    'Interview Meeting',
    _customMeetingTitle,
  ];

  String selectedMeetingTitle = _noMeetingTitle;
  bool showCustomMeetingTitle = false;

  final List<TimeOfDay> times = const [
    TimeOfDay(hour: 8, minute: 0),
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
    TimeOfDay(hour: 17, minute: 0),
    TimeOfDay(hour: 18, minute: 0),
  ];

  final List<_BookingTimePreset> timePresets = const [
    _BookingTimePreset(
      value: 'morning',
      label: 'Morning',
      startTime: TimeOfDay(hour: 9, minute: 0),
      hours: 3,
      icon: Icons.wb_sunny_outlined,
    ),
    _BookingTimePreset(
      value: 'afternoon',
      label: 'Afternoon',
      startTime: TimeOfDay(hour: 13, minute: 0),
      hours: 4,
      icon: Icons.light_mode_outlined,
    ),
    _BookingTimePreset(
      value: 'full_day',
      label: 'Full Day',
      startTime: TimeOfDay(hour: 9, minute: 0),
      hours: 8,
      icon: Icons.calendar_view_day_outlined,
    ),
    _BookingTimePreset(
      value: 'custom',
      label: 'Custom',
      startTime: TimeOfDay(hour: 11, minute: 0),
      hours: 2,
      icon: Icons.tune_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    final booking = widget.booking;

    final start = booking?.startDatetime ?? widget.initialStartDateTime;

    final end = booking?.endDatetime ?? widget.initialEndDateTime;

    if (start != null) {
      selectedDate = DateTime(start.year, start.month, start.day);
      selectedTime = TimeOfDay(hour: start.hour, minute: start.minute);
    }

    if (start != null && end != null) {
      final duration = end.difference(start);

      durationHours = duration.inMinutes ~/ 60;

      if (duration.inMinutes % 60 != 0) {
        durationHours += 1;
      }
    }

    if (booking == null) return;

    meetingTitle.text = booking.meetingTitle;

    if (booking.meetingTitle.trim().isEmpty) {
      selectedMeetingTitle = _noMeetingTitle;
    } else if (meetingTitleOptions.contains(booking.meetingTitle)) {
      selectedMeetingTitle = booking.meetingTitle;
    } else {
      selectedMeetingTitle = _customMeetingTitle;
      showCustomMeetingTitle = true;
    }

    chairman.text = booking.meetingChairman;

    snackRequired = booking.snackRequired;
    snackNote.text = booking.snackNote ?? '';

    technicianRequired = booking.technicianRequired;
    technicianNote.text = booking.technicianNote ?? '';

    recurrenceType = booking.recurrenceType.trim().isEmpty
        ? 'none'
        : booking.recurrenceType;

    recurrencePeriod = booking.recurrencePeriod ?? 1;
    recurrenceUntil = booking.recurrenceUntil;
  }

  @override
  void dispose() {
    meetingTitle.dispose();
    chairman.dispose();
    snackNote.dispose();
    technicianNote.dispose();
    super.dispose();
  }

  DateTime get _startDateTime {
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  DateTime get _endDateTime {
    return _startDateTime.add(Duration(hours: durationHours));
  }

  bool get _scheduleLocked {
    return !widget.isEdit &&
        widget.initialStartDateTime != null &&
        widget.initialEndDateTime != null;
  }

  String _apiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  String _timeText(TimeOfDay time) {
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      time.hour,
      time.minute,
    );
    return DateFormat('hh:mm a').format(date);
  }

  void _applyTimePreset(_BookingTimePreset preset) {
    setState(() {
      selectedTimeOption = preset.value;

      if (preset.value != 'custom') {
        selectedTime = preset.startTime;
        durationHours = preset.hours;
      }
    });
  }

  void _selectMeetingTitle(String? value) {
    if (value == null) return;

    setState(() {
      selectedMeetingTitle = value;
      showCustomMeetingTitle = value == _customMeetingTitle;

      if (value == _noMeetingTitle) {
        meetingTitle.clear();
      } else if (value != _customMeetingTitle) {
        meetingTitle.text = value;
      } else if (meetingTitleOptions.contains(meetingTitle.text)) {
        meetingTitle.clear();
      }
    });
  }

  Future<void> _pickBookingDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = firstDate.add(const Duration(days: 60));

    final safeInitialDate = selectedDate.isBefore(firstDate)
        ? firstDate
        : selectedDate.isAfter(lastDate)
        ? lastDate
        : selectedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Booking Date',
      confirmText: 'Select',
      cancelText: 'Cancel',
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });
  }

  Future<void> _pickRecurrenceUntil() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = firstDate.add(const Duration(days: 60));

    final candidate = recurrenceUntil ?? firstDate;

    final safeInitialDate = candidate.isBefore(firstDate)
        ? firstDate
        : candidate.isAfter(lastDate)
        ? lastDate
        : candidate;

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInitialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select Recurrence End Date',
      confirmText: 'Select',
      cancelText: 'Cancel',
    );

    if (picked == null) return;

    setState(() {
      recurrenceUntil = picked;
    });
  }

  Future<void> _submit() async {
    if (meetingTitle.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter meeting title')),
      );
      return;
    }
    if (chairman.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter meeting chairman')),
      );
      return;
    }

    if (recurrenceType != 'none' && recurrenceUntil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select recurrence until date')),
      );
      return;
    }

    if (recurrenceType == 'none') {
      recurrenceUntil = null;
      recurrencePeriod = 1;
    }

    final payload = <String, dynamic>{
      'room_id': widget.room.id,
      'start_datetime': _apiDate(_startDateTime),
      'end_datetime': _apiDate(_endDateTime),
      'recurrence_type': recurrenceType,
      if (recurrenceType == 'weekly')
        'recurrence_days': <String>[
          DateFormat('E').format(selectedDate).substring(0, 3).toLowerCase(),
        ],
      if (recurrenceType != 'none') 'recurrence_period': recurrencePeriod,
      if (recurrenceType != 'none' && recurrenceUntil != null)
        'recurrence_until': DateFormat('yyyy-MM-dd').format(recurrenceUntil!),
      'meeting_title': meetingTitle.text.trim().isEmpty
          ? null
          : meetingTitle.text.trim(),
      'meeting_chairman': chairman.text.trim(),
      'snack_required': snackRequired ? 1 : 0,
      'snack_note': snackRequired ? snackNote.text.trim() : null,
      'technician_required': technicianRequired ? 1 : 0,
      'technician_note': technicianRequired ? technicianNote.text.trim() : null,
    };

    debugPrint('BOOKING PAYLOAD: $payload');

    try {
      final controller = context.read<BookingController>();

      final ok = widget.isEdit
          ? await controller.updateBooking(widget.booking!.bookingId, payload)
          : await controller.createBooking(payload);

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Booking updated successfully'
                  : 'Booking submitted successfully',
            ),
          ),
        );

        await controller.fetchBookings();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BookingScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(controller.error ?? 'Booking failed')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Booking error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingController = context.watch<BookingController>();

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        foregroundColor: context.appColors.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isEdit ? 'Update Booking' : 'New Booking',
          style: context.appText.titleLarge?.copyWith(
            color: context.appColors.text,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          _RoomSummary(room: widget.room),

          const SizedBox(height: 24),

          if (_scheduleLocked) ...[
            const _SectionTitle('Selected Schedule'),

            _LockedScheduleCard(
              startDateTime: _startDateTime,
              endDateTime: _endDateTime,
            ),

            const SizedBox(height: 24),
          ] else ...[
            const _SectionTitle('Select Date *'),

            _DateSelector(selectedDate: selectedDate, onTap: _pickBookingDate),

            const SizedBox(height: 24),

            const _SectionTitle('Select Time Option *'),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timePresets.map((preset) {
                final selected = selectedTimeOption == preset.value;

                return _TimeChoiceChip(
                  icon: preset.icon,
                  label: preset.label,
                  selected: selected,
                  onSelected: () => _applyTimePreset(preset),
                );
              }).toList(),
            ),

            const SizedBox(height: 14),

            SelectedTimePanel(
              text:
                  'Selected: ${_timeText(selectedTime)} - ${DateFormat('hh:mm a').format(_endDateTime.toLocal())}',
            ),

            const SizedBox(height: 24),

            const _SectionTitle('Select Start Time *'),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: times.map((time) {
                final selected =
                    time.hour == selectedTime.hour &&
                    time.minute == selectedTime.minute;

                return _StartTimeChip(
                  label: time.format(context),
                  selected: selected,
                  onSelected: () {
                    setState(() {
                      selectedTimeOption = 'custom';
                      selectedTime = time;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 26),

            const _SectionTitle('Booking Duration'),

            _StepControlBox(
              title: 'Duration\n(hours)',
              value: durationHours,
              onDecrease: durationHours > 1
                  ? () {
                      setState(() {
                        selectedTimeOption = 'custom';
                        durationHours--;
                      });
                    }
                  : null,
              onIncrease: () {
                setState(() {
                  selectedTimeOption = 'custom';
                  durationHours++;
                });
              },
            ),

            const SizedBox(height: 24),
          ],

          const _SectionTitle('Meeting Title *'),

          MeetingTitleSelector(
            value: selectedMeetingTitle,
            titles: meetingTitleOptions,
            onChanged: _selectMeetingTitle,
          ),

          if (showCustomMeetingTitle) ...[
            const SizedBox(height: 12),
            _Input(
              controller: meetingTitle,
              hint: 'Enter custom meeting title',
            ),
          ],

          const SizedBox(height: 22),

          const _SectionTitle('Meeting Chairman *'),

          _Input(controller: chairman, hint: 'Enter chairman name'),

          const SizedBox(height: 22),

          const _SectionTitle('Snacks & Catering'),

          _SwitchBox(
            title: 'Snack Required',
            value: snackRequired,
            onChanged: (value) {
              setState(() {
                snackRequired = value;
              });
            },
          ),

          if (snackRequired) ...[
            const SizedBox(height: 8),
            _Input(controller: snackNote, hint: 'Snack Note'),
          ],

          const SizedBox(height: 22),

          const _SectionTitle('Technical Support'),

          _SwitchBox(
            title: 'Technician Required',
            value: technicianRequired,
            onChanged: (value) {
              setState(() {
                technicianRequired = value;
              });
            },
          ),

          if (technicianRequired) ...[
            const SizedBox(height: 8),
            _Input(controller: technicianNote, hint: 'Technician Note'),
          ],

          const SizedBox(height: 22),

          const _SectionTitle('Recurrence Type'),

          _RecurrenceTypePanel(
            recurrenceType: recurrenceType,
            onChanged: (value) {
              setState(() {
                recurrenceType = value ?? 'none';

                if (recurrenceType == 'none') {
                  recurrenceUntil = null;
                  recurrencePeriod = 1;
                }
              });
            },
          ),

          if (recurrenceType != 'none') ...[
            const SizedBox(height: 22),

            const _SectionTitle('Recurrence Period'),

            _StepControlBox(
              title: recurrenceType == 'daily'
                  ? 'Repeat every $recurrencePeriod day(s)'
                  : 'Repeat every $recurrencePeriod week(s)',
              value: recurrencePeriod,
              onDecrease: recurrencePeriod > 1
                  ? () {
                      setState(() {
                        recurrencePeriod--;
                      });
                    }
                  : null,
              onIncrease: () {
                setState(() {
                  recurrencePeriod++;
                });
              },
            ),

            const SizedBox(height: 22),

            const _SectionTitle('Recurrence Until'),

            _RecurrenceDateSelector(
              recurrenceUntil: recurrenceUntil,
              onTap: _pickRecurrenceUntil,
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: bookingController.submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: context.appColors.surfaceSoft,
                disabledForegroundColor: context.appColors.textMuted,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: bookingController.submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_forward_rounded),
              label: Text(
                widget.isEdit ? 'Update Booking' : 'Confirm Booking',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _LockedScheduleCard extends StatelessWidget {
  final DateTime startDateTime;
  final DateTime endDateTime;

  const _LockedScheduleCard({
    required this.startDateTime,
    required this.endDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat('EEEE, dd MMM yyyy').format(startDateTime);
    final startText = DateFormat('hh:mm a').format(startDateTime);
    final endText = DateFormat('hh:mm a').format(endDateTime);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(context),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.appColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lock_clock_rounded,
                  color: AppConstants.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Schedule selected from available-room search',
                  style: context.appText.bodyMedium?.copyWith(
                    color: context.appColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _LockedScheduleRow(
            icon: Icons.calendar_month_rounded,
            label: 'Date',
            value: dateText,
          ),

          const SizedBox(height: 10),

          _LockedScheduleRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: '$startText - $endText',
          ),
        ],
      ),
    );
  }
}

class _LockedScheduleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _LockedScheduleRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppConstants.primary),
        const SizedBox(width: 10),
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: context.appText.bodyMedium?.copyWith(
              color: context.appColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingHeroSummary extends StatelessWidget {
  final Room room;
  final String dateText;
  final String startText;

  const _BookingHeroSummary({
    required this.room,
    required this.dateText,
    required this.startText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primary.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          RoomImageBox(
            url: room.imageUrl,
            width: 82,
            height: 82,
            borderRadius: BorderRadius.circular(18),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BOOKING ROOM',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  room.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                _HeroInfoRow(
                  icon: Icons.calendar_month_rounded,
                  text: dateText,
                ),

                const SizedBox(height: 5),

                _HeroInfoRow(icon: Icons.access_time_rounded, text: startText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white.withOpacity(0.82)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.82),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class BookingStepCard extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const BookingStepCard({
    super.key,
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

class MeetingTitleSelector extends StatelessWidget {
  final String value;
  final List<String> titles;
  final ValueChanged<String?> onChanged;

  const MeetingTitleSelector({
    super.key,
    required this.value,
    required this.titles,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration(context),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: context.appColors.surface,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppConstants.primary,
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.groups_2_outlined,
            color: AppConstants.primary,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        ),
        items: titles
            .map(
              (title) => DropdownMenuItem<String>(
                value: title,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.bodyMedium?.copyWith(
                    color: title == _NewBookingScreenState._noMeetingTitle
                        ? context.appColors.textMuted
                        : context.appColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _BookingTimePreset {
  final String value;
  final String label;
  final TimeOfDay startTime;
  final int hours;
  final IconData icon;

  const _BookingTimePreset({
    required this.value,
    required this.label,
    required this.startTime,
    required this.hours,
    required this.icon,
  });
}

class _RoomSummary extends StatelessWidget {
  final Room room;

  const _RoomSummary({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _boxDecoration(context),
      child: Row(
        children: [
          RoomImageBox(
            url: room.imageUrl,
            width: 70,
            height: 56,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              room.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.appText.titleMedium?.copyWith(
                color: context.appColors.text,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onTap;

  const _DateSelector({required this.selectedDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: _boxDecoration(context),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: AppConstants.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Date',
                    style: context.appText.bodySmall?.copyWith(
                      color: context.appColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
                    style: context.appText.bodyMedium?.copyWith(
                      color: context.appColors.text,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: context.appColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeChoiceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _TimeChoiceChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: selected ? Colors.white : AppConstants.primary,
      ),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppConstants.primary,
      backgroundColor: context.appColors.surface,
      side: BorderSide(
        color: selected ? AppConstants.primary : context.appColors.border,
      ),
      onSelected: (_) => onSelected(),
      labelStyle: context.appText.bodySmall?.copyWith(
        color: selected ? Colors.white : context.appColors.text,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _StartTimeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _StartTimeChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: SizedBox(width: 82, child: Center(child: Text(label))),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppConstants.primary,
      backgroundColor: context.appColors.surface,
      side: BorderSide(
        color: selected ? AppConstants.primary : context.appColors.border,
      ),
      onSelected: (_) => onSelected(),
      labelStyle: context.appText.bodySmall?.copyWith(
        color: selected ? Colors.white : context.appColors.text,
        fontWeight: FontWeight.w800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class SelectedTimePanel extends StatelessWidget {
  final String text;

  const SelectedTimePanel({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // soft card background
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade300, // subtle border
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: AppConstants.primaryDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepControlBox extends StatelessWidget {
  final String title;
  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  const _StepControlBox({
    required this.title,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _boxDecoration(context),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.appText.bodyMedium?.copyWith(
                color: context.appColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _CircleButton(icon: Icons.remove, onTap: onDecrease),
          SizedBox(
            width: 44,
            child: Center(
              child: Text(
                '$value',
                style: context.appText.titleMedium?.copyWith(
                  color: AppConstants.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          _CircleButton(icon: Icons.add, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: context.appText.titleLarge?.copyWith(
          color: context.appColors.text,
          fontSize: 19,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _Input({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration(context),
      child: TextField(
        controller: controller,
        style: context.appText.bodyMedium?.copyWith(
          color: context.appColors.text,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: context.appText.bodyMedium?.copyWith(
            color: context.appColors.textMuted,
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _SwitchBox extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchBox({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: _boxDecoration(context),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.appText.bodyMedium?.copyWith(
                color: context.appColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primary,
          ),
        ],
      ),
    );
  }
}

class _RecurrenceTypePanel extends StatelessWidget {
  final String recurrenceType;
  final ValueChanged<String?> onChanged;

  const _RecurrenceTypePanel({
    required this.recurrenceType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: _boxDecoration(context),
      child: Column(
        children: ['none', 'daily', 'weekly'].map((type) {
          return RadioListTile<String>(
            contentPadding: EdgeInsets.zero,
            title: Text(
              type[0].toUpperCase() + type.substring(1),
              style: context.appText.bodyMedium?.copyWith(
                color: context.appColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
            value: type,
            groupValue: recurrenceType,
            activeColor: AppConstants.primary,
            onChanged: onChanged,
          );
        }).toList(),
      ),
    );
  }
}

class _RecurrenceDateSelector extends StatelessWidget {
  final DateTime? recurrenceUntil;
  final VoidCallback onTap;

  const _RecurrenceDateSelector({
    required this.recurrenceUntil,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: _boxDecoration(context),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: AppConstants.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recurrenceUntil == null
                    ? 'Select end date'
                    : DateFormat('yyyy-MM-dd').format(recurrenceUntil!),
                style: context.appText.bodyMedium?.copyWith(
                  color: recurrenceUntil == null
                      ? context.appColors.textMuted
                      : context.appColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;

    return Material(
      color: disabled
          ? context.appColors.surfaceSoft
          : context.appColors.primarySoft,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            color: disabled
                ? context.appColors.textMuted
                : AppConstants.primary,
          ),
        ),
      ),
    );
  }
}

BoxDecoration _boxDecoration(BuildContext context) {
  return BoxDecoration(
    color: context.appColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: context.appColors.border),
    boxShadow: [
      BoxShadow(
        color: context.appColors.shadow,
        blurRadius: 16,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
