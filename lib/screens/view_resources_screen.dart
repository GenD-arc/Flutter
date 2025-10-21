import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testing/screens/superadmin/add_resource_screen.dart';
import 'package:testing/screens/superadmin/edit_resource_screen.dart';
import 'package:testing/screens/widgets/resource_list_widget.dart';
import 'package:testing/screens/superadmin/workflow_setup_dialog.dart';
import '../services/resource_service.dart';
import '../utils/app_colors.dart';

class ResourceUtils {
  static String getResourceInitials(String name) {
    if (name.isEmpty) return 'R';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + (parts.length > 1 ? parts[1][0] : '')).toUpperCase();
  }
}

class ViewResourcesScreen extends StatefulWidget {

  const ViewResourcesScreen({super.key,});

  @override
  State<ViewResourcesScreen> createState() => _ViewResourcesScreenState();
}

class _ViewResourcesScreenState extends State<ViewResourcesScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _selectedCategories = {'Facility', 'Room', 'Vehicle'};
  String _searchQuery = '';
  late TabController _tabController;
  final Set<String> _selectedResourceIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadResources());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadResources() {
    context.read<ResourceService>().fetchResources(_selectedCategories.toList());
  }

  Widget _buildSmartResourceTabs(bool isMobile, bool isTablet) {
  // Tab configurations with icons and colors
  final List<Map<String, dynamic>> tabConfigs = [
    {
      'title': 'All',
      'category': 'all',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF5D4037),
    },
    {
      'title': 'Facilities',
      'category': 'Facility',
      'icon': Icons.business_outlined,
      'color': Color(0xFF1565C0),
    },
    {
      'title': 'Rooms',
      'category': 'Room',
      'icon': Icons.meeting_room_outlined,
      'color': Color(0xFF00695C),
    },
    {
      'title': 'Vehicles',
      'category': 'Vehicle',
      'icon': Icons.directions_car_outlined,
      'color': Color(0xFFD84315),
    },
  ];

  return Consumer<ResourceService>(
    builder: (context, resourceService, child) {
      final allResources = _getFilteredResources(resourceService.resources);
      
      // Calculate counts for each category
      int getCount(String category) {
        if (category == 'all') return allResources.length;
        return allResources.where((r) => r.category == category).length;
      }

      return AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  tabConfigs.length,
                  (index) {
                    final config = tabConfigs[index];
                    final isSelected = _tabController.index == index;
                    final tabColor = config['color'] as Color;
                    final icon = config['icon'] as IconData;
                    final title = config['title'] as String;
                    final category = config['category'] as String;
                    final count = getCount(category);

                    return Padding(
                      padding: EdgeInsets.only(right: isMobile ? 6 : 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _tabController.animateTo(index),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 12 : isTablet ? 14 : 16,
                              vertical: isMobile ? 8 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? tabColor.withOpacity(0.12) 
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected 
                                    ? tabColor.withOpacity(0.4) 
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon
                                Icon(
                                  icon,
                                  size: isMobile ? 16 : 18,
                                  color: isSelected ? tabColor : Colors.grey[600],
                                ),
                                SizedBox(width: isMobile ? 6 : 8),
                                
                                // Title
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : isTablet ? 14 : 15,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isSelected ? tabColor : Colors.grey[700],
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                
                                // Count Badge
                                SizedBox(width: isMobile ? 6 : 8),
                                Container(
                                  constraints: BoxConstraints(minWidth: isMobile ? 24 : 28),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 6 : 8,
                                    vertical: isMobile ? 2 : 3,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [AppColors.primary, AppColors.lightMaroon],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: isSelected ? null : tabColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected 
                                          ? AppColors.primary.withOpacity(0.3)
                                          : tabColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '$count',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : tabColor,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
  List<Resource> _getFilteredResources(List<Resource> resources) {
    if (_searchQuery.isEmpty) return resources;

    final query = _searchQuery.toLowerCase();
    return resources.where((resource) {
      return resource.name.toLowerCase().contains(query) ||
          resource.id.toLowerCase().contains(query) ||
          resource.description.toLowerCase().contains(query) ||
          resource.category.toLowerCase().contains(query);
    }).toList();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedResourceIds.clear();
      }
    });
  }

  void _toggleResourceSelection(String resourceId) {
    setState(() {
      if (_selectedResourceIds.contains(resourceId)) {
        _selectedResourceIds.remove(resourceId);
      } else {
        _selectedResourceIds.add(resourceId);
      }
      if (_selectedResourceIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAllResources(List<Resource> resources) {
    setState(() {
      _selectedResourceIds.addAll(resources.map((r) => r.id));
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedResourceIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _editResource(Resource resource) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditResourceScreen(resource: resource),
      ),
    );

    if (result == true) {
      _loadResources();
    }
  }

  Future<void> _deleteResource(Resource resource) async {
    final confirmed = await _showDeleteConfirmationDialog(
      title: 'Delete Resource',
      message: 'Are you sure you want to delete "${resource.name}"? This action cannot be undone.',
    );

    if (confirmed == true) {
      final resourceService = Provider.of<ResourceService>(context, listen: false);
      final success = await resourceService.deleteResource(resource.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resource deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resourceService.errorMessage ?? 'Failed to delete resource'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteSelectedResources() async {
    if (_selectedResourceIds.isEmpty) return;

    final confirmed = await _showDeleteConfirmationDialog(
      title: 'Delete Resources',
      message: 'Are you sure you want to delete ${_selectedResourceIds.length} selected resource(s)? This action cannot be undone.',
    );

    if (confirmed == true) {
      final resourceService = Provider.of<ResourceService>(context, listen: false);
      final success = await resourceService.deleteMultipleResources(_selectedResourceIds.toList());

      if (success) {
        setState(() {
          _selectedResourceIds.clear();
          _isSelectionMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resources deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resourceService.errorMessage ?? 'Failed to delete resources'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog({
    required String title,
    required String message,
  }) async {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkMaroon,
            fontSize: isMobile ? 16 : 18,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResourceOptionsPopup(Resource resource) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final isMobile = MediaQuery.of(context).size.width < 768;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Backdrop blur effect
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            // Main popup card
            Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                margin: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 40,
                  vertical: isMobile ? 40 : 60,
                ),
                constraints: BoxConstraints(
                  maxWidth: isMobile ? double.infinity : 400,
                  maxHeight: size.height * 0.8,
                ),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
                  elevation: 24,
                  shadowColor: Colors.black.withOpacity(0.2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildResourceHeader(resource, isMobile),
                        Flexible(
                          child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                            child: _buildOptionsSection(resource, isMobile),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResourceHeader(Resource resource, bool isMobile) {
    // Use same category colors as ResourceListWidget
    const Map<String, List<Color>> _categoryColors = {
      'Facility': [Color(0xFF8B0000), Color(0xFF4A1E1E)], // Maroon
      'Room': [Color(0xFF00897B), Color(0xFF004D40)], // Teal
      'Vehicle': [Color(0xFFFFA000), Color(0xFFC67100)], // Amber
      'Other': [Color(0xFFF57C00), Color(0xFFBF360C)], // Orange
    };

    final colors = _categoryColors[resource.category] ?? _categoryColors['Other']!;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Resource Avatar
          Container(
            width: isMobile ? 60 : 70,
            height: isMobile ? 60 : 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 15 : 18),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                ResourceUtils.getResourceInitials(resource.name),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 16 : 20),
          // Resource Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'ID: ${resource.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  resource.category,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 13 : 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(Resource resource, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        children: [
          // Quick Actions Row
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _editResource(resource);
                  },
                  isMobile: isMobile,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.info_outline_rounded,
                  label: 'Details',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _showResourceDetails(resource);
                  },
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _buildActionTile(
    icon: Icons.work,
    title: 'Setup Workflow',
    subtitle: 'Configure approval steps',
    color: Colors.blue,
    onTap: () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => QuickWorkflowDialog(
          facilityId: resource.id,
          facilityName: resource.name,
        ),
      );
    },
    isMobile: isMobile,
  ),
          SizedBox(height: isMobile ? 12 : 16),
          // Delete Action
          _buildActionTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Resource',
            subtitle: 'Permanently remove resource',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _deleteResource(resource);
            },
            isMobile: isMobile,
            isDanger: true,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          // Close Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                ),
                backgroundColor: Colors.grey[100],
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 16 : 20,
          horizontal: isMobile ? 12 : 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              ),
              child: Icon(
                icon,
                color: color,
                size: isMobile ? 20 : 24,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 20,
          vertical: isMobile ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: isDanger ? Colors.red.withOpacity(0.02) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          border: isDanger
              ? Border.all(color: Colors.red.withOpacity(0.1), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              ),
              child: Icon(
                icon,
                color: color,
                size: isMobile ? 18 : 20,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDanger ? Colors.red[700] : Colors.grey[800],
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: isMobile ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showResourceDetails(Resource resource) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;

    // Category colors matching ResourceListWidget
    const Map<String, List<Color>> _categoryColors = {
      'Facility': [Color(0xFF8B0000), Color(0xFF4A1E1E)], // Maroon
      'Room': [Color(0xFF00897B), Color(0xFF004D40)], // Teal
      'Vehicle': [Color(0xFFFFA000), Color(0xFFC67100)], // Amber
      'Other': [Color(0xFFF57C00), Color(0xFFBF360C)], // Orange
    };

    final colors = _categoryColors[resource.category] ?? _categoryColors['Other']!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow dynamic height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(isMobile ? 16 : 20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header with gradient and avatar
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(isMobile ? 16 : 20)),
              ),
              child: Row(
                children: [
                  // Resource Avatar
                  Container(
                    width: isMobile ? 50 : 60,
                    height: isMobile ? 50 : 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(isMobile ? 12 : 15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        ResourceUtils.getResourceInitials(resource.name),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  // Resource Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          resource.category,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isMobile ? 14 : 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        ],
                    ),
                  ),
                ],
              ),
            ),
            // Content section
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                physics: ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID with Copy button
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'ID: ${resource.id}',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: Colors.grey[800],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              size: isMobile ? 20 : 24,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: resource.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Resource ID copied to clipboard'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            tooltip: 'Copy ID',
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      // Category
                      Text(
                        'Category: ${resource.category}',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      // Description
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkMaroon,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        resource.description.isEmpty ? 'No description available' : resource.description,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      // Image
                      if (resource.imageUrl != null) ...[
                        Container(
                          height: isMobile ? 150 : isTablet ? 200 : 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                            child: Image.network(
                              resource.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image,
                                        color: Colors.grey[600],
                                        size: isMobile ? 40 : 50,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: isMobile ? 12 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: isMobile ? 12 : 16),
                      ],
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16,
                                vertical: isMobile ? 8 : 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: AppColors.darkMaroon,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _editResource(resource);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 16,
                                vertical: isMobile ? 8 : 10,
                              ),
                            ),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
@override
Widget build(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final isMobile = screenSize.width < 768;
  final isTablet = screenSize.width >= 768 && screenSize.width < 1024;
  const Color primaryMaroon = Color(0xFF8B0000);
  const Color lightMaroon = Color(0xFFB71C1C);

  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      title: Text(
        'Resource Management',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: isMobile ? 18 : isTablet ? 20 : 22,
        ),
      ),
      backgroundColor: primaryMaroon,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: false,
      actions: [
        _buildAppBarAction(
          icon: Icons.refresh,
          onPressed: _loadResources,
          tooltip: 'Refresh',
          isMobile: isMobile,
        ),
        _buildAppBarAction(
          icon: _isSelectionMode ? Icons.cancel : Icons.select_all,
          onPressed: _toggleSelectionMode,
          tooltip: _isSelectionMode ? 'Cancel Selection' : 'Select Resources',
          isMobile: isMobile,
        ),
        if (_isSelectionMode && _selectedResourceIds.isNotEmpty)
          _buildAppBarAction(
            icon: Icons.delete,
            onPressed: _deleteSelectedResources,
            tooltip: 'Delete Selected',
            isMobile: isMobile,
          ),
      ],
    ),
    body: Consumer<ResourceService>(
      builder: (context, resourceService, child) {
        if (resourceService.isLoading) {
          return _buildLoadingState(isMobile);
        }

        if (resourceService.errorMessage != null) {
          return _buildErrorState(resourceService.errorMessage!, isMobile);
        }

        // Always show the tab structure, even if there are no resources
        return Column(
          children: [
            // Tab Bar - Always Visible
            _buildSmartResourceTabs(isMobile, isTablet),
            // Main Content Area
            Expanded(
              child: _buildMainContent(resourceService, isMobile, isTablet),
            ),
          ],
        );
      },
    ),
    floatingActionButton: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryMaroon, lightMaroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 28 : 32),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddResourceScreen()),
        ).then((result) {
          if (result == true) _loadResources();
        }),
        backgroundColor: Colors.transparent,
        elevation: 0,
        mini: isMobile,
        tooltip: 'Add Resource',
        child: Icon(
          Icons.inventory_2_rounded,
          size: isMobile ? 24 : 28,
          color: Colors.white,
        ),
      ),
    ),
  );
}

Widget _buildMainContent(ResourceService resourceService, bool isMobile, bool isTablet) {
  final filteredResources = _getFilteredResources(resourceService.resources);
  
  // Check if current tab has any resources (ignoring search)
  final currentTabHasResources = _getCurrentTabHasResources(resourceService.resources);

  return Column(
    children: [
      // Search Field
      Padding(
        padding: EdgeInsets.all(isMobile ? 6 : isTablet ? 8 : 12),
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Search Resources',
            labelStyle: TextStyle(fontSize: isMobile ? 14 : 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.search, color: AppColors.primary, size: isMobile ? 20 : 24),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
            ),
          ),
          style: TextStyle(fontSize: isMobile ? 14 : 16),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
      // Content Area - Shows either resource list or empty state
      Expanded(
        child: _buildContentArea(resourceService, filteredResources, currentTabHasResources, isMobile, isTablet),
      ),
    ],
  );
}

Widget _buildContentArea(ResourceService resourceService, List<Resource> filteredResources, bool currentTabHasResources, bool isMobile, bool isTablet) {
  // Show no search results if searching and no matches
  if (_searchQuery.isNotEmpty && filteredResources.isEmpty) {
    return _buildNoSearchResultsState(isMobile);
  }
  
  // Show empty state if tab is genuinely empty (no search active)
  if (filteredResources.isEmpty && _searchQuery.isEmpty && !currentTabHasResources) {
    return _buildEmptyState(isMobile);
  }

  // Otherwise show the tab content
  return TabBarView(
    controller: _tabController,
    children: [
      ResourceListWidget(
        resources: _getFilteredResources(resourceService.resources),
        selectedResourceIds: _selectedResourceIds,
        isSelectionMode: _isSelectionMode,
        onResourceTap: (resource) => _isSelectionMode
            ? _toggleResourceSelection(resource.id)
            : _showResourceOptionsPopup(resource),
        onResourceLongPress: _toggleResourceSelection,
        onSelectAll: () => _selectAllResources(_getFilteredResources(resourceService.resources)),
        onClearSelection: _clearSelection,
        isMobile: isMobile,
        isTablet: isTablet,
      ),
      ResourceListWidget(
        resources: _getFilteredResources(
          resourceService.resources.where((r) => r.category == 'Facility').toList(),
        ),
        selectedResourceIds: _selectedResourceIds,
        isSelectionMode: _isSelectionMode,
        onResourceTap: (resource) => _isSelectionMode
            ? _toggleResourceSelection(resource.id)
            : _showResourceOptionsPopup(resource),
        onResourceLongPress: _toggleResourceSelection,
        onSelectAll: () => _selectAllResources(
          resourceService.resources.where((r) => r.category == 'Facility').toList(),
        ),
        onClearSelection: _clearSelection,
        isMobile: isMobile,
        isTablet: isTablet,
      ),
      ResourceListWidget(
        resources: _getFilteredResources(
          resourceService.resources.where((r) => r.category == 'Room').toList(),
        ),
        selectedResourceIds: _selectedResourceIds,
        isSelectionMode: _isSelectionMode,
        onResourceTap: (resource) => _isSelectionMode
            ? _toggleResourceSelection(resource.id)
            : _showResourceOptionsPopup(resource),
        onResourceLongPress: _toggleResourceSelection,
        onSelectAll: () => _selectAllResources(
          resourceService.resources.where((r) => r.category == 'Room').toList(),
        ),
        onClearSelection: _clearSelection,
        isMobile: isMobile,
        isTablet: isTablet,
      ),
      ResourceListWidget(
        resources: _getFilteredResources(
          resourceService.resources.where((r) => r.category == 'Vehicle').toList(),
        ),
        selectedResourceIds: _selectedResourceIds,
        isSelectionMode: _isSelectionMode,
        onResourceTap: (resource) => _isSelectionMode
            ? _toggleResourceSelection(resource.id)
            : _showResourceOptionsPopup(resource),
        onResourceLongPress: _toggleResourceSelection,
        onSelectAll: () => _selectAllResources(
          resourceService.resources.where((r) => r.category == 'Vehicle').toList(),
        ),
        onClearSelection: _clearSelection,
        isMobile: isMobile,
        isTablet: isTablet,
      ),
    ],
  );
}

// Add this helper method to check if current tab has resources
bool _getCurrentTabHasResources(List<Resource> allResources) {
  switch (_tabController.index) {
    case 0: // All
      return allResources.isNotEmpty;
    case 1: // Facilities
      return allResources.any((r) => r.category == 'Facility');
    case 2: // Rooms
      return allResources.any((r) => r.category == 'Room');
    case 3: // Vehicles
      return allResources.any((r) => r.category == 'Vehicle');
    default:
      return false;
  }
}

// Add this method for no search results state
Widget _buildNoSearchResultsState(bool isMobile) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_rounded,
          size: isMobile ? 48 : 64,
          color: Colors.grey[400],
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Text(
          'No matching resources found',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: AppColors.darkMaroon,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Text(
          'Try adjusting your search terms',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[500],
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _searchQuery = '';
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 10 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Clear Search',
            style: TextStyle(fontSize: isMobile ? 14 : 16),
          ),
        ),
      ],
    ),
  );
}

// Update the empty state to be more contextual
Widget _buildEmptyState(bool isMobile) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: isMobile ? 48 : 64,
          color: Colors.grey[400],
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Text(
          'No resources in this category',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: AppColors.darkMaroon,
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Text(
          'Try switching to another tab or add a new resource',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isMobile ? 16 : 24),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddResourceScreen()),
          ).then((result) {
            if (result == true) _loadResources();
          }),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 10 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Add Resource',
            style: TextStyle(fontSize: isMobile ? 14 : 16),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildAppBarAction({
  required IconData icon,
  required VoidCallback onPressed,
  required String tooltip,
  required bool isMobile,
}) {
  final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;
  
  return Container(
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
  );
}

  
  Widget _buildLoadingState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Loading resources...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isMobile ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: isMobile ? 48 : 64,
            color: AppColors.lightMaroon.withOpacity(0.7),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: AppColors.darkMaroon,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            error,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.lightMaroon,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 16 : 24),
          ElevatedButton(
            onPressed: _loadResources,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 24,
                vertical: isMobile ? 10 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }

  

}