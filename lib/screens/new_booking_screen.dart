import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/booking_controller.dart';
import '../models/room_model.dart';
import '../utils/constants.dart';
import '../widgets/room_card.dart';

class NewBookingScreen extends StatefulWidget {
  final Room room;

  const NewBookingScreen({super.key, required this.room});

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 11, minute: 0);
  int durationHours = 2;

  bool snackRequired = false;
  bool technicianRequired = false;

  String recurrenceType = 'none';
  int recurrencePeriod = 1;
  DateTime? recurrenceUntil;

  final meetingTitle = TextEditingController();
  final chairman = TextEditingController();
  final snackNote = TextEditingController();
  final technicianNote = TextEditingController();

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

  @override
  void dispose() {
    meetingTitle.dispose();
    chairman.dispose();
    snackNote.dispose();
    technicianNote.dispose();
    super.dispose();
  }

  DateTime get _startDateTime => DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  DateTime get _endDateTime =>
      _startDateTime.add(Duration(hours: durationHours));

  String _apiDate(DateTime date) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(date);

  Future<void> _pickRecurrenceUntil() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: recurrenceUntil ?? selectedDate.add(const Duration(days: 7)),
      firstDate: selectedDate,
      lastDate: selectedDate.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => recurrenceUntil = picked);
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
      final ok = await controller.createBooking(payload);

      if (!mounted) return;

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking submitted successfully')),
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
        title: const Text(
          'New Booking',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          _RoomSummary(room: widget.room),
          const SizedBox(height: 24),
          const _SectionTitle('Select Date'),
          _DateStrip(
            selectedDate: selectedDate,
            onDateSelected: (d) => setState(() => selectedDate = d),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Select Time'),
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
                onSelected: (_) => setState(() => selectedTime = time),
                selectedColor: AppConstants.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppConstants.text,
                  fontWeight: FontWeight.w800,
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
                      ? () => setState(() => durationHours--)
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
                  onTap: () => setState(() => durationHours++),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Meeting Title (Optional)'),
          _Input(
            controller: meetingTitle,
            hint: 'e.g. Quarterly Strategy Sync',
          ),
          const SizedBox(height: 22),
          const _SectionTitle('Meeting Chairman'),
          _Input(controller: chairman, hint: 'Enter chairman name'),
          const SizedBox(height: 22),
          const _SectionTitle('Snacks & Catering'),
          _SwitchBox(
            title: 'Snack Required',
            value: snackRequired,
            onChanged: (v) => setState(() => snackRequired = v),
          ),
          if (snackRequired)
            _Input(controller: snackNote, hint: 'Snack Note (Optional)'),
          const SizedBox(height: 22),
          const _SectionTitle('Technical Support'),
          _SwitchBox(
            title: 'Technician Required',
            value: technicianRequired,
            onChanged: (v) => setState(() => technicianRequired = v),
          ),
          if (technicianRequired)
            _Input(
              controller: technicianNote,
              hint: 'Technician Note (Optional)',
            ),
          const SizedBox(height: 22),
          const _SectionTitle('Recurrence Type'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: _boxDecoration(),
            child: Column(
              children: ['none', 'daily', 'weekly'].map((type) {
                return RadioListTile<String>(
                  title: Text(
                    type[0].toUpperCase() + type.substring(1),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  value: type,
                  groupValue: recurrenceType,
                  activeColor: AppConstants.primary,
                  onChanged: (v) {
                    setState(() {
                      recurrenceType = v ?? 'none';
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
                        ? () => setState(() => recurrencePeriod--)
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
                    onTap: () => setState(() => recurrencePeriod++),
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
              label: const Text(
                'Confirm Booking',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
      (i) => DateTime(first.year, first.month, first.day + i),
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
