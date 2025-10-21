
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/today_status_service.dart';

// Activity status enum
enum ActivityStatus {
  upcoming,
  ongoing,
  completed
}

// Stateful widget for collapsible activity items
class ActivityItemStateful extends StatefulWidget {
  final DailyActivityNews activity;
  final bool isMobile;

  const ActivityItemStateful({
    Key? key,
    required this.activity,
    required this.isMobile,
  }) : super(key: key);

  @override
  ActivityItemState createState() => ActivityItemState();
}

class ActivityItemState extends State<ActivityItemStateful> {
  bool _isExpanded = false;

  // Helper to determine device type from context
  bool get _isLaptopOrDesktop {
    final width = MediaQuery.of(context).size.width;
    return width >= 900;
  }

  @override
  Widget build(BuildContext context) {
    final activityStatus = _getActivityStatus(widget.activity);
    final (statusColor, statusLabel, statusIcon, statusBgColor) = _getStatusProperties(activityStatus);

    // Responsive sizing
    final isCompact = _isLaptopOrDesktop;
    final margin = isCompact ? 8.0 : (widget.isMobile ? 12.0 : 14.0);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: margin, vertical: isCompact ? 4 : 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
        border: Border.all(color: statusColor.withOpacity(0.2), width: isCompact ? 1 : 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: isCompact ? 4 : 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (always visible)
          _buildHeader(activityStatus, statusColor, statusLabel, statusIcon, statusBgColor),
          
          // Collapsible content
          if (_isExpanded)
            _buildExpandedContent(activityStatus, statusColor, statusBgColor),
        ],
      ),
    );
  }

  Widget _buildHeader(
    ActivityStatus activityStatus,
    Color statusColor,
    String statusLabel,
    IconData statusIcon,
    Color statusBgColor,
  ) {
    final isCompact = _isLaptopOrDesktop;
    final padding = isCompact ? 10.0 : (widget.isMobile ? 12.0 : 14.0);
    final iconSize = isCompact ? 32.0 : 36.0;
    final iconInnerSize = isCompact ? 16.0 : 18.0;
    
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
      child: Container(
        padding: EdgeInsets.all(padding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status icon
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: iconInnerSize,
              ),
            ),
            SizedBox(width: isCompact ? 10 : 12),
            
            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.activity.resourceName,
                          style: TextStyle(
                            fontSize: isCompact ? 13.0 : (widget.isMobile ? 14.0 : 15.0),
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F1F1F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6),
                      // Expand/collapse icon
                      Icon(
                        _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                        color: statusColor,
                        size: isCompact ? 16.0 : 18.0,
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 4 : 6),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCompact ? 6.0 : 8.0, 
                          vertical: isCompact ? 2.0 : 3.0
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF8B0000).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(isCompact ? 4 : 6),
                          border: Border.all(color: Color(0xFF8B0000).withOpacity(0.2)),
                        ),
                        child: Text(
                          widget.activity.resourceCategory.toUpperCase(),
                          style: TextStyle(
                            fontSize: isCompact ? 8.0 : 9.0,
                            color: Color(0xFF8B0000),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: isCompact ? 6 : 8),
                      
                      // ✨ MULTI-DAY BADGE - NEW!
                      if (widget.activity.totalDays > 1) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 6.0 : 8.0,
                            vertical: isCompact ? 2.0 : 3.0
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF7C3AED).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isCompact ? 4 : 6),
                            border: Border.all(color: Color(0xFF7C3AED).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: isCompact ? 8.0 : 9.0,
                                color: Color(0xFF7C3AED),
                              ),
                              SizedBox(width: 3),
                              Text(
                                widget.activity.durationLabel.toUpperCase(),
                                style: TextStyle(
                                  fontSize: isCompact ? 8.0 : 9.0,
                                  color: Color(0xFF7C3AED),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isCompact ? 6 : 8),
                      ],
                      
                      // Time slot (minimized view)
                      Expanded(
                        child: Text(
                          widget.activity.timeSlots,
                          style: TextStyle(
                            fontSize: isCompact ? 10.0 : 11.0,
                            color: Color(0xFF737373),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 4 : 6),
                  // Purpose preview (minimized view)
                  Text(
                    widget.activity.purpose,
                    style: TextStyle(
                      fontSize: isCompact ? 11.0 : 12.0,
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            SizedBox(width: isCompact ? 8 : 12),
            
            // Status badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8.0 : 10.0, 
                vertical: isCompact ? 4.0 : 6.0
              ),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                border: Border.all(color: statusColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: isCompact ? 10.0 : 12.0, color: statusColor),
                  SizedBox(width: isCompact ? 4 : 6),
                  Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: isCompact ? 9.0 : 10.0,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    ActivityStatus activityStatus,
    Color statusColor,
    Color statusBgColor,
  ) {
    final isCompact = _isLaptopOrDesktop;
    final padding = isCompact ? 10.0 : (widget.isMobile ? 12.0 : 14.0);
    
    return Container(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
      child: Column(
        children: [
          Divider(height: 1, color: Color(0xFFE5E7EB)),
          SizedBox(height: isCompact ? 10 : 12),
          
          // Purpose section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isCompact ? 8.0 : 10.0),
            decoration: BoxDecoration(
              color: Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
              border: Border.all(color: Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.description_rounded, size: isCompact ? 11.0 : 12.0, color: Color(0xFF8B0000)),
                    SizedBox(width: 6),
                    Text(
                      'Purpose',
                      style: TextStyle(
                        fontSize: isCompact ? 9.0 : 10.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B0000),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isCompact ? 6 : 8),
                Text(
                  widget.activity.purpose,
                  style: TextStyle(
                    fontSize: isCompact ? 11.0 : (widget.isMobile ? 12.0 : 13.0),
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isCompact ? 10 : 12),
          
          // Time and duration section
          Row(
            children: [
              // Time slot with status indicator
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 8.0 : 10.0, 
                    vertical: isCompact ? 6.0 : 8.0
                  ),
                  decoration: BoxDecoration(
                    color: _getTimeSlotColor(activityStatus),
                    borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                    border: Border.all(color: _getTimeSlotBorderColor(activityStatus)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: isCompact ? 11.0 : 12.0, color: _getTimeSlotTextColor(activityStatus)),
                          SizedBox(width: 6),
                          Text(
                            'TIME',
                            style: TextStyle(
                              fontSize: isCompact ? 8.0 : 9.0,
                              fontWeight: FontWeight.w800,
                              color: _getTimeSlotTextColor(activityStatus),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.activity.timeSlots,
                        style: TextStyle(
                          fontSize: isCompact ? 10.0 : 11.0,
                          color: _getTimeSlotTextColor(activityStatus),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(width: 8),
              
              // ✨ ENHANCED Duration badge with multi-day info
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8.0 : 10.0, 
                  vertical: isCompact ? 6.0 : 8.0
                ),
                decoration: BoxDecoration(
                  color: widget.activity.totalDays > 1 
                      ? Color(0xFF7C3AED).withOpacity(0.1)
                      : statusBgColor,
                  borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                  border: Border.all(
                    color: widget.activity.totalDays > 1 
                        ? Color(0xFF7C3AED).withOpacity(0.3)
                        : statusColor.withOpacity(0.3)
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.activity.totalDays > 1 
                              ? Icons.event_repeat_rounded 
                              : Icons.event_rounded,
                          size: isCompact ? 10.0 : 11.0,
                          color: widget.activity.totalDays > 1 
                              ? Color(0xFF7C3AED) 
                              : statusColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'DURATION',
                          style: TextStyle(
                            fontSize: isCompact ? 8.0 : 9.0,
                            fontWeight: FontWeight.w800,
                            color: widget.activity.totalDays > 1 
                                ? Color(0xFF7C3AED) 
                                : statusColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      widget.activity.durationLabel,
                      style: TextStyle(
                        fontSize: isCompact ? 10.0 : 11.0,
                        fontWeight: FontWeight.w700,
                        color: widget.activity.totalDays > 1 
                            ? Color(0xFF7C3AED) 
                            : statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: isCompact ? 10 : 12),
          
          // Footer with requester and progress indicator
          Row(
            children: [
              // Requester info
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 8.0 : 10.0, 
                    vertical: isCompact ? 6.0 : 8.0
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                    border: Border.all(color: Color(0xFFDCFCE7)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_rounded, size: isCompact ? 11.0 : 12.0, color: Color(0xFF166534)),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Reserved by: ${widget.activity.requesterName}',
                          style: TextStyle(
                            fontSize: isCompact ? 10.0 : 11.0,
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(width: 8),
              
              // Progress indicator for ongoing activities
              if (activityStatus == ActivityStatus.ongoing)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 6.0 : 8.0, 
                    vertical: isCompact ? 4.0 : 6.0
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(isCompact ? 5 : 6),
                    border: Border.all(color: Color(0xFFF59E0B).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isCompact ? 5.0 : 6.0,
                        height: isCompact ? 5.0 : 6.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: isCompact ? 8.0 : 9.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Determine activity status based on current time
  ActivityStatus _getActivityStatus(DailyActivityNews activity) {
    final now = DateTime.now();
    
    // Parse time slots to get start and end times
    final timeParts = activity.timeSlots.split(' - ');
    if (timeParts.length == 2) {
      try {
        final startTime = _parseTimeString(timeParts[0]);
        final endTime = _parseTimeString(timeParts[1]);
        
        final activityStart = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
        final activityEnd = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);
        
        if (now.isBefore(activityStart)) {
          return ActivityStatus.upcoming;
        } else if (now.isAfter(activityEnd)) {
          return ActivityStatus.completed;
        } else {
          return ActivityStatus.ongoing;
        }
      } catch (e) {
        return ActivityStatus.upcoming;
      }
    }
    
    return ActivityStatus.upcoming;
  }

  // Parse time string (e.g., "2:00 PM")
  TimeOfDay _parseTimeString(String timeString) {
    try {
      final timeFormat = RegExp(r'(\d+):(\d+)\s*(AM|PM)', caseSensitive: false);
      final match = timeFormat.firstMatch(timeString);
      
      if (match != null) {
        int hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final period = match.group(3)!.toUpperCase();
        
        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
        
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      print('Error parsing time: $timeString');
    }
    
    return TimeOfDay.now();
  }

  // Get status properties (color, label, icon, background)
  (Color, String, IconData, Color) _getStatusProperties(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.upcoming:
        return (
          Color(0xFF2563EB),
          'UPCOMING',
          Icons.schedule_rounded,
          Color(0xFFDBEAFE),
        );
      case ActivityStatus.ongoing:
        return (
          Color(0xFFD97706),
          'ONGOING',
          Icons.play_circle_fill_rounded,
          Color(0xFFFEF3C7),
        );
      case ActivityStatus.completed:
        return (
          Color(0xFF059669),
          'COMPLETED',
          Icons.check_circle_rounded,
          Color(0xFFD1FAE5),
        );
    }
  }

  // Helper functions for time slot styling
  Color _getTimeSlotColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.upcoming:
        return Color(0xFFEFF6FF);
      case ActivityStatus.ongoing:
        return Color(0xFFFFFBEB);
      case ActivityStatus.completed:
        return Color(0xFFF0FDF4);
    }
  }

  Color _getTimeSlotBorderColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.upcoming:
        return Color(0xFFDBEAFE);
      case ActivityStatus.ongoing:
        return Color(0xFFFDE68A);
      case ActivityStatus.completed:
        return Color(0xFFBBF7D0);
    }
  }

  Color _getTimeSlotTextColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.upcoming:
        return Color(0xFF1D4ED8);
      case ActivityStatus.ongoing:
        return Color(0xFFD97706);
      case ActivityStatus.completed:
        return Color(0xFF059669);
    }
  }
}

// Main DashboardOverviewSection class - UPDATED CONSTRUCTOR
class DashboardOverviewSection extends StatelessWidget {
  final bool isMobile;
  final bool isTablet;
  final bool? isLaptop;
  final bool? isDesktop;

  const DashboardOverviewSection({
    Key? key,
    required this.isMobile,
    required this.isTablet,
    this.isLaptop,
    this.isDesktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TodayStatusService>(
      builder: (context, statusService, _) {
        if (statusService.isLoading && statusService.todayStatus == null) {
          return _buildLoadingState(isMobile);
        }

        if (statusService.errorMessage != null && statusService.todayStatus == null) {
          return _buildErrorState(context, statusService, isMobile);
        }

        final status = statusService.todayStatus;
        if (status == null) {
          return _buildEmptyState(isMobile);
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildSummaryCards(status, isMobile, isTablet),
              SizedBox(height: isMobile ? 16 : 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading today\'s status...',
              style: TextStyle(
                color: Color(0xFF4A4A4A),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TodayStatusService statusService, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFDC2626).withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 32),
            SizedBox(height: 12),
            Text(
              'Could not load today\'s status',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              statusService.errorMessage ?? 'Unknown error',
              style: TextStyle(color: Color(0xFFDC2626).withOpacity(0.8), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => statusService.fetchTodayStatus(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B0000),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text('Retry', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Center(
        child: Text(
          'No status data available',
          style: TextStyle(color: Color(0xFF737373), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(TodayStatusData status, bool isMobile, bool isTablet) {
    final fully = status.fullyAvailable.length;
    final partial = status.partiallyAvailable.length;
    final notAvail = status.notAvailable.length;

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with maroon background to match "Today's Activities"
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isMobile ? 14.0 : (isTablet ? 16.0 : 14.0)),
            decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        const Color.fromARGB(255, 113, 29, 29),
        Color(0xFF8B0000),
        Color(0xFFB71C1C),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.5, 1.0],
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
  ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: isMobile ? 18.0 : (isTablet ? 20.0 : 18.0),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resource Availability Today',
                    style: TextStyle(
                      fontSize: isMobile ? 14.0 : (isTablet ? 16.0 : 15.0),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Content container with matching styling
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: Color(0xFFE5E7EB), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    label: 'Fully Available',
                    count: fully,
                    color: Color(0xFF059669),
                    icon: Icons.check_circle_rounded,
                    isMobile: isMobile,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    label: 'Partially Available',
                    count: partial,
                    color: Color(0xFFD97706),
                    icon: Icons.pending_actions_rounded,
                    isMobile: isMobile,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatusCard(
                    label: 'Not Available',
                    count: notAvail,
                    color: Color(0xFFDC2626),
                    icon: Icons.block_rounded,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildStatusCard({
  required String label,
  required int count,
  required Color color,
  required IconData icon,
  required bool isMobile,
}) {
  return Container(
    padding: EdgeInsets.all(isMobile ? 12 : 16),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.05)]),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3), width: 1),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isMobile ? 16 : 20),
            SizedBox(width: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: isMobile ? 9 : 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A4A4A),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    ),
  );
}
}