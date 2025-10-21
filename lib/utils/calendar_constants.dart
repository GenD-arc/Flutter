// utils/calendar_constants.dart

import 'package:flutter/material.dart';

/// Device type enumeration for responsive design
enum DeviceType { mobile, tablet, laptop, desktop }

/// Calendar-wide color constants
class CalendarColors {
  // Primary colors
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color warmGray = Color(0xFFF5F6F9);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color successGreen = Color(0xFF10B981);
  static const Color completedBlue = Color(0xFF1976D2); // ADDED: Completed color

  // Status colors for reservations
  static const Map<String, Color> statusColors = {
    'approved': Color(0xFF10B981),
    'pending': Color(0xFFF59E0B),
    'cancelled': Color(0xFF6B7280),
    'rejected': Color(0xFFEF4444),
    'completed': completedBlue, // ADDED: Completed status
  };

  // Status background colors
  static const Map<String, Color> statusBackgroundColors = {
    'approved': Color(0xFFECFDF5),
    'pending': Color(0xFFFFFBEB),
    'cancelled': Color(0xFFF3F4F6),
    'rejected': Color(0xFFFEF2F2),
    'completed': Color(0xFFEFF6FF), // ADDED: Completed background
  };

  // Resource category colors
  static const Map<String, Color> resourceColors = {
    'Facility': Color(0xFF3B82F6),
    'Room': Color(0xFF8B5CF6),
    'Vehicle': Color(0xFFF97316),
    'Equipment': Color(0xFF06B6D4),
    'Unknown': Color(0xFF64748B),
  };

  // Availability level colors (based on reservation count)
  static const Map<int, Color> availabilityLevelColors = {
    0: successGreen,           // Available (0 bookings)
    1: Color(0xFF10B981),      // Limited (1-2 bookings)
    2: Color(0xFFFFD700),      // Moderate (3-4 bookings)
    3: Color(0xFFFF8C00),      // Busy (5-6 bookings)
    4: primaryMaroon,          // Full (7+ bookings)
  };

  // Get status color safely
  static Color getStatusColor(String status) {
    return statusColors[status.toLowerCase()] ?? Colors.grey;
  }

  // Get status background color safely
  static Color getStatusBackgroundColor(String status) {
    return statusBackgroundColors[status.toLowerCase()] ?? Colors.grey[100]!;
  }

  // Get resource color safely
  static Color getResourceColor(String category) {
    return resourceColors[category] ?? resourceColors['Unknown']!;
  }

  // Get availability level color
  static Color getAvailabilityColor(int level) {
    return availabilityLevelColors[level] ?? successGreen;
  }
}

/// Responsive breakpoints
class CalendarBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double desktop = 1440;

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobile) return DeviceType.mobile;
    if (width < tablet) return DeviceType.tablet;
    if (width < desktop) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is desktop or laptop
  static bool isDesktop(BuildContext context) {
    final type = getDeviceType(context);
    return type == DeviceType.laptop || type == DeviceType.desktop;
  }
}

/// Calendar dimensions and sizing
class CalendarDimensions {
  /// Get day cell height based on device type
  static double getDayCellHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 70;
      case DeviceType.tablet:
        return 80;
      case DeviceType.laptop:
      case DeviceType.desktop:
        return 90;
    }
  }

  /// Get spacing based on device type
  static double getSpacing(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 8;
      case DeviceType.tablet:
        return 10;
      case DeviceType.laptop:
      case DeviceType.desktop:
        return 12;
    }
  }

  /// Get padding based on device type
  static EdgeInsets getPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.laptop:
      case DeviceType.desktop:
        return const EdgeInsets.all(20);
    }
  }

  /// Get margin based on device type
  static EdgeInsets getMargin(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.laptop:
      case DeviceType.desktop:
        return const EdgeInsets.all(20);
    }
  }
}

/// Text sizes for different device types
class CalendarTextSizes {
  /// Get title font size
  static double getTitleSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 18;
      case DeviceType.tablet:
        return 20;
      case DeviceType.laptop:
      case DeviceType.desktop:
        return 22;
    }
  }

  /// Get body font size
  static double getBodySize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 14;
      case DeviceType.tablet:
        return 16;
      case DeviceType.laptop:
      case DeviceType.desktop:
        return 18;
    }
  }

  /// Get caption font size
  static double getCaptionSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 11;
      case DeviceType.tablet:
        return 12;
      case DeviceType.laptop:
      case DeviceType.desktop:
        return 13;
    }
  }

  /// Get small font size
  static double getSmallSize(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 9;
      case DeviceType.tablet:
        return 10;
      case DeviceType.laptop:
      case DeviceType.desktop:
        return 11;
    }
  }
}

/// Animation durations
class CalendarAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

/// Month and weekday names
class CalendarLabels {
  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  static const List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> weekdaysShort = [
    'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
  ];

  /// Get month name from index (1-12)
  static String getMonthName(int month) {
    if (month < 1 || month > 12) return 'Invalid';
    return months[month - 1];
  }

  /// Get weekday name from index (1-7, where 1 is Monday)
  static String getWeekdayName(int weekday) {
    if (weekday < 1 || weekday > 7) return 'Invalid';
    return weekdays[weekday - 1];
  }

  /// Get short weekday name
  static String getWeekdayShort(int index) {
    if (index < 0 || index > 6) return '';
    return weekdaysShort[index];
  }
}

/// Calendar text utilities
class CalendarText {
  /// Status display text
  static String getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      case 'completed': // ADDED: Completed status
        return 'Completed';
      default:
        return status;
    }
  }
}