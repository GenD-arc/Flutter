// widgets/workflow_step_card.dart
import 'package:flutter/material.dart';
import '../../theme/workflow_theme.dart';
import '../../models/user_model.dart';
import '../../services/workflow_service.dart';

class WorkflowStepCard extends StatelessWidget {
  final WorkflowStep step;
  final int index;
  final List<User> availableUsers;
  final ValueChanged<WorkflowStep> onUserChanged;
  final VoidCallback onRemove;
  final bool isTablet;

  const WorkflowStepCard({
    Key? key,
    required this.step,
    required this.index,
    required this.availableUsers,
    required this.onUserChanged,
    required this.onRemove,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    final user = availableUsers.firstWhere(
      (u) => u.id == step.userId,
      orElse: () => User(
        id: step.userId,
        name: step.name ?? 'Unknown User',
        email: '',
        department: step.department ?? 'N/A',
        username: '',
        roleId: '',
        roleType: step.roleType ?? 'N/A',
        active: true,
      ),
    );

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: WorkflowTheme.cardGradient,
        borderRadius: WorkflowTheme.borderRadiusMedium,
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: WorkflowTheme.elevatedShadow,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: isMobile ? _buildMobileLayout() : _buildTabletLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with step number and remove button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildStepNumber(size: 32, fontSize: 14),
                SizedBox(width: 8),
                Text(
                  'Step ${step.stepOrder}',
                  style: WorkflowTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            _buildRemoveButton(compact: true),
          ],
        ),
        SizedBox(height: 12),
        // User dropdown (full width)
        _buildUserDropdown(isMobile: true),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        _buildStepNumber(),
        SizedBox(width: 16),
        Expanded(child: _buildUserDropdown()),
        SizedBox(width: 12),
        _buildRemoveButton(),
      ],
    );
  }

  Widget _buildStepNumber({double? size, double? fontSize}) {
    final stepSize = size ?? 48;
    final textSize = fontSize ?? 18;
    
    return Container(
      width: stepSize,
      height: stepSize,
      decoration: BoxDecoration(
        gradient: WorkflowTheme.primaryGradient,
        borderRadius: WorkflowTheme.borderRadiusMedium,
        boxShadow: WorkflowTheme.elevatedShadow,
      ),
      child: Center(
        child: Text(
          step.stepOrder.toString(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: textSize,
          ),
        ),
      ),
    );
  }

  Widget _buildUserDropdown({bool isMobile = false}) {
    return Container(
      decoration: BoxDecoration(
        color: WorkflowTheme.warmGray,
        borderRadius: WorkflowTheme.borderRadiusMedium,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: step.userId,
        isExpanded: true, // This helps prevent overflow
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16, 
            vertical: isMobile ? 8 : 12,
          ),
        ),
        style: WorkflowTheme.bodyLarge.copyWith(
          color: WorkflowTheme.darkMaroon,
          fontSize: isMobile ? 14 : null,
        ),
        menuMaxHeight: 300, // Limit dropdown height
        items: availableUsers.map((user) {
          return DropdownMenuItem(
            value: user.id,
            child: _buildDropdownItem(user, isMobile),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onUserChanged(step.copyWith(userId: value));
          }
        },
      ),
    );
  }

  Widget _buildDropdownItem(User user, bool isMobile) {
    if (isMobile) {
      // Simplified mobile layout - single line with ellipsis
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              user.name,
              style: WorkflowTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Text(
              '${user.department}',
              style: WorkflowTheme.bodyMedium.copyWith(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
    } else {
      // Desktop/tablet layout - single line to prevent overflow
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              user.name,
              style: WorkflowTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Text(
              '${user.department}',
              style: WorkflowTheme.bodyMedium.copyWith(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildRemoveButton({bool compact = false}) {
    final size = compact ? 32.0 : 40.0;
    final iconSize = compact ? 18.0 : 24.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: WorkflowTheme.borderRadiusSmall,
        border: Border.all(color: Colors.red.shade200),
      ),
      child: IconButton(
        onPressed: onRemove,
        icon: Icon(
          Icons.delete_outline_rounded, 
          color: Colors.red.shade600,
          size: iconSize,
        ),
        tooltip: 'Remove Step',
        padding: EdgeInsets.zero,
      ),
    );
  }
}