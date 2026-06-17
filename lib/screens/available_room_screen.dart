import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/booking_controller.dart';
import '../models/room_model.dart';
import '../utils/app_palette.dart';
import '../utils/constants.dart';
import '../widgets/room_card.dart';
import 'new_booking_screen.dart';

class AvailableRoomScreen extends StatelessWidget {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int participants;
  final String equipment;

  const AvailableRoomScreen({
    super.key,
    required this.startDateTime,
    required this.endDateTime,
    required this.participants,
    required this.equipment,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BookingController>();

    final rooms = controller.availableRooms.where((room) {
      final capacityOk = room.capacity >= participants;

      final selectedEquipment = equipment.trim().toLowerCase();

      final equipmentNames = room.equipment
          .map((e) => e.name.toLowerCase())
          .toList();

      final equipmentOk =
          selectedEquipment == 'any' ||
          selectedEquipment.isEmpty ||
          equipmentNames.any((name) => name.contains(selectedEquipment)) ||
          equipmentNames.any((name) {
            if (selectedEquipment.contains('lcd')) {
              return name.contains('lcd') || name.contains('projector');
            }

            if (selectedEquipment.contains('projector')) {
              return name.contains('projector') || name.contains('lcd');
            }

            if (selectedEquipment.contains('video')) {
              return name.contains('video') || name.contains('conference');
            }

            if (selectedEquipment.contains('whiteboard')) {
              return name.contains('whiteboard') || name.contains('board');
            }

            return false;
          });

      return capacityOk && equipmentOk;
    }).toList();

    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        elevation: 0,
        title: Text(
          'Select Room',
          style: context.appText.titleLarge?.copyWith(
            color: AppConstants.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: [
          _SearchSummaryCard(
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            participants: participants,
            equipment: equipment,
          ),

          Expanded(
            child: rooms.isEmpty
                ? Center(
                    child: Text(
                      'No available rooms found',
                      style: context.appText.bodyMedium?.copyWith(
                        color: context.appColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.pagePadding),
                    itemCount: rooms.length,
                    itemBuilder: (context, index) {
                      final Room room = rooms[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FeaturedRoomListCard(
                          room: room,
                          onBook: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NewBookingScreen(
                                  room: room,
                                  initialStartDateTime: startDateTime,
                                  initialEndDateTime: endDateTime,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchSummaryCard extends StatelessWidget {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final int participants;
  final String equipment;

  const _SearchSummaryCard({
    required this.startDateTime,
    required this.endDateTime,
    required this.participants,
    required this.equipment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.pagePadding),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: AppConstants.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_formatDate(startDateTime)} - ${_formatDate(endDateTime)}',
                  style: context.appText.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: AppConstants.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${_formatTime(startDateTime)} - ${_formatTime(endDateTime)}',
                  style: context.appText.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(Icons.groups_rounded, color: AppConstants.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$participants participant(s)',
                  style: context.appText.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.devices_other_rounded,
                color: AppConstants.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  equipment.trim().isEmpty ? 'Any equipment' : equipment,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.bodyMedium?.copyWith(
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

  static String _formatDate(DateTime date) {
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

    return '${months[date.month - 1]} ${date.day}';
  }

  static String _formatTime(DateTime date) {
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
