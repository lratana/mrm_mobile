import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/calendar_controller.dart';
import '../models/booking_model.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int viewMode = 0; // 0 = Month, 1 = Week, 2 = Day

  static const Color appleRed = Color(0xFFFF3B30);

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;

      context.read<CalendarController>().fetchMonth(DateTime.now());
    });
  }

  Future<void> _refreshCalendar(BuildContext context) async {
    final controller = context.read<CalendarController>();

    await controller.fetchMonth(controller.focusedDay);
  }

  Future<void> _goToday(BuildContext context) async {
    final today = DateTime.now();
    final controller = context.read<CalendarController>();

    controller.selectDay(today, today);

    await controller.fetchMonth(today);
  }

  Future<void> _changePeriod(
    BuildContext context,
    CalendarController controller,
    int direction,
  ) async {
    late final DateTime next;

    if (viewMode == 0) {
      next = DateTime(
        controller.focusedDay.year,
        controller.focusedDay.month + direction,
        1,
      );
    } else if (viewMode == 1) {
      next = controller.selectedDay.add(Duration(days: 7 * direction));
    } else {
      next = controller.selectedDay.add(Duration(days: direction));
    }

    controller.selectDay(next, next);

    await controller.fetchMonth(next);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  int _eventCountForDay(CalendarController controller, DateTime day) {
    int count = 0;

    for (final entry in controller.events.entries) {
      for (final booking in entry.value) {
        final start = booking.startDatetime;

        if (start != null && _isSameDay(start, day)) {
          count++;
        }
      }
    }

    return count;
  }

  List<Booking> _eventsForDay(CalendarController controller, DateTime day) {
    final events = <Booking>[];

    for (final entry in controller.events.entries) {
      for (final booking in entry.value) {
        final start = booking.startDatetime;

        if (start != null && _isSameDay(start, day)) {
          events.add(booking);
        }
      }
    }

    events.sort(
      (a, b) => (a.startDatetime ?? DateTime(1900)).compareTo(
        b.startDatetime ?? DateTime(1900),
      ),
    );

    return events;
  }

  List<DateTime> _monthDays(DateTime focusedDay) {
    final firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);

    final firstVisibleDay = firstDayOfMonth.subtract(
      Duration(days: firstDayOfMonth.weekday % 7),
    );

    return List.generate(
      42,
      (index) => _dateOnly(firstVisibleDay.add(Duration(days: index))),
    );
  }

  List<DateTime> _weekDays(DateTime selectedDay) {
    final selected = _dateOnly(selectedDay);

    final startOfWeek = selected.subtract(Duration(days: selected.weekday % 7));

    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _headerTitle(CalendarController controller) {
    if (viewMode == 0) {
      return DateFormat('MMMM yyyy').format(controller.focusedDay);
    }

    if (viewMode == 1) {
      final week = _weekDays(controller.selectedDay);
      final start = week.first;
      final end = week.last;

      if (start.month == end.month) {
        return '${DateFormat('MMM d').format(start)} - '
            '${DateFormat('d, yyyy').format(end)}';
      }

      return '${DateFormat('MMM d').format(start)} - '
          '${DateFormat('MMM d, yyyy').format(end)}';
    }

    return DateFormat('EEEE, MMMM d').format(controller.selectedDay);
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status.toLowerCase().trim()) {
      case 'approved':
        return context.appColors.success;
      case 'pending':
        return context.appColors.warning;
      case 'rejected':
        return context.appColors.danger;
      case 'cancelled':
        return context.appColors.textMuted;
      case 'cancel_requested':
        return AppConstants.primary;
      case 'completed':
        return context.appColors.success;
      default:
        return AppConstants.primary;
    }
  }

  String _bookingTitle(Booking booking) {
    if (booking.meetingTitle.trim().isNotEmpty) {
      return booking.meetingTitle.trim();
    }

    return booking.room?.name ?? 'Booking';
  }

  String _bookingTime(Booking booking) {
    final start = booking.startDatetime;
    final end = booking.endDatetime;

    if (start == null) return '-';

    if (end == null) {
      return DateFormat('hh:mm a').format(start.toLocal());
    }

    return '${DateFormat('hh:mm a').format(start.toLocal())} - '
        '${DateFormat('hh:mm a').format(end.toLocal())}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: SafeArea(
        child: Consumer<CalendarController>(
          builder: (context, controller, _) {
            final selectedEvents = _eventsForDay(
              controller,
              controller.selectedDay,
            );

            return RefreshIndicator(
              color: appleRed,
              onRefresh: () => _refreshCalendar(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _IOSHeader(
                      title: _headerTitle(controller),
                      viewMode: viewMode,
                      loading: controller.loading,
                      onBack: () => Navigator.maybePop(context),
                      onToday: () => _goToday(context),
                      onPrevious: () => _changePeriod(context, controller, -1),
                      onNext: () => _changePeriod(context, controller, 1),
                      onViewChanged: (value) {
                        setState(() {
                          viewMode = value;
                        });
                      },
                    ),
                  ),

                  if (viewMode == 0)
                    SliverToBoxAdapter(
                      child: _IOSMonthCalendar(
                        days: _monthDays(controller.focusedDay),
                        focusedDay: controller.focusedDay,
                        selectedDay: controller.selectedDay,
                        eventCounter: (day) {
                          return _eventCountForDay(controller, day);
                        },
                        onSelectDay: (day) async {
                          controller.selectDay(day, day);

                          if (day.month != controller.focusedDay.month ||
                              day.year != controller.focusedDay.year) {
                            await controller.fetchMonth(day);
                          }
                        },
                      ),
                    )
                  else if (viewMode == 1)
                    SliverToBoxAdapter(
                      child: _IOSWeekCalendar(
                        days: _weekDays(controller.selectedDay),
                        selectedDay: controller.selectedDay,
                        eventCounter: (day) {
                          return _eventCountForDay(controller, day);
                        },
                        onSelectDay: (day) {
                          controller.selectDay(day, day);
                        },
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: _IOSDayView(
                        selectedDay: controller.selectedDay,
                        events: selectedEvents,
                        titleBuilder: _bookingTitle,
                        timeBuilder: _bookingTime,
                        colorBuilder: (status) {
                          return _statusColor(context, status);
                        },
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: _SelectedDateHeader(
                      selectedDay: controller.selectedDay,
                      count: selectedEvents.length,
                    ),
                  ),

                  if (controller.loading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(
                          child: CircularProgressIndicator(color: appleRed),
                        ),
                      ),
                    )
                  else if (selectedEvents.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyAgendaCard())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 26),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final booking = selectedEvents[index];

                          return _IOSAgendaCard(
                            booking: booking,
                            title: _bookingTitle(booking),
                            time: _bookingTime(booking),
                            color: _statusColor(context, booking.status),
                          );
                        }, childCount: selectedEvents.length),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IOSHeader extends StatelessWidget {
  final String title;
  final int viewMode;
  final bool loading;
  final VoidCallback? onBack;
  final VoidCallback onToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onViewChanged;
  const _IOSHeader({
    required this.title,
    required this.viewMode,
    required this.loading,
    this.onBack,
    required this.onToday,
    required this.onPrevious,
    required this.onNext,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appColors.background,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null) ...[
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 32,
                  onPressed: onBack,
                  child: const Icon(
                    CupertinoIcons.chevron_left,
                    color: _CalendarScreenState.appleRed,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 4),
              ],

              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 32,
                onPressed: onToday,
                child: const Text(
                  'Today',
                  style: TextStyle(
                    color: _CalendarScreenState.appleRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
              ),

              const Spacer(),

              IconButton(
                tooltip: 'Previous',
                visualDensity: VisualDensity.compact,
                onPressed: onPrevious,
                icon: const Icon(
                  CupertinoIcons.chevron_left,
                  color: _CalendarScreenState.appleRed,
                ),
              ),

              IconButton(
                tooltip: 'Next',
                visualDensity: VisualDensity.compact,
                onPressed: onNext,
                icon: const Icon(
                  CupertinoIcons.chevron_right,
                  color: _CalendarScreenState.appleRed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.displaySmall?.copyWith(
                    color: context.appColors.text,
                    fontSize: 31,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _CalendarScreenState.appleRed,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: CupertinoSegmentedControl<int>(
              groupValue: viewMode,
              selectedColor: _CalendarScreenState.appleRed,
              unselectedColor: context.appColors.surface,
              borderColor: _CalendarScreenState.appleRed,
              pressedColor: _CalendarScreenState.appleRed.withOpacity(0.12),
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Text(
                    'Month',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Text(
                    'Week',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                2: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Text(
                    'Day',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              },
              onValueChanged: onViewChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _IOSMonthCalendar extends StatelessWidget {
  final List<DateTime> days;
  final DateTime focusedDay;
  final DateTime selectedDay;
  final int Function(DateTime day) eventCounter;
  final ValueChanged<DateTime> onSelectDay;

  const _IOSMonthCalendar({
    required this.days,
    required this.focusedDay,
    required this.selectedDay,
    required this.eventCounter,
    required this.onSelectDay,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime day) {
    return _isSameDay(DateTime.now(), day);
  }

  @override
  Widget build(BuildContext context) {
    return _CalendarSurface(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
      child: Column(
        children: [
          const Row(
            children: [
              _IOSWeekdayLabel('S'),
              _IOSWeekdayLabel('M'),
              _IOSWeekdayLabel('T'),
              _IOSWeekdayLabel('W'),
              _IOSWeekdayLabel('T'),
              _IOSWeekdayLabel('F'),
              _IOSWeekdayLabel('S'),
            ],
          ),

          const SizedBox(height: 6),

          GridView.builder(
            itemCount: days.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 52,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final selected = _isSameDay(day, selectedDay);
              final today = _isToday(day);
              final currentMonth = day.month == focusedDay.month;
              final count = eventCounter(day);

              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => onSelectDay(day),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? _CalendarScreenState.appleRed
                            : Colors.transparent,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : today
                              ? _CalendarScreenState.appleRed
                              : currentMonth
                              ? context.appColors.text
                              : context.appColors.textMuted.withOpacity(0.55),
                          fontWeight: selected || today
                              ? FontWeight.w800
                              : FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      height: 5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          count > 3 ? 3 : count,
                          (_) => Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : context.appColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _IOSWeekCalendar extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDay;
  final int Function(DateTime day) eventCounter;
  final ValueChanged<DateTime> onSelectDay;

  const _IOSWeekCalendar({
    required this.days,
    required this.selectedDay,
    required this.eventCounter,
    required this.onSelectDay,
  });

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime day) {
    return _isSameDay(DateTime.now(), day);
  }

  @override
  Widget build(BuildContext context) {
    return _CalendarSurface(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: days.map((day) {
          final selected = _isSameDay(day, selectedDay);
          final today = _isToday(day);
          final count = eventCounter(day);

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelectDay(day),
              child: Column(
                children: [
                  Text(
                    DateFormat('E').format(day).substring(0, 1),
                    style: context.appText.bodySmall?.copyWith(
                      color: context.appColors.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: selected
                        ? _CalendarScreenState.appleRed
                        : Colors.transparent,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : today
                            ? _CalendarScreenState.appleRed
                            : context.appColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        count > 3 ? 3 : count,
                        (_) => Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : context.appColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _IOSDayView extends StatelessWidget {
  final DateTime selectedDay;
  final List<Booking> events;
  final String Function(Booking booking) titleBuilder;
  final String Function(Booking booking) timeBuilder;
  final Color Function(String status) colorBuilder;

  const _IOSDayView({
    required this.selectedDay,
    required this.events,
    required this.titleBuilder,
    required this.timeBuilder,
    required this.colorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(13, (index) => 7 + index);

    return _CalendarSurface(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _CalendarScreenState.appleRed,
                  child: Text(
                    '${selectedDay.day}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('EEEE\nMMMM d, yyyy').format(selectedDay),
                    style: context.appText.titleLarge?.copyWith(
                      color: context.appColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No events scheduled today.',
                style: context.appText.bodyMedium?.copyWith(
                  color: context.appColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            Column(
              children: hours.map((hour) {
                final hourEvents = events.where((booking) {
                  final start = booking.startDatetime;

                  return start != null && start.hour == hour;
                }).toList();

                return _DayHourRow(
                  hour: hour,
                  events: hourEvents,
                  titleBuilder: titleBuilder,
                  timeBuilder: timeBuilder,
                  colorBuilder: colorBuilder,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _DayHourRow extends StatelessWidget {
  final int hour;
  final List<Booking> events;
  final String Function(Booking booking) titleBuilder;
  final String Function(Booking booking) timeBuilder;
  final Color Function(String status) colorBuilder;

  const _DayHourRow({
    required this.hour,
    required this.events,
    required this.titleBuilder,
    required this.timeBuilder,
    required this.colorBuilder,
  });

  String _hourLabel(int value) {
    if (value == 0) return '12 AM';
    if (value < 12) return '$value AM';
    if (value == 12) return '12 PM';

    return '${value - 12} PM';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.appColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Padding(
              padding: const EdgeInsets.only(top: 12, right: 8),
              child: Text(
                _hourLabel(hour),
                textAlign: TextAlign.right,
                style: context.appText.bodySmall?.copyWith(
                  color: context.appColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 12, 8),
              child: events.isEmpty
                  ? const SizedBox(height: 32)
                  : Column(
                      children: events.map((booking) {
                        final color = colorBuilder(booking.status);

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withOpacity(
                              context.isDarkMode ? 0.18 : 0.12,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border(
                              left: BorderSide(color: color, width: 4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timeBuilder(booking),
                                style: context.appText.bodySmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                titleBuilder(booking),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.appText.titleMedium?.copyWith(
                                  color: context.appColors.text,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IOSWeekdayLabel extends StatelessWidget {
  final String label;

  const _IOSWeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: context.appText.bodySmall?.copyWith(
            color: context.appColors.textMuted,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SelectedDateHeader extends StatelessWidget {
  final DateTime selectedDay;
  final int count;

  const _SelectedDateHeader({required this.selectedDay, required this.count});

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(selectedDay, DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isToday
                  ? 'Today'
                  : DateFormat('EEEE, MMMM d').format(selectedDay),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.appText.headlineSmall?.copyWith(
                color: context.appColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$count event${count == 1 ? '' : 's'}',
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAgendaCard extends StatelessWidget {
  const _EmptyAgendaCard();

  @override
  Widget build(BuildContext context) {
    return _CalendarSurface(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      padding: const EdgeInsets.all(26),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.calendar_badge_plus,
            color: context.appColors.textMuted,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            'No Events',
            style: context.appText.titleLarge?.copyWith(
              color: context.appColors.text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'There are no bookings for this date.',
            textAlign: TextAlign.center,
            style: context.appText.bodyMedium?.copyWith(
              color: context.appColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IOSAgendaCard extends StatelessWidget {
  final Booking booking;
  final String title;
  final String time;
  final Color color;

  const _IOSAgendaCard({
    required this.booking,
    required this.title,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final roomName = booking.room?.name ?? 'Room #${booking.roomId}';
    final chairman = booking.meetingChairman.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      time,
                      style: context.appText.bodySmall?.copyWith(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.appText.titleMedium?.copyWith(
                        color: context.appColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _AgendaInfoRow(
                      icon: CupertinoIcons.location_solid,
                      text: roomName,
                    ),
                    if (chairman.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _AgendaInfoRow(
                        icon: CupertinoIcons.person_fill,
                        text: chairman,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(
                            context.isDarkMode ? 0.18 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          booking.status.replaceAll('_', ' ').toUpperCase(),
                          style: context.appText.bodySmall?.copyWith(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgendaInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AgendaInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: context.appColors.textMuted),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appText.bodySmall?.copyWith(
              color: context.appColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarSurface extends StatelessWidget {
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _CalendarSurface({
    required this.margin,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
