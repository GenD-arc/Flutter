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

  // MSEUFCI Color Palette (consistent with ApprovalLogsScreen)
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color cardBackground = Color(0xFFFFFBFF);
  static const Color warmGray = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return AnimatedBuilder(
      animation: tabController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: 6),
          color: warmGray,
          child: Row(
            children: [
              _buildFilterTab('All', counts['All'] ?? 0, 0, isMobile, isTablet),
              _buildFilterTab('Users', counts['Users'] ?? 0, 1, isMobile, isTablet),
              _buildFilterTab('Admin', counts['Admin'] ?? 0, 2, isMobile, isTablet),
              _buildFilterTab('SuperAdmin', counts['Super Admin'] ?? 0, 3, isMobile, isTablet),
              _buildFilterTab('Archived', counts['Archived'] ?? 0, 4, isMobile, isTablet),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTab(String title, int count, int index, bool isMobile, bool isTablet) {
    final isSelected = tabController.index == index;
    final isLast = index == 4; // Archived is the last tab

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: isLast ? 0 : 8),
        child: GestureDetector(
          onTap: () {
            tabController.animateTo(index);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [primaryMaroon, lightMaroon],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.white, cardBackground],
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? primaryMaroon.withOpacity(0.3)
                    : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: primaryMaroon.withOpacity(0.15),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey[700],
                    letterSpacing: 0.3,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.2)
                        : primaryMaroon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.3)
                          : primaryMaroon.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : isTablet ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected 
                          ? Colors.white.withOpacity(0.9) 
                          : primaryMaroon,
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