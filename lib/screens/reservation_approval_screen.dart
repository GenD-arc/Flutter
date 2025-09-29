import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/screens/dialog/enhanced_approval_dialog.dart';
import 'package:testing/screens/widgets/approval_components.dart';
import 'package:testing/screens/widgets/approval_state_widgets.dart';
import '../../models/reservation_approval_model.dart';
import '../../services/reservation_approval_service.dart';
import '../../utils/approval_design_system.dart';

class ReservationApprovalScreen extends StatefulWidget {
  final String approverId;
  final String token;

  const ReservationApprovalScreen({
    super.key,
    required this.approverId,
    required this.token,
  });

  @override
  State<ReservationApprovalScreen> createState() => _ReservationApprovalScreenState();
}

class _ReservationApprovalScreenState extends State<ReservationApprovalScreen> {
  late final ReservationApprovalService _approvalService;
  
  @override
  void initState() {
    super.initState();
    _approvalService = context.read<ReservationApprovalService>();
    _loadPendingReservations();
  }

  Future<void> _loadPendingReservations() async {
    await _approvalService.fetchPendingReservations(widget.approverId, widget.token);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    
    return Scaffold(
      backgroundColor: ApprovalDesignSystem.backgroundColor,
      body: Consumer<ReservationApprovalService>(
        builder: (context, service, child) {
          return Column(
            children: [
              ApprovalHeader(
                isMobile: isMobile,
                isLoading: service.isLoading,
                onRefresh: _loadPendingReservations,
              ),
              Expanded(
                child: _buildBody(service, isMobile),
              ),
            ],
          );
        },
      ),
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
    // Show loading indicator
    _showLoadingDialog();

    try {
      final success = await _approvalService.processApproval(
        reservation.approvalId,
        widget.approverId,
        action,
        widget.token,
        comment: comment,
      );

      // Hide loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Show success message
        _showSuccessSnackBar(action, reservation.facilityName);
        
        // Refresh the list
        await _loadPendingReservations();
      } else {
        // Show error message
        _showErrorDialog(_approvalService.errorMessage ?? 'Unknown error occurred');
      }
    } catch (e) {
      // Hide loading dialog
      Navigator.of(context).pop();
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
            padding: EdgeInsets.all(24),
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
                SizedBox(height: 16),
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
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: action == 'approved' 
            ? ApprovalDesignSystem.successGreen 
            : ApprovalDesignSystem.errorRed,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
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
              SizedBox(width: 8),
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