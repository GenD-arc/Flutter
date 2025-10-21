import 'package:intl/intl.dart';
import '../utils/datetime_extensions.dart';

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
      final start = DateFormat('hh:mm a').format(
        DateTime.parse('2000-01-01 $startTime'),
      );
      final end = DateFormat('hh:mm a').format(
        DateTime.parse('2000-01-01 $endTime'),
      );
      return '$start - $end';
    } catch (_) {
      return '$startTime - $endTime';
    }
  }

  String formatDatePh(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date.toUtc().add(const Duration(hours: 8)));
  }
}

class ReservationApproval {
  final String approvalId;
  final String reservationId;
  final String facilityId;
  final String facilityName;
  final String purpose;
  final String requesterId;
  final String requesterName;
  final int stepOrder;
  final String status;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime createdAt;
  final List<DailySlot> dailySlots; // ✅ Added

  ReservationApproval({
    required this.approvalId,
    required this.reservationId,
    required this.facilityId,
    required this.facilityName,
    required this.purpose,
    required this.requesterId,
    required this.requesterName,
    required this.stepOrder,
    required this.status,
    required this.dateFrom,
    required this.dateTo,
    required this.createdAt,
    this.dailySlots = const [], // ✅ Added
  });

  factory ReservationApproval.fromJson(Map<String, dynamic> json) {
    DateTime safeParseDate(dynamic value) {
      try {
        if (value == null) return DateTime.now().toUtc();
        return DateTime.parse(value.toString()).toUtc();
      } catch (_) {
        return DateTime.now().toUtc();
      }
    }

    String safeParseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      return value.toString().trim();
    }

    int safeParseInt(dynamic value, {int fallback = 0}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    // ✅ Parse daily slots
    List<DailySlot> parseDailySlots(dynamic slotsData) {
      if (slotsData == null) return [];
      if (slotsData is! List) return [];
      
      try {
        return (slotsData as List)
            .map((slot) => DailySlot.fromJson(slot as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
    
    return ReservationApproval(
      approvalId: safeParseString(
        json['approval_id'] ?? json['approvalId']
      ),
      reservationId: safeParseString(
        json['reservation_id'] ?? json['reservationId']
      ),
      facilityId: safeParseString(
        json['facility_id'] ?? json['facilityId'] ?? json['f_id']
      ),
      facilityName: safeParseString(
        json['facility_name'] ?? json['facilityName'] ?? json['f_name']
      ),
      purpose: safeParseString(json['purpose']),
      requesterId: safeParseString(
        json['requester_id'] ?? json['requesterId']
      ),
      requesterName: safeParseString(
        json['requester_name'] ?? json['requesterName'] ?? json['name'],
        fallback: 'Unknown User',
      ),
      stepOrder: safeParseInt(
        json['step_order'] ?? json['stepOrder'], 
        fallback: 1
      ),
      status: safeParseString(json['status'], fallback: 'pending'),
      dateFrom: safeParseDate(json['date_from'] ?? json['dateFrom']),
      dateTo: safeParseDate(json['date_to'] ?? json['dateTo']),
      createdAt: safeParseDate(json['created_at'] ?? json['createdAt']),
      dailySlots: parseDailySlots(json['daily_slots']), // ✅ Added
    );
  }

  /// Date range display - uses daily slots if available
  String get dateRange {
    if (dailySlots.isEmpty) {
      return '${dateFrom.toPhString(pattern: "MMM dd, yyyy")} - ${dateTo.toPhString(pattern: "MMM dd, yyyy")}';
    }
    
    if (dailySlots.length == 1) {
      return dailySlots[0].formatDatePh(dailySlots[0].date);
    }
    
    return '${dailySlots.first.formatDatePh(dailySlots.first.date)} - ${dailySlots.last.formatDatePh(dailySlots.last.date)}';
  }

  /// Time range display - uses daily slots if available
  String get timeRange {
    if (dailySlots.isEmpty) {
      return '${dateFrom.toPhString(pattern: "hh:mm a")} - ${dateTo.toPhString(pattern: "hh:mm a")}';
    }
    
    return dailySlots.first.formattedTime;
  }

  /// Formatted request date
  String get formattedCreatedAt => createdAt.toPhString();

  /// Single date display (for same-day reservations)
  String get singleDate => dateFrom.toPhString(pattern: "MMM dd, yyyy");

  /// Check if reservation spans multiple days
  bool get isMultiDay {
    if (dailySlots.isNotEmpty) {
      return dailySlots.length > 1;
    }
    return dateFrom.year != dateTo.year ||
           dateFrom.month != dateTo.month ||
           dateFrom.day != dateTo.day;
  }

  /// Duration in days
  int get durationInDays {
    if (dailySlots.isNotEmpty) {
      return dailySlots.length;
    }
    return dateTo.difference(dateFrom).inDays + 1;
  }

  /// Get day label with ordinal suffix
  String getDayLabel(int index) {
    final suffixes = ['st', 'nd', 'rd'];
    final suffix = (index < 3) ? suffixes[index] : 'th';
    return '${index + 1}$suffix Day';
  }

  Map<String, dynamic> toJson() {
    return {
      'approval_id': approvalId,
      'reservation_id': reservationId,
      'facility_id': facilityId,
      'facility_name': facilityName,
      'purpose': purpose,
      'requester_id': requesterId,
      'requester_name': requesterName,
      'step_order': stepOrder,
      'status': status,
      'date_from': dateFrom.toIso8601String(),
      'date_to': dateTo.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'daily_slots': dailySlots.map((slot) => {
        'slot_date': slot.date.toIso8601String(),
        'start_time': slot.startTime,
        'end_time': slot.endTime,
      }).toList(),
    };
  }
}
