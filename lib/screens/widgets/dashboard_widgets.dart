import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/screens/login_screen.dart';
import '../../services/auth_service.dart';

// ==================== MSEUFCI OFFICIAL COLOR PALETTE ====================
class DashboardColors {
  // Primary MSEUFCI Colors - "Maroon and White Forever"
  static const Color mseufMaroon = Color(0xFF8B0000);
  static const Color mseufMaroonDark = Color(0xFF4A1E1E);
  static const Color mseufMaroonLight = Color(0xFFB71C1C);
  
  // Official MSEUFCI White variations
  static const Color mseufWhite = Color(0xFFFFFFFF);
  static const Color mseufOffWhite = Color(0xFFFAFAFA);
  static const Color mseufCream = Color(0xFFF8F6F4);
  
  // Supporting Colors
  static const Color accentGray = Color(0xFFF8F9FA);
  static const Color accentGrayLight = Color(0xFF9CA3AF);
  
  // Neutral Foundation Colors
  static const Color backgroundPrimary = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  static const Color surfacePrimary = Color(0xFFFFFBFF);
  static const Color surfaceSecondary = Color(0xFFFBFBFB);
  static const Color surfaceTertiary = Color(0xFFF0F0F0);
  
  // Text and Content Colors
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF737373);
  
  // On-Brand Colors
  static const Color onMaroon = Color(0xFFFFFFFF);
  static const Color onWhite = Color(0xFF1F1F1F);
  
  // Semantic Colors
  static const Color successColor = Color(0xFF059669);
  static const Color warningColor = Color(0xFFD97706);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color infoColor = Color(0xFF2563EB);
  
  // Gradients
  static const LinearGradient maroonGradient = LinearGradient(
    colors: [mseufMaroonDark, mseufMaroon, mseufMaroonLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient whiteGradient = LinearGradient(
    colors: [mseufWhite, mseufOffWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surfacePrimary, surfaceSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient mseufAccentGradient = LinearGradient(
    colors: [mseufMaroon, mseufMaroonLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

enum DeviceType { mobile, tablet, laptop, desktop }

class DashboardWidgets {
  // Responsive breakpoints
  static const double mobileBreakpoint = 691.2;
  static const double tabletBreakpoint = 921.6;
  static const double desktopBreakpoint = 1296;

  // Device type detection
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < desktopBreakpoint) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  // ==================== DESKTOP SIDEBAR ====================
  static Widget buildDesktopSidebar(
    BuildContext context,
    AuthService authService, 
    DeviceType deviceType, 
    int selectedIndex, 
    Function(int) onNavigation,
  ) {
    final isLaptop = deviceType == DeviceType.laptop;
    
    return Container(
      width: isLaptop ? 226.8 : 259.2,
      decoration: BoxDecoration(
        gradient: DashboardColors.surfaceGradient,
        boxShadow: [
          BoxShadow(
            color: DashboardColors.mseufMaroon.withOpacity(0.08),
            blurRadius: 14.4,
            offset: Offset(3.6, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 7.2,
            offset: Offset(1.8, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPremiumDrawerHeader(authService, deviceType),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DashboardColors.surfaceSecondary, 
                    DashboardColors.surfaceTertiary.withOpacity(0.3)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: _buildHierarchicalDrawerMenu(
                context,
                authService, 
                deviceType, 
                selectedIndex, 
                onNavigation,
              ),
            ),
          ),
          _buildModernDrawerFooter(context, deviceType),
        ],
      ),
    );
  }

  // ==================== MOBILE/TABLET DRAWER ====================
  static Widget buildEnhancedDrawer(
    BuildContext context,
    AuthService authService, 
    DeviceType deviceType, 
    int selectedIndex, 
    Function(int) onNavigation,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) {
    final isTablet = deviceType == DeviceType.tablet;
    
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: isTablet ? 288 : 252,
      child: Container(
        decoration: BoxDecoration(
          gradient: DashboardColors.surfaceGradient,
          borderRadius: BorderRadius.horizontal(right: Radius.circular(21.6)),
          boxShadow: [
            BoxShadow(
              color: DashboardColors.mseufMaroon.withOpacity(0.15),
              blurRadius: 18,
              offset: Offset(7.2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildPremiumDrawerHeader(authService, deviceType),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DashboardColors.surfaceSecondary, 
                      DashboardColors.surfaceTertiary.withOpacity(0.5)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: _buildHierarchicalDrawerMenu(
                  context,
                  authService, 
                  deviceType, 
                  selectedIndex, 
                  onNavigation,
                ),
              ),
            ),
            _buildModernDrawerFooter(context, deviceType),
          ],
        ),
      ),
    );
  }

  static Widget _buildPremiumDrawerHeader(AuthService authService, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return Container(
      height: isMobile ? 126 : 144,
      decoration: BoxDecoration(
        gradient: DashboardColors.maroonGradient,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(21.6),
          bottomLeft: Radius.circular(28.8),
          bottomRight: Radius.circular(7.2),
        ),
        boxShadow: [
          BoxShadow(
            color: DashboardColors.mseufMaroonDark.withOpacity(0.3),
            blurRadius: 10.8,
            offset: Offset(0, 3.6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 14.4 : 16.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Row
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: DashboardColors.mseufCream.withOpacity(0.8),
                        width: 2.7,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: DashboardColors.onMaroon.withOpacity(0.2),
                          blurRadius: 7.2,
                          offset: Offset(0, 1.8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: isMobile ? 19.8 : 23.4,
                      backgroundImage: AssetImage('MSEUFCI_Logo.webp'),
                      backgroundColor: DashboardColors.onMaroon.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(width: isMobile ? 10.8 : 14.4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${authService.userName ?? "User"}',
                          style: TextStyle(
                            color: DashboardColors.onMaroon,
                            fontSize: isMobile ? 14.4 : 16.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.27,
                            height: 1.08,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5.4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 7.2 : 9,
                            vertical: isMobile ? 2.7 : 3.6,
                          ),
                          decoration: BoxDecoration(
                            color: DashboardColors.mseufWhite,
                            borderRadius: BorderRadius.circular(14.4),
                            border: Border.all(
                              color: DashboardColors.mseufMaroonLight.withOpacity(0.3),
                              width: 1.35,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: DashboardColors.mseufMaroon.withOpacity(0.2),
                                blurRadius: 3.6,
                                offset: Offset(0, 0.9),
                              ),
                            ],
                          ),
                          child: Text(
                            _getRoleDisplayName(authService.roleId),
                            style: TextStyle(
                              color: DashboardColors.mseufMaroonDark,
                              fontSize: isMobile ? 9 : 9.9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.72,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Spacer(),
              
              // University branding
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 7.2, vertical: 2.7),
                    decoration: BoxDecoration(
                      color: DashboardColors.onMaroon.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.8),
                      border: Border.all(
                        color: DashboardColors.mseufCream.withOpacity(0.4),
                        width: 0.9,
                      ),
                    ),
                    child: Text(
                      'MSEUF CANDELARIA INC.',
                      style: TextStyle(
                        color: DashboardColors.accentGrayLight,
                        fontSize: isMobile ? 9.9 : 10.8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.08,
                      ),
                    ),
                  ),
                  SizedBox(height: 3.6),
                  Text(
                    'Academic Resource Management System',
                    style: TextStyle(
                      color: DashboardColors.onMaroon.withOpacity(0.8),
                      fontSize: isMobile ? 8.1 : 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.36,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildHierarchicalDrawerMenu(
  BuildContext context,
  AuthService authService, 
  DeviceType deviceType, 
  int selectedIndex, 
  Function(int) onNavigation,
) {
  final isMobile = deviceType == DeviceType.mobile;
  
  return SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      isMobile ? 14.4 : 16.2,
      isMobile ? 18 : 19.44,
      isMobile ? 14.4 : 16.2,
      isMobile ? 10.8 : 12.96,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMenuSection('DASHBOARD', deviceType, [
          _buildPremiumDrawerItem(
            context: context,
            icon: Icons.dashboard_rounded,
            title: 'Overview',
            index: 0,
            isSelected: selectedIndex == 0,
            isPrimary: true,
            deviceType: deviceType,
            onNavigation: onNavigation,
          ),
        ]),
        
        if (authService.roleId == 'R01') ...[
          SizedBox(height: isMobile ? 21.6 : 25.2),
          _buildMenuSection('MY WORKSPACE', deviceType, [
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.calendar_today_rounded, // Changed from resources to calendar
              title: 'Public Calendar',
              index: 5, // Public Calendar
              isSelected: selectedIndex == 5,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.history_rounded,
              title: 'My Reserations',
              index: 6,
              isSelected: selectedIndex == 6,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
          ]),
        ],
        
        if (authService.roleId == 'R02') ...[
          SizedBox(height: isMobile ? 21.6 : 25.2),
          _buildMenuSection('FACULTY PORTAL', deviceType, [
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.event_note_rounded,
              title: 'Appointment Manager',
              index: 1,
              isSelected: selectedIndex == 1,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.calendar_today_rounded, // Added Public Calendar
              title: 'Public Calendar',
              index: 5,
              isSelected: selectedIndex == 5,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.assignment_turned_in_rounded,
              title: 'Approval Logs',
              index: 7,
              isSelected: selectedIndex == 7,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
          ]),
        ],
        
        if (authService.roleId == 'R03') ...[
          SizedBox(height: isMobile ? 21.6 : 25.2),
          _buildMenuSection('ADMINISTRATION', deviceType, [
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.event_note_rounded,
              title: 'Appointment Manager',
              index: 1,
              isSelected: selectedIndex == 1,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.calendar_today_rounded, // Added Public Calendar
              title: 'Public Calendar',
              index: 5,
              isSelected: selectedIndex == 5,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.assignment_turned_in_rounded,
              title: 'Approval Logs',
              index: 7,
              isSelected: selectedIndex == 7,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.people_rounded,
              title: 'User Management',
              index: 2,
              isSelected: selectedIndex == 2,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
            _buildPremiumDrawerItem(
              context: context,
              icon: Icons.inventory_rounded,
              title: 'Resource Control',
              index: 3,
              isSelected: selectedIndex == 3,
              deviceType: deviceType,
              onNavigation: onNavigation,
            ),
          ]),
        ],
      ],
    ),
  );
}

  static Widget _buildMenuSection(String title, DeviceType deviceType, List<Widget> items) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10.8 : 12.6,
            vertical: isMobile ? 5.4 : 7.2,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                DashboardColors.mseufMaroon.withOpacity(0.1),
                DashboardColors.mseufMaroon.withOpacity(0.05),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(10.8),
            border: Border.all(
              color: DashboardColors.mseufMaroon.withOpacity(0.2),
              width: 0.9,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 2.7,
                height: 10.8,
                decoration: BoxDecoration(
                  gradient: DashboardColors.maroonGradient,
                  borderRadius: BorderRadius.circular(1.8),
                ),
              ),
              SizedBox(width: 7.2),
              Text(
                title,
                style: TextStyle(
                  color: DashboardColors.mseufMaroonDark,
                  fontSize: isMobile ? 9 : 8.91,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 10.8 : 14.4),
        ...items,
      ],
    );
  }

  static Widget _buildPremiumDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
    required DeviceType deviceType,
    required Function(int) onNavigation,
    bool isPrimary = false,
  }) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 315),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(bottom: isMobile ? 5.4 : 7.2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.4),
        child: InkWell(
          onTap: () {
            onNavigation(index);
            if (deviceType == DeviceType.mobile || deviceType == DeviceType.tablet) {
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(14.4),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 315),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10.8 : 14.4,
              vertical: isMobile ? 10.8 : 12.6,
            ),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(
                colors: [
                  DashboardColors.mseufMaroon.withOpacity(0.15),
                  DashboardColors.mseufMaroon.withOpacity(0.08),
                  DashboardColors.mseufMaroon.withOpacity(0.03),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ) : null,
              borderRadius: BorderRadius.circular(14.4),
              border: Border.all(
                color: isSelected 
                  ? DashboardColors.mseufMaroon.withOpacity(0.4)
                  : DashboardColors.surfaceTertiary,
                width: isSelected ? 1.8 : 0.9,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: DashboardColors.mseufMaroon.withOpacity(0.2),
                  blurRadius: 10.8,
                  offset: Offset(0, 3.6),
                ),
                BoxShadow(
                  color: DashboardColors.mseufCream.withOpacity(0.1),
                  blurRadius: 5.4,
                  offset: Offset(0, 1.8),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 7.2 : 9),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                      ? DashboardColors.maroonGradient
                      : LinearGradient(
                          colors: [
                            DashboardColors.surfaceSecondary, 
                            DashboardColors.surfaceTertiary
                          ],
                        ),
                    borderRadius: BorderRadius.circular(10.8),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: DashboardColors.mseufMaroon.withOpacity(0.3),
                        blurRadius: 7.2,
                        offset: Offset(0, 1.8),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected 
                      ? DashboardColors.onMaroon
                      : DashboardColors.textSecondary,
                    size: isMobile ? 16.2 : 18,
                  ),
                ),
                SizedBox(width: isMobile ? 10.8 : 14.4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? DashboardColors.mseufMaroonDark : DashboardColors.textPrimary,
                      fontSize: isMobile ? 12.6 : 13.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: 0.27,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: isMobile ? 5.4 : 7.2),
                  Container(
                    width: isMobile ? 3.6 : 4.5,
                    height: isMobile ? 14.4 : 16.2,
                    decoration: BoxDecoration(
                      gradient: DashboardColors.mseufAccentGradient,
                      borderRadius: BorderRadius.circular(2.7),
                      boxShadow: [
                        BoxShadow(
                          color: DashboardColors.mseufMaroon.withOpacity(0.4),
                          blurRadius: 3.6,
                          offset: Offset(0, 0.9),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildModernDrawerFooter(BuildContext context, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 14.4 : 18),
      decoration: BoxDecoration(
        gradient: DashboardColors.surfaceGradient,
        border: Border(
          top: BorderSide(color: DashboardColors.surfaceTertiary, width: 0.9),
        ),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(21.6)),
      ),
      child: Column(
        children: [
          // Version info with MSEUF branding
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10.8 : 12.6,
              vertical: isMobile ? 7.2 : 9,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DashboardColors.surfaceSecondary, 
                  DashboardColors.surfaceTertiary.withOpacity(0.5)
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: DashboardColors.mseufCream.withOpacity(0.3), 
                width: 1.35,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(5.4),
                  decoration: BoxDecoration(
                    gradient: DashboardColors.whiteGradient,
                    borderRadius: BorderRadius.circular(7.2),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: DashboardColors.onWhite,
                    size: isMobile ? 12.6 : 14.4,
                  ),
                ),
                SizedBox(width: isMobile ? 5.4 : 7.2),
                Text(
                  'MSEUF v1.2.0',
                  style: TextStyle(
                    color: DashboardColors.textSecondary,
                    fontSize: isMobile ? 9.9 : 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isMobile ? 14.4 : 16.2),
          
          // Enhanced logout button
          Container(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showModernLogoutDialog(context),
                borderRadius: BorderRadius.circular(14.4),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 14.4 : 16.2,
                    vertical: isMobile ? 10.8 : 12.6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red[50]!,
                        Colors.red[25] ?? Colors.red[50]!.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14.4),
                    border: Border.all(
                      color: DashboardColors.errorColor.withOpacity(0.3), 
                      width: 1.35,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: DashboardColors.errorColor.withOpacity(0.1),
                        blurRadius: 7.2,
                        offset: Offset(0, 1.8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 5.4 : 6.3),
                        decoration: BoxDecoration(
                          color: DashboardColors.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: DashboardColors.errorColor.withOpacity(0.8),
                          size: isMobile ? 14.4 : 16.2,
                        ),
                      ),
                      SizedBox(width: isMobile ? 9 : 10.8),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: DashboardColors.errorColor.withOpacity(0.9),
                          fontSize: isMobile ? 12.6 : 13.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.27,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildModernTopBar(
  BuildContext context,
  AuthService authService, 
  DeviceType deviceType, 
  int selectedIndex,
  GlobalKey<ScaffoldState> scaffoldKey,
) {
  final isMobile = deviceType == DeviceType.mobile;
  final isTablet = deviceType == DeviceType.tablet;
  
  return Container(
    height: isMobile ? 67.5 : 81,
    decoration: BoxDecoration(
      gradient: DashboardColors.surfaceGradient,
      boxShadow: [
        BoxShadow(
          color: DashboardColors.mseufMaroon.withOpacity(0.06),
          blurRadius: 10.8,
          offset: Offset(0, 2.7),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 5.4,
          offset: Offset(0, 0.9),
        ),
      ],
    ),
    child: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14.4 : 25.92,
          vertical: isMobile ? 10.8 : 12.96,
        ),
        child: Row(
          children: [
            // Enhanced Logo with MSEUF branding
            Container(
              padding: EdgeInsets.all(5.4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: DashboardColors.whiteGradient,
                border: Border.all(
                  color: DashboardColors.mseufMaroon.withOpacity(0.4),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: DashboardColors.mseufCream.withOpacity(0.3),
                    blurRadius: 10.8,
                    offset: Offset(0, 3.6),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(3.6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DashboardColors.surfacePrimary,
                ),
                child: Image.asset(
                  'MSEUFCI_Logo.webp',
                  width: isMobile ? 32.4 : isTablet ? 39.6 : 45,
                  height: isMobile ? 32.4 : isTablet ? 39.6 : 45,
                ),
              ),
            ),
            
            SizedBox(width: 14.4),
            
            // Enhanced title with MSEUF branding
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        _getPageTitle(selectedIndex, deviceType),
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 21.6,
                          fontWeight: FontWeight.w600,
                          color: DashboardColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (!isMobile) ...[
                    SizedBox(height: 1.8),
                    Row(
                      children: [
                        Container(
                          width: 2.7,
                          height: 10.8,
                          decoration: BoxDecoration(
                            gradient: DashboardColors.maroonGradient,
                            borderRadius: BorderRadius.circular(1.8),
                          ),
                        ),
                        SizedBox(width: 5.4),
                        Text(
                          'University Resource Booking Portal',
                          style: TextStyle(
                            fontSize: 12.6,
                            fontWeight: FontWeight.w600,
                            color: DashboardColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Enhanced Notification Icon (hide on mobile to save space)
            if (!isMobile) ...[
              _buildEnhancedNotificationIcon(deviceType),
              SizedBox(width: isTablet ? 14.4 : 18),
            ],
            
            // Enhanced Profile with Dropdown Menu (now includes sign out)
            _buildEnhancedProfile(context, authService, deviceType),
          ],
        ),
      ),
    ),
  );
}


  static Widget _buildEnhancedNotificationIcon(DeviceType deviceType) {
    final isTablet = deviceType == DeviceType.tablet;
    
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 10.8 : 12.6),
          decoration: BoxDecoration(
            gradient: DashboardColors.surfaceGradient,
            borderRadius: BorderRadius.circular(16.2),
            border: Border.all(
              color: DashboardColors.surfaceTertiary, 
              width: 1.35,
            ),
            boxShadow: [
              BoxShadow(
                color: DashboardColors.mseufMaroon.withOpacity(0.08),
                blurRadius: 7.2,
                offset: Offset(0, 1.8),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: DashboardColors.textSecondary,
            size: isTablet ? 18 : 19.8,
          ),
        ),
        Positioned(
          top: 7.2,
          right: 7.2,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DashboardColors.errorColor, 
                  DashboardColors.errorColor.withOpacity(0.8)
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: DashboardColors.surfacePrimary, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: DashboardColors.errorColor.withOpacity(0.3),
                  blurRadius: 3.6,
                  offset: Offset(0, 0.9),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildEnhancedProfile(BuildContext context, AuthService authService, DeviceType deviceType) {
  final isMobile = deviceType == DeviceType.mobile;
  final isTablet = deviceType == DeviceType.tablet;
  
  return Container(
    padding: EdgeInsets.all(3.6),
    decoration: BoxDecoration(
      gradient: DashboardColors.maroonGradient,
      shape: BoxShape.circle,
      border: Border.all(
        color: DashboardColors.mseufWhite,
        width: 2.25,
      ),
      boxShadow: [
        BoxShadow(
          color: DashboardColors.mseufMaroon.withOpacity(0.3),
          blurRadius: 10.8,
          offset: Offset(0, 3.6),
        ),
      ],
    ),
    child: _buildProfileDropdown(context, authService, deviceType),
  );
}

// Add this new method to replace _buildProfileDropdown

static Widget _buildProfileDropdown(BuildContext context, AuthService authService, DeviceType deviceType) {
  final isMobile = deviceType == DeviceType.mobile;
  final isTablet = deviceType == DeviceType.tablet;
  
  return PopupMenuButton<String>(
    onSelected: (value) {
      if (value == 'sign_out') {
        _showModernLogoutDialog(context);
      }
    },
    itemBuilder: (BuildContext context) => [
      PopupMenuItem<String>(
        enabled: false,
        child: DarkModeToggleWidget(),
      ),
      PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'sign_out',
        child: Row(
          children: [
            Icon(Icons.logout_rounded, color: DashboardColors.errorColor, size: 18),
            SizedBox(width: 10),
            Text('Sign Out', style: TextStyle(color: DashboardColors.errorColor, fontSize: 12.6, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    ],
    offset: Offset(0, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14.4),
      side: BorderSide(color: DashboardColors.surfaceTertiary, width: 1.0),
    ),
    child: CircleAvatar(
      radius: isMobile ? 16.2 : isTablet ? 19.8 : 21.6,
      backgroundColor: DashboardColors.surfacePrimary,
      child: Text(
        _getUserInitials(authService.userName ?? 'User'),
        style: TextStyle(
          color: DashboardColors.mseufMaroonDark,
          fontSize: isMobile ? 10.8 : isTablet ? 12.6 : 13.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.45,
        ),
      ),
    ),
  );
}

// New method for animated dark mode toggle
static Widget _buildAnimatedDarkModeToggle() {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      bool isDarkMode = false;
      
      return Row(
        children: [
          Icon(Icons.dark_mode_rounded, color: DashboardColors.textSecondary, size: 18),
          SizedBox(width: 10),
          Text('Dark Mode', style: TextStyle(color: DashboardColors.textPrimary, fontSize: 12.6)),
          Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
              // TODO: Trigger actual dark mode state change in your provider
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              width: 52,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: isDarkMode 
                    ? [DashboardColors.mseufMaroonDark, DashboardColors.mseufMaroon]
                    : [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                
              ),
              child: Stack(
                
              ),
            ),
          ),
        ],
      );
    },
  );
}

// Helper method to animate dark mode toggle
static void _animateDarkModeToggle(BuildContext context) {
  // TODO: Implement actual dark mode toggle with provider state management
  // This could trigger a theme provider to switch themes across the entire app
  print('Dark mode toggle clicked - implement actual theme switching here');
}

  // ==================== WELCOME BANNER ====================
  static Widget buildMSEUFWelcomeBanner(AuthService authService, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final hour = DateTime.now().hour;
    final String timeGreeting = hour < 12 ? 'Morning' : hour < 18 ? 'Afternoon' : 'Evening';
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 21.6 : 25.2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 113, 29, 29),
            DashboardColors.mseufMaroon,
            DashboardColors.mseufMaroonLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: DashboardColors.mseufCream.withOpacity(0.2), 
          width: 1.35,
        ),
        boxShadow: [
          BoxShadow(
            color: DashboardColors.mseufMaroon.withOpacity(0.08),
            blurRadius: 14.4,
            offset: Offset(0, 5.4),
          ),
          BoxShadow(
            color: DashboardColors.mseufCream.withOpacity(0.05),
            blurRadius: 7.2,
            offset: Offset(0, 1.8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.2, vertical: 3.6),
                      decoration: BoxDecoration(
                        gradient: DashboardColors.whiteGradient,
                        borderRadius: BorderRadius.circular(10.8),
                      ),
                      child: Text(
                        'MSEUFCI PORTAL',
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 9.9,
                          fontWeight: FontWeight.w800,
                          color: DashboardColors.onWhite,
                          letterSpacing: 0.72,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.8),
                Text(
                  'Good $timeGreeting',
                  style: TextStyle(
                    fontSize: isMobile ? 19.8 : 21.06,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.9),
                    height: 0.99,
                  ),
                ),
                SizedBox(height: 7.2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Text(
                    'Welcome to your booking dashboard. Here\'s your daily overview.',
                    style: TextStyle(
                      fontSize: isMobile ? 11.7 : 12.6,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      height: 1.26,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isMobile ? 14.4 : 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DashboardColors.mseufMaroon.withOpacity(0.1),
                  DashboardColors.mseufCream.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.4),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 0.9,
              ),
            ),
            child: Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: isMobile ? 28.8 : 32.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  static String _getRoleDisplayName(String? roleId) {
    switch (roleId) {
      case 'R01':
        return 'Student';
      case 'R02':
        return 'Faculty';
      case 'R03':
        return 'Administrator';
      default:
        return 'User';
    }
  }

  static String _getUserInitials(String userName) {
    final names = userName.trim().split(' ');
    if (names.isEmpty) return 'U';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0]}${names.last[0]}'.toUpperCase();
  }

  static String _getPageTitle(int selectedIndex, DeviceType deviceType) {
    switch (selectedIndex) {
      case 0:
        switch (deviceType) {
          case DeviceType.mobile:
            return 'MSEUF-CI';
          case DeviceType.tablet:
            return 'MSEUF-CI Dashboard';
          case DeviceType.laptop:
            return 'MSEUF - Candelaria Inc.';
          case DeviceType.desktop:
            return 'Manuel S. Enverga University Foundation - Candelaria Inc.';
        }
      case 1:
        return 'Appointment Manager';
      case 2:
        return 'User Management';
      case 3:
        return 'Resource Control';
      case 4:
        return 'Appointment Status';
      case 5:
        return 'University Resources';
      case 6:
        return 'Appointment History';
      case 7:
        return 'Approval Logs';
      default:
        switch (deviceType) {
          case DeviceType.mobile:
            return 'MSEUF-CI';
          case DeviceType.tablet:
            return 'MSEUF-CI Dashboard';
          case DeviceType.laptop:
            return 'MSEUF - Candelaria Inc.';
          case DeviceType.desktop:
            return 'Manuel S. Enverga University Foundation - Candelaria Inc.';
        }
    }
  }
  
static void _showModernLogoutDialog(BuildContext context) {
  final deviceType = getDeviceType(context);
  final isMobile = deviceType == DeviceType.mobile;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: isMobile ? 252 : 288,
          padding: EdgeInsets.all(isMobile ? 18 : 21.6),
          decoration: BoxDecoration(
            gradient: DashboardColors.surfaceGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: DashboardColors.mseufMaroon.withOpacity(0.3),
              width: 1.35,
            ),
            boxShadow: [
              BoxShadow(
                color: DashboardColors.mseufMaroon.withOpacity(0.1),
                blurRadius: 14.4,
                offset: Offset(0, 5.4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10.8),
                decoration: BoxDecoration(
                  gradient: DashboardColors.maroonGradient,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DashboardColors.mseufWhite,
                    width: 1.8,
                  ),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: DashboardColors.onMaroon,
                  size: isMobile ? 28.8 : 32.4,
                ),
              ),
              SizedBox(height: 14.4),
              Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16.2,
                  color: DashboardColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 7.2),
              Text(
                'Are you sure you want to sign out from the MSEUFCI Portal?',
                style: TextStyle(
                  fontSize: 12.6,
                  color: DashboardColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(10.8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.8),
                          border: Border.all(
                            color: DashboardColors.surfaceTertiary,
                            width: 0.9,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 12.6,
                            color: DashboardColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                        final authService = context.read<AuthService>();
                        await authService.logout();
                        // FIXED: Use direct navigation instead of named route
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(10.8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          gradient: DashboardColors.maroonGradient,
                          borderRadius: BorderRadius.circular(10.8),
                          border: Border.all(
                            color: DashboardColors.mseufMaroon.withOpacity(0.3),
                            width: 0.9,
                          ),
                        ),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(
                            fontSize: 12.6,
                            color: DashboardColors.onMaroon,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ==================== PREMIUM BOTTOM NAVIGATION BAR ====================
static Widget buildResponsiveBottomNavBar(
  BuildContext context,
  AuthService authService,
  DeviceType deviceType,
  int selectedIndex,
  Function(int) onNavigation,
) {
  final isMobile = deviceType == DeviceType.mobile;
  final screenWidth = MediaQuery.of(context).size.width;
  
  final items = _getBottomNavItems(authService);
  final needsCompactMode = items.length > 3 || screenWidth < 380;
  
  return Container(
    decoration: BoxDecoration(
      color: DashboardColors.surfacePrimary,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Container(
        height: 70, // Perfect height for touch targets
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = selectedIndex == item.index;
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onNavigation(item.index),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected ? DashboardColors.mseufMaroon.withOpacity(0.1) : null,
                        border: isSelected ? Border.all(
                          color: DashboardColors.mseufMaroon.withOpacity(0.3),
                          width: 1.5,
                        ) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: isSelected 
                              ? DashboardColors.mseufMaroon
                              : DashboardColors.textSecondary,
                            size: needsCompactMode ? 20 : 22,
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: needsCompactMode ? 10 : 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected 
                                ? DashboardColors.mseufMaroon
                                : DashboardColors.textSecondary,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}

static List<BottomNavItem> _getBottomNavItems(AuthService authService) {
  List<BottomNavItem> items = [
    BottomNavItem(
      icon: Icons.dashboard_rounded,
      label: 'Home',
      index: 0,
    ),
  ];

  if (authService.roleId == 'R01') {
    items.addAll([
      BottomNavItem(
        icon: Icons.book_online_rounded,
        label: 'Reservations',
        index: 6,
      ),
      BottomNavItem(
        icon: Icons.calendar_today_rounded,
        label: 'Calendar',
        index: 5,
      ),
    ]);
  } else if (authService.roleId == 'R02') {
    items.addAll([
      BottomNavItem(
        icon: Icons.event_note_rounded,
        label: 'Manage',
        index: 1,
      ),
      BottomNavItem(
        icon: Icons.calendar_today_rounded, // Added Public Calendar
        label: 'Calendar',
        index: 5,
      ),
      BottomNavItem(
        icon: Icons.assignment_turned_in_rounded,
        label: 'Logs',
        index: 7,
      ),
    ]);
  } else if (authService.roleId == 'R03') {
    items.addAll([
      BottomNavItem(
        icon: Icons.event_note_rounded,
        label: 'Manage',
        index: 1,
      ),
      BottomNavItem(
        icon: Icons.calendar_today_rounded, // Added Public Calendar
        label: 'Calendar',
        index: 5,
      ),
      BottomNavItem(
        icon: Icons.assignment_turned_in_rounded,
        label: 'Logs',
        index: 7,
      ),
      BottomNavItem(
        icon: Icons.people_rounded,
        label: 'Users',
        index: 2,
      ),
      BottomNavItem(
        icon: Icons.inventory_rounded,
        label: 'Resources',
        index: 3,
      ),
    ]);
  }

  return items;
}

}

class BottomNavItem {
  final IconData icon;
  final String label;
  final int index;

  BottomNavItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class DarkModeToggleWidget extends StatefulWidget {
  @override
  State<DarkModeToggleWidget> createState() => _DarkModeToggleWidgetState();
}

class _DarkModeToggleWidgetState extends State<DarkModeToggleWidget> with SingleTickerProviderStateMixin {
  bool isDarkMode = false;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(-0.5, 0),
      end: Offset(0.5, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDarkMode() {
    setState(() {
      isDarkMode = !isDarkMode;
      if (isDarkMode) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    // TODO: Trigger actual dark mode state change in your provider
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.dark_mode_rounded, color: DashboardColors.textSecondary, size: 18),
        SizedBox(width: 10),
        Text('Dark Mode', style: TextStyle(color: DashboardColors.textPrimary, fontSize: 12.6)),
        Spacer(),
        GestureDetector(
          onTap: _toggleDarkMode,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            width: 52,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: isDarkMode 
                  ? [DashboardColors.mseufMaroonDark, DashboardColors.mseufMaroon]
                  : [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                    ? DashboardColors.mseufMaroon.withOpacity(0.4)
                    : Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
                if (isDarkMode)
                  BoxShadow(
                    color: DashboardColors.mseufMaroon.withOpacity(0.25),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Animated toggle thumb
                AnimatedPositioned(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  left: isDarkMode ? 26 : 2,
                  top: 2,
                  bottom: 2,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOutCubic,
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                        BoxShadow(
                          color: isDarkMode
                            ? DashboardColors.mseufMaroon.withOpacity(0.3)
                            : Colors.transparent,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: AnimatedRotation(
                          turns: isDarkMode ? 0.25 : 0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOutCubic,
                          child: Icon(
                            isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            color: isDarkMode 
                              ? DashboardColors.mseufMaroon
                              : DashboardColors.textTertiary,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Background stars
                if (isDarkMode)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: AnimatedOpacity(
                      opacity: isDarkMode ? 0.4 : 0,
                      duration: Duration(milliseconds: 500),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 4),
                          Container(
                            width: 2,
                            height: 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}