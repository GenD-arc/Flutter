import 'package:flutter/material.dart';
import '../../../models/availability_checker_model.dart';
import '../../../utils/calendar_constants.dart';
import '../../../utils/philippines_time_utils.dart';
import '../../../utils/calendar_helpers.dart';

/// Card displaying reservation details
class ReservationCard extends StatelessWidget {
  final ScheduleItem reservation;
  final DeviceType deviceType;
  final bool showResourceInfo;
  final DateTime? displayDate; // ✅ NEW: The date this card is being displayed for

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.deviceType,
    this.showResourceInfo = true,
    this.displayDate, // ✅ NEW: Optional display date parameter
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    final displayStatus = CalendarHelpers.getDisplayStatus(reservation);
    final statusColor = CalendarHelpers.getReservationStatusColor(reservation);
    final statusBgColor = CalendarHelpers.getReservationStatusBackgroundColor(reservation);
    final resourceColor = CalendarColors.getResourceColor(reservation.resourceCategory);
    final isMultiDay = PhilippinesTimeUtils.isMultiDayReservation(
      reservation.dateFrom,
      reservation.dateTo,
    );
    final isCompleted = displayStatus == 'completed';
    
    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resource name and category (if enabled)
          if (showResourceInfo) ...[
            _buildResourceHeader(
              isMobile,
              isTablet,
              resourceColor,
            ),
            SizedBox(height: isMobile ? 8 : 10),
          ],
          
          // Status and time
          _buildStatusTimeRow(
            isMobile,
            isTablet,
            statusColor,
            statusBgColor,
            displayStatus,
            isMultiDay,
            isCompleted,
          ),
          
          SizedBox(height: isMobile ? 8 : 10),
          
          // Purpose
          _buildPurpose(isMobile, isTablet),
          
          SizedBox(height: isMobile ? 6 : 8),
          
          Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
          SizedBox(height: isMobile ? 6 : 8),
          
          // Reserved by and ID
          _buildFooter(isMobile, isCompleted),
        ],
      ),
    );
  }

  Widget _buildResourceHeader(bool isMobile, bool isTablet, Color resourceColor) {
    return Row(
      children: [
        Container(
          width: isMobile ? 4 : 5,
          height: isMobile ? 20 : 24,
          decoration: BoxDecoration(
            color: resourceColor,
            borderRadius: BorderRadius.circular(isMobile ? 2 : 3),
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: Text(
            reservation.resourceName.isNotEmpty
                ? reservation.resourceName
                : reservation.resourceId,
            style: TextStyle(
              fontSize: isMobile ? 14 : isTablet ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: CalendarColors.darkMaroon,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 6 : 8,
            vertical: isMobile ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: resourceColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
          ),
          child: Text(
            reservation.resourceCategory.toUpperCase(),
            style: TextStyle(
              fontSize: isMobile ? 8 : 9,
              fontWeight: FontWeight.bold,
              color: resourceColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeRow(
    bool isMobile,
    bool isTablet,
    Color statusColor,
    Color statusBgColor,
    String displayStatus,
    bool isMultiDay,
    bool isCompleted,
  ) {
    // ✅ NEW: Get the correct time for the display date
    String timeToDisplay;
    if (displayDate != null) {
      // Use the date-specific time
      timeToDisplay = reservation.getFormattedTimeForDate(displayDate!);
    } else {
      // Fallback to default formatted time
      timeToDisplay = reservation.formattedTime;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 10,
            vertical: isMobile ? 4 : 5,
          ),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCompleted)
                Icon(
                  Icons.done_all_rounded,
                  size: isMobile ? 10 : 12,
                  color: Colors.white,
                ),
              if (isCompleted) SizedBox(width: isMobile ? 4 : 6),
              Text(
                CalendarText.getStatusDisplayText(displayStatus).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 9 : 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        if (isMultiDay) ...[
          SizedBox(width: isMobile ? 6 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 8,
              vertical: isMobile ? 3 : 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(isMobile ? 4 : 6),
            ),
            child: Text(
              'MULTI-DAY',
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: isMobile ? 8 : 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeToDisplay, // ✅ CHANGED: Use the date-specific time
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: isCompleted ? CalendarColors.completedBlue : Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'PST',
              style: TextStyle(
                fontSize: isMobile ? 9 : 10,
                color: isCompleted ? CalendarColors.completedBlue.withOpacity(0.7) : Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPurpose(bool isMobile, bool isTablet) {
    return Text(
      reservation.purpose,
      style: TextStyle(
        fontSize: isMobile ? 13 : isTablet ? 14 : 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(bool isMobile, bool isCompleted) {
    return Row(
      children: [
        Icon(
          Icons.person_outline,
          size: isMobile ? 12 : 14,
          color: isCompleted ? CalendarColors.completedBlue : Colors.grey[600],
        ),
        SizedBox(width: isMobile ? 4 : 6),
        Expanded(
          child: Text(
            reservation.reservedBy,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              color: isCompleted ? CalendarColors.completedBlue : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          'ID: ${_truncateId(reservation.reservationId.toString())}',
          style: TextStyle(
            fontSize: isMobile ? 9 : 10,
            color: isCompleted ? CalendarColors.completedBlue.withOpacity(0.7) : Colors.grey[500],
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  String _truncateId(String id) {
    if (id.length <= 8) return id;
    return '${id.substring(0, 8)}...';
  }
}