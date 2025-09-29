import '../utils/datetime_extensions.dart';

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
    
    return ReservationApproval(
      approvalId: safeParseString(json['approval_id'] ?? json['approvalId']),
      reservationId: safeParseString(json['reservation_id'] ?? json['reservationId']),
      facilityId: safeParseString(json['facility_id'] ?? json['facilityId'] ?? json['f_id']),
      facilityName: safeParseString(json['facility_name'] ?? json['facilityName'] ?? json['f_name']),
      purpose: safeParseString(json['purpose']),
      requesterId: safeParseString(json['requester_id'] ?? json['requesterId']),
      requesterName: safeParseString(
        json['requester_name'] ?? json['requesterName'] ?? json['name'],
        fallback: 'Unknown User',
      ),
      stepOrder: safeParseInt(json['step_order'] ?? json['stepOrder'], fallback: 1),
      status: safeParseString(json['status'], fallback: 'pending'),
      dateFrom: safeParseDate(json['date_from'] ?? json['dateFrom']),
      dateTo: safeParseDate(json['date_to'] ?? json['dateTo']),
      createdAt: safeParseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  /// ✅ Use PH-time extension
  String get dateRange =>
      '${dateFrom.toPhString(pattern: "MMM dd, yyyy")} - ${dateTo.toPhString(pattern: "MMM dd, yyyy")}';

  String get timeRange =>
      '${dateFrom.toPhString(pattern: "hh:mm a")} - ${dateTo.toPhString(pattern: "hh:mm a")}';

  String get formattedCreatedAt => createdAt.toPhString();
}