// widgets/calendar/calendar_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/availability_checker_model.dart';
import '../../../utils/calendar_constants.dart';
import '../../../utils/philippines_time_utils.dart';
import '../../../utils/calendar_helpers.dart';
import 'calendar_day_cell.dart';

/// Complete calendar grid with enhanced UI
class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final DateTimeRange? selectedDateRange;
  final Map<String, List<ScheduleItem>> monthData;
  final Function(DateTime) onDateTapped;
  final DeviceType deviceType;
  final bool enableHapticFeedback;
  final bool showResourceIndicators;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    this.selectedDate,
    this.selectedDateRange,
    required this.monthData,
    required this.onDateTapped,
    required this.deviceType,
    this.enableHapticFeedback = true,
    this.showResourceIndicators = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: CalendarColors.primaryMaroon.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        child: Column(
          children: [
            CalendarWeekdayHeaders(deviceType: deviceType),
            SizedBox(height: isMobile ? 6 : 8),
            if (showResourceIndicators)
              _AvailabilityScale(deviceType: deviceType),
            SizedBox(height: isMobile ? 8 : 12),
            _buildCalendarDays(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDays() {
    final daysInMonth = PhilippinesTimeUtils.getDaysInMonth(currentMonth);
    final startingWeekday = PhilippinesTimeUtils.getStartingWeekday(currentMonth);
    final weeksCount = PhilippinesTimeUtils.getWeeksInMonth(currentMonth);

    return Column(
      children: List.generate(weeksCount, (weekIndex) {
        return _buildWeekRow(weekIndex, daysInMonth, startingWeekday);
      }),
    );
  }

  Widget _buildWeekRow(int weekIndex, int daysInMonth, int startingWeekday) {
    return Row(
      children: List.generate(7, (dayIndex) {
        final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 1;

        if (dayNumber <= 0 || dayNumber > daysInMonth) {
          return Expanded(
            child: Container(
              height: CalendarDimensions.getDayCellHeight(deviceType),
            ),
          );
        }

        final date = DateTime(currentMonth.year, currentMonth.month, dayNumber);
        final dateKey = PhilippinesTimeUtils.getDateKey(date);
        final dayReservations = monthData[dateKey] ?? [];

        final isSelected = selectedDate != null &&
            PhilippinesTimeUtils.isSameDay(selectedDate!, date);

        final isInRange = selectedDateRange != null &&
            PhilippinesTimeUtils.isDateInRange(
              date,
              selectedDateRange!.start,
              selectedDateRange!.end,
            );

        return Expanded(
          child: CalendarDayCell(
            date: date,
            reservations: dayReservations,
            isSelected: isSelected,
            isInRange: isInRange,
            onTap: () => _handleDateTap(date),
            deviceType: deviceType,
            showResourceIndicators: showResourceIndicators,
          ),
        );
      }),
    );
  }

  void _handleDateTap(DateTime date) async {
    if (enableHapticFeedback) {
      await HapticFeedback.lightImpact();
    }
    onDateTapped(date);
  }
}

/// Availability scale indicator
class _AvailabilityScale extends StatelessWidget {
  final DeviceType deviceType;

  const _AvailabilityScale({required this.deviceType});

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      child: Row(
        children: [
          Text(
            'Availability:',
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: isMobile ? 6 : 8),
          _AvailabilityLegendButton(deviceType: deviceType),
        ],
      ),
    );
  }
}

/// Button to show availability legend popup
class _AvailabilityLegendButton extends StatelessWidget {
  final DeviceType deviceType;

  const _AvailabilityLegendButton({required this.deviceType});

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showAvailabilityDialog(context),
        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : 12,
            vertical: isMobile ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: CalendarColors.primaryMaroon.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            border: Border.all(
              color: CalendarColors.primaryMaroon.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMobile ? 50 : 60,
                height: isMobile ? 3 : 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CalendarColors.availabilityLevelColors[0]!,
                      CalendarColors.availabilityLevelColors[2]!,
                      CalendarColors.availabilityLevelColors[4]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: isMobile ? 4 : 6),
              Icon(
                Icons.info_outline,
                size: isMobile ? 12 : 14,
                color: CalendarColors.primaryMaroon,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvailabilityDialog(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Availability Legend',
          style: TextStyle(
            fontSize: isMobile ? 16 : isTablet ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem(
              CalendarHelpers.getAvailabilityDescription(0),
              CalendarColors.availabilityLevelColors[0]!,
              0.1,
              isMobile,
            ),
            _buildLegendItem(
              CalendarHelpers.getAvailabilityDescription(1),
              CalendarColors.availabilityLevelColors[1]!,
              0.3,
              isMobile,
            ),
            _buildLegendItem(
              CalendarHelpers.getAvailabilityDescription(2),
              CalendarColors.availabilityLevelColors[2]!,
              0.5,
              isMobile,
            ),
            _buildLegendItem(
              CalendarHelpers.getAvailabilityDescription(3),
              CalendarColors.availabilityLevelColors[3]!,
              0.7,
              isMobile,
            ),
            _buildLegendItem(
              CalendarHelpers.getAvailabilityDescription(4),
              CalendarColors.availabilityLevelColors[4]!,
              0.9,
              isMobile,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, double opacity, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
      child: Row(
        children: [
          Container(
            width: isMobile ? 16 : 20,
            height: isMobile ? 3 : 4,
            decoration: BoxDecoration(
              color: color.withOpacity(opacity),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }
}