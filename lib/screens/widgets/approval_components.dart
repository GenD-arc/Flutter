import 'package:flutter/material.dart';
import 'package:testing/theme/colors.dart';
import '../../models/reservation_approval_model.dart';
import '../../utils/approval_design_system.dart';

class ApprovalHeader extends StatelessWidget {
  final bool isMobile;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ApprovalHeader({
    super.key,
    required this.isMobile,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, ApprovalDesignSystem.cardBackground],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ApprovalDesignSystem.getSectionPadding(isMobile),
            vertical: 16,
          ),
          child: Row(
            children: [
              _buildIconContainer(),
              SizedBox(width: ApprovalDesignSystem.getElementSpacing(isMobile)),
              if (isMobile)
              _buildTitleSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ApprovalDesignSystem.primaryMaroon.withOpacity(0.1),
            ApprovalDesignSystem.primaryMaroon.withOpacity(0.05)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Icon(
        Icons.event_available_rounded,
        color: ApprovalDesignSystem.primaryMaroon,
        size: 24,
      ),
    );
  }

  Widget _buildTitleSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Reservation Approvals',
            style: ApprovalDesignSystem.displayMedium(isMobile).copyWith(
              color: ApprovalDesignSystem.darkMaroon,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class ApprovalCard extends StatelessWidget {
  final ReservationApproval reservation;
  final bool isMobile;
  final VoidCallback onTap;

  const ApprovalCard({
    super.key,
    required this.reservation,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: ApprovalDesignSystem.getElementSpacing(isMobile)),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(ApprovalDesignSystem.getCardPadding(isMobile)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ApprovalDesignSystem.cardBackground, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: ApprovalDesignSystem.getElementSpacing(isMobile)),
              _buildPurpose(),
              SizedBox(height: ApprovalDesignSystem.getElementSpacing(isMobile)),
              _buildDateTimeInfo(),
              SizedBox(height: 12),
              _buildRequesterInfo(),
              SizedBox(height: ApprovalDesignSystem.getElementSpacing(isMobile)),
              _buildActionHint(),
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
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.meeting_room_rounded, color: ApprovalDesignSystem.primaryMaroon, size: 20),
        ),
        SizedBox(width: 12),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            reservation.facilityName?.trim().isEmpty == true 
                ? 'Unnamed Facility' 
                : reservation.facilityName ?? 'Unnamed Facility',
            style: ApprovalDesignSystem.titleLarge(isMobile).copyWith(
              color: ApprovalDesignSystem.darkMaroon,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 12),
        _buildStepBadge(),
      ],
    );
  }

  Widget _buildStepBadge() {
    final stepOrder = reservation.stepOrder ?? 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ApprovalDesignSystem.stepBadgeDecoration(stepOrder),
      child: Text(
        stepOrder > 0 ? 'Step $stepOrder' : 'Step N/A',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: ApprovalDesignSystem.getStepColor(stepOrder),
        ),
      ),
    );
  }

  Widget _buildPurpose() {
    final purpose = reservation.purpose?.trim();
    return Text(
      purpose?.isEmpty == true || purpose == null 
          ? 'No purpose specified' 
          : purpose,
      style: ApprovalDesignSystem.bodyLarge(isMobile).copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.grey[700],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateTimeInfo() {
    return Row(
      children: [
        _buildInfoItem(
          Icons.calendar_today_rounded, 
          _getDisplayText(reservation.dateRange, 'No date specified')
        ),
        SizedBox(width: 16),
        _buildInfoItem(
          Icons.access_time_rounded, 
          _getDisplayText(reservation.timeRange, 'No time specified')
        ),
      ],
    );
  }

  Widget _buildRequesterInfo() {
    return _buildInfoItem(
      Icons.person_rounded,
      'Requester: ${_getDisplayText(reservation.requesterName, 'Unknown User')}'
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Flexible(
      fit: FlexFit.loose,
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          SizedBox(width: 6),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              text,
              style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionHint() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ApprovalDesignSystem.primaryMaroon.withOpacity(0.05),
            ApprovalDesignSystem.primaryMaroon.withOpacity(0.02)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app_rounded, color: ApprovalDesignSystem.primaryMaroon, size: 16),
          SizedBox(width: 8),
          Text(
            'Tap to review and take action',
            style: TextStyle(
              color: ApprovalDesignSystem.primaryMaroon,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to handle null and empty strings
  String _getDisplayText(String? value, String fallback) {
    final trimmedValue = value?.trim();
    return trimmedValue?.isEmpty == true || trimmedValue == null 
        ? fallback 
        : trimmedValue;
  }
}

class ApprovalDialog extends StatelessWidget {
  final ReservationApproval reservation;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isMobile;

  const ApprovalDialog({
    super.key,
    required this.reservation,
    required this.onApprove,
    required this.onReject,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: EdgeInsets.all(ApprovalDesignSystem.getCardPadding(isMobile)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, ApprovalDesignSystem.cardBackground],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.2),
              blurRadius: 30,
              offset: Offset(0, 15),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: ApprovalDesignSystem.getElementSpacing(isMobile)),
              _buildDetails(),
              SizedBox(height: ApprovalDesignSystem.getElementSpacing(isMobile)),
              _buildActionSection(),
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
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ApprovalDesignSystem.primaryMaroon, ApprovalDesignSystem.lightMaroon],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.event_available_rounded, color: Colors.white, size: 24),
        ),
        SizedBox(width: 12),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            'Review Reservation',
            style: ApprovalDesignSystem.titleLarge(isMobile).copyWith(
              color: ApprovalDesignSystem.darkMaroon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDetailRow('Facility', _getDisplayText(reservation.facilityName, 'Unnamed Facility')),
        _buildDetailRow('Purpose', _getDisplayText(reservation.purpose, 'No purpose specified')),
        _buildDetailRow('Date', _getDisplayText(reservation.dateRange, 'No date specified')),
        _buildDetailRow('Time', _getDisplayText(reservation.timeRange, 'No time specified')),
        _buildDetailRow('Requester', _getDisplayText(reservation.requesterName, 'Unknown User')),
        _buildDetailRow('Approval Step', 
          reservation.stepOrder != null && reservation.stepOrder! > 0 
              ? 'Step ${reservation.stepOrder}' 
              : 'Step N/A'
        ),
        if (reservation.reservationId != null && reservation.reservationId!.isNotEmpty)
          _buildDetailRow('Reservation ID', reservation.reservationId!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 100 : 120,
            child: Text(
              '$label:',
              style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
                fontWeight: FontWeight.w600,
                color: darkMaroon,
              ),
            ),
          ),
          SizedBox(width: 12),
          Flexible(
            fit: FlexFit.loose,
            child: Text(
              value,
              style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
                color: ApprovalDesignSystem.darkMaroon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Action Required',
          style: ApprovalDesignSystem.bodyLarge(isMobile).copyWith(
            fontWeight: FontWeight.w700,
            color: ApprovalDesignSystem.darkMaroon,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Please review the reservation request and take appropriate action.',
          style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: ApprovalDesignSystem.getElementSpacing(isMobile)),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: ApprovalDesignSystem.errorRed),
                ),
                child: Text(
                  'Reject',
                  style: TextStyle(
                    color: ApprovalDesignSystem.errorRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ApprovalDesignSystem.primaryMaroon,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Approve',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to handle null and empty strings with proper trimming
  String _getDisplayText(String? value, String fallback) {
    final trimmedValue = value?.trim();
    return trimmedValue?.isEmpty == true || trimmedValue == null 
        ? fallback 
        : trimmedValue;
  }
}