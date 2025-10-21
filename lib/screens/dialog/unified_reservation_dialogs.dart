import 'package:flutter/material.dart';
import 'package:testing/models/unified_reservation_model.dart';
import 'package:testing/utils/app_design_system.dart';

class UnifiedCancelReservationDialog extends StatelessWidget {
  final UnifiedReservation reservation;
  final VoidCallback onConfirm;
  final bool isMobile;

  const UnifiedCancelReservationDialog({
    super.key,
    required this.reservation,
    required this.onConfirm,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 380,
        ),
        margin: EdgeInsets.all(isMobile ? 14.4 : 21.6),
        decoration: BoxDecoration(
          color: AppDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.15),
                      Colors.deepOrange.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Cancel Reservation',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppDesignSystem.darkMaroon,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to cancel your reservation for "${reservation.resourceName}"?',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[50]!,
                      Colors.grey[100]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.calendar_today_rounded,
                      'Date',
                      reservation.dateRange,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Colors.grey[300], height: 1),
                    ),
                    _buildDetailRow(
                      Icons.access_time_rounded,
                      'Time',
                      reservation.timeRange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Colors.red[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'This action cannot be undone',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: Colors.grey[300]!, width: 1.5),
                        ),
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text(
                        'Keep',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shadowColor: Colors.red.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppDesignSystem.primaryMaroon,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================
// RESERVATION DETAILS DIALOG
// ============================================
class UnifiedReservationDetailsDialog extends StatefulWidget {
  final UnifiedReservation reservation;
  final bool isMobile;

  const UnifiedReservationDetailsDialog({
    super.key,
    required this.reservation,
    required this.isMobile,
  });

  @override
  State<UnifiedReservationDetailsDialog> createState() =>
      _UnifiedReservationDetailsDialogState();
}

class _UnifiedReservationDetailsDialogState
    extends State<UnifiedReservationDetailsDialog> {
  bool _scheduleExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: widget.isMobile ? double.infinity : 480,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        margin: EdgeInsets.all(widget.isMobile ? 14.4 : 21.6),
        decoration: BoxDecoration(
          color: AppDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(widget.isMobile ? 20 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Reservation Information'),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Resource',
                      widget.reservation.resourceName,
                      Icons.meeting_room_rounded,
                    ),
                    _buildDetailRow(
                      'Purpose',
                      widget.reservation.purpose,
                      Icons.description_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildScheduleSection(),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Status',
                      widget.reservation.status.toUpperCase(),
                      Icons.info_outline_rounded,
                      isLast: !widget.reservation.hasApprovalTracking,
                    ),
                    if (widget.reservation.hasApprovalTracking) ...[
                      const SizedBox(height: 24),
                      _buildSectionTitle('Approval Timeline'),
                      const SizedBox(height: 12),
                      _buildApprovalTimeline(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppDesignSystem.primaryMaroon,
            AppDesignSystem.lightMaroon,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppDesignSystem.primaryMaroon.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              _getStatusIcon(widget.reservation.status),
              color: Colors.white,
              size: widget.isMobile ? 22 : 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservation Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isMobile ? 17 : 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.reservation.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.reservation.status.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.isMobile ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: widget.isMobile ? 20 : 24,
              ),
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: widget.isMobile ? 16 : 17,
        fontWeight: FontWeight.w700,
        color: AppDesignSystem.darkMaroon,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppDesignSystem.primaryMaroon.withOpacity(0.1),
                      AppDesignSystem.lightMaroon.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppDesignSystem.primaryMaroon.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppDesignSystem.primaryMaroon,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: widget.isMobile ? 12 : 13,
                        fontWeight: FontWeight.w600,
                        color: AppDesignSystem.darkMaroon,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: widget.isMobile ? 14 : 15,
                        color: Colors.grey[700],
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildScheduleSection() {
    if (widget.reservation.dailySlots.isEmpty) {
      return Column(
        children: [
          _buildDetailRow(
            'Date Range',
            widget.reservation.dateRange,
            Icons.calendar_today_rounded,
          ),
          _buildDetailRow(
            'Time Range',
            widget.reservation.timeRange,
            Icons.access_time_rounded,
          ),
        ],
      );
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _scheduleExpanded = !_scheduleExpanded),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppDesignSystem.primaryMaroon.withOpacity(0.1),
                        AppDesignSystem.lightMaroon.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppDesignSystem.primaryMaroon.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.schedule_rounded,
                    color: AppDesignSystem.primaryMaroon,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: AppDesignSystem.darkMaroon,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${widget.reservation.dailySlots.length} day(s) • Tap to ${_scheduleExpanded ? 'collapse' : 'expand'}',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 14 : 15,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _scheduleExpanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppDesignSystem.primaryMaroon,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_scheduleExpanded) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              children: List.generate(
                widget.reservation.dailySlots.length,
                (index) => _buildDaySlot(index),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDaySlot(int index) {
    final slot = widget.reservation.dailySlots[index];
    final isLast = index == widget.reservation.dailySlots.length - 1;
    final dayLabel = widget.reservation.getDayLabel(index);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppDesignSystem.primaryMaroon.withOpacity(0.1),
                      AppDesignSystem.lightMaroon.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppDesignSystem.primaryMaroon.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppDesignSystem.primaryMaroon,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.formatDatePh(slot.date),
                      style: TextStyle(
                        fontSize: widget.isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: AppDesignSystem.darkMaroon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          slot.formattedTime,
                          style: TextStyle(
                            fontSize: widget.isMobile ? 12 : 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            color: Colors.grey[200],
            height: 1,
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }

  Widget _buildApprovalTimeline() {
    return Column(
      children: widget.reservation.approvalSteps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == widget.reservation.approvalSteps.length - 1;
        return _buildTimelineStep(step, isLast);
      }).toList(),
    );
  }

  Widget _buildTimelineStep(ApprovalStep step, bool isLast) {
    final statusColor = _getStepStatusColor(step.status);
    final statusIcon = _getStepStatusIcon(step.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                statusIcon,
                size: 16,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withOpacity(0.3),
                      Colors.grey.shade200,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.primaryMaroon.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Step ${step.stepOrder}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppDesignSystem.primaryMaroon,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        step.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: AppDesignSystem.primaryMaroon,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        step.approverName,
                        style: TextStyle(
                          fontSize: widget.isMobile ? 13 : 14,
                          fontWeight: FontWeight.w600,
                          color: AppDesignSystem.darkMaroon,
                        ),
                      ),
                    ),
                  ],
                ),
                if (step.comment != null && step.comment!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue[200]!,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.comment_rounded,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Comment',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          step.comment!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (step.actedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Processed: ${step.formattedDate}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'cancelled':
        return Icons.block_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green[600]!;
      case 'pending':
        return Colors.orange[600]!;
      case 'rejected':
        return Colors.red[600]!;
      case 'cancelled':
        return Colors.grey[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  IconData _getStepStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_rounded;
      case 'rejected':
        return Icons.close_rounded;
      case 'cancelled':
        return Icons.block_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  Color _getStepStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppDesignSystem.successGreen;
      case 'rejected':
        return AppDesignSystem.errorRed;
      case 'cancelled':
        return Colors.grey[600]!;
      default:
        return AppDesignSystem.warningOrange;
    }
  }
}