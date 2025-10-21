// widgets/calendar/calendar_day_cell.dart

import 'package:flutter/material.dart';
import '../../../models/availability_checker_model.dart';
import '../../../utils/calendar_constants.dart';
import '../../../utils/philippines_time_utils.dart';
import '../../../utils/calendar_helpers.dart';

/// Individual calendar day cell with availability indicators
class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final List<ScheduleItem> reservations;
  final bool isSelected;
  final bool isInRange;
  final VoidCallback onTap;
  final DeviceType deviceType;
  final bool showResourceIndicators;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.reservations,
    this.isSelected = false,
    this.isInRange = false,
    required this.onTap,
    required this.deviceType,
    this.showResourceIndicators = true,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    final availabilityLevel = CalendarHelpers.calculateAvailabilityLevel(reservations.length);
    final isToday = PhilippinesTimeUtils.isToday(date);
    final isPastDate = PhilippinesTimeUtils.isPastDate(date);

    // Generate semantics label for accessibility
    final semanticsLabel = CalendarHelpers.generateSemanticsLabel(date, reservations);

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: CalendarDimensions.getDayCellHeight(deviceType),
            margin: EdgeInsets.all(isMobile ? 1 : 2),
            decoration: BoxDecoration(
              gradient: _getDayGradient(availabilityLevel),
              borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              border: _getDayBorder(isToday),
              boxShadow: _getDayShadow(),
            ),
            child: Stack(
              children: [
                // Availability indicator background
                if (reservations.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: CalendarColors.getAvailabilityColor(availabilityLevel)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                    ),
                  ),
                
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: _getDayTextColor(availabilityLevel, isToday, isPastDate),
                        fontSize: isMobile ? 14 : isTablet ? 16 : 18,
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    _buildAvailabilityBadge(isMobile, availabilityLevel),
                    if (reservations.isNotEmpty && showResourceIndicators)
                      _buildResourceIndicators(isMobile),
                  ],
                ),
                
                // Today indicator
                if (isToday)
                  Positioned(
                    top: isMobile ? 3 : 4,
                    right: isMobile ? 3 : 4,
                    child: Container(
                      width: isMobile ? 5 : 6,
                      height: isMobile ? 5 : 6,
                      decoration: const BoxDecoration(
                        color: CalendarColors.accentBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Gradient? _getDayGradient(int availabilityLevel) {
    if (isSelected) {
      return LinearGradient(
        colors: [
          CalendarColors.primaryMaroon.withOpacity(0.2),
          CalendarColors.primaryMaroon.withOpacity(0.1),
        ],
      );
    }
    if (isInRange) {
      return LinearGradient(
        colors: [
          CalendarColors.accentBlue.withOpacity(0.1),
          CalendarColors.accentBlue.withOpacity(0.05),
        ],
      );
    }
    return null;
  }

  Border? _getDayBorder(bool isToday) {
    if (isSelected) {
      return Border.all(color: CalendarColors.primaryMaroon, width: 2);
    }
    if (isToday) {
      return Border.all(color: CalendarColors.accentBlue, width: 1.5);
    }
    if (isInRange) {
      return Border.all(
        color: CalendarColors.accentBlue.withOpacity(0.5),
        width: 1,
      );
    }
    return null;
  }

  List<BoxShadow>? _getDayShadow() {
    if (isSelected) {
      return [
        BoxShadow(
          color: CalendarColors.primaryMaroon.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    }
    return null;
  }

  Color _getDayTextColor(int availabilityLevel, bool isToday, bool isPastDate) {
    if (isSelected) return CalendarColors.primaryMaroon;
    if (isToday) return CalendarColors.accentBlue;
    if (isPastDate) return Colors.grey[400]!;
    
    return availabilityLevel >= 3 ? Colors.white : Colors.black87;
  }

  Widget _buildAvailabilityBadge(bool isMobile, int availabilityLevel) {
    if (reservations.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 6,
        vertical: isMobile ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: CalendarColors.getAvailabilityColor(availabilityLevel)
            .withOpacity(0.9),
        borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
      ),
      child: Text(
        reservations.length.toString(),
        style: TextStyle(
          fontSize: isMobile ? 9 : 10,
          fontWeight: FontWeight.bold,
          color: availabilityLevel >= 3 ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildResourceIndicators(bool isMobile) {
    final resourceTypes = <String>{};
    for (final reservation in reservations) {
      resourceTypes.add(reservation.resourceCategory);
    }

    final resourceList = resourceTypes.toList();
    final maxDots = 3;
    
    return Container(
      height: isMobile ? 10 : 12,
      margin: EdgeInsets.only(top: isMobile ? 1 : 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...resourceList.take(maxDots).map((resourceType) {
            return Container(
              width: isMobile ? 4 : 5,
              height: isMobile ? 4 : 5,
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 0.5 : 1),
              decoration: BoxDecoration(
                color: CalendarColors.getResourceColor(resourceType),
                shape: BoxShape.circle,
              ),
            );
          }).toList(),
          if (resourceList.length > maxDots)
            Text(
              '+${resourceList.length - maxDots}',
              style: TextStyle(
                fontSize: isMobile ? 7 : 8,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

/// Weekday headers for calendar grid
class CalendarWeekdayHeaders extends StatelessWidget {
  final DeviceType deviceType;

  const CalendarWeekdayHeaders({
    super.key,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      decoration: BoxDecoration(
        color: CalendarColors.darkMaroon.withOpacity(0.08),
        border: const Border(bottom: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: CalendarLabels.weekdaysShort.map((day) {
          return Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 12 : isTablet ? 14 : 16,
              ),
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: CalendarColors.darkMaroon,
                  fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}