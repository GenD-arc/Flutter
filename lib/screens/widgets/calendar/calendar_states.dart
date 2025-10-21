// widgets/calendar/calendar_states.dart

import 'package:flutter/material.dart';
import '../../../utils/calendar_constants.dart';
import '../../../models/availability_checker_model.dart';

/// Skeleton loading state for calendar
class CalendarLoadingState extends StatelessWidget {
  final DeviceType deviceType;

  const CalendarLoadingState({
    super.key,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
      child: Column(
        children: [
          _SkeletonCalendar(deviceType: deviceType),
          SizedBox(height: isMobile ? 12 : 16),
          _SkeletonDetails(deviceType: deviceType),
        ],
      ),
    );
  }
}

/// Skeleton calendar grid
class _SkeletonCalendar extends StatelessWidget {
  final DeviceType deviceType;

  const _SkeletonCalendar({required this.deviceType});

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          // Skeleton weekday headers
          Row(
            children: List.generate(
              7,
              (index) => Expanded(
                child: Container(
                  height: isMobile ? 16 : 20,
                  margin: EdgeInsets.all(isMobile ? 3 : 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          // Skeleton calendar grid
          ...List.generate(
            6,
            (weekIndex) => Row(
              children: List.generate(
                7,
                (dayIndex) => Expanded(
                  child: Container(
                    height: isMobile ? 50 : 60,
                    margin: EdgeInsets.all(isMobile ? 1 : 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton details section
class _SkeletonDetails extends StatelessWidget {
  final DeviceType deviceType;

  const _SkeletonDetails({required this.deviceType});

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isMobile ? 16 : 20,
            width: isMobile ? 120 : 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          ...List.generate(
            3,
            (index) => Container(
              margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: isMobile ? 14 : 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Container(
                    height: isMobile ? 10 : 12,
                    width: isMobile ? 80 : 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: isMobile ? 6 : 8),
                  Container(
                    height: isMobile ? 10 : 12,
                    width: isMobile ? 60 : 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state widget
class CalendarErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final DeviceType deviceType;

  const CalendarErrorState({
    super.key,
    this.errorMessage,
    required this.onRetry,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      margin: EdgeInsets.all(isMobile ? 16 : isTablet ? 20 : 24),
      padding: EdgeInsets.all(isMobile ? 20 : isTablet ? 24 : 28),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: isMobile ? 48 : isTablet ? 56 : 64,
            color: Colors.red[400],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Unable to Load Calendar',
            style: TextStyle(
              fontSize: isMobile ? 16 : isTablet ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            errorMessage ?? 'An unexpected error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red[600],
              fontSize: isMobile ? 12 : isTablet ? 13 : 14,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh, size: isMobile ? 16 : 18),
            label: Text(
              'Try Again',
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: CalendarColors.primaryMaroon,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 20 : 24,
                vertical: isMobile ? 10 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty state when no reservations exist
class CalendarEmptyState extends StatelessWidget {
  final VoidCallback? onAction;
  final String? actionLabel;
  final DeviceType deviceType;

  const CalendarEmptyState({
    super.key,
    this.onAction,
    this.actionLabel,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      padding: EdgeInsets.all(isMobile ? 32 : isTablet ? 40 : 48),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            size: isMobile ? 56 : isTablet ? 64 : 72,
            color: Colors.grey[300],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'No Reservations This Month',
            style: TextStyle(
              fontSize: isMobile ? 16 : isTablet ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'All resources are available for booking',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: isMobile ? 13 : isTablet ? 14 : 15,
            ),
          ),
          if (onAction != null) ...[
            SizedBox(height: isMobile ? 12 : 16),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.today, size: isMobile ? 16 : 18),
              label: Text(
                actionLabel ?? 'View Today',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: CalendarColors.primaryMaroon,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty selection state (no date selected)
class EmptySelectionState extends StatelessWidget {
  final DeviceType deviceType;

  const EmptySelectionState({
    super.key,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Container(
      padding: EdgeInsets.all(isMobile ? 32 : isTablet ? 40 : 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_view_day,
            size: isMobile ? 56 : isTablet ? 64 : 72,
            color: Colors.grey[300],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Select a Date',
            style: TextStyle(
              fontSize: isMobile ? 16 : isTablet ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'Tap on any date to view reservation details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: isMobile ? 13 : isTablet ? 14 : 15,
            ),
          ),
        ],
      ),
    );
  }
}

/// Date info display widget
class DateInfoWidget extends StatelessWidget {
  final DateTime? selectedDate;
  final DateTimeRange? selectedDateRange;
  final List<ScheduleItem> reservations;
  final DeviceType deviceType;
  final Widget Function(ScheduleItem) reservationBuilder;

  const DateInfoWidget({
    super.key,
    this.selectedDate,
    this.selectedDateRange,
    required this.reservations,
    required this.deviceType,
    required this.reservationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    if (selectedDate == null && selectedDateRange == null) {
      return EmptySelectionState(deviceType: deviceType);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateHeader(isMobile, isTablet),
          SizedBox(height: isMobile ? 12 : 16),
          
          if (reservations.isEmpty)
            _buildEmptyReservations(isMobile)
          else
            _buildReservationsList(),
        ],
      ),
    );
  }

  Widget _buildDateHeader(bool isMobile, bool isTablet) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: CalendarColors.accentBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
          ),
          child: Icon(
            Icons.calendar_today,
            color: CalendarColors.accentBlue,
            size: isMobile ? 18 : 20,
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getDateText(),
                style: TextStyle(
                  fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: CalendarColors.darkMaroon,
                ),
              ),
              if (selectedDate != null && _isPastDate())
                Text(
                  'Past Date',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyReservations(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: CalendarColors.successGreen.withOpacity(0.08),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color: CalendarColors.successGreen.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: CalendarColors.successGreen,
            size: isMobile ? 20 : 22,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              selectedDate != null && _isPastDate()
                  ? 'No reservations were scheduled'
                  : 'All resources available',
              style: TextStyle(
                color: CalendarColors.successGreen,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 13 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReservationsHeader(),
        SizedBox(height: deviceType == DeviceType.mobile ? 10 : 14),
        // ✅ CHANGED: Now pass the reservation to the builder
        // The builder will handle passing displayDate to ReservationCard
        ...reservations.map((reservation) => reservationBuilder(reservation)),
      ],
    );
  }

  Widget _buildReservationsHeader() {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Row(
      children: [
        Text(
          'Reservations',
          style: TextStyle(
            fontSize: isMobile ? 16 : isTablet ? 18 : 20,
            fontWeight: FontWeight.bold,
            color: CalendarColors.darkMaroon,
          ),
        ),
        SizedBox(width: isMobile ? 6 : 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 8 : 10,
            vertical: isMobile ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: CalendarColors.primaryMaroon.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          ),
          child: Text(
            '${reservations.length}',
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.bold,
              color: CalendarColors.primaryMaroon,
            ),
          ),
        ),
      ],
    );
  }

  String _getDateText() {
    if (selectedDate != null) {
      return _formatDate(selectedDate!);
    }
    if (selectedDateRange != null) {
      return '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool _isPastDate() {
    if (selectedDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    return dateOnly.isBefore(today);
  }
}