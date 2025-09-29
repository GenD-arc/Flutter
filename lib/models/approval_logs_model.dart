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
  });

  factory ApprovalLog.fromJson(Map<String, dynamic> json) {
    return ApprovalLog(
      resourceName: json['resource_name'] as String?,
      requesterName: json['requester_name'] as String?,
      action: json['action'] as String?,
      reservationId: json['reservation_id']?.toString(),
      resourceType: json['resource_type'] as String?,
      resourceLocation: json['resource_location'] as String?,
      purpose: json['purpose'] as String?,
      reservationDate: json['reservation_date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      actionDate: json['action_date'] as String?,
      notes: json['notes'] as String?,
      stepOrder: json['step_order'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resource_name': resourceName,
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
    };
  }
}