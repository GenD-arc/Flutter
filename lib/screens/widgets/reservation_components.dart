import 'package:flutter/material.dart';
import 'package:testing/utils/datetime_extensions.dart';
import '../../utils/reservation_design_system.dart';
import '../../models/reservation_model.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _getStatusProperties(status);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          if (!compact) SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getStatusProperties(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return (Colors.green, Icons.check_circle);
      case 'pending':
        return (Colors.orange, Icons.hourglass_empty);
      case 'rejected':
        return (Colors.red, Icons.cancel);
      case 'cancelled':
        return (Colors.grey, Icons.block);
      default:
        return (Colors.grey, Icons.help);
    }
  }
}

class ReservationStatsCard extends StatelessWidget {
  final int total;
  final int pending;
  final int approved;
  final bool isMobile;

  const ReservationStatsCard({
    super.key,
    required this.total,
    required this.pending,
    required this.approved,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ReservationDesignSystem.getSectionPadding(isMobile)),
      padding: EdgeInsets.all(ReservationDesignSystem.getCardPadding(isMobile)),
      decoration: ReservationDesignSystem.gradientHeader(isMobile),
      child: Row(
        children: [
          _buildStatItem(total, 'Total Reservations', isMobile),
          _buildDivider(),
          _buildStatItem(pending, 'Pending', isMobile),
          _buildDivider(),
          _buildStatItem(approved, 'Approved', isMobile),
        ],
      ),
    );
  }

  Widget _buildStatItem(int count, String label, bool isMobile) => Expanded(
    child: Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: isMobile ? 10 : 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildDivider() => Container(
    width: 1,
    height: 30,
    margin: EdgeInsets.symmetric(horizontal: 8),
    color: Colors.white.withOpacity(0.3),
  );
}

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final bool isMobile;
  final VoidCallback onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: Remove the ds variable and use ReservationDesignSystem directly
    return Container(
      margin: EdgeInsets.only(bottom: ReservationDesignSystem.getElementSpacing(isMobile)),
      decoration: ReservationDesignSystem.cardDecoration(isMobile),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(ReservationDesignSystem.getCardPadding(isMobile)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: ReservationDesignSystem.getElementSpacing(isMobile)),
                _buildPurpose(),
                SizedBox(height: ReservationDesignSystem.getElementSpacing(isMobile)),
                _buildDateTimeInfo(),
                SizedBox(height: 8),
                _buildCreatedDate(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.facilityName,
                style: ReservationDesignSystem.titleLarge(isMobile),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              Text(
                'ID: ${reservation.facilityId}',
                style: ReservationDesignSystem.bodySmall(isMobile),
              ),
            ],
          ),
        ),
        StatusBadge(status: reservation.status),
      ],
    );
  }

  Widget _buildPurpose() {
    return Text(
      reservation.purpose,
      style: ReservationDesignSystem.bodyLarge(isMobile).copyWith(height: 1.3),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateTimeInfo() {
    return Row(
      children: [
        _buildDateTimeColumn(Icons.calendar_today, 'Start', reservation.dateFrom),
        _buildDivider(),
        _buildDateTimeColumn(Icons.event_available, 'End', reservation.dateTo),
      ],
    );
  }

  Widget _buildDateTimeColumn(IconData icon, String label, DateTime date) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: ReservationDesignSystem.primaryMaroon),
              SizedBox(width: 6),
              Text(label, style: ReservationDesignSystem.bodySmall(isMobile)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            _formatDateTime(date),
            style: ReservationDesignSystem.bodySmall(isMobile).copyWith(
              color: ReservationDesignSystem.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      margin: EdgeInsets.symmetric(horizontal: 12),
      color: Colors.grey[300],
    );
  }

  Widget _buildCreatedDate() {
    return Row(
      children: [
        Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
        SizedBox(width: 6),
        Text(
          'Requested on ${_formatDate(reservation.createdAt)}',
          style: ReservationDesignSystem.bodySmall(isMobile).copyWith(
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return date.toPhString(pattern: 'MM/dd/yyyy • hh:mm a');
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}