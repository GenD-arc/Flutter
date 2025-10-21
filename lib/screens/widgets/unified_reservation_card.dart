// ============================================
// UNIFIED RESERVATION CARD
// widgets/unified_reservation_card.dart
// ============================================

import 'package:flutter/material.dart';
import 'package:testing/models/unified_reservation_model.dart';
import 'package:testing/utils/app_design_system.dart';

class UnifiedReservationCard extends StatelessWidget {
  final UnifiedReservation reservation;
  final bool isMobile;
  final bool showApprovalProgress;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const UnifiedReservationCard({
    super.key,
    required this.reservation,
    required this.isMobile,
    required this.showApprovalProgress,
    required this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      elevation: 3.6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.4),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.4),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 14.4 : 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, AppDesignSystem.cardBackground],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14.4),
            border: Border.all(color: Colors.grey[100]!, width: 0.9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 14.4),
              _buildDetails(),
              if (showApprovalProgress && reservation.hasApprovalTracking) ...[
                SizedBox(height: 14.4),
                _buildApprovalProgress(),
              ],
              SizedBox(height: 14.4),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.2),
          decoration: BoxDecoration(
            color: AppDesignSystem.primaryMaroon.withOpacity(0.09),
            borderRadius: BorderRadius.circular(10.8),
          ),
          child: Icon(
            Icons.meeting_room_rounded,
            color: AppDesignSystem.primaryMaroon,
            size: 18,
          ),
        ),
        SizedBox(width: 10.8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.resourceName,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 21.6,
                  fontWeight: FontWeight.w700,
                  color: AppDesignSystem.darkMaroon,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 3.6),
              Text(
                reservation.purpose,
                style: TextStyle(
                  fontSize: isMobile ? 10.8 : 12.6,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 14.4, color: Colors.grey[600]),
            SizedBox(width: 7.2),
            Expanded(
              child: Text(
                reservation.dateRange,
                style: TextStyle(
                  fontSize: isMobile ? 10.8 : 12.6,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 7.2),
        Row(
          children: [
            Icon(Icons.access_time_rounded,
                size: 14.4, color: Colors.grey[600]),
            SizedBox(width: 7.2),
            Expanded(
              child: Text(
                reservation.timeRange,
                style: TextStyle(
                  fontSize: isMobile ? 10.8 : 12.6,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApprovalProgress() {
    final isCancelled = reservation.status.toLowerCase() == 'cancelled';
    final isCompleted = reservation.isCompleted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Approval Progress',
              style: TextStyle(
                fontSize: isMobile ? 12.6 : 14.4,
                fontWeight: FontWeight.w600,
                color: AppDesignSystem.darkMaroon,
              ),
            ),
            Text(
              isCancelled
                  ? 'Cancelled'
                  : isCompleted
                      ? 'Completed'
                      : reservation.hasRejection
                          ? 'Rejected'
                          : reservation.totalApprovalSteps == 0
                              ? 'No approvers'
                              : '${reservation.completedApprovals} of ${reservation.totalApprovalSteps} approved',
              style: TextStyle(
                fontSize: isMobile ? 10.8 : 12.6,
                fontWeight: FontWeight.w600,
                color: isCancelled
                    ? Colors.grey[600]
                    : isCompleted
                        ? Color(0xFF1976D2) // Blue for completed
                        : reservation.hasRejection
                            ? AppDesignSystem.errorRed
                            : reservation.totalApprovalSteps == 0
                                ? Colors.grey[600]
                                : AppDesignSystem.primaryMaroon,
              ),
            ),
          ],
        ),
        SizedBox(height: 7.2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: reservation.approvalProgress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isCancelled
                  ? Colors.grey
                  : isCompleted
                      ? Color(0xFF1976D2) // Blue for completed
                      : reservation.hasRejection
                          ? AppDesignSystem.errorRed
                          : reservation.totalApprovalSteps == 0
                              ? Colors.grey
                              : AppDesignSystem.primaryMaroon,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final (color, icon, displayText) = _getStatusProperties(reservation);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.8, vertical: 5.4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(10.8),
        border: Border.all(color: color.withOpacity(0.27)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.6, color: color),
          SizedBox(width: 3.6),
          Text(
            displayText.toUpperCase(),
            style: TextStyle(
              fontSize: 10.8,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(Icons.visibility_rounded, size: 14.4),
            label: Text(
              'View Details',
              style: TextStyle(fontSize: 12.6),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.8),
              ),
              side: BorderSide(color: AppDesignSystem.primaryMaroon),
              foregroundColor: AppDesignSystem.primaryMaroon,
            ),
          ),
        ),
        if (onCancel != null) ...[
          SizedBox(width: 7.2),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onCancel,
              icon: Icon(Icons.cancel_rounded, size: 14.4),
              label: Text(
                'Cancel',
                style: TextStyle(fontSize: 12.6),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.errorRed,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 10.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  (Color, IconData, String) _getStatusProperties(UnifiedReservation reservation) {
    if (reservation.isCompleted) {
      return (Color(0xFF1976D2), Icons.done_all_rounded, 'completed');
    }
    
    switch (reservation.status.toLowerCase()) {
      case 'approved':
        return (AppDesignSystem.successGreen, Icons.check_circle, 'approved');
      case 'rejected':
        return (AppDesignSystem.errorRed, Icons.cancel, 'rejected');
      case 'cancelled':
        return (Colors.grey[600]!, Icons.cancel_outlined, 'cancelled');
      case 'pending':
      default:
        return (AppDesignSystem.warningOrange, Icons.schedule, 'pending');
    }
  }
}