import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/workflow_service.dart';
import '../../services/resource_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../utils/app_colors.dart';

class WorkflowManagementScreen extends StatefulWidget {
  @override
  _WorkflowManagementScreenState createState() => _WorkflowManagementScreenState();
}

class _WorkflowManagementScreenState extends State<WorkflowManagementScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedFacilityId;
  List<WorkflowStep> _workflowSteps = [];
  List<User> _availableUsers = [];
  late TabController _tabController;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() async {
    final resourceService = context.read<ResourceService>();
    final userService = context.read<UserService>();
    
    // Load facilities
    await resourceService.fetchResources(['Facility']);
    
    // Load users with admin/approver roles
    await userService.fetchUsers(status: 'active');
  }

  void _loadWorkflow() async {
    if (_selectedFacilityId == null) return;
    
    final workflowService = context.read<WorkflowService>();
    final success = await workflowService.fetchWorkflowByFacility(_selectedFacilityId!);
    
    if (success) {
      setState(() {
        _workflowSteps = List.from(workflowService.workflowSteps);
        _isEditing = false;
      });
    } else {
      setState(() {
        _workflowSteps = [];
        _isEditing = false;
      });
    }
  }

  void _addStep() {
    if (_availableUsers.isEmpty) return;
    
    setState(() {
      _workflowSteps.add(WorkflowStep(
        userId: _availableUsers.first.id,
        stepOrder: _workflowSteps.length + 1,
      ));
      _isEditing = true;
    });
  }

  void _removeStep(int index) {
    setState(() {
      _workflowSteps.removeAt(index);
      // Reorder steps
      for (int i = 0; i < _workflowSteps.length; i++) {
        _workflowSteps[i] = _workflowSteps[i].copyWith(stepOrder: i + 1);
      }
      _isEditing = true;
    });
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final step = _workflowSteps.removeAt(oldIndex);
      _workflowSteps.insert(newIndex, step);
      
      // Update step orders
      for (int i = 0; i < _workflowSteps.length; i++) {
        _workflowSteps[i] = _workflowSteps[i].copyWith(stepOrder: i + 1);
      }
      _isEditing = true;
    });
  }

  void _saveWorkflow() async {
    if (_selectedFacilityId == null || _workflowSteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a facility and add at least one step'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final workflowService = context.read<WorkflowService>();
    final success = await workflowService.createOrUpdateWorkflow(
      facilityId: _selectedFacilityId!,
      steps: _workflowSteps,
    );

    if (success) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workflow saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadWorkflow(); // Refresh to get updated data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(workflowService.errorMessage ?? 'Failed to save workflow'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteWorkflow() async {
    if (_selectedFacilityId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Workflow'),
        content: Text('Are you sure you want to delete this workflow? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final workflowService = context.read<WorkflowService>();
      final success = await workflowService.deleteWorkflow(_selectedFacilityId!);
      
      if (success) {
        setState(() {
          _workflowSteps = [];
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Workflow deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Workflow Management',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 16 : isTablet ? 18 : 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkMaroon,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(isMobile ? 40 : 48),
          child: Column(
            children: [
              Container(
                height: 1,
                color: AppColors.primary.withOpacity(0.2),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                labelStyle: TextStyle(fontSize: isMobile ? 12 : 14),
                tabs: [
                  Tab(text: 'Setup Workflow'),
                  Tab(text: 'View Workflows'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSetupTab(isMobile, isTablet),
          _buildViewTab(isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildSetupTab(bool isMobile, bool isTablet) {
  return Consumer3<ResourceService, UserService, WorkflowService>(
    builder: (context, resourceService, userService, workflowService, child) {
      final facilities = resourceService.resources.where((r) => r.category == 'Facility').toList();
      
      // FILTER for r02 and r03 only
      _availableUsers = userService.users.where((u) => 
        u.active && (u.roleId == 'R02' || u.roleId == 'R03')
      ).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Facility Selection
              _buildSectionHeader('Select Facility', isMobile),
              SizedBox(height: isMobile ? 8 : 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedFacilityId,
                  decoration: InputDecoration(
                    labelText: 'Choose Facility',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(isMobile ? 16 : 20),
                  ),
                  items: facilities.map((facility) {
                    return DropdownMenuItem(
                      value: facility.id,
                      child: Text(facility.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFacilityId = value;
                      _workflowSteps = [];
                      _isEditing = false;
                    });
                    if (value != null) {
                      _loadWorkflow();
                    }
                  },
                ),
              ),
              
              SizedBox(height: isMobile ? 24 : 32),
              
              // Workflow Steps
              if (_selectedFacilityId != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('Approval Steps', isMobile),
                    ElevatedButton.icon(
                      onPressed: _availableUsers.isNotEmpty ? _addStep : null,
                      icon: Icon(Icons.add, size: isMobile ? 18 : 20),
                      label: Text('Add Step'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                
                if (_workflowSteps.isEmpty)
                  _buildEmptyWorkflow(isMobile)
                else
                  _buildWorkflowSteps(isMobile),
                
                SizedBox(height: isMobile ? 24 : 32),
                
                // Action Buttons
                if (_workflowSteps.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: workflowService.isLoading ? null : _saveWorkflow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                          ),
                          child: workflowService.isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text('Save Workflow'),
                        ),
                      ),
                      if (_workflowSteps.any((step) => step.id != null)) ...[
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: workflowService.isLoading ? null : _deleteWorkflow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                          ),
                          child: Text('Delete Workflow'),
                        ),
                      ],
                    ],
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildViewTab(bool isMobile, bool isTablet) {
    return Consumer<ResourceService>(
      builder: (context, resourceService, child) {
        final facilities = resourceService.resources.where((r) => r.category == 'Facility').toList();
        
        return ListView.builder(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          itemCount: facilities.length,
          itemBuilder: (context, index) {
            final facility = facilities[index];
            return _buildFacilityCard(facility, isMobile);
          },
        );
      },
    );
  }

  Widget _buildFacilityCard(Resource facility, bool isMobile) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(Icons.business, color: AppColors.primary),
        ),
        title: Text(
          facility.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        subtitle: Text('ID: ${facility.id}'),
        children: [
          FutureBuilder<bool>(
            future: context.read<WorkflowService>().fetchWorkflowByFacility(facility.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final workflowService = context.watch<WorkflowService>();
              if (workflowService.workflowSteps.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No workflow defined for this facility',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }
              
              return Column(
                children: workflowService.workflowSteps.map((step) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        step.stepOrder.toString(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(step.name ?? 'Unknown User'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Department: ${step.department ?? 'N/A'}'),
                        Text('Role: ${step.roleType ?? 'N/A'}'),
                      ],
                    ),
                    isThreeLine: true,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isMobile) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isMobile ? 18 : 20,
        fontWeight: FontWeight.bold,
        color: AppColors.darkMaroon,
      ),
    );
  }

  Widget _buildEmptyWorkflow(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.work,
            size: isMobile ? 48 : 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'No workflow steps defined',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'Add approval steps to create a workflow for this facility',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowSteps(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _workflowSteps.length,
        onReorder: _reorderSteps,
        itemBuilder: (context, index) {
          final step = _workflowSteps[index];
          return _buildStepCard(step, index, isMobile);
        },
      ),
    );
  }

  Widget _buildStepCard(WorkflowStep step, int index, bool isMobile) {
    final user = _availableUsers.firstWhere(
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

    return Card(
      key: ValueKey(step.stepOrder),
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                step.stepOrder.toString(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: step.userId,
                    decoration: InputDecoration(
                      labelText: 'Approver',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                    items: _availableUsers.map((user) {
                      return DropdownMenuItem(
                        value: user.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name),
                            Text(
                              '${user.department} - ${user.roleType}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _workflowSteps[index] = step.copyWith(userId: value);
                          _isEditing = true;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Column(
              children: [
                IconButton(
                  onPressed: () => _removeStep(index),
                  icon: Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Remove Step',
                ),
                Icon(
                  Icons.drag_handle,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}