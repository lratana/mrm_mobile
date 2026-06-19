import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/booking_controller.dart';
import '../utils/constants.dart';

// ignore: unused_import
import 'package:intl/intl.dart';

enum AnalyticsPeriod { daily, weekly, monthly, yearly }

extension AnalyticsPeriodExtension on AnalyticsPeriod {
  String get apiValue {
    switch (this) {
      case AnalyticsPeriod.daily:
        return 'daily';
      case AnalyticsPeriod.weekly:
        return 'weekly';
      case AnalyticsPeriod.monthly:
        return 'monthly';
      case AnalyticsPeriod.yearly:
        return 'yearly';
    }
  }

  String get label {
    switch (this) {
      case AnalyticsPeriod.daily:
        return 'Daily';
      case AnalyticsPeriod.weekly:
        return 'Weekly';
      case AnalyticsPeriod.monthly:
        return 'Monthly';
      case AnalyticsPeriod.yearly:
        return 'Yearly';
    }
  }
}

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.daily;
  final DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  Future<void> _loadAnalytics() async {
    await context.read<BookingController>().fetchBookingReport(
      type: _selectedPeriod.apiValue,
      selectedDate: _selectedDate,
    );
  }

  Future<void> _changePeriod(AnalyticsPeriod period) async {
    if (_selectedPeriod == period) return;

    setState(() {
      _selectedPeriod = period;
    });

    await _loadAnalytics();
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) return [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double? _asDoubleOrNull(dynamic value) {
    if (value == null) return null;

    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }

  String? _imageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;

    final cleanPath = path.trim();

    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    return '${AppConstants.storageBaseUrl}/$cleanPath';
  }

  String _trendText(double? percentage) {
    if (percentage == null) {
      return 'Selected period';
    }

    final formatted = percentage.abs().toStringAsFixed(
      percentage == percentage.roundToDouble() ? 0 : 1,
    );

    if (percentage > 0) {
      return '+$formatted% vs previous';
    }

    if (percentage < 0) {
      return '-$formatted% vs previous';
    }

    return '0% vs previous';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.bg,
      appBar: AppBar(
        backgroundColor: AppConstants.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: AppConstants.text),
        ),
        titleSpacing: 2,
        title: const Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              color: AppConstants.primary,
              size: 26,
            ),
            SizedBox(width: 10),
            Text(
              'Analytics',
              style: TextStyle(
                color: AppConstants.primary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 16),
          //   child: CircleAvatar(
          //     radius: 18,
          //     backgroundColor: const Color(0xFFE6F2F2),
          //     child: const Icon(
          //       Icons.person_rounded,
          //       color: AppConstants.primary,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Consumer<BookingController>(
        builder: (context, controller, _) {
          final report = controller.analyticsReport ?? <String, dynamic>{};
          final stats = _asMap(report['stats']);
          final trend = _asMapList(report['summary']);
          final topRooms = _asMapList(report['top_rooms']);

          final totalBookings = _asInt(stats['total']);
          final totalCompleted = _asInt(stats['completed']);

          final totalUsersRaw = stats['total_users'] ?? report['total_users'];

          final totalUsers = totalUsersRaw == null
              ? null
              : _asInt(totalUsersRaw);

          final kpis = _asMap(report['kpis']);

          final bookingChange = _asDoubleOrNull(
            kpis['booking_change_percent'] ??
                stats['booking_change_percent'] ??
                report['booking_change_percent'],
          );

          final userChange = _asDoubleOrNull(
            kpis['user_change_percent'] ??
                stats['user_change_percent'] ??
                report['user_change_percent'],
          );

          return RefreshIndicator(
            color: AppConstants.primary,
            onRefresh: _loadAnalytics,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
              children: [
                _AnalyticsTabBar(
                  selected: _selectedPeriod,
                  onChanged: _changePeriod,
                ),

                const SizedBox(height: 24),

                if (controller.analyticsLoading && report.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppConstants.primary,
                      ),
                    ),
                  )
                else if (controller.analyticsError != null && report.isEmpty)
                  _AnalyticsErrorState(
                    message: controller.analyticsError!,
                    onRetry: _loadAnalytics,
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: 'Total Bookings',
                          value: totalBookings.toString(),
                          trendText: _trendText(bookingChange),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MetricCard(
                          title: totalUsers == null
                              ? 'Completed'
                              : 'Total Users',
                          value: totalUsers == null
                              ? totalCompleted.toString()
                              : totalUsers.toString(),
                          trendText: totalUsers == null
                              ? 'Selected period'
                              : _trendText(userChange),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  _TrendCard(points: trend, period: _selectedPeriod),

                  const SizedBox(height: 28),

                  Text(
                    'Most Booked Spaces',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppConstants.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (topRooms.isEmpty)
                    _EmptyTopRoomsCard(
                      title: 'No room booking data found',
                      subtitle:
                          'Rooms with bookings will appear in this section.',
                    )
                  else
                    ...topRooms.map((room) {
                      final roomName =
                          room['room_name']?.toString() ?? 'Unnamed Room';

                      final bookingCount = _asInt(room['booking_count']);

                      final occupancy = _asDoubleOrNull(
                        room['occupancy_percent'] ??
                            room['utilization_percent'],
                      );

                      final thumbnailPath = room['room_thumbnail_path']
                          ?.toString();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _TopRoomCard(
                          roomName: roomName,
                          bookingCount: bookingCount,
                          occupancy: occupancy,
                          imageUrl: _imageUrl(thumbnailPath),
                        ),
                      );
                    }),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AnalyticsTabBar extends StatelessWidget {
  final AnalyticsPeriod selected;
  final ValueChanged<AnalyticsPeriod> onChanged;

  const _AnalyticsTabBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: AnalyticsPeriod.values.map((period) {
          final isSelected = period == selected;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFA8E9E3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period.label,
                  style: TextStyle(
                    color: isSelected
                        ? AppConstants.primary
                        : const Color(0xFF3F4A4D),
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trendText;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.trendText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF465154),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppConstants.text,
              fontSize: 29,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.trending_up_rounded,
                color: AppConstants.primary,
                size: 17,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  trendText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppConstants.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final List<Map<String, dynamic>> points;
  final AnalyticsPeriod period;

  const _TrendCard({required this.points, required this.period});

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatTrendLabel(String rawLabel, AnalyticsPeriod period) {
    final label = rawLabel.trim();

    if (label.isEmpty) return '-';

    switch (period) {
      case AnalyticsPeriod.daily:
        // API example: 08:00, 09:00, 14:00
        return label;

      case AnalyticsPeriod.weekly:
        // API can send: 2026-06-18 OR Mon/Tue/Wed
        final date = DateTime.tryParse(label);

        if (date != null) {
          // Change 'EEE' to 'EEEE' for Monday, Tuesday, Wednesday...
          return DateFormat('EE').format(date);
        }

        // If API already sends Mon / Tue / Wed, keep it.
        return label.length > 3 ? label.substring(0, 3) : label;

      case AnalyticsPeriod.monthly:
        // API example: 2026-06-18
        final date = DateTime.tryParse(label);

        if (date != null) {
          // Change 'dd' to 'dd MMM' if you want: 18 Jun
          return DateFormat('dd MMM').format(date);
        }

        return label;

      case AnalyticsPeriod.yearly:
        // API example: 2026-06
        final date = DateTime.tryParse('$label-01');

        if (date != null) {
          // Change this format as needed:
          // yyyy-MM   => 2026-06
          // MMM       => Jun
          // MMM yyyy  => Jun 2026
          return DateFormat('yyyy-MM').format(date);
        }

        return label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartPoints = points
        .map(
          (item) => _TrendPoint(
            label: item['label']?.toString() ?? '-',
            count: _toInt(item['count']),
          ),
        )
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Booking Trends',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppConstants.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: Color(0xFF465154)),
            ],
          ),
          const SizedBox(height: 22),

          _TrendBarChart(
            points: chartPoints,
            labelFormatter: (label) => _formatTrendLabel(label, period),
          ),
        ],
      ),
    );
  }
}

class _TrendBarChart extends StatelessWidget {
  final List<_TrendPoint> points;

  // New: control how labels are shown under bars
  final String Function(String rawLabel) labelFormatter;

  const _TrendBarChart({required this.points, required this.labelFormatter});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 190,
        child: Center(
          child: Text(
            'No trend data available',
            style: TextStyle(
              color: Color(0xFF788487),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final maxCount = points.fold<int>(
      1,
      (currentMax, point) =>
          point.count > currentMax ? point.count : currentMax,
    );

    final highestIndex = points.indexWhere((point) => point.count == maxCount);

    return SizedBox(
      height: 215,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final calculatedBarWidth =
              (constraints.maxWidth / points.length) - 10;

          final barWidth = math.max(40.0, calculatedBarWidth);
          final totalWidth = math.max(
            constraints.maxWidth,
            points.length * (barWidth + 10),
          );

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(points.length, (index) {
                  final point = points[index];
                  final ratio = point.count / maxCount;
                  final barHeight = math.max(10.0, ratio * 145);
                  final isHighest = index == highestIndex;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: SizedBox(
                      width: barWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 18,
                            child: Text(
                              point.count.toString(),
                              style: TextStyle(
                                color: isHighest
                                    ? AppConstants.primary
                                    : const Color(0xFF516064),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),

                          Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: isHighest
                                  ? const Color(0xFFA8E9E3)
                                  : const Color(0xFFE0F5F3),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            labelFormatter(point.label), // ✅ Changed here
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF677477),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TopRoomCard extends StatelessWidget {
  final String roomName;
  final int bookingCount;
  final double? occupancy;
  final String? imageUrl;

  const _TopRoomCard({
    required this.roomName,
    required this.bookingCount,
    required this.occupancy,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {},
        child: Container(
          height: 112,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: imageUrl == null
                      ? const _RoomImagePlaceholder()
                      : Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const _RoomImagePlaceholder();
                          },
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppConstants.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _AnalyticsTag(text: '$bookingCount BOOKINGS'),
                        if (occupancy != null)
                          _AnalyticsTag(
                            text: '${occupancy!.toStringAsFixed(0)}% OCC.',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFBCC7C9),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsTag extends StatelessWidget {
  final String text;

  const _AnalyticsTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2F2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppConstants.primary,
          fontSize: 10,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RoomImagePlaceholder extends StatelessWidget {
  const _RoomImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5EDF9),
      alignment: Alignment.center,
      child: const Icon(
        Icons.meeting_room_rounded,
        color: AppConstants.primary,
        size: 34,
      ),
    );
  }
}

class _AnalyticsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AnalyticsErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100),
      child: Column(
        children: [
          const Icon(
            Icons.analytics_outlined,
            size: 56,
            color: Color(0xFF7B898C),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF526064),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class _EmptyTopRoomsCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyTopRoomsCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.meeting_room_outlined,
            color: AppConstants.primary,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: AppConstants.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF718083),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendPoint {
  final String label;
  final int count;

  const _TrendPoint({required this.label, required this.count});
}
