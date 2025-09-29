import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/services/auth_service.dart';
import '../services/reservation_status_service.dart';
import '../models/reservation_status_model.dart';
import '../utils/approval_design_system.dart';

class ReservationStatusTrackerScreen extends StatefulWidget {
  final String userId;

  const ReservationStatusTrackerScreen({
    super.key,
    required this.userId,
  });

  @override
  State<ReservationStatusTrackerScreen> createState() => _ReservationStatusTrackerScreenState();
}

class _ReservationStatusTrackerScreenState extends State<ReservationStatusTrackerScreen> {
  late final ReservationStatusService _statusService;

  @override
  void initState() {
    super.initState();
    _statusService = context.read<ReservationStatusService>();
    // Use addPostFrameCallback to avoid calling during build 
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations(); // Now called after the build is complete
    });
  }

  Future<void> _loadReservations() async {
    final authService = context.read<AuthService>();
    if (authService.isAuthenticated && authService.token != null && authService.token!.isNotEmpty) {
      await _statusService.fetchUserReservations(
        widget.userId, 
        token: authService.token,
      );
    } else {
      // Handle case where user is not authenticated or token is missing
      _statusService.clearData();
      // You might want to navigate to login screen here
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _cancelReservation(String reservationId) async {
    final authService = context.read<AuthService>();
    if (!authService.isAuthenticated || authService.token == null || authService.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to cancel a reservation')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Reservation'),
        content: const Text('Are you sure you want to cancel this reservation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _statusService.cancelReservation(
        reservationId,
        token: authService.token,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation cancelled successfully')),
        );
        await _loadReservations(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to cancel reservation. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Scaffold(
      backgroundColor: ApprovalDesignSystem.backgroundColor,
      body: Column(
        children: [
          _buildHeader(isMobile),
          Expanded(
            child: Consumer<ReservationStatusService>(
              builder: (context, service, child) {
                if (service.isLoading && service.userReservations.isEmpty) {
                  return _buildLoadingState();
                }

                if (service.errorMessage != null) {
                  return _buildErrorState(service.errorMessage!, isMobile);
                }

                if (service.userReservations.isEmpty) {
                  return _buildEmptyState(isMobile);
                }

                return _buildReservationsList(service.userReservations, isMobile);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      height: isMobile ? 100 : 120,
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
              Container(
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
                  Icons.track_changes_rounded,
                  color: ApprovalDesignSystem.primaryMaroon,
                  size: 24,
                ),
              ),
              SizedBox(width: ApprovalDesignSystem.getElementSpacing(isMobile)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Appointment Status',
                      style: ApprovalDesignSystem.displayLarge(isMobile).copyWith(
                        color: ApprovalDesignSystem.darkMaroon,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track your reservation requests and approvals',
                      style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [ApprovalDesignSystem.primaryMaroon, ApprovalDesignSystem.lightMaroon],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: _loadReservations,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(ApprovalDesignSystem.primaryMaroon),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading your reservations...',
            style: TextStyle(
              fontSize: 16,
              color: ApprovalDesignSystem.darkMaroon,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ApprovalDesignSystem.getSectionPadding(isMobile)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ApprovalDesignSystem.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ApprovalDesignSystem.errorRed, width: 1.5),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: ApprovalDesignSystem.errorRed,
                size: 48,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Unable to load reservations',
              style: ApprovalDesignSystem.titleLarge(isMobile).copyWith(
                color: ApprovalDesignSystem.darkMaroon,
              ),
            ),
            SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadReservations,
              style: ElevatedButton.styleFrom(
                backgroundColor: ApprovalDesignSystem.primaryMaroon,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ApprovalDesignSystem.getSectionPadding(isMobile)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue, width: 1.5),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: Colors.blue,
                size: 48,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No Reservations Found',
              style: ApprovalDesignSystem.titleLarge(isMobile).copyWith(
                color: ApprovalDesignSystem.darkMaroon,
              ),
            ),
            SizedBox(height: 12),
            // Add debug info
            Consumer<ReservationStatusService>(
              builder: (context, service, child) {
                return Text(
                  'Debug: isLoading=${service.isLoading}, error=${service.errorMessage}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.red),
                );
              },
            ),
            SizedBox(height: 12),
            Text(
              'You haven\'t made any reservation requests yet.\nStart by browsing available resources!',
              textAlign: TextAlign.center,
              style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationsList(List<UserReservationStatus> reservations, bool isMobile) {
  debugPrint('Building reservations list with ${reservations.length} reservations');
  for (var reservation in reservations) {
    debugPrint('Reservation ${reservation.id}: ${reservation.approvalSteps.length} approval steps');
  }
  return RefreshIndicator(
    onRefresh: _loadReservations,
    color: ApprovalDesignSystem.primaryMaroon,
    child: ListView.builder(
      padding: EdgeInsets.all(ApprovalDesignSystem.getSectionPadding(isMobile)),
      itemCount: reservations.length,
      itemBuilder: (context, index) {
        final reservation = reservations[index];
        return _buildReservationCard(reservation, isMobile);
      },
    ),
  );
}

  Widget _buildReservationCard(UserReservationStatus reservation, bool isMobile) {
    final canCancel = reservation.currentStatus.toLowerCase() == 'pending' || 
                      reservation.currentStatus.toLowerCase() == 'approved';

    return Card(
      margin: EdgeInsets.only(bottom: ApprovalDesignSystem.getElementSpacing(isMobile)),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showReservationDetails(reservation, isMobile),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReservationHeader(reservation, isMobile),
              SizedBox(height: 16),
              _buildReservationDetails(reservation, isMobile),
              SizedBox(height: 16),
              _buildProgressIndicator(reservation, isMobile),
              SizedBox(height: 16),
              _buildActionButtons(reservation, isMobile, canCancel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReservationHeader(UserReservationStatus reservation, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.meeting_room_rounded, 
            color: ApprovalDesignSystem.primaryMaroon, 
            size: 20
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reservation.resourceName,
                style: ApprovalDesignSystem.titleLarge(isMobile).copyWith(
                  color: ApprovalDesignSystem.darkMaroon,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                reservation.purpose,
                style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
        _buildStatusBadge(reservation.currentStatus, isMobile),
      ],
    );
  }

  Widget _buildReservationDetails(UserReservationStatus reservation, bool isMobile) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[600]),
            SizedBox(width: 8),
            Text(
              reservation.dateRange,
              style: ApprovalDesignSystem.bodySmall(isMobile),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 16, color: Colors.grey[600]),
            SizedBox(width: 8),
            Text(
              reservation.timeRange,
              style: ApprovalDesignSystem.bodySmall(isMobile),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(UserReservationStatus reservation, bool isMobile) {
  final totalSteps = reservation.approvalSteps.length;
  final completedSteps = reservation.approvalSteps.where((step) => step.status == 'approved').length;
  final hasRejection = reservation.approvalSteps.any((step) => step.status == 'rejected');
  final isCancelled = reservation.currentStatus.toLowerCase() == 'cancelled';
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Approval Progress',
            style: ApprovalDesignSystem.bodyMedium(isMobile).copyWith(
              fontWeight: FontWeight.w600,
              color: ApprovalDesignSystem.darkMaroon,
            ),
          ),
          Text(
            isCancelled 
              ? 'Cancelled' 
              : hasRejection 
                ? 'Rejected' 
                : totalSteps == 0 
                  ? 'No approvers' 
                  : '$completedSteps of $totalSteps approved',
            style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
              color: isCancelled 
                ? Colors.grey[600] 
                : hasRejection 
                  ? ApprovalDesignSystem.errorRed 
                  : totalSteps == 0
                    ? Colors.grey[600]
                    : ApprovalDesignSystem.primaryMaroon,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      SizedBox(height: 8),
      LinearProgressIndicator(
        value: isCancelled 
          ? 0.0 
          : hasRejection 
            ? 1.0 
            : totalSteps == 0 
              ? 0.0 
              : completedSteps / totalSteps,
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(
          isCancelled 
            ? Colors.grey 
            : hasRejection 
              ? ApprovalDesignSystem.errorRed 
              : totalSteps == 0
                ? Colors.grey
                : ApprovalDesignSystem.primaryMaroon
        ),
      ),
    ],
  );
}

  Widget _buildStatusBadge(String status, bool isMobile) {
  Color backgroundColor;
  Color textColor;
  IconData icon;

  switch (status.toLowerCase()) {
    case 'approved':
      backgroundColor = ApprovalDesignSystem.successGreen.withOpacity(0.1);
      textColor = ApprovalDesignSystem.successGreen;
      icon = Icons.check_circle;
      break;
    case 'rejected':
      backgroundColor = ApprovalDesignSystem.errorRed.withOpacity(0.1);
      textColor = ApprovalDesignSystem.errorRed;
      icon = Icons.cancel;
      break;
    case 'cancelled':
      backgroundColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey[600]!;
      icon = Icons.cancel_outlined;
      break;
    case 'pending':
    default:
      backgroundColor = ApprovalDesignSystem.warningOrange.withOpacity(0.1);
      textColor = ApprovalDesignSystem.warningOrange;
      icon = Icons.schedule;
      break;
  }

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: textColor.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        SizedBox(width: 4),
        Text(
          status.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildActionButtons(UserReservationStatus reservation, bool isMobile, bool canCancel) {
    final authService = context.read<AuthService>();
    final statusService = context.read<ReservationStatusService>();
  
  // Show cancel button only for pending or approved reservations
  bool canCancel = reservation.currentStatus.toLowerCase() == 'pending' || 
                   reservation.currentStatus.toLowerCase() == 'approved';
  
  if (canCancel && authService.isAuthenticated) {
    return Container(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showReservationDetails(reservation, isMobile),
              icon: Icon(Icons.visibility_rounded, size: 16),
              label: Text('View Details'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: ApprovalDesignSystem.primaryMaroon),
                foregroundColor: ApprovalDesignSystem.primaryMaroon,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showCancelConfirmationDialog(reservation, isMobile),
              icon: Icon(Icons.cancel_rounded, size: 16),
              label: Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ApprovalDesignSystem.errorRed,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  } else {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showReservationDetails(reservation, isMobile),
            icon: const Icon(Icons.visibility_rounded, size: 16),
            label: const Text('View Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: ApprovalDesignSystem.primaryMaroon),
              foregroundColor: ApprovalDesignSystem.primaryMaroon,
            ),
          ),
        ),
        if (canCancel) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _cancelReservation(reservation.id),
              icon: const Icon(Icons.cancel_rounded, size: 16),
              label: const Text('Cancel Reservation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ApprovalDesignSystem.errorRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ],
    );
  }
  }

  void _showCancelConfirmationDialog(UserReservationStatus reservation, bool isMobile) {
  final authService = context.read<AuthService>();
  final statusService = context.read<ReservationStatusService>();
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: ApprovalDesignSystem.errorRed),
          SizedBox(width: 8),
          Text('Cancel Reservation'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to cancel your reservation for "${reservation.resourceName}"?',
            style: ApprovalDesignSystem.bodyMedium(isMobile),
          ),
          SizedBox(height: 12),
          Text(
            'This action cannot be undone and will notify all approvers.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Keep Reservation'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(); // Close dialog
            _showCancelLoadingDialog();
            
            final success = await statusService.cancelReservation(
              reservation.id,
              token: authService.token,
            );
            
            Navigator.of(context).pop(); // Close loading dialog
            
            if (success) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reservation cancelled successfully'),
                    backgroundColor: ApprovalDesignSystem.successGreen,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              if (mounted && statusService.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(statusService.errorMessage!),
                    backgroundColor: ApprovalDesignSystem.errorRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: ApprovalDesignSystem.errorRed,
            foregroundColor: Colors.white,
          ),
          child: Text('Cancel Reservation'),
        ),
      ],
    ),
  );
}

void _showCancelLoadingDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(ApprovalDesignSystem.errorRed),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Cancelling reservation...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ApprovalDesignSystem.darkMaroon,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _showReservationDetails(UserReservationStatus reservation, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => ReservationDetailsDialog(
        reservation: reservation,
        isMobile: isMobile,
      ),
    );
  }
}

class ReservationDetailsDialog extends StatelessWidget {
  final UserReservationStatus reservation;
  final bool isMobile;

  const ReservationDetailsDialog({
    super.key,
    required this.reservation,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final canCancel = reservation.currentStatus.toLowerCase() == 'pending' || 
                      reservation.currentStatus.toLowerCase() == 'approved';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReservationInfo(),
                    SizedBox(height: 24),
                    _buildApprovalTimeline(),
                  ],
                ),
              ),
            ),
            _buildDialogFooter(context, canCancel),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ApprovalDesignSystem.primaryMaroon, ApprovalDesignSystem.lightMaroon],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.track_changes_rounded, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reservation Details',
                  style: ApprovalDesignSystem.titleLarge(isMobile).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  reservation.resourceName,
                  style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reservation Information',
          style: ApprovalDesignSystem.titleMedium(isMobile).copyWith(
            color: ApprovalDesignSystem.darkMaroon,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _buildInfoRow('Resource', reservation.resourceName, Icons.meeting_room_rounded),
        _buildInfoRow('Purpose', reservation.purpose, Icons.description_rounded),
        _buildInfoRow('Date Range', reservation.dateRange, Icons.calendar_today_rounded),
        _buildInfoRow('Time Range', reservation.timeRange, Icons.access_time_rounded),
        _buildInfoRow('Status', reservation.currentStatus.toUpperCase(), Icons.info_outline_rounded),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ApprovalDesignSystem.primaryMaroon, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: ApprovalDesignSystem.bodySmall(isMobile).copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: ApprovalDesignSystem.bodyMedium(isMobile).copyWith(
                    color: ApprovalDesignSystem.darkMaroon,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Approval Timeline',
          style: ApprovalDesignSystem.titleMedium(isMobile).copyWith(
            color: ApprovalDesignSystem.darkMaroon,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        ...reservation.approvalSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == reservation.approvalSteps.length - 1;
          
          return _buildTimelineStep(step, isLast);
        }).toList(),
      ],
    );
  }

  Widget _buildTimelineStep(ApprovalStep step, bool isLast) {
    Color statusColor;
    IconData statusIcon;

    switch (step.status.toLowerCase()) {
    case 'approved':
      statusColor = ApprovalDesignSystem.successGreen;
      statusIcon = Icons.check_circle;
      break;
    case 'rejected':
      statusColor = ApprovalDesignSystem.errorRed;
      statusIcon = Icons.cancel;
      break;
    case 'cancelled':
      statusColor = Colors.grey[600]!;
      statusIcon = Icons.cancel_outlined;
      break;
    case 'pending':
    default:
      statusColor = Colors.grey;
      statusIcon = Icons.schedule;
      break;
  }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                statusIcon,
                size: 10,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey.shade200,
              ),
          ],
        ),
        SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(16),
            decoration: ApprovalDesignSystem.timelineItemDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Step ${step.stepOrder}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ApprovalDesignSystem.primaryMaroon,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        step.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Approver: ${step.approverName}',
                  style: ApprovalDesignSystem.bodyMedium(isMobile).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (step.comment != null && step.comment!.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: ApprovalDesignSystem.commentBoxDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.comment_rounded, size: 14, color: Colors.blue),
                            SizedBox(width: 4),
                            Text(
                              'Comment',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          step.comment!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (step.actedAt != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Processed: ${step.formattedDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogFooter(BuildContext context, bool canCancel) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: ApprovalDesignSystem.primaryMaroon,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}