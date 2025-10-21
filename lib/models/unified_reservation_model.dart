import 'package:intl/intl.dart';
import 'package:testing/utils/datetime_extensions.dart';

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

// ============================================
// UNIFIED RESERVATION - Single source of truth
// ============================================
class UnifiedReservation {
  // Core fields (common to both old models)
  final String id;                    // Changed from int to String for consistency
  final String facilityId;            // From Reservation model
  final String resourceName;          // From UserReservationStatus
  final String purpose;
  final String status;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Advanced fields (from UserReservationStatus)
  final List<ApprovalStep> approvalSteps;
  final List<DailySlot> dailySlots;

  UnifiedReservation({
    required this.id,
    required this.facilityId,
    required this.resourceName,
    required this.purpose,
    required this.status,
    required this.dateFrom,
    required this.dateTo,
    required this.createdAt,
    this.updatedAt,
    this.approvalSteps = const [],
    this.dailySlots = const [],
  });

  // ============================================
  // Factory Constructors - Support both API responses
  // ============================================
  
  /// Primary constructor from API (combined reservation + status data)
  factory UnifiedReservation.fromJson(Map<String, dynamic> json) {
    DateTime safeParseDate(dynamic value) {
      try {
        if (value == null) return DateTime.now().toUtc();
        return DateTime.parse(value.toString()).toUtc();
      } catch (_) {
        return DateTime.now().toUtc();
      }
    }

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

    List<ApprovalStep> parseApprovals(dynamic approvalsData) {
      if (approvalsData == null || approvalsData is! List || (approvalsData as List).isEmpty) {
        return [];
      }
      
      try {
        return (approvalsData as List)
            .map((step) => ApprovalStep.fromJson(step as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }

    return UnifiedReservation(
      id: json['id']?.toString() ?? '0',
      facilityId: json['f_id']?.toString() ?? json['facility_id']?.toString() ?? '',
      resourceName: json['resource_name'] ?? json['f_name'] ?? json['facilityName'] ?? 'Unknown Resource',
      purpose: json['purpose'] ?? '',
      status: json['reservation_status'] ?? json['status'] ?? 'pending',
      dateFrom: safeParseDate(json['date_from'] ?? json['dateFrom']),
      dateTo: safeParseDate(json['date_to'] ?? json['dateTo']),
      createdAt: safeParseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: json['updated_at'] != null ? safeParseDate(json['updated_at']) : null,
      dailySlots: parseDailySlots(json['daily_slots']),
      approvalSteps: parseApprovals(json['approvals']),
    );
  }

  // ============================================
  // Business Logic & Computed Properties
  // ============================================
  
  /// Check if reservation is completed (approved and end date has passed)
  bool get isCompleted {
    final statusLower = status.toLowerCase();
    if (statusLower != 'approved') return false;
    
    final now = DateTime.now().toUtc();
    return dateTo.isBefore(now);
  }

  /// Check if reservation is active (not completed and not history status)
  bool get isActive {
    if (isCompleted) return false;
    
    final statusLower = status.toLowerCase();
    return statusLower == 'pending' || statusLower == 'approved';
  }

  /// Check if reservation is history (completed or terminal status)
  bool get isHistory {
    final statusLower = status.toLowerCase();
    return isCompleted || 
           statusLower == 'rejected' || 
           statusLower == 'cancelled';
  }

  /// Can this reservation be cancelled?
  bool get canCancel {
    final statusLower = status.toLowerCase();
    if (statusLower == 'cancelled' || statusLower == 'rejected' || isCompleted) {
      return false;
    }
    // Can only cancel if it's in the future
    return dateFrom.isAfter(DateTime.now().toUtc());
  }

  /// Does this reservation have approval tracking?
  bool get hasApprovalTracking => approvalSteps.isNotEmpty;

  /// Number of completed approvals
  int get completedApprovals => 
      approvalSteps.where((s) => s.status.toLowerCase() == 'approved').length;

  /// Total approval steps
  int get totalApprovalSteps => approvalSteps.length;

  /// Has any approval step been rejected?
  bool get hasRejection => 
      approvalSteps.any((s) => s.status.toLowerCase() == 'rejected');

  /// Approval progress (0.0 to 1.0)
  double get approvalProgress {
    if (totalApprovalSteps == 0) return 0.0;
    if (hasRejection) return 1.0;
    return completedApprovals / totalApprovalSteps;
  }

  // ============================================
  // Display Helpers
  // ============================================
  
  String get dateRange {
    if (dailySlots.isEmpty) {
      return '${dateFrom.toPhString(pattern: "dd/M/yyyy")} - ${dateTo.toPhString(pattern: "dd/M/yyyy")}';
    }
    
    if (dailySlots.length == 1) {
      return dailySlots[0].formatDatePh(dailySlots[0].date);
    }
    
    return '${dailySlots.first.formatDatePh(dailySlots.first.date)} - ${dailySlots.last.formatDatePh(dailySlots.last.date)}';
  }

  String get timeRange {
    if (dailySlots.isEmpty) {
      return '${dateFrom.toPhString(pattern: "hh:mm a")} - ${dateTo.toPhString(pattern: "hh:mm a")}';
    }
    
    return dailySlots.first.formattedTime;
  }

  String getDayLabel(int index) {
    final suffixes = ['st', 'nd', 'rd'];
    final suffix = (index < 3) ? suffixes[index] : 'th';
    return '${index + 1}$suffix Day';
  }

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

  // ============================================
  // Immutable Updates
  // ============================================
  
  UnifiedReservation copyWith({
    String? id,
    String? facilityId,
    String? resourceName,
    String? purpose,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ApprovalStep>? approvalSteps,
    List<DailySlot>? dailySlots,
  }) {
    return UnifiedReservation(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      resourceName: resourceName ?? this.resourceName,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvalSteps: approvalSteps ?? this.approvalSteps,
      dailySlots: dailySlots ?? this.dailySlots,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facilityId': facilityId,
      'resourceName': resourceName,
      'purpose': purpose,
      'status': status,
      'date_from': dateFrom.toIso8601String(),
      'date_to': dateTo.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'daily_slots': dailySlots.map((slot) => {
        'slot_date': slot.date.toIso8601String(),
        'start_time': slot.startTime,
        'end_time': slot.endTime,
      }).toList(),
      'approvals': approvalSteps.map((step) => step.toJson()).toList(),
    };
  }
}

// ============================================
// ApprovalStep - Keep as-is
// ============================================
class ApprovalStep {
  final String id;
  final int stepOrder;
  final String approverName;
  final String approverRole;
  final String status;
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
      id: json['id']?.toString() ?? '',
      stepOrder: json['stepOrder'] ?? json['step_order'] ?? 0,
      approverName: json['approverName'] ?? json['approver_name'] ?? '',
      approverRole: json['approverRole'] ?? json['approver_role'] ?? '',
      status: json['status'] ?? 'pending',
      comment: json['comment'],
      actedAt: safeParseDate(json['actedAt'] ?? json['acted_at']),
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
    final acted = actedAt!.toLocal();
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