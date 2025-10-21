import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/screens/dialog/enhanced_approval_dialog.dart';
import 'package:testing/screens/widgets/approval_components.dart';
import 'package:testing/screens/widgets/approval_state_widgets.dart';
import 'package:testing/utils/approval_design_system.dart';
import '../../models/reservation_approval_model.dart';
import '../../services/reservation_approval_service.dart';
import '../../services/notification_service.dart';

class ReservationApprovalScreen extends StatefulWidget {
  final String approverId;
  final String token;
  final String? resourceId;
  final String? resourceName;

  const ReservationApprovalScreen({
    super.key,
    required this.approverId,
    required this.token,
    this.resourceId,
    this.resourceName,
  });

  @override
  State<ReservationApprovalScreen> createState() => _ReservationApprovalScreenState();
}

class _ReservationApprovalScreenState extends State<ReservationApprovalScreen> {
  late final ReservationApprovalService _approvalService;
  late final NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _approvalService = context.read<ReservationApprovalService>();
    _notificationService = context.read<NotificationService>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPendingReservations();
      _initializeNotifications();
    });
  }

  void _initializeNotifications() {
  _notificationService.connectWebSocket(
    widget.approverId,
    widget.token,
  );
}

  @override
void dispose() {
  _notificationService.disconnect();
  super.dispose();
}

  Future<void> _loadPendingReservations() async {
    await _approvalService.fetchPendingReservations(
      widget.approverId, 
      widget.token,
      resourceId: widget.resourceId,
    );
    
    // Mark notifications as read when user views the screen
    if (widget.resourceId != null) {
      _notificationService.markResourceAsRead(widget.resourceId!);
    } else {
      _notificationService.markAsRead();
    }
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required bool isMobile,
    required bool isTablet,
  }) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final hasNew = widget.resourceId != null 
            ? notificationService.hasNewForResource(widget.resourceId!)
            : notificationService.hasNewReservations;
            
        return Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: isMobile ? 4 : isTablet ? 6 : 8, vertical: 6),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                  onTap: onPressed,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    height: isMobile ? 32 : isTablet ? 36 : 40,
                    width: isMobile ? 32 : isTablet ? 36 : 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isMobile ? 16 : isTablet ? 18 : 20,
                    ),
                  ),
                ),
              ),
            ),
            if (hasNew)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    
    return Stack(
      children: [
        Scaffold(
          backgroundColor: ApprovalDesignSystem.backgroundColor,
          appBar: AppBar(
            title: Text(
              widget.resourceName != null 
                  ? 'Approvals - ${widget.resourceName}'
                  : 'Pending Approvals',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 18 : isTablet ? 20 : 22,
              ),
            ),
            backgroundColor: ApprovalDesignSystem.primaryMaroon,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: false,
            actions: [
              Consumer<ReservationApprovalService>(
                builder: (context, service, child) {
                  return _buildAppBarAction(
                    icon: Icons.refresh_rounded,
                    onPressed: _loadPendingReservations,
                    tooltip: 'Refresh',
                    isMobile: isMobile,
                    isTablet: isTablet,
                  );
                },
              ),
            ],
          ),
          body: Consumer<ReservationApprovalService>(
            builder: (context, service, child) {
              return _buildBody(service, isMobile);
            },
          ),
        ),
        // Notification popup for this screen too
        _buildNotificationPopup(),
      ],
    );
  }

  // Notification popup widget for approval screen
  Widget _buildNotificationPopup() {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        if (!notificationService.showPopup || 
            notificationService.currentPopupNotification == null) {
          return const SizedBox.shrink();
        }

        final notification = notificationService.currentPopupNotification!;
        final facilityName = notification['facility_name']?.toString() ?? 'Unknown Facility';
        final purpose = notification['purpose']?.toString() ?? 'No purpose provided';
        final requesterName = notification['requester_name']?.toString() ?? 'Unknown User';

        return Positioned(
          top: 16,
          right: 16,
          left: 16,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ApprovalDesignSystem.primaryMaroon.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: ApprovalDesignSystem.primaryMaroon,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'New Reservation Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ApprovalDesignSystem.primaryMaroon,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                        onPressed: () => notificationService.closePopup(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    facilityName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By: $requesterName',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    purpose.length > 100 
                        ? '${purpose.substring(0, 100)}...' 
                        : purpose,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => notificationService.closePopup(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Dismiss'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            notificationService.viewAllNotifications();
                            _loadPendingReservations(); // Refresh the current list
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ApprovalDesignSystem.primaryMaroon,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Refresh List'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(ReservationApprovalService service, bool isMobile) {
    if (service.isLoading && service.pendingReservations.isEmpty) {
      return const LoadingState();
    }

    if (service.errorMessage != null) {
      return ErrorState(
        errorMessage: service.errorMessage!,
        onRetry: _loadPendingReservations,
        isMobile: isMobile,
      );
    }

    if (service.pendingReservations.isEmpty) {
      return EmptyState(isMobile: isMobile);
    }

    return RefreshIndicator(
      onRefresh: _loadPendingReservations,
      color: ApprovalDesignSystem.primaryMaroon,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: ApprovalDesignSystem.getSectionPadding(isMobile),
          vertical: 16,
        ),
        itemCount: service.pendingReservations.length,
        itemBuilder: (context, index) {
          final reservation = service.pendingReservations[index];
          return ApprovalCard(
            reservation: reservation,
            isMobile: isMobile,
            onTap: () => _showApprovalDialog(reservation, isMobile),
          );
        },
      ),
    );
  }

  void _showApprovalDialog(ReservationApproval reservation, bool isMobile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return EnhancedApprovalDialog(
          reservation: reservation,
          isMobile: isMobile,
          onAction: (String action, String? comment) async {
            await _processApproval(reservation, action, comment);
          },
        );
      },
    );
  }

  Future<void> _processApproval(
    ReservationApproval reservation, 
    String action, 
    String? comment
  ) async {
    _showLoadingDialog();

    try {
      final success = await _approvalService.processApproval(
        reservation.approvalId,
        widget.approverId,
        action,
        widget.token,
        comment: comment,
      );

      if (mounted) Navigator.of(context).pop();

      if (success) {
        _showSuccessSnackBar(action, reservation.facilityName);
        await _loadPendingReservations();
      } else {
        _showErrorDialog(_approvalService.errorMessage ?? 'Unknown error occurred');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog('An unexpected error occurred: $e');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ApprovalDesignSystem.primaryMaroon),
                ),
                const SizedBox(height: 16),
                Text(
                  'Processing approval...',
                  style: TextStyle(
                    color: ApprovalDesignSystem.darkMaroon,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessSnackBar(String action, String? facilityName) {
    final message = action == 'approved' 
        ? 'Reservation for ${facilityName ?? 'facility'} approved successfully!'
        : 'Reservation for ${facilityName ?? 'facility'} rejected successfully!';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              action == 'approved' ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: action == 'approved' 
            ? ApprovalDesignSystem.successGreen 
            : ApprovalDesignSystem.errorRed,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: ApprovalDesignSystem.errorRed),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: TextStyle(color: ApprovalDesignSystem.errorRed),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: ApprovalDesignSystem.primaryMaroon),
              ),
            ),
          ],
        );
      },
    );
  }
}