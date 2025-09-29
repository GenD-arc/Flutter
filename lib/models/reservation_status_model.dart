import 'package:testing/utils/datetime_extensions.dart';

class UserReservationStatus {
  final String id;
  final String resourceName;
  final String purpose;
  final String currentStatus;
  final List<ApprovalStep> approvalSteps;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime dateFrom;
  final DateTime dateTo;

  UserReservationStatus({
    required this.id,
    required this.resourceName,
    required this.purpose,
    required this.currentStatus,
    required this.approvalSteps,
    required this.createdAt,
    this.updatedAt,
    required this.dateFrom,
    required this.dateTo,
  });

  UserReservationStatus copyWith({
    String? id,
    String? resourceName,
    String? purpose,
    String? currentStatus,
    List<ApprovalStep>? approvalSteps,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return UserReservationStatus(
      id: id ?? this.id,
      resourceName: resourceName ?? this.resourceName,
      purpose: purpose ?? this.purpose,
      currentStatus: currentStatus ?? this.currentStatus,
      approvalSteps: approvalSteps ?? this.approvalSteps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  // Getter for dateRange
  String get dateRange =>
      '${dateFrom.toPhString(pattern: "dd/M/yyyy")} - ${dateTo.toPhString(pattern: "dd/M/yyyy")}';

  // Getter for timeRange
  String get timeRange =>
      '${dateFrom.toPhString(pattern: "hh:mm a")} - ${dateTo.toPhString(pattern: "hh:mm a")}';

  factory UserReservationStatus.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now().toUtc(); // Store as UTC
      try {
        String dateString = value.toString();
        print('Raw date string: $dateString');
        
        // Parse and store as UTC
        DateTime parsed = DateTime.parse(dateString).toUtc();
        
        print('Stored as UTC: $parsed');
        print('UTC Day: ${parsed.day}, Month: ${parsed.month}');
        
        return parsed;
      } catch (e) {
        print('Error parsing date $value: $e');
        return DateTime.now().toUtc();
      }
    }

    final startTime = parseDate(json['date_from']);
    final endTime = parseDate(json['date_to']);

    return UserReservationStatus(
      id: json['id']?.toString() ?? '',
      resourceName: json['resource_name'] ?? '',
      purpose: json['purpose'] ?? '',
      currentStatus: json['reservation_status'] ?? 'pending',
      approvalSteps: (json['approvals'] as List<dynamic>? ?? [])
          .map((step) => ApprovalStep.fromJson(step))
          .toList(),
      createdAt: parseDate(json['created_at']),
      updatedAt: json['updated_at'] != null ? parseDate(json['updated_at']) : null,
      dateFrom: startTime,
      dateTo: endTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resourceName': resourceName,
      'purpose': purpose,
      'date_from': dateFrom.toIso8601String(),
      'date_to': dateTo.toIso8601String(),
      'currentStatus': currentStatus,
      'approvalSteps': approvalSteps.map((step) => step.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ApprovalStep {
  final String id;
  final int stepOrder;
  final String approverName;
  final String approverRole;
  final String status; // 'pending', 'approved', 'rejected'
  final String? comment;
  final DateTime? actedAt;

  ApprovalStep({
    required this.id,
    required this.stepOrder,
    required this.approverName,
    required this.approverRole,
    required this.status,
    this.comment,
    this.actedAt,
  });

  ApprovalStep copyWith({
    String? id,
    int? stepOrder,
    String? approverName,
    String? approverRole,
    String? status,
    String? comment,
    DateTime? actedAt,
  }) {
    return ApprovalStep(
      id: id ?? this.id,
      stepOrder: stepOrder ?? this.stepOrder,
      approverName: approverName ?? this.approverName,
      approverRole: approverRole ?? this.approverRole,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      actedAt: actedAt ?? this.actedAt,
    );
  }

  factory ApprovalStep.fromJson(Map<String, dynamic> json) {
    DateTime? safeParseDate(dynamic value) {
      try {
        if (value == null) return null;
        return DateTime.parse(value.toString()).toUtc();
      } catch (_) {
        return null;
      }
    }

    return ApprovalStep(
      id: json['id'] ?? '',
      stepOrder: json['stepOrder'] ?? 0,
      approverName: json['approverName'] ?? '',
      approverRole: json['approverRole'] ?? '',
      status: json['status'] ?? 'pending',
      comment: json['comment'],
      actedAt: safeParseDate(json['actedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepOrder': stepOrder,
      'approverName': approverName,
      'approverRole': approverRole,
      'status': status,
      'comment': comment,
      'actedAt': actedAt?.toIso8601String(),
    };
  }

  String get formattedDate {
    if (actedAt == null) return 'Not processed';

    final now = DateTime.now();
    final acted = actedAt!.toLocal(); // Convert to local time if needed
    final diff = now.difference(acted);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}