// widgets/calendar/calendar_header.dart

import 'package:flutter/material.dart';
import '../../../utils/calendar_constants.dart';
import '../../../utils/philippines_time_utils.dart';

/// Enhanced calendar header with month navigation and quick actions
class CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onMonthYearPicker;
  final VoidCallback? onJumpToToday;
  final VoidCallback? onShowCurrentWeek;
  final bool isLoading;
  final DeviceType deviceType;

  const CalendarHeader({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onMonthYearPicker,
    this.onJumpToToday,
    this.onShowCurrentWeek,
    this.isLoading = false,
    required this.deviceType,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    final philippinesNow = PhilippinesTimeUtils.now();

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Quick actions row (if provided)
          if (onJumpToToday != null || onShowCurrentWeek != null)
            _buildQuickActionsRow(isMobile, isTablet),
          
          if (onJumpToToday != null || onShowCurrentWeek != null)
            SizedBox(height: isMobile ? 12 : 16),

          // Main navigation row
          _buildNavigationRow(isMobile, isTablet),
          
          SizedBox(height: isMobile ? 12 : 16),

          // Philippines time indicator
          _buildTimeIndicator(philippinesNow, isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(bool isMobile, bool isTablet) {
    return Row(
      children: [
        if (onJumpToToday != null)
          _QuickNavButton(
            label: 'Today',
            icon: Icons.today,
            onPressed: onJumpToToday!,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
        if (onJumpToToday != null && onShowCurrentWeek != null)
          SizedBox(width: isMobile ? 8 : 12),
        if (onShowCurrentWeek != null)
          _QuickNavButton(
            label: 'This Week',
            icon: Icons.view_week,
            onPressed: onShowCurrentWeek!,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
        const Spacer(),
      ],
    );
  }

  Widget _buildNavigationRow(bool isMobile, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavigationButton(
          icon: Icons.chevron_left,
          onPressed: isLoading ? null : onPreviousMonth,
          isLoading: isLoading,
          isMobile: isMobile,
          isTablet: isTablet,
        ),
        
        // Month/Year picker
        GestureDetector(
          onTap: onMonthYearPicker,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : isTablet ? 20 : 24,
              vertical: isMobile ? 10 : isTablet ? 12 : 14,
            ),
            decoration: BoxDecoration(
              color: CalendarColors.warmGray,
              borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
              border: Border.all(
                color: CalendarColors.primaryMaroon.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  PhilippinesTimeUtils.formatMonthYear(currentMonth),
                  style: TextStyle(
                    fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: CalendarColors.darkMaroon,
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Icon(
                  Icons.arrow_drop_down,
                  color: CalendarColors.primaryMaroon,
                  size: isMobile ? 20 : 24,
                ),
              ],
            ),
          ),
        ),
        
        _NavigationButton(
          icon: Icons.chevron_right,
          onPressed: isLoading ? null : onNextMonth,
          isLoading: isLoading,
          isMobile: isMobile,
          isTablet: isTablet,
        ),
      ],
    );
  }

  Widget _buildTimeIndicator(DateTime time, bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : isTablet ? 16 : 20,
        vertical: isMobile ? 8 : isTablet ? 10 : 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CalendarColors.primaryMaroon.withOpacity(0.08),
            CalendarColors.primaryMaroon.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(
          color: CalendarColors.primaryMaroon.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            size: isMobile ? 14 : 16,
            color: CalendarColors.primaryMaroon,
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Text(
            'Philippines Time: ${PhilippinesTimeUtils.formatTime(time)}',
            style: TextStyle(
              fontSize: isMobile ? 12 : isTablet ? 13 : 14,
              fontWeight: FontWeight.w600,
              color: CalendarColors.primaryMaroon,
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick navigation button widget
class _QuickNavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isMobile;
  final bool isTablet;

  const _QuickNavButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : isTablet ? 12 : 14,
            vertical: isMobile ? 6 : isTablet ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: CalendarColors.primaryMaroon.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            border: Border.all(
              color: CalendarColors.primaryMaroon.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isMobile ? 14 : 16,
                color: CalendarColors.primaryMaroon,
              ),
              SizedBox(width: isMobile ? 4 : 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 11 : isTablet ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: CalendarColors.primaryMaroon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation button for month switching
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isMobile;
  final bool isTablet;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    required this.isLoading,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        child: Container(
          width: isMobile ? 40 : isTablet ? 44 : 48,
          height: isMobile ? 40 : isTablet ? 44 : 48,
          decoration: BoxDecoration(
            color: isLoading
                ? Colors.grey[100]
                : CalendarColors.primaryMaroon.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isLoading
                ? Colors.grey[400]
                : CalendarColors.primaryMaroon,
            size: isMobile ? 20 : isTablet ? 22 : 24,
          ),
        ),
      ),
    );
  }
}