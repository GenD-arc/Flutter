import 'package:intl/intl.dart';

class Reservation {
  final int id;
  final String facilityId;
  final String facilityName;
  final String purpose;
  final String status;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.purpose,
    required this.status,
    required this.dateFrom,
    required this.dateTo,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    DateTime safeParseDate(dynamic value) {
      try {
        if (value == null) return DateTime.now().toUtc();
        return DateTime.parse(value.toString()).toUtc();
      } catch (_) {
        return DateTime.now().toUtc();
      }
    }

    return Reservation(
      id: json['id'] ?? 0,
      facilityId: json['f_id'] ?? json['facility_id'] ?? '',
      facilityName: json['f_name'] ?? json['facilityName'] ?? '',
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? 'pending',
      dateFrom: safeParseDate(json['date_from'] ?? json['dateFrom']),
      dateTo: safeParseDate(json['date_to'] ?? json['dateTo']),
      createdAt: safeParseDate(json['created_at'] ?? json['createdAt']),
    );
  }

  /// ✅ Can the reservation be cancelled?
  bool get canCancel {
    if (status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'rejected') {
      return false;
    }
    return dateFrom.isAfter(DateTime.now().toUtc());
  }

  /// ✅ Duration string
  String get duration {
    final diff = dateTo.difference(dateFrom);
    if (diff.inDays > 0) {
      return '${diff.inDays} day(s), ${diff.inHours % 24} hour(s)';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour(s), ${diff.inMinutes % 60} minute(s)';
    } else {
      return '${diff.inMinutes} minute(s)';
    }
  }

  /// ✅ Convert to Philippine Time (UTC+8)
  String formatPh(DateTime date, {String pattern = "MMM d, yyyy hh:mm a"}) {
    return DateFormat(pattern).format(date.toUtc().add(const Duration(hours: 8)));
  }

  /// ✅ Convenience Getters
  String get formattedDateRange => 
      '${formatPh(dateFrom, pattern: "MMM d, yyyy hh:mm a")} - ${formatPh(dateTo, pattern: "MMM d, yyyy hh:mm a")}';

  String get createdAtFormatted => formatPh(createdAt);
}