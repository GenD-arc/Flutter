import 'package:flutter/material.dart';
import '../../utils/device_type.dart';

class UserTabsWidget extends StatelessWidget {
  final TabController tabController;
  final Map<String, int> counts;
  final DeviceType deviceType;

  const UserTabsWidget({
    Key? key,
    required this.tabController,
    required this.counts,
    required this.deviceType,
  }) : super(key: key);

  // MSEUFCI Color Palette
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color cardBackground = Color(0xFFFFFBFF);
  static const Color warmGray = Color(0xFFF8F9FA);

  // Tab configurations with icons and colors
  static const List<Map<String, dynamic>> _tabConfigs = [
    {
      'title': 'All',
      'key': 'All',
      'icon': Icons.grid_view_rounded,
      'color': Color(0xFF5D4037),
    },
    {
      'title': 'Users',
      'key': 'Users',
      'icon': Icons.people_outline,
      'color': Color(0xFF5D4037),
    },
    {
      'title': 'Admin',
      'key': 'Admin',
      'icon': Icons.shield_outlined,
      'color': Color(0xFF1565C0),
    },
    {
      'title': 'Super Admin',
      'key': 'Super Admin',
      'icon': Icons.verified_user_outlined,
      'color': Color(0xFF6A1B9A),
    },
    {
      'title': 'Archived',
      'key': 'Archived',
      'icon': Icons.archive_outlined,
      'color': Color(0xFF616161),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 8 : 12,
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
                  isMobile: isMobile,
                  isTablet: isTablet,
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
    required bool isMobile,
    required bool isTablet,
  }) {
    final isSelected = tabController.index == index;
    final count = counts[config['key']] ?? 0;
    final tabColor = config['color'] as Color;
    final icon = config['icon'] as IconData;
    final title = config['title'] as String;

    return Padding(
      padding: EdgeInsets.only(right: isMobile ? 6 : 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => tabController.animateTo(index),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : isTablet ? 14 : 16,
              vertical: isMobile ? 8 : 10,
            ),
            decoration: BoxDecoration(
              color: isSelected ? tabColor.withOpacity(0.12) : warmGray,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? tabColor.withOpacity(0.4) : Colors.grey[300]!,
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
                            colors: [primaryMaroon, lightMaroon],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : tabColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? primaryMaroon.withOpacity(0.3)
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
  }
}