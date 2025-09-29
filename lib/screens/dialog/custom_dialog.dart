// widgets/custom_dialog.dart
import 'package:flutter/material.dart';
import '../../theme/workflow_theme.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final List<Widget> actions;
  final bool isLoading;
  final VoidCallback? onClose;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.actions,
    this.isLoading = false,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: WorkflowTheme.borderRadiusLarge),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isTablet ? 600 : MediaQuery.of(context).size.width * 0.95,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          gradient: WorkflowTheme.cardGradient,
          borderRadius: WorkflowTheme.borderRadiusLarge,
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
          boxShadow: WorkflowTheme.intenseShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(isTablet),
            if (isLoading) _buildLoadingState() else content,
            if (!isLoading) _buildActions(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: WorkflowTheme.primaryGradient,
        borderRadius: BorderRadius.vertical(top: WorkflowTheme.borderRadiusLarge.topLeft),
        boxShadow: WorkflowTheme.elevatedShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: WorkflowTheme.borderRadiusMedium,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Icon(Icons.work_rounded, color: Colors.white, size: isTablet ? 28 : 24),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WorkflowTheme.headlineLarge.copyWith(color: Colors.white)),
                SizedBox(height: 4),
                Text(subtitle, 
                  style: WorkflowTheme.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onClose != null) IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: WorkflowTheme.borderRadiusMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(WorkflowTheme.primaryMaroon),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text('Loading...', style: WorkflowTheme.headlineMedium),
          SizedBox(height: 8),
          Text('Please wait while we fetch the information', 
            style: WorkflowTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActions(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: WorkflowTheme.warmGray,
        borderRadius: BorderRadius.vertical(bottom: WorkflowTheme.borderRadiusLarge.bottomLeft),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: actions.length == 1 
            ? [Expanded(child: actions.first)]
            : actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: index > 0 ? 12 : 0),
                    child: action,
                  ),
                );
              }).toList(),
      ),
    );
  }
}