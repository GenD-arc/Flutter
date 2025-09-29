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

class ScheduleItem {
  final int reservationId;
  final String purpose;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String status;
  final String reservedBy;

  // Philippines timezone offset (UTC+8)
  static const Duration philippinesOffset = Duration(hours: 8);

  ScheduleItem({
    required this.reservationId,
    required this.purpose,
    required this.dateFrom,
    required this.dateTo,
    required this.status,
    required this.reservedBy,
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
          // If not UTC, treat as local server time and convert to UTC first
          dateFrom = dateFrom.toUtc();
        }
      } catch (e) {
        print('Error parsing date_from: ${json['date_from']}, trying alternative format');
        // Try alternative parsing if needed
        dateFrom = DateTime.tryParse(json['date_from'] as String);
      }

      try {
        dateTo = DateTime.parse(json['date_to'] as String);
        if (!dateTo.isUtc) {
          // If not UTC, treat as local server time and convert to UTC first
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

      print('✅ Parsed ScheduleItem times:');
      print('   - Original date_from: ${json['date_from']}');
      print('   - Parsed UTC date_from: ${dateFrom.toIso8601String()}');
      print('   - Philippines time: ${_toPhilippinesTime(dateFrom).toIso8601String()}');

      return ScheduleItem(
        reservationId: reservationId,
        purpose: json['purpose'].toString().trim(),
        dateFrom: dateFrom, // Store as UTC
        dateTo: dateTo,     // Store as UTC
        status: json['status'].toString().trim(),
        reservedBy: json['reserved_by'].toString().trim(),
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

  // Method to get formatted Philippines time string
  String getPhilippinesTimeString() {
    final phStart = dateFromPhilippines;
    final phEnd = dateToPhilippines;
    
    final startTime = '${phStart.hour.toString().padLeft(2, '0')}:${phStart.minute.toString().padLeft(2, '0')}';
    final endTime = '${phEnd.hour.toString().padLeft(2, '0')}:${phEnd.minute.toString().padLeft(2, '0')}';
    
    return '$startTime - $endTime PST';
  }

  @override
  String toString() {
    return 'ScheduleItem(id: $reservationId, purpose: $purpose, '
           'from: ${dateFromPhilippines.toIso8601String()}, '
           'to: ${dateToPhilippines.toIso8601String()}, '
           'status: $status, by: $reservedBy)';
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