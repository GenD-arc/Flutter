// utils/philippines_time_utils.dart

/// Utility class for handling Philippines timezone conversions and formatting
/// Philippines is UTC+8 (PST - Philippine Standard Time)
class PhilippinesTimeUtils {
  /// Philippines timezone offset from UTC (8 hours)
  static const Duration philippinesOffset = Duration(hours: 8);

  /// Convert UTC DateTime to Philippines time (PST)
  static DateTime toPhilippinesTime(DateTime utcTime) {
    return utcTime.add(philippinesOffset);
  }

  /// Convert Philippines time to UTC
  static DateTime toUtc(DateTime philippinesTime) {
    return philippinesTime.subtract(philippinesOffset);
  }

  /// Get current time in Philippines
  static DateTime now() {
    return DateTime.now().toUtc().add(philippinesOffset);
  }

  /// Get current date in Philippines (time set to 00:00:00)
  static DateTime today() {
    final now = PhilippinesTimeUtils.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Format time as "h:mm AM/PM" (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $amPm';
  }

  /// Format date as "M/D/YYYY" (e.g., "10/19/2025")
  static String formatDateShort(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  /// Format date as "Month DD, YYYY" (e.g., "October 19, 2025")
  static String formatDateLong(DateTime dateTime) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  /// Format date with weekday as "Weekday, Month DD, YYYY" 
  /// (e.g., "Thursday, October 19, 2025")
  static String formatDateWithWeekday(DateTime dateTime) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${weekdays[dateTime.weekday - 1]}, ${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  /// Format complete date-time as "MM/DD/YYYY h:mm AM/PM PST"
  static String formatFullDateTime(DateTime dateTime) {
    return '${formatDateShort(dateTime)} ${formatTime(dateTime)} PST';
  }

  /// Format date-time for display in calendar
  /// (e.g., "Oct 19, 2025 • 2:30 PM")
  static String formatCalendarDateTime(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} • ${formatTime(dateTime)}';
  }

  /// Format month and year (e.g., "October 2025")
  static String formatMonthYear(DateTime dateTime) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.year}';
  }

  /// Format time range (e.g., "2:30 PM - 5:00 PM")
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  /// Format date range (e.g., "10/19/2025 - 10/21/2025")
  static String formatDateRange(DateTime start, DateTime end) {
    return '${formatDateShort(start)} - ${formatDateShort(end)}';
  }

  /// Get month key for data organization (e.g., "2025-10")
  static String getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Get date key for data organization (e.g., "2025-10-19")
  static String getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if date is today (in Philippines timezone)
  static bool isToday(DateTime date) {
    final today = now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  /// Check if date is in the past (in Philippines timezone)
  static bool isPastDate(DateTime date) {
    final today = now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    return dateOnly.isBefore(todayOnly);
  }

  /// Check if date is in the future (in Philippines timezone)
  static bool isFutureDate(DateTime date) {
    final today = now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    return dateOnly.isAfter(todayOnly);
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Check if date is within a date range (inclusive)
  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    
    return dateOnly.isAtSameMomentAs(startOnly) ||
           dateOnly.isAtSameMomentAs(endOnly) ||
           (dateOnly.isAfter(startOnly) && dateOnly.isBefore(endOnly));
  }

  /// Get the start of week for a given date (Monday)
  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Get the end of week for a given date (Sunday)
  static DateTime getEndOfWeek(DateTime date) {
    final startOfWeek = getStartOfWeek(date);
    return startOfWeek.add(const Duration(days: 6));
  }

  /// Get the start of month for a given date
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the end of month for a given date
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Get number of days in a month
  static int getDaysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  /// Get the starting weekday of a month (0 = Sunday, 6 = Saturday)
  static int getStartingWeekday(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday % 7;
  }

  /// Calculate number of weeks needed to display a month
  static int getWeeksInMonth(DateTime date) {
    final daysInMonth = getDaysInMonth(date);
    final startingWeekday = getStartingWeekday(date);
    return ((daysInMonth + startingWeekday + 6) ~/ 7);
  }

  /// Check if a reservation spans multiple days
  static bool isMultiDayReservation(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return !startDate.isAtSameMomentAs(endDate);
  }

  /// Get days between two dates (inclusive)
  static int getDaysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays + 1;
  }
}