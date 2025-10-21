import 'package:intl/intl.dart';

class ApprovalLog {
  final String? resourceName;
  final String? requesterName;
  final String? action;
  final String? reservationId;
  final String? resourceType;
  final String? resourceLocation;
  final String? purpose;
  final String? reservationDate;
  final String? startTime;
  final String? endTime;
  final String? actionDate;
  final String? notes;
  final int? stepOrder;
  final List<dynamic> dailySlots; // Keep as dynamic for now

  ApprovalLog({
    this.resourceName,
    this.requesterName,
    this.action,
    this.reservationId,
    this.resourceType,
    this.resourceLocation,
    this.purpose,
    this.reservationDate,
    this.startTime,
    this.endTime,
    this.actionDate,
    this.notes,
    this.stepOrder,
    this.dailySlots = const [],
  });

  factory ApprovalLog.fromJson(Map<String, dynamic> json) {
    return ApprovalLog(
      resourceName: json['facility_name'] as String?,
      requesterName: json['requester_name'] as String?,
      action: json['action'] as String?,
      reservationId: json['reservation_id']?.toString(),
      resourceType: json['resource_type'] as String?,
      resourceLocation: json['resource_location'] as String?,
      purpose: json['purpose'] as String?,
      reservationDate: json['date_from'] as String?,
      startTime: json['date_from'] as String?,
      endTime: json['date_to'] as String?,
      actionDate: json['action_date'] as String?,
      notes: json['comment'] as String?,
      stepOrder: json['step_order'] as int?,
      dailySlots: json['daily_slots'] as List<dynamic>? ?? [],
    );
  }

  // Helper method to format date in Philippine time
  String _formatToPhTime(DateTime date, {String pattern = "MMM dd, yyyy"}) {
    try {
      // Convert UTC to Philippine Time (UTC+8)
      final phTime = date.add(const Duration(hours: 8));
      return DateFormat(pattern).format(phTime);
    } catch (_) {
      return DateFormat(pattern).format(date);
    }
  }

  // Helper method to parse date string safely with timezone adjustment
  DateTime? _parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      final date = DateTime.parse(dateString);
      // Convert UTC to local time for Philippine timezone
      return date.add(const Duration(hours: 8));
    } catch (_) {
      return null;
    }
  }

  // Parse daily slot date from dynamic data
  DateTime? _parseSlotDate(dynamic slotData) {
    if (slotData is! Map<String, dynamic>) return null;
    try {
      final dateString = slotData['slot_date']?.toString();
      if (dateString == null) return null;
      final date = DateTime.parse(dateString);
      return date.add(const Duration(hours: 8)); // Convert to PH time
    } catch (_) {
      return null;
    }
  }

  String get formattedDateTime {
    // Use daily slots if available
    if (dailySlots.isNotEmpty) {
      final firstSlotDate = _parseSlotDate(dailySlots.first);
      final lastSlotDate = _parseSlotDate(dailySlots.last);
      
      if (firstSlotDate != null && lastSlotDate != null) {
        if (firstSlotDate.year == lastSlotDate.year &&
            firstSlotDate.month == lastSlotDate.month &&
            firstSlotDate.day == lastSlotDate.day) {
          return _formatToPhTime(firstSlotDate);
        } else {
          return '${_formatToPhTime(firstSlotDate)} - ${_formatToPhTime(lastSlotDate)}';
        }
      }
    }
    
    // Fallback to date_from and date_to
    final dateFrom = _parseDate(reservationDate);
    final dateTo = _parseDate(endTime);
    
    if (dateFrom != null && dateTo != null) {
      final isSameDay = dateFrom.year == dateTo.year &&
                       dateFrom.month == dateTo.month &&
                       dateFrom.day == dateTo.day;
      
      if (isSameDay) {
        return _formatToPhTime(dateFrom);
      } else {
        return '${_formatToPhTime(dateFrom)} - ${_formatToPhTime(dateTo)}';
      }
    } else if (dateFrom != null) {
      return _formatToPhTime(dateFrom);
    } else {
      return 'Not specified';
    }
  }


  bool get hasDetailedSchedule => dailySlots.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'facility_name': resourceName,
      'requester_name': requesterName,
      'action': action,
      'reservation_id': reservationId,
      'resource_type': resourceType,
      'resource_location': resourceLocation,
      'purpose': purpose,
      'reservation_date': reservationDate,
      'start_time': startTime,
      'end_time': endTime,
      'action_date': actionDate,
      'notes': notes,
      'step_order': stepOrder,
      'daily_slots': dailySlots,
    };
  }
}