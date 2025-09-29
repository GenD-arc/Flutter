import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/workflow_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../theme/workflow_theme.dart';
import '../dialog/custom_dialog.dart';
import '../widgets/workflow_step_card.dart';

class QuickWorkflowDialog extends StatefulWidget {
  final String facilityId;
  final String facilityName;

  const QuickWorkflowDialog({
    Key? key,
    required this.facilityId,
    required this.facilityName,
  }) : super(key: key);

  @override
  _QuickWorkflowDialogState createState() => _QuickWorkflowDialogState();
}

class _QuickWorkflowDialogState extends State<QuickWorkflowDialog> {
  List<WorkflowStep> _workflowSteps = [];
  List<User> _availableUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final userService = context.read<UserService>();
      final workflowService = context.read<WorkflowService>();
      
      await userService.fetchUsers(status: 'active');
      if (!mounted) return;

      final availableUsers = userService.users.where((u) => 
        u.active && (u.roleId == 'R02' || u.roleId == 'R03')
      ).toList();
      
      await workflowService.fetchWorkflowByFacility(widget.facilityId);
      if (!mounted) return;
      
      setState(() {
        _availableUsers = availableUsers;
        _workflowSteps = List<WorkflowStep>.from(workflowService.workflowSteps);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog('Error loading workflow data: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => _buildAlertDialog(
        title: 'Error',
        message: message,
        icon: Icons.error_outline_rounded,
        iconColor: WorkflowTheme.errorRed,
        buttonColor: WorkflowTheme.errorRed,
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => _buildAlertDialog(
        title: 'Success',
        message: message,
        icon: Icons.check_circle_outline_rounded,
        iconColor: WorkflowTheme.successGreen,
        buttonColor: WorkflowTheme.successGreen,
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
  }

  Widget _buildAlertDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color buttonColor,
    VoidCallback? onPressed,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: WorkflowTheme.borderRadiusLarge),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: WorkflowTheme.cardGradient,
          borderRadius: WorkflowTheme.borderRadiusLarge,
          boxShadow: WorkflowTheme.intenseShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: WorkflowTheme.borderRadiusMedium,
              ),
              child: Icon(icon, color: iconColor, size: 40),
            ),
            SizedBox(height: 16),
            Text(title, style: WorkflowTheme.headlineLarge),
            SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: WorkflowTheme.bodyLarge),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed ?? () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: WorkflowTheme.borderRadiusMedium),
                ),
                child: Text('OK', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addStep() {
    if (_availableUsers.isEmpty) return;
    
    setState(() {
      _workflowSteps.add(WorkflowStep(
        userId: _availableUsers.first.id,
        stepOrder: _workflowSteps.length + 1,
      ));
    });
  }

  void _removeStep(int index) {
    setState(() {
      _workflowSteps.removeAt(index);
      for (int i = 0; i < _workflowSteps.length; i++) {
        _workflowSteps[i] = _workflowSteps[i].copyWith(stepOrder: i + 1);
      }
    });
  }

  void _updateStep(int index, WorkflowStep updatedStep) {
    setState(() {
      _workflowSteps[index] = updatedStep;
    });
  }

  Future<void> _saveWorkflow() async {
    if (_workflowSteps.isEmpty) {
      _showErrorDialog('Please add at least one approval step');
      return;
    }

    final workflowService = context.read<WorkflowService>();
    final success = await workflowService.createOrUpdateWorkflow(
      facilityId: widget.facilityId,
      steps: _workflowSteps,
    );

    if (success) {
      _showSuccessDialog('Workflow saved successfully');
    } else {
      _showErrorDialog(workflowService.errorMessage ?? 'Failed to save workflow');
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: WorkflowTheme.warmGray,
        borderRadius: WorkflowTheme.borderRadiusMedium,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.work_outline_rounded, size: 48, color: Colors.grey.shade500),
          SizedBox(height: 16),
          Text('No approval steps defined', style: WorkflowTheme.headlineMedium),
          SizedBox(height: 8),
          Text('Add users to create an approval workflow', 
            style: WorkflowTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Approval Steps', style: WorkflowTheme.headlineLarge),
              SizedBox(height: 4),
              Text('Define the workflow approval process', 
                style: WorkflowTheme.bodyMedium),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _availableUsers.isNotEmpty ? _addStep : null,
            icon: Icon(Icons.add_rounded),
            label: Text('Add Step'),
            style: ElevatedButton.styleFrom(
              backgroundColor: WorkflowTheme.primaryMaroon,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Flexible(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5, // Limit height to 50% of screen
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_workflowSteps.isEmpty)
                _buildEmptyState()
              else
                ..._workflowSteps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: WorkflowStepCard(
                      step: step,
                      index: index,
                      availableUsers: _availableUsers,
                      onUserChanged: (updatedStep) => _updateStep(index, updatedStep),
                      onRemove: () => _removeStep(index),
                      isTablet: isTablet,
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        _buildScrollableContent(),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Consumer<WorkflowService>(
      builder: (context, workflowService, child) {
        return ElevatedButton.icon(
          onPressed: workflowService.isLoading ? null : _saveWorkflow,
          icon: workflowService.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Icon(Icons.save_rounded),
          label: Text(workflowService.isLoading ? 'Saving...' : 'Save Workflow'),
          style: ElevatedButton.styleFrom(
            backgroundColor: WorkflowTheme.primaryMaroon,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildDeleteButton() {
    return OutlinedButton.icon(
      onPressed: _workflowSteps.any((step) => step.id != null) ? _deleteWorkflow : null,
      icon: Icon(Icons.delete_outline_rounded),
      label: Text('Delete Workflow'),
      style: OutlinedButton.styleFrom(
        foregroundColor: WorkflowTheme.errorRed,
        side: BorderSide(color: WorkflowTheme.errorRed),
      ),
    );
  }

  Future<void> _deleteWorkflow() async {
    final workflowService = context.read<WorkflowService>();
    final success = await workflowService.deleteWorkflow(widget.facilityId);

    if (success) {
      setState(() {
        _workflowSteps = [];
      });
      _showSuccessDialog('Workflow deleted successfully');
    } else {
      _showErrorDialog(workflowService.errorMessage ?? 'Failed to delete workflow');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: 'Workflow Setup',
      subtitle: widget.facilityName,
      content: _buildContent(),
      actions: [
        if (_workflowSteps.any((step) => step.id != null)) _buildDeleteButton(),
        _buildSaveButton(),
      ],
      isLoading: _isLoading,
      onClose: () => Navigator.of(context).pop(),
    );
  }
}