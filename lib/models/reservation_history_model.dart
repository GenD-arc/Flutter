import '../utils/datetime_extensions.dart';

class ReservationHistory {
  final ReservationDetails reservation;
  final List<ActivityLog> activities;

  ReservationHistory({
    required this.reservation,
    required this.activities,
  });

  factory ReservationHistory.fromJson(Map<String, dynamic> json) {
    return ReservationHistory(
      reservation: ReservationDetails.fromJson(json['reservation'] ?? {}),
      activities: (json['activities'] as List<dynamic>? ?? [])
          .map((activity) => ActivityLog.fromJson(activity))
          .toList(),
    );
  }
}

class ReservationDetails {
  final String reservationId;
  final String facilityId;
  final String resourceName;
  final String requesterId;
  final String requesterName;
  final String purpose;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String currentStatus;
  final DateTime requestedAt;

  ReservationDetails({
    required this.reservationId,
    required this.facilityId,
    required this.resourceName,
    required this.requesterId,
    required this.requesterName,
    required this.purpose,
    required this.dateFrom,
    required this.dateTo,
    required this.currentStatus,
    required this.requestedAt,
  });

  factory ReservationDetails.fromJson(Map<String, dynamic> json) {
    DateTime safeParseDate(dynamic value) {
      try {
        if (value == null) return DateTime.now().toUtc();
        return DateTime.parse(value.toString()).toUtc(); // ✅ always store as UTC
      } catch (_) {
        return DateTime.now().toUtc();
      }
    }

    String safeParseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      return value.toString().trim();
    }

    return ReservationDetails(
      reservationId: safeParseString(json['reservation_id']),
      facilityId: safeParseString(json['f_id']),
      resourceName: safeParseString(json['resource_name']),
      requesterId: safeParseString(json['requester_id']),
      requesterName: safeParseString(json['requester_name']),
      purpose: safeParseString(json['purpose']),
      dateFrom: safeParseDate(json['date_from']),
      dateTo: safeParseDate(json['date_to']),
      currentStatus: safeParseString(json['current_status'], fallback: 'pending'),
      requestedAt: safeParseDate(json['requested_at']),
    );
  }

  /// ✅ Use PH-time extension for display
  String get dateRange =>
      '${dateFrom.toPhString(pattern: "MMM dd, yyyy")} - ${dateTo.toPhString(pattern: "MMM dd, yyyy")}';

  String get timeRange =>
      '${dateFrom.toPhString(pattern: "hh:mm a")} - ${dateTo.toPhString(pattern: "hh:mm a")}';

  String get formattedRequestedAt => requestedAt.toPhString();
}

class ActivityLog {
  final String logId;
  final String actionType;
  final String description;
  final String? oldStatus;
  final String? newStatus;
  final int? stepOrder;
  final String? comment;
  final String actionById;
  final String actionByName;
  final String actionByRole;
  final DateTime actionAt;

  ActivityLog({
    required this.logId,
    required this.actionType,
    required this.description,
    this.oldStatus,
    this.newStatus,
    this.stepOrder,
    this.comment,
    required this.actionById,
    required this.actionByName,
    required this.actionByRole,
    required this.actionAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    DateTime safeParseDate(dynamic value) {
      try {
        if (value == null) return DateTime.now().toUtc();
        return DateTime.parse(value.toString()).toUtc(); // ✅ always UTC
      } catch (_) {
        return DateTime.now().toUtc();
      }
    }

    String safeParseString(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      return value.toString().trim();
    }

    int? safeParseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return ActivityLog(
      logId: safeParseString(json['log_id']),
      actionType: safeParseString(json['action_type']),
      description: safeParseString(json['description']),
      oldStatus: json['old_status'] != null ? safeParseString(json['old_status']) : null,
      newStatus: json['new_status'] != null ? safeParseString(json['new_status']) : null,
      stepOrder: safeParseInt(json['step_order']),
      comment: json['comment'] != null ? safeParseString(json['comment']) : null,
      actionById: safeParseString(json['action_by_id']),
      actionByName: safeParseString(json['action_by_name']),
      actionByRole: safeParseString(json['action_by_role']),
      actionAt: safeParseDate(json['action_at']),
    );
  }

  /// ✅ Use PH-time extension
  String get formattedDate =>
      actionAt.toPhString(pattern: 'MMM dd, yyyy at hh:mm a');

  bool get hasComment => comment != null && comment!.isNotEmpty;

  String get statusChangeText {
    if (oldStatus != null && newStatus != null) {
      return '$oldStatus → $newStatus';
    } else if (newStatus != null) {
      return 'Status: $newStatus';
    }
    return '';
  }

  String get stepText => stepOrder != null ? 'Step $stepOrder' : '';
}