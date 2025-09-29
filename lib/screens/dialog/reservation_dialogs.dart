import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation_model.dart';
import '../../utils/reservation_design_system.dart';

class CancelReservationDialog extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onConfirm;
  final bool isMobile;

  const CancelReservationDialog({
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
          maxWidth: isMobile ? double.infinity : 400,
        ),
        margin: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: ReservationDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              
              SizedBox(height: 20),
              
              // Title
              Text(
                'Cancel Reservation',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w700,
                  color: ReservationDesignSystem.darkMaroon,
                ),
              ),
              
              SizedBox(height: 12),
              
              // Message
              Text(
                'Are you sure you want to cancel your reservation for "${reservation.facilityName}"?',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 8),
              
              // Reservation details
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(reservation.dateFrom.toLocal())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Time: ${DateFormat('hh:mm a').format(reservation.dateFrom.toLocal())} - ${DateFormat('hh:mm a').format(reservation.dateTo.toLocal())}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20),
              
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Keep Reservation',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel Reservation',
                        style: TextStyle(fontWeight: FontWeight.w600),
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
}

class ReservationDetailsDialog extends StatelessWidget {
  final Reservation reservation;
  final bool isMobile;

  const ReservationDetailsDialog({
    super.key,
    required this.reservation,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        margin: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: ReservationDesignSystem.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ReservationDesignSystem.primaryMaroon, ReservationDesignSystem.lightMaroon],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(reservation.status),
                    color: Colors.white,
                    size: isMobile ? 24 : 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservation Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          reservation.status.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Facility', reservation.facilityName, isMobile),
                    _buildDetailRow('Facility ID', reservation.facilityId, isMobile),
                    _buildDetailRow('Purpose', reservation.purpose, isMobile),
                    _buildDetailRow(
                      'Start Date & Time',
                      DateFormat('EEEE, MMMM dd, yyyy • hh:mm a').format(reservation.dateFrom.toLocal()),
                      isMobile,
                    ),
                    _buildDetailRow(
                      'End Date & Time',
                      DateFormat('EEEE, MMMM dd, yyyy • hh:mm a').format(reservation.dateTo.toLocal()),
                      isMobile,
                    ),
                    _buildDetailRow(
                      'Duration',
                      reservation.duration,
                      isMobile,
                    ),
                    _buildDetailRow(
                      'Requested On',
                      DateFormat('EEEE, MMMM dd, yyyy • hh:mm a').format(reservation.createdAt.toLocal()),
                      isMobile,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isMobile) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: ReservationDesignSystem.darkMaroon,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.help;
    }
  }
}