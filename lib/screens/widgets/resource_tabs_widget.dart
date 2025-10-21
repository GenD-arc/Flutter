import 'package:flutter/material.dart';
import 'package:testing/utils/app_colors.dart';
import '../../services/resource_service.dart';

class ResourceTabsWidget extends StatelessWidget {
  final TabController tabController;
  final List<Resource> resources;

  const ResourceTabsWidget({
    Key? key,
    required this.tabController,
    required this.resources,
  }) : super(key: key);

  // Professional color palette
  static const Color cardBackground = Color(0xFFFFFBFF);
  static const Color warmGray = Color(0xFFF8F9FA);

  // Tab configurations with icons and colors
  static const List<Map<String, dynamic>> _tabConfigs = [
    {
      'title': 'All',
      'type': 'all',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF5D4037),
    },
    {
      'title': 'Facility',
      'type': 'Facility',
      'icon': Icons.business_outlined,
      'color': Color(0xFF1565C0),
    },
    {
      'title': 'Room',
      'type': 'Room',
      'icon': Icons.meeting_room_outlined,
      'color': Color(0xFF00695C),
    },
    {
      'title': 'Vehicle',
      'type': 'Vehicle',
      'icon': Icons.directions_car_outlined,
      'color': Color(0xFFD84315),
    },
  ];

  int _getCountForType(String type) {
    if (type == 'all') return resources.length;
    return resources.where((r) => r.category == type).length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;
    
    // Compact padding for all sizes
    double horizontalPadding = isMobile ? 8 : (isTablet ? 10 : 8);
    double verticalPadding = isMobile ? 8 : (isTablet ? 10 : 8);
    
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, 
            vertical: verticalPadding
          ),
          decoration: BoxDecoration(
            color: cardBackground,
            border: Border(
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
                _tabConfigs.length,
                (index) => _buildSmartTab(
                  config: _tabConfigs[index],
                  index: index,
                  context: context,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmartTab({
    required Map<String, dynamic> config,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = tabController.index == index;
    final count = _getCountForType(config['type']);
    final tabColor = config['color'] as Color;
    final icon = config['icon'] as IconData;
    final title = config['title'] as String;

    // Responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    
    // Compact sizing for all devices
    final iconSize = isMobile ? 14.0 : (isTablet ? 15.0 : 14.0);
    final fontSize = isMobile ? 11.0 : (isTablet ? 12.0 : 12.0);
    final badgeFontSize = isMobile ? 9.0 : (isTablet ? 10.0 : 10.0);
    final horizontalPadding = isMobile ? 8.0 : (isTablet ? 10.0 : 10.0);
    final verticalPadding = isMobile ? 5.0 : (isTablet ? 6.0 : 6.0);
    final spacing = isMobile ? 4.0 : (isTablet ? 5.0 : 4.0);
    final borderRadius = isMobile ? 8.0 : (isTablet ? 9.0 : 8.0);
    final tabSpacing = isMobile ? 6.0 : (isTablet ? 6.0 : 6.0);
    final minBadgeWidth = isMobile ? 18.0 : (isTablet ? 20.0 : 20.0);

    return Padding(
      padding: EdgeInsets.only(right: tabSpacing),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => tabController.animateTo(index),
          borderRadius: BorderRadius.circular(borderRadius),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            decoration: BoxDecoration(
              color: isSelected ? tabColor.withOpacity(0.12) : warmGray,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isSelected ? tabColor.withOpacity(0.4) : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Icon(
                  icon,
                  size: iconSize,
                  color: isSelected ? tabColor : Colors.grey[600],
                ),
                SizedBox(width: spacing),
                
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? tabColor : Colors.grey[700],
                    letterSpacing: 0.1,
                  ),
                ),
                
                // Count Badge
                SizedBox(width: spacing),
                Container(
                  constraints: BoxConstraints(minWidth: minBadgeWidth),
                  padding: EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : tabColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
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
                      fontSize: badgeFontSize,
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
  }
}