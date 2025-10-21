// utils/calendar_helpers.dart

import 'dart:ui';
import 'package:testing/utils/calendar_constants.dart';
import '../models/availability_checker_model.dart';
import 'philippines_time_utils.dart';

/// Helper functions for calendar operations and calculations
class CalendarHelpers {
  /// Check if a reservation is completed (approved and end date has passed)
  static bool isReservationCompleted(ScheduleItem reservation) {
    final status = reservation.status.toLowerCase();
    if (status != 'approved') return false;
    
    final now = DateTime.now().toUtc();
    return reservation.dateTo.isBefore(now);
  }

  /// Get display status (considers completion)
  static String getDisplayStatus(ScheduleItem reservation) {
    if (isReservationCompleted(reservation)) {
      return 'completed';
    }
    return reservation.status.toLowerCase();
  }

  /// Get status color (considers completion)
  static Color getReservationStatusColor(ScheduleItem reservation) {
    final displayStatus = getDisplayStatus(reservation);
    return CalendarColors.getStatusColor(displayStatus);
  }

  /// Get status background color (considers completion)
  static Color getReservationStatusBackgroundColor(ScheduleItem reservation) {
    final displayStatus = getDisplayStatus(reservation);
    return CalendarColors.getStatusBackgroundColor(displayStatus);
  }

  /// Calculate availability level based on reservation count
  /// Returns: 0 = Available, 1 = Limited, 2 = Moderate, 3 = Busy, 4 = Full
  static int calculateAvailabilityLevel(int reservationCount) {
    if (reservationCount == 0) return 0;  // Available
    if (reservationCount <= 2) return 1;  // Limited
    if (reservationCount <= 4) return 2;  // Moderate
    if (reservationCount <= 6) return 3;  // Busy
    return 4;                              // Full
  }

  /// Get availability status text
  static String getAvailabilityStatus(int reservationCount) {
    final level = calculateAvailabilityLevel(reservationCount);
    switch (level) {
      case 0:
        return 'Available';
      case 1:
        return 'Limited availability';
      case 2:
        return 'Moderately busy';
      case 3:
        return 'Busy';
      case 4:
        return 'Fully booked';
      default:
        return 'Unknown';
    }
  }

  /// Get availability description for accessibility
  static String getAvailabilityDescription(int level) {
    switch (level) {
      case 0:
        return 'Free (0 bookings)';
      case 1:
        return 'Limited (1-2 bookings)';
      case 2:
        return 'Moderate (3-4 bookings)';
      case 3:
        return 'Busy (5-6 bookings)';
      case 4:
        return 'Full (7+ bookings)';
      default:
        return 'Unknown';
    }
  }

  /// Filter reservations by search query
  static List<ScheduleItem> filterBySearch(
    List<ScheduleItem> reservations,
    String searchQuery,
  ) {
    if (searchQuery.isEmpty) return reservations;

    final query = searchQuery.toLowerCase();
    return reservations.where((reservation) {
      return reservation.resourceName.toLowerCase().contains(query) ||
             reservation.reservedBy.toLowerCase().contains(query) ||
             reservation.purpose.toLowerCase().contains(query) ||
             reservation.resourceId.toLowerCase().contains(query);
    }).toList();
  }

  /// Filter reservations by category
  static List<ScheduleItem> filterByCategory(
    List<ScheduleItem> reservations,
    Set<String> activeFilters,
  ) {
    if (activeFilters.contains('All') || activeFilters.isEmpty) {
      return reservations;
    }

    return reservations.where((reservation) {
      return activeFilters.contains(reservation.resourceCategory);
    }).toList();
  }

  /// Filter reservations by status (including completed)
  static List<ScheduleItem> filterByStatus(
    List<ScheduleItem> reservations,
    Set<String> statusFilters,
  ) {
    if (statusFilters.isEmpty) return reservations;

    return reservations.where((reservation) {
      final displayStatus = getDisplayStatus(reservation);
      return statusFilters.contains(displayStatus);
    }).toList();
  }

  /// Combined filter: search + category
  static List<ScheduleItem> filterReservations(
    List<ScheduleItem> reservations,
    String searchQuery,
    Set<String> activeFilters,
  ) {
    return filterByCategory(
      filterBySearch(reservations, searchQuery),
      activeFilters,
    );
  }

  /// Get unique resource categories from reservations
  static Set<String> getUniqueCategories(List<ScheduleItem> reservations) {
    return reservations.map((r) => r.resourceCategory).toSet();
  }

  /// Get unique statuses from reservations (including completed)
  static Set<String> getUniqueStatuses(List<ScheduleItem> reservations) {
    return reservations.map((r) => getDisplayStatus(r)).toSet();
  }

  /// Count reservations by status (including completed)
  static Map<String, int> countByStatus(List<ScheduleItem> reservations) {
    final counts = <String, int>{};
    for (final reservation in reservations) {
      final status = getDisplayStatus(reservation);
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Count reservations by category
  static Map<String, int> countByCategory(List<ScheduleItem> reservations) {
    final counts = <String, int>{};
    for (final reservation in reservations) {
      final category = reservation.resourceCategory;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  /// Get reservations for a specific date from monthly data
  static List<ScheduleItem> getReservationsForDate(
    Map<String, List<ScheduleItem>> monthData,
    DateTime date,
  ) {
    final dateKey = PhilippinesTimeUtils.getDateKey(date);
    return monthData[dateKey] ?? [];
  }

  /// Get reservations for a date range
  static List<ScheduleItem> getReservationsForDateRange(
    Map<String, List<ScheduleItem>> monthData,
    DateTime start,
    DateTime end,
  ) {
    final allReservations = <ScheduleItem>[];
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDate)) {
      allReservations.addAll(getReservationsForDate(monthData, current));
      current = current.add(const Duration(days: 1));
    }

    return allReservations;
  }

  /// Calculate monthly statistics (including completed)
  static Map<String, dynamic> calculateMonthlyStats(
    Map<String, List<ScheduleItem>> monthData,
  ) {
    int totalReservations = 0;
    final statusCounts = <String, int>{};
    final resourceCounts = <String, int>{};

    for (final dayReservations in monthData.values) {
      for (final reservation in dayReservations) {
        totalReservations++;
        final status = getDisplayStatus(reservation);
        final resource = reservation.resourceCategory;
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        resourceCounts[resource] = (resourceCounts[resource] ?? 0) + 1;
      }
    }

    return {
      'totalReservations': totalReservations,
      'busyDays': monthData.length,
      'statusCounts': statusCounts,
      'resourceCounts': resourceCounts,
      'uniqueStatuses': statusCounts.length,
      'uniqueResources': resourceCounts.length,
    };
  }

  /// Generate semantics label for accessibility
  static String generateSemanticsLabel(
    DateTime date,
    List<ScheduleItem> reservations,
  ) {
    final dateLabel = PhilippinesTimeUtils.formatDateWithWeekday(date);
    final reservationCount = reservations.length;
    final status = getAvailabilityStatus(reservationCount);

    return '$dateLabel. $reservationCount reservations. $status. Double tap to view details.';
  }

  /// Sort reservations by date (earliest first)
  static List<ScheduleItem> sortByDate(List<ScheduleItem> reservations) {
    final sorted = List<ScheduleItem>.from(reservations);
    sorted.sort((a, b) => a.dateFrom.compareTo(b.dateFrom));
    return sorted;
  }

  /// Sort reservations by status priority (approved > pending > completed > cancelled > rejected)
  static List<ScheduleItem> sortByStatusPriority(List<ScheduleItem> reservations) {
    final statusPriority = {
      'approved': 1,
      'pending': 2,
      'completed': 3, // ADDED: Completed status priority
      'cancelled': 4,
      'rejected': 5,
    };

    final sorted = List<ScheduleItem>.from(reservations);
    sorted.sort((a, b) {
      final displayStatusA = getDisplayStatus(a);
      final displayStatusB = getDisplayStatus(b);
      final priorityA = statusPriority[displayStatusA] ?? 99;
      final priorityB = statusPriority[displayStatusB] ?? 99;
      return priorityA.compareTo(priorityB);
    });
    return sorted;
  }

  /// Group reservations by date
  static Map<String, List<ScheduleItem>> groupByDate(List<ScheduleItem> reservations) {
    final grouped = <String, List<ScheduleItem>>{};
    
    for (final reservation in reservations) {
      // Convert to Philippines time for grouping
      final phTime = PhilippinesTimeUtils.toPhilippinesTime(reservation.dateFrom);
      final dateKey = PhilippinesTimeUtils.getDateKey(phTime);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(reservation);
    }
    
    return grouped;
  }

  /// Check if there are any conflicts (overlapping reservations)
  static bool hasConflicts(List<ScheduleItem> reservations) {
    if (reservations.length <= 1) return false;

    final approved = reservations
        .where((r) => r.status.toLowerCase() == 'approved' || 
                     r.status.toLowerCase() == 'pending')
        .toList();

    for (int i = 0; i < approved.length; i++) {
      for (int j = i + 1; j < approved.length; j++) {
        if (_reservationsOverlap(approved[i], approved[j])) {
          return true;
        }
      }
    }

    return false;
  }

  /// Check if two reservations overlap
  static bool _reservationsOverlap(ScheduleItem a, ScheduleItem b) {
    return a.dateFrom.isBefore(b.dateTo) && b.dateFrom.isBefore(a.dateTo);
  }

  /// Get conflict count for a specific date
  static int getConflictCount(List<ScheduleItem> reservations) {
    return reservations
        .where((r) => r.status.toLowerCase() == 'approved' || 
                     r.status.toLowerCase() == 'pending')
        .length;
  }

  /// Validate if a date range is valid
  static bool isValidDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return !start.isAfter(end);
  }

  /// Get appropriate empty state message
  static String getEmptyStateMessage(DateTime? selectedDate, bool isPast) {
    if (selectedDate != null && isPast) {
      return 'No reservations were scheduled for this date';
    }
    return 'All resources available';
  }
}