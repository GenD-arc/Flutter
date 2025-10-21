import 'package:intl/intl.dart';
import 'package:testing/utils/datetime_extensions.dart';

class AvailabilityResource {
  final String id;
  final String name;
  final String category;
  final String description;

  AvailabilityResource({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
  });
}

class Conflict {
  final int reservationId;
  final String purpose;
  final DateTime reservedFrom;
  final DateTime reservedTo;
  final String status;
  final String reservedBy;

  Conflict({
    required this.reservationId,
    required this.purpose,
    required this.reservedFrom,
    required this.reservedTo,
    required this.status,
    required this.reservedBy,
  });

  factory Conflict.fromJson(Map<String, dynamic> json) {
    return Conflict(
      reservationId: json['reservation_id'] ?? 0,
      purpose: json['purpose'] ?? '',
      reservedFrom: DateTime.parse(json['reserved_from']),
      reservedTo: DateTime.parse(json['reserved_to']),
      status: json['status'] ?? 'pending',
      reservedBy: json['reserved_by'] ?? 'Unknown User',
    );
  }
}

class DailySlot {
  final DateTime date;
  final String startTime;
  final String endTime;

  DailySlot({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  factory DailySlot.fromJson(Map<String, dynamic> json) {
    DateTime safeParseDate(dynamic value) {
      try {
        if (value == null) return DateTime.now().toUtc();
        return DateTime.parse(value.toString()).toUtc();
      } catch (_) {
        return DateTime.now().toUtc();
      }
    }

    return DailySlot(
      date: safeParseDate(json['slot_date'] ?? json['date']),
      startTime: json['start_time'] ?? '00:00:00',
      endTime: json['end_time'] ?? '00:00:00',
    );
  }

  String get formattedTime {
    try {
      // Parse time strings to extract hours and minutes
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      
      final startHour = int.parse(startParts[0]);
      final startMinute = int.parse(startParts[1]);
      final endHour = int.parse(endParts[0]);
      final endMinute = int.parse(endParts[1]);
      
      // Create DateTime objects in local time (not UTC)
      // Since times from server are already in Philippines time
      final startDateTime = DateTime(2000, 1, 1, startHour, startMinute);
      final endDateTime = DateTime(2000, 1, 1, endHour, endMinute);
      
      // Format the time
      final startFormatted = DateFormat('hh:mm a').format(startDateTime);
      final endFormatted = DateFormat('hh:mm a').format(endDateTime);
      
      return '$startFormatted - $endFormatted';
    } catch (e) {
      print('❌ Error formatting time: $e');
      return '$startTime - $endTime';
    }
  }

  String formatDatePh(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date.toUtc().add(const Duration(hours: 8)));
  }
}

class ScheduleItem {
  final int reservationId;
  final String purpose;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String status;
  final String reservedBy;
  final String resourceId;
  final String resourceName;
  final String resourceCategory;
  final List<DailySlot> dailySlots;

  // Philippines timezone offset (UTC+8)
  static const Duration philippinesOffset = Duration(hours: 8);

  ScheduleItem({
    required this.reservationId,
    required this.purpose,
    required this.dateFrom,
    required this.dateTo,
    required this.status,
    required this.reservedBy,
    required this.resourceId,
    required this.resourceName,
    required this.resourceCategory,
    required this.dailySlots,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      throw FormatException('Cannot create ScheduleItem from null JSON');
    }

    final requiredFields = ['reservation_id', 'purpose', 'date_from', 'date_to', 'status', 'reserved_by'];
    for (String field in requiredFields) {
      if (json[field] == null) {
        throw FormatException('Missing required field "$field" in ScheduleItem JSON: $json');
      }
    }

    if (json['purpose'].toString().trim().isEmpty ||
        json['status'].toString().trim().isEmpty ||
        json['reserved_by'].toString().trim().isEmpty) {
      throw FormatException('Empty required string fields in ScheduleItem JSON: $json');
    }

    try {
      // Parse dates - assume they come from server in UTC or local server time
      DateTime? dateFrom;
      DateTime? dateTo;
      
      // Try parsing with different formats
      try {
        dateFrom = DateTime.parse(json['date_from'] as String);
        if (!dateFrom.isUtc) {
          dateFrom = dateFrom.toUtc();
        }
      } catch (e) {
        print('Error parsing date_from: ${json['date_from']}, trying alternative format');
        dateFrom = DateTime.tryParse(json['date_from'] as String);
      }

      try {
        dateTo = DateTime.parse(json['date_to'] as String);
        if (!dateTo.isUtc) {
          dateTo = dateTo.toUtc();
        }
      } catch (e) {
        print('Error parsing date_to: ${json['date_to']}, trying alternative format');
        dateTo = DateTime.tryParse(json['date_to'] as String);
      }

      final reservationId = json['reservation_id'] is int
          ? json['reservation_id']
          : int.tryParse(json['reservation_id'].toString());

      if (dateFrom == null) {
        throw FormatException('Invalid date_from format: ${json['date_from']}');
      }
      if (dateTo == null) {
        throw FormatException('Invalid date_to format: ${json['date_to']}');
      }
      if (reservationId == null || reservationId == 0) {
        throw FormatException('Invalid reservation_id: ${json['reservation_id']}');
      }

      // Parse daily slots with DEBUG
      List<DailySlot> parseDailySlots(dynamic slotsData) {
        print('🔍 DEBUG parseDailySlots for reservation $reservationId:');
        print('  slotsData type: ${slotsData.runtimeType}');
        print('  slotsData value: $slotsData');
        
        if (slotsData == null) {
          print('  ❌ slotsData is null');
          return [];
        }
        if (slotsData is! List) {
          print('  ❌ slotsData is not a List, it is ${slotsData.runtimeType}');
          return [];
        }
        
        try {
          final slots = (slotsData as List)
              .map((slot) {
                print('  📦 Parsing slot: $slot');
                return DailySlot.fromJson(slot as Map<String, dynamic>);
              })
              .toList();
          print('  ✅ Successfully parsed ${slots.length} slots');
          return slots;
        } catch (e) {
          print('  ❌ Error parsing slots: $e');
          return [];
        }
      }

      // Debug: Print full JSON
      print('📋 Full JSON for reservation $reservationId:');
      print(json);

      return ScheduleItem(
        reservationId: reservationId,
        purpose: json['purpose'].toString().trim(),
        dateFrom: dateFrom,
        dateTo: dateTo,
        status: json['status'].toString().trim(),
        reservedBy: json['reserved_by'].toString().trim(),
        resourceId: json['f_id']?.toString().trim() ?? '',
        resourceName: json['resource_name']?.toString().trim() ?? '',
        resourceCategory: json['resource_category']?.toString().trim() ?? '',
        dailySlots: parseDailySlots(json['daily_slots']),
      );
    } catch (e) {
      print('Error parsing ScheduleItem from JSON: $e');
      print('Problematic JSON: $json');
      throw FormatException('Failed to parse ScheduleItem: $e');
    }
  }

  // Helper method to convert UTC to Philippines time
  static DateTime _toPhilippinesTime(DateTime utcTime) {
    return utcTime.add(philippinesOffset);
  }

  // Getter for Philippines time
  DateTime get dateFromPhilippines => _toPhilippinesTime(dateFrom);
  DateTime get dateToPhilippines => _toPhilippinesTime(dateTo);

  // ✅ NEW: Get the daily slot for a specific date
  DailySlot? getSlotForDate(DateTime date) {
    if (dailySlots.isEmpty) return null;
    
    // Normalize the date to compare only year, month, day
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    for (var slot in dailySlots) {
      final slotDate = DateTime(slot.date.year, slot.date.month, slot.date.day);
      if (slotDate == normalizedDate) {
        return slot;
      }
    }
    
    return null;
  }

  // ✅ NEW: Get formatted time for a specific display date
  String getFormattedTimeForDate(DateTime displayDate) {
    // Try to find the slot for this specific date
    final slot = getSlotForDate(displayDate);
    
    if (slot != null) {
      // Found a slot for this date
      if (isMultiDay) {
        // For multi-day, show which day this is
        final dayNumber = _getDayNumberForDate(displayDate);
        final totalDays = dailySlots.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet().length;
        return '${slot.formattedTime} (Day $dayNumber of $totalDays)';
      } else {
        // Single day reservation
        return slot.formattedTime;
      }
    }
    
    // Fallback: use the default formattedTime
    return formattedTime;
  }

  // Helper to get which day number this date represents in the reservation
  int _getDayNumberForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final sortedDates = dailySlots
        .map((slot) => DateTime(slot.date.year, slot.date.month, slot.date.day))
        .toSet()
        .toList()
      ..sort();
    
    for (int i = 0; i < sortedDates.length; i++) {
      if (sortedDates[i] == normalizedDate) {
        return i + 1; // 1-based index
      }
    }
    
    return 1; // Fallback
  }

  // ✅ FIXED: Get formatted time - USE DAILY SLOTS INSTEAD OF DATE FROM/TO
  String get formattedTime {
    // ALWAYS use daily slots if available - they contain the actual reservation times
    if (dailySlots.isNotEmpty) {
      // For single slot, show directly
      if (dailySlots.length == 1) {
        return dailySlots.first.formattedTime;
      }
      
      // For multiple slots on same day
      final uniqueDates = dailySlots.map((slot) => slot.date).toSet();
      if (uniqueDates.length == 1) {
        return '${dailySlots.first.formattedTime} • ${dailySlots.length} slots';
      }
      
      // Multi-day with different times - show first day's time with indicator
      return '${dailySlots.first.formattedTime} (Day 1 of ${uniqueDates.length})';
    }
    
    // Fallback: Only use dateFrom/dateTo if NO daily slots available
    print('⚠️ WARNING: No daily slots available for reservation $reservationId, using dateFrom/dateTo fallback');
    final phStart = dateFromPhilippines;
    final phEnd = dateToPhilippines;
    
    final startTime = DateFormat('hh:mm a').format(phStart);
    final endTime = DateFormat('hh:mm a').format(phEnd);
    
    return '$startTime - $endTime';
  }

  // ✅ FIXED: Get complete formatted schedule string
  String get formattedSchedule {
    if (dailySlots.isNotEmpty) {
      final dates = dailySlots.map((slot) => slot.date).toSet();
      if (dates.length == 1) {
        // Single day with specific time slots
        final dateStr = dates.first.toPhString(pattern: "MMM dd, yyyy");
        return '$dateStr • $formattedTime';
      } else {
        // Multi-day reservation
        final sortedDates = dates.toList()..sort();
        final startDate = sortedDates.first.toPhString(pattern: "MMM dd");
        final endDate = sortedDates.last.toPhString(pattern: "MMM dd, yyyy");
        return '$startDate - $endDate • $formattedTime';
      }
    }
    
    // Fallback for reservations without daily slots
    return '${dateFrom.toPhString(pattern: "MMM dd, yyyy")} • $formattedTime';
  }

  // Helper method to check if this is likely a multi-day event
  bool get isMultiDay {
    if (dailySlots.isNotEmpty) {
      final dates = dailySlots.map((slot) => slot.date).toSet();
      return dates.length > 1;
    }
    return dateFromPhilippines.day != dateToPhilippines.day;
  }

  @override
  String toString() {
    return 'ScheduleItem(id: $reservationId, purpose: $purpose, '
           'from: ${dateFromPhilippines.toIso8601String()}, '
           'to: ${dateToPhilippines.toIso8601String()}, '
           'status: $status, by: $reservedBy, '
           'daily_slots: ${dailySlots.length})';
  }
}

class CalendarDay {
  final DateTime date;
  final bool isCurrentMonth;
  final List<ScheduleItem> reservations;
  final bool isAvailable;

  CalendarDay({
    required this.date,
    required this.isCurrentMonth,
    required this.reservations,
    required this.isAvailable,
  });
}