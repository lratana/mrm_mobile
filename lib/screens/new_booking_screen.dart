import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/booking_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/booking_controller.dart';
import '../models/room_model.dart';
import '../utils/constants.dart';
import '../widgets/room_card.dart';

class NewBookingScreen extends StatefulWidget {
  final Room room;
  final Booking? booking;

  const NewBookingScreen({super.key, required this.room, this.booking});

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

  final meetingTitle = TextEditingController();
  final chairman = TextEditingController();
  final snackNote = TextEditingController();
  final technicianNote = TextEditingController();

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
    TimeOfDay(hour: 9, minute: 0),
    TimeOfDay(hour: 10, minute: 0),
    TimeOfDay(hour: 11, minute: 0),
    TimeOfDay(hour: 12, minute: 0),
    TimeOfDay(hour: 13, minute: 0),
    TimeOfDay(hour: 14, minute: 0),
    TimeOfDay(hour: 15, minute: 0),
    TimeOfDay(hour: 16, minute: 0),
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
      icon: Icons.tune,
    ),
  ];
  @override
  void initState() {
    super.initState();

    final booking = widget.booking;

    if (booking != null) {
      final start = booking.startDatetime;
      final end = booking.endDatetime;

      if (start != null) {
        selectedDate = DateTime(start.year, start.month, start.day);
        selectedTime = TimeOfDay(hour: start.hour, minute: start.minute);
      }

      if (start != null && end != null) {
        final hours = end.difference(start).inHours;
        durationHours = hours <= 0 ? 1 : hours;
      }

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

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 60)),
      helpText: 'Select Booking Date',
      confirmText: 'Select',
      cancelText: 'Cancel',
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickRecurrenceUntil() async {
    final first = DateTime.now();
    final last = first.add(const Duration(days: 60)); // limit 60 days

    final picked = await showDatePicker(
      context: context,
      initialDate: recurrenceUntil ?? first,
      firstDate: first,
      lastDate: last,
    );

    if (picked != null) {
      setState(() {
        recurrenceUntil = picked;
      });
    }
  }

  Future<void> _submit() async {
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

    final payload = {
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
        Navigator.pop(context);
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
      backgroundColor: AppConstants.bg,
      appBar: AppBar(
        backgroundColor: AppConstants.bg,
        elevation: 0,
        foregroundColor: AppConstants.primaryDark,
        title: Text(
          widget.isEdit ? 'Update Booking' : 'New Booking',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          _RoomSummary(room: widget.room),

          const SizedBox(height: 24),

          const _SectionTitle('Select Date *'),

          InkWell(
            onTap: _pickBookingDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: _boxDecoration(),
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
                        const Text(
                          'Booking Date',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.arrow_drop_down_rounded),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const _SectionTitle('Select Time Option *'),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timePresets.map((preset) {
              final selected = selectedTimeOption == preset.value;

              return ChoiceChip(
                avatar: Icon(
                  preset.icon,
                  size: 18,
                  color: selected ? Colors.white : AppConstants.primary,
                ),
                label: Text(preset.label),
                selected: selected,
                selectedColor: AppConstants.primary,
                backgroundColor: Colors.white,
                onSelected: (_) {
                  _applyTimePreset(preset);
                },
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppConstants.text,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: selected
                        ? AppConstants.primary
                        : AppConstants.border,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _boxDecoration(),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: AppConstants.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selected: ${_timeText(selectedTime)} - ${DateFormat('hh:mm a').format(_endDateTime)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppConstants.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
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

              return ChoiceChip(
                label: SizedBox(
                  width: 82,
                  child: Center(child: Text(time.format(context))),
                ),
                selected: selected,
                selectedColor: AppConstants.primary,
                backgroundColor: Colors.white,
                onSelected: (_) {
                  setState(() {
                    selectedTimeOption = 'custom';
                    selectedTime = time;
                  });
                },
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppConstants.text,
                  fontWeight: FontWeight.w800,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: selected
                        ? AppConstants.primary
                        : AppConstants.border,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 26),

          const _SectionTitle('Booking Duration'),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _boxDecoration(),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Duration\n(hours)',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                _CircleButton(
                  icon: Icons.remove,
                  onTap: durationHours > 1
                      ? () {
                          setState(() {
                            selectedTimeOption = 'custom';
                            durationHours--;
                          });
                        }
                      : null,
                ),
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Text(
                      '$durationHours',
                      style: const TextStyle(
                        color: AppConstants.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                _CircleButton(
                  icon: Icons.add,
                  onTap: () {
                    setState(() {
                      selectedTimeOption = 'custom';
                      durationHours++;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

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

          if (snackRequired) _Input(controller: snackNote, hint: 'Snack Note'),

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

          if (technicianRequired)
            _Input(controller: technicianNote, hint: 'Technician Note'),

          const SizedBox(height: 22),

          const _SectionTitle('Recurrence Type'),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: _boxDecoration(),
            child: Column(
              children: ['none', 'daily', 'weekly'].map((type) {
                return RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,

                  title: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  value: type,
                  groupValue: recurrenceType,
                  activeColor: AppConstants.primary,
                  onChanged: (value) {
                    setState(() {
                      recurrenceType = value ?? 'none';

                      if (recurrenceType == 'none') {
                        recurrenceUntil = null;
                        recurrencePeriod = 1;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

          if (recurrenceType != 'none') ...[
            const SizedBox(height: 22),
            const _SectionTitle('Recurrence Period'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: _boxDecoration(),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      recurrenceType == 'daily'
                          ? 'Repeat every $recurrencePeriod day(s)'
                          : 'Repeat every $recurrencePeriod week(s)',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  _CircleButton(
                    icon: Icons.remove,
                    onTap: recurrencePeriod > 1
                        ? () {
                            setState(() {
                              recurrencePeriod--;
                            });
                          }
                        : null,
                  ),
                  SizedBox(
                    width: 44,
                    child: Center(
                      child: Text(
                        '$recurrencePeriod',
                        style: const TextStyle(
                          color: AppConstants.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  _CircleButton(
                    icon: Icons.add,
                    onTap: () {
                      setState(() {
                        recurrencePeriod++;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle('Recurrence Until'),
            InkWell(
              onTap: _pickRecurrenceUntil,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                decoration: _boxDecoration(),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: AppConstants.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        recurrenceUntil == null
                            ? 'Select end date'
                            : DateFormat('yyyy-MM-dd').format(recurrenceUntil!),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 28),

          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: bookingController.submitting ? null : () => _submit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
                  : const Icon(Icons.arrow_forward, color: Colors.white),
              label: Text(
                widget.isEdit ? 'Update Booking' : 'Confirm Booking',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
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
    required this.value,
    required this.titles,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _boxDecoration(),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
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
          contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        ),
        items: titles
            .map(
              (title) => DropdownMenuItem<String>(
                value: title,
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: title == _NewBookingScreenState._noMeetingTitle
                        ? AppConstants.muted
                        : AppConstants.text,
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
      decoration: _boxDecoration(),
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
              style: const TextStyle(
                color: AppConstants.primaryDark,
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

class _DateStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const _DateStrip({required this.selectedDate, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final first = DateTime.now();

    final days = List.generate(
      14,
      (index) => DateTime(first.year, first.month, first.day + index),
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisExtent: 44,
      ),
      itemBuilder: (context, index) {
        final date = days[index];
        final selected = DateUtils.isSameDay(date, selectedDate);

        return InkWell(
          onTap: () => onDateSelected(date),
          child: Center(
            child: CircleAvatar(
              backgroundColor: selected
                  ? AppConstants.primary
                  : Colors.transparent,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: selected ? Colors.white : AppConstants.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      },
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
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
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
      decoration: _boxDecoration(),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
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

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: CircleAvatar(
        backgroundColor: AppConstants.softBlue,
        child: Icon(icon, color: AppConstants.primary),
      ),
    );
  }
}

BoxDecoration _boxDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(.04),
        blurRadius: 16,
        offset: const Offset(0, 5),
      ),
    ],
  );
}
