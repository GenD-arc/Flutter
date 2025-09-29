import 'package:flutter/material.dart';
import '../../utils/approval_design_system.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});
  
  @override
  Widget build(BuildContext context) {
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
            'Loading pending reservations...',
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
}

class ErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final bool isMobile;

  const ErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
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
              onPressed: onRetry,
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
}

class EmptyState extends StatelessWidget {
  final bool isMobile;

  const EmptyState({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ApprovalDesignSystem.getSectionPadding(isMobile)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: ApprovalDesignSystem.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: ApprovalDesignSystem.successGreen, width: 1.5),
              ),
              child: Icon(
                Icons.check_circle_rounded,
                color: ApprovalDesignSystem.successGreen,
                size: 48,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No Pending Approvals',
              style: ApprovalDesignSystem.titleLarge(isMobile).copyWith(
                color: ApprovalDesignSystem.darkMaroon,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'All reservation requests have been processed.\nYou\'re all caught up!',
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
}