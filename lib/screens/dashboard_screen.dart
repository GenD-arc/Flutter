import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/screens/reservation_approval_screen.dart';
import 'package:testing/screens/reservation_history_screen.dart';
import 'package:testing/screens/approval_logs_screen.dart';
import 'package:testing/screens/view_resources_screen.dart';
import 'package:testing/screens/view_resources_screen_for_user.dart';
import '../services/auth_service.dart';
import '../screens/reservation_status_tracker_screen.dart';
import 'superadmin/view_users_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  // ==================== MSEUFCI OFFICIAL COLOR PALETTE ====================
  
// Primary MSEUFCI Colors - "Maroon and White Forever"
  static const Color mseufMaroon = Color(0xFF8B0000); // Official MSEUFCI Maroon - primary brand color
  static const Color mseufMaroonDark = Color(0xFF4A1E1E); // Darker maroon for headers and emphasis
  static const Color mseufMaroonLight = Color(0xFFB71C1C); // Lighter maroon for highlights and accents
  
  // Official MSEUFCI White variations
  static const Color mseufWhite = Color(0xFFFFFFFF); // Pure white - secondary brand color
  static const Color mseufOffWhite = Color(0xFFFAFAFA); // Subtle off-white for backgrounds
  static const Color mseufCream = Color(0xFFF8F6F4); // Warm cream for elegant backgrounds
  
  // Supporting Colors (refined to complement Maroon and White)
  static const Color accentGray = Color(0xFFF8F9FA); // Professional gray for accents
  static const Color accentGrayLight = Color(0xFF9CA3AF); // Light gray for subtle elements
  
  // Neutral Foundation Colors (60% of design)
  static const Color backgroundPrimary = Color(0xFFFAFAFA); // Clean white background
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Slightly off-white
  static const Color surfacePrimary = Color(0xFFFFFBFF);// Pure white for cards and panels
  static const Color surfaceSecondary = Color(0xFFFBFBFB); // Very subtle off-white for secondary surfaces
  static const Color surfaceTertiary = Color(0xFFF0F0F0); // Light gray for dividers and borders
  
  // Text and Content Colors (using warmer tones to complement maroon)
  static const Color textPrimary = Color(0xFF1F1F1F); // Near black for primary text
  static const Color textSecondary = Color(0xFF4A4A4A); // Medium gray for secondary text
  static const Color textTertiary = Color(0xFF737373); // Light gray for tertiary text
  
  // On-Brand Colors (for text on colored backgrounds)
  static const Color onMaroon = Color(0xFFFFFFFF); // White text on maroon
  static const Color onWhite = Color(0xFF1F1F1F); // Dark text on white
  
  // Semantic Colors (adjusted to work well with maroon and white)
  static const Color successColor = Color(0xFF059669); // Green that complements maroon
  static const Color warningColor = Color(0xFFD97706); // Orange that works with the palette
  static const Color errorColor = Color(0xFFDC2626); // Red that harmonizes with maroon
  static const Color infoColor = Color(0xFF2563EB); // Blue for information
  
  // Gradients for premium feel using MSEUFCI colors
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

  // MSEUFCI-specific accent gradient (maroon to lighter maroon)
  static const LinearGradient mseufAccentGradient = LinearGradient(
    colors: [mseufMaroon, mseufMaroonLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Responsive breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = context.read<AuthService>();
      if (authService.isAuthenticated && authService.token != null) {
        debugPrint('Dashboard - Auth Service Token: ${authService.token != null ? "Present" : "Missing"}');
        debugPrint('Dashboard - Token: ${authService.token?.substring(0, 20) ?? "No token"}...');
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Device type detection
  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < desktopBreakpoint) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final deviceType = _getDeviceType(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundPrimary, // Enhanced warm background
      drawer: deviceType == DeviceType.mobile || deviceType == DeviceType.tablet 
          ? _buildEnhancedDrawer(authService, deviceType) 
          : null,
      body: Row(
        children: [
          // Desktop/Laptop Sidebar
          if (deviceType == DeviceType.laptop || deviceType == DeviceType.desktop)
            _buildDesktopSidebar(authService, deviceType),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                _buildModernTopBar(authService, deviceType),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: _buildMainContent(authService),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== DESKTOP SIDEBAR ====================
  Widget _buildDesktopSidebar(AuthService authService, DeviceType deviceType) {
    final isLaptop = deviceType == DeviceType.laptop;
    
    return Container(
      width: isLaptop ? 280 : 320,
      decoration: BoxDecoration(
        gradient: surfaceGradient, // Premium gradient background
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.08), // Maroon-tinted shadow
            blurRadius: 16,
            offset: Offset(4, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(2, 0),
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
                  colors: [surfaceSecondary, surfaceTertiary.withOpacity(0.3)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: _buildHierarchicalDrawerMenu(authService, deviceType),
            ),
          ),
          _buildModernDrawerFooter(deviceType),
        ],
      ),
    );
  }

  // ==================== MOBILE/TABLET DRAWER ====================
  Widget _buildEnhancedDrawer(AuthService authService, DeviceType deviceType) {
    final isTablet = deviceType == DeviceType.tablet;
    
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: isTablet ? 320 : 280,
      child: Container(
        decoration: BoxDecoration(
          gradient: surfaceGradient,
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: mseufMaroon.withOpacity(0.15),
              blurRadius: 20,
              offset: Offset(8, 0),
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
                    colors: [surfaceSecondary, surfaceTertiary.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: _buildHierarchicalDrawerMenu(authService, deviceType),
              ),
            ),
            _buildModernDrawerFooter(deviceType),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumDrawerHeader(AuthService authService, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return Container(
      height: isMobile ? 140 : 160,
      decoration: BoxDecoration(
        gradient: maroonGradient, // Official MSEUF maroon gradient
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: mseufMaroonDark.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
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
                        color: mseufCream.withOpacity(0.8), // Gold border
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: onMaroon.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: isMobile ? 22 : 26,
                      backgroundImage: AssetImage('MSEUFCI_Logo.webp'),
                      backgroundColor: onMaroon.withOpacity(0.1),
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${authService.userName ?? "User"}',
                          style: TextStyle(
                            color: onMaroon,
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 8 : 10,
                            vertical: isMobile ? 3 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: mseufWhite, // White background for role badge
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: mseufMaroonLight.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: mseufMaroon.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            _getRoleDisplayName(authService.roleId),
                            style: TextStyle(
                              color: mseufMaroonDark, // Maroon text on white
                              fontSize: isMobile ? 10 : 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
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
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: onMaroon.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: mseufCream.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'MSEUF CANDELARIA INC.',
                      style: TextStyle(
                        color: accentGrayLight,
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Academic Resource Management System',
                    style: TextStyle(
                      color: onMaroon.withOpacity(0.8),
                      fontSize: isMobile ? 9 : 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
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

  Widget _buildHierarchicalDrawerMenu(AuthService authService, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 20,
        isMobile ? 20 : 24,
        isMobile ? 16 : 20,
        isMobile ? 12 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuSection('DASHBOARD', deviceType, [
            _buildPremiumDrawerItem(
              icon: Icons.dashboard_rounded,
              title: 'Overview',
              index: 0,
              isSelected: _selectedIndex == 0,
              isPrimary: true,
              deviceType: deviceType,
            ),
          ]),
          
          if (authService.roleId == 'R01') ...[
            SizedBox(height: isMobile ? 24 : 28),
            _buildMenuSection('MY WORKSPACE', deviceType, [
              _buildPremiumDrawerItem(
                icon: Icons.inventory_2_rounded,
                title: 'University Resources',
                index: 5,
                isSelected: _selectedIndex == 5,
                deviceType: deviceType,
              ),
              _buildPremiumDrawerItem(
                icon: Icons.track_changes_rounded,
                title: 'Appointment Status',
                index: 4,
                isSelected: _selectedIndex == 4,
                deviceType: deviceType,
              ),
              _buildPremiumDrawerItem(
                icon: Icons.history_rounded,
                title: 'Appointments History',
                index: 6,
                isSelected: _selectedIndex == 6,
                deviceType: deviceType,
              ),
            ]),
          ],
          
          if (authService.roleId == 'R02') ...[
            SizedBox(height: isMobile ? 24 : 28),
            _buildMenuSection('FACULTY PORTAL', deviceType, [
              _buildPremiumDrawerItem(
                icon: Icons.event_note_rounded,
                title: 'Appointment Manager',
                index: 1,
                isSelected: _selectedIndex == 1,
                deviceType: deviceType,
              ),
              _buildPremiumDrawerItem(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Approval Logs',
                index: 7,
                isSelected: _selectedIndex == 7,
                deviceType: deviceType,
              ),
            ]),
          ],
          
          if (authService.roleId == 'R03') ...[
            SizedBox(height: isMobile ? 24 : 28),
            _buildMenuSection('ADMINISTRATION', deviceType, [
              _buildPremiumDrawerItem(
                icon: Icons.event_note_rounded,
                title: 'Appointment Manager',
                index: 1,
                isSelected: _selectedIndex == 1,
                deviceType: deviceType,
              ),
              _buildPremiumDrawerItem(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Approval Logs',
                index: 7,
                isSelected: _selectedIndex == 7,
                deviceType: deviceType,
              ),
              _buildPremiumDrawerItem(
                icon: Icons.people_rounded,
                title: 'User Management',
                index: 2,
                isSelected: _selectedIndex == 2,
                deviceType: deviceType,
              ),
              _buildPremiumDrawerItem(
                icon: Icons.inventory_rounded,
                title: 'Resource Control',
                index: 3,
                isSelected: _selectedIndex == 3,
                deviceType: deviceType,
              ),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, DeviceType deviceType, List<Widget> items) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 14,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                mseufMaroon.withOpacity(0.1),
                mseufMaroon.withOpacity(0.05),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: mseufMaroon.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  gradient: maroonGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: mseufMaroonDark,
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        ...items,
      ],
    );
  }

  Widget _buildPremiumDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    required bool isSelected,
    required DeviceType deviceType,
    bool isPrimary = false,
  }) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(bottom: isMobile ? 6 : 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            if (deviceType == DeviceType.mobile || deviceType == DeviceType.tablet) {
              Navigator.pop(context);
            }
            _handleNavigation(index);
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 350),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 14,
            ),
            decoration: BoxDecoration(
              gradient: isSelected ? LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.15),
                  mseufMaroon.withOpacity(0.08),
                  mseufMaroon.withOpacity(0.03),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ) : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                  ? mseufMaroon.withOpacity(0.4)
                  : surfaceTertiary,
                width: isSelected ? 2.0 : 1.0,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: mseufMaroon.withOpacity(0.2),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
                BoxShadow(
                  color: mseufCream.withOpacity(0.1),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 10),
                  decoration: BoxDecoration(
                    gradient: isSelected 
                      ? maroonGradient
                      : LinearGradient(
                          colors: [surfaceSecondary, surfaceTertiary],
                        ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: mseufMaroon.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected 
                      ? onMaroon
                      : textSecondary,
                    size: isMobile ? 18 : 20,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? mseufMaroonDark : textPrimary,
                      fontSize: isMobile ? 14 : 15,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected) ...[
                  SizedBox(width: isMobile ? 6 : 8),
                  Container(
                    width: isMobile ? 4 : 5,
                    height: isMobile ? 16 : 18,
                    decoration: BoxDecoration(
                      gradient: mseufAccentGradient,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: mseufMaroon.withOpacity(0.4),
                          blurRadius: 4,
                          offset: Offset(0, 1),
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

  Widget _buildModernDrawerFooter(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: surfaceGradient,
        border: Border(
          top: BorderSide(color: surfaceTertiary, width: 1),
        ),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Version info with MSEUF branding
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 14,
              vertical: isMobile ? 8 : 10,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [surfaceSecondary, surfaceTertiary.withOpacity(0.5)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: mseufCream.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: whiteGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.school_rounded, // University icon
                    color: onWhite,
                    size: isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'MSEUF v1.2.0',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isMobile ? 16 : 18),
          
          // Enhanced logout button
          Container(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showModernLogoutDialog(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 18,
                    vertical: isMobile ? 12 : 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red[50]!,
                        Colors.red[25] ?? Colors.red[50]!.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: errorColor.withOpacity(0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: errorColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isMobile ? 6 : 7),
                        decoration: BoxDecoration(
                          color: errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: errorColor.withOpacity(0.8),
                          size: isMobile ? 16 : 18,
                        ),
                      ),
                      SizedBox(width: isMobile ? 10 : 12),
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          color: errorColor.withOpacity(0.9),
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
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

  // ==================== TOP BAR ====================
  Widget _buildModernTopBar(AuthService authService, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    return Container(
      height: isMobile ? 75 : 90,
      decoration: BoxDecoration(
        gradient: surfaceGradient,
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 32,
            vertical: isMobile ? 12 : 16,
          ),
          child: Row(
            children: [
              // Menu Button (only show on mobile/tablet)
              if (deviceType == DeviceType.mobile || deviceType == DeviceType.tablet)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [surfaceSecondary, surfaceTertiary.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: mseufMaroon.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mseufMaroon.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.menu_rounded, color: mseufMaroonDark, size: isMobile ? 22 : 24),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    padding: EdgeInsets.all(8),
                  ),
                ),
              
              if (deviceType == DeviceType.mobile || deviceType == DeviceType.tablet)
                SizedBox(width: 16),
              
              // Enhanced Logo with MSEUF branding
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: whiteGradient,
                  border: Border.all(
                    color: mseufMaroon.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: mseufCream.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: surfacePrimary,
                  ),
                  child: Image.asset(
                    'MSEUFCI_Logo.webp',
                    width: isMobile ? 36 : isTablet ? 44 : 50,
                    height: isMobile ? 36 : isTablet ? 44 : 50,
                  ),
                ),
              ),
              
              SizedBox(width: 16),
              
              // Enhanced title with MSEUF branding
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                           _getPageTitle(deviceType),
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (!isMobile) ...[
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: maroonGradient,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'University Resource Booking Portal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textTertiary,
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
                SizedBox(width: isTablet ? 16 : 20),
              ],
              
              // Enhanced Profile with MSEUF colors
              _buildEnhancedProfile(authService, deviceType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedNotificationIcon(DeviceType deviceType) {
    final isTablet = deviceType == DeviceType.tablet;
    
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 14),
          decoration: BoxDecoration(
            gradient: surfaceGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: surfaceTertiary, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: mseufMaroon.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.notifications_outlined,
            color: textSecondary,
            size: isTablet ? 20 : 22,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [errorColor, errorColor.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: surfacePrimary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: errorColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedProfile(AuthService authService, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: maroonGradient,
        shape: BoxShape.circle,
        border: Border.all(
          color: mseufWhite,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: isMobile ? 18 : isTablet ? 22 : 24,
        backgroundColor: surfacePrimary,
        child: Text(
          _getUserInitials(authService.userName ?? 'User'),
          style: TextStyle(
            color: mseufMaroonDark,
            fontSize: isMobile ? 12 : isTablet ? 14 : 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ==================== MAIN CONTENT ====================
  Widget _buildMainContent(AuthService authService) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0.0, 0.1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutCubic,
      )),
      child: _getContentForIndex(authService),
    );
  }

  Widget _getContentForIndex(AuthService authService) {
    if (!authService.isAuthenticated || authService.currentUser == null) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: surfaceGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: errorColor.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.login_rounded,
                color: errorColor,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Please log in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: errorColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (_selectedIndex) {
      case 0:
        return _buildEnhancedDashboardContent(authService);
      case 1:
        return _buildAppointmentManagerContent();
      case 2:
        return _buildManageUsersContent();
      case 3:
        return _buildManageResourcesContent();
      case 4:
        return _buildAnalyticsContent();
      case 5:
        return _buildManageResourcesContentForUser();
      case 6:
        return _buildReservationHistoryScreen(authService);
      case 7:
        return _buildApprovalLogsContent(authService);
      default:
        return _buildEnhancedDashboardContent(authService);
    }
  }

  // ==================== ENHANCED DASHBOARD CONTENT ====================
  Widget _buildEnhancedDashboardContent(AuthService authService) {
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundPrimary, backgroundSecondary.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 20 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Welcome Banner with MSEUF branding
            _buildMSEUFWelcomeBanner(authService, deviceType),
            
            SizedBox(height: isMobile ? 28 : 36),
            
            // Enhanced Quick Stats with university metrics
            _buildMSEUFQuickStats(deviceType),
            
            SizedBox(height: isMobile ? 28 : 36),
            
            // Enhanced Recent Activity with academic focus
            _buildMSEUFRecentActivity(deviceType),
          ],
        ),
      ),
    );
  }

  Widget _buildMSEUFWelcomeBanner(AuthService authService, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final hour = DateTime.now().hour;
    final String timeGreeting = hour < 12 ? 'Morning' : hour < 18 ? 'Afternoon' : 'Evening';
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(255, 113, 29, 29),
                  mseufMaroon,
                  mseufMaroonLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: mseufCream.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: mseufCream.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
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
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: whiteGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'MSEUFCI PORTAL',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w800,
                          color: onWhite,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'Good $timeGreeting',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  child: Text(
                    'Welcome to your booking dashboard. Here\'s your daily overview.',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.1),
                  mseufCream.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: isMobile ? 32 : 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMSEUFQuickStats(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    final stats = [
      {
        'title': 'Active Students',
        'value': '1,247',
        'icon': Icons.people_rounded,
        'color': mseufMaroon,
        'growth': '+5.2%',
        'subtitle': 'This semester',
      },
      {
        'title': 'Faculty Members',
        'value': '89',
        'icon': Icons.person_rounded,
        'color': accentGray,
        'growth': '+2.1%',
        'subtitle': 'Active staff',
      },
      {
        'title': 'Resources',
        'value': '234',
        'icon': Icons.inventory_2_rounded,
        'color': infoColor,
        'growth': '+8.5%',
        'subtitle': 'Available items',
      },
      {
        'title': 'Appointments',
        'value': '47',
        'icon': Icons.event_note_rounded,
        'color': successColor,
        'growth': '+12.3%',
        'subtitle': 'This week',
      },
    ];

    if (isMobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildMSEUFStatCard(stats[0], deviceType)),
              SizedBox(width: 12),
              Expanded(child: _buildMSEUFStatCard(stats[1], deviceType)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMSEUFStatCard(stats[2], deviceType)),
              SizedBox(width: 12),
              Expanded(child: _buildMSEUFStatCard(stats[3], deviceType)),
            ],
          ),
        ],
      );
    } else if (isTablet) {
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: stats.map((stat) => 
          Container(
            width: (MediaQuery.of(context).size.width - 80) / 2 - 8,
            child: _buildMSEUFStatCard(stat, deviceType),
          ),
        ).toList(),
      );
    } else {
      return Row(
        children: stats.map((stat) => 
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: stat == stats.last ? 0 : 20),
              child: _buildMSEUFStatCard(stat, deviceType),
            ),
          ),
        ).toList(),
      );
    }
  }

  Widget _buildMSEUFStatCard(Map<String, dynamic> stat, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    final Color cardColor = stat['color'] as Color;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : isTablet ? 22 : 26),
      decoration: BoxDecoration(
        gradient: surfaceGradient,
        borderRadius: BorderRadius.circular(isMobile ? 18 : 22),
        border: Border.all(
          color: cardColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.08),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cardColor.withOpacity(0.15),
                      cardColor.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cardColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  stat['icon'] as IconData,
                  color: cardColor,
                  size: isMobile ? 20 : isTablet ? 24 : 28,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      successColor.withOpacity(0.1),
                      successColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: successColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  stat['growth'] as String,
                  style: TextStyle(
                    color: successColor,
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 14 : 18),
          Text(
            stat['value'] as String,
            style: TextStyle(
              fontSize: isMobile ? 24 : isTablet ? 28 : 32,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              height: 0.9,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            stat['title'] as String,
            style: TextStyle(
              fontSize: isMobile ? 13 : isTablet ? 14 : 15,
              fontWeight: FontWeight.w700,
              color: textSecondary,
            ),
          ),
          SizedBox(height: 2),
          Text(
            stat['subtitle'] as String,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w500,
              color: textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMSEUFRecentActivity(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    final activities = [
      {
        'icon': Icons.person_add_rounded,
        'title': 'New Student Enrollment',
        'subtitle': 'Maria Santos enrolled in Computer Science program',
        'time': '2 hours ago',
        'color': mseufMaroon,
        'priority': 'high',
        'category': 'Enrollment',
      },
      {
        'icon': Icons.assignment_turned_in_rounded,
        'title': 'Resource Request Approved',
        'subtitle': 'Laboratory equipment request for Physics Department',
        'time': '4 hours ago',
        'color': successColor,
        'priority': 'medium',
        'category': 'Approval',
      },
      {
        'icon': Icons.schedule_rounded,
        'title': 'Appointment Scheduled',
        'subtitle': 'Academic consultation with Dr. Rodriguez',
        'time': '6 hours ago',
        'color': warningColor,
        'priority': 'medium',
        'category': 'Schedule',
      },
      {
        'icon': Icons.assessment_rounded,
        'title': 'Academic Report Generated',
        'subtitle': 'Monthly performance analytics for all departments',
        'time': '8 hours ago',
        'color': infoColor,
        'priority': 'low',
        'category': 'Report',
      },
      {
        'icon': Icons.security_rounded,
        'title': 'System Security Update',
        'subtitle': 'Enhanced authentication protocols activated',
        'time': '1 day ago',
        'color': warningColor,
        'priority': 'high',
        'category': 'System',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: surfaceGradient,
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        border: Border.all(color: surfaceTertiary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.06),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced Header
          Container(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 20 : 28,
              isMobile ? 20 : 28,
              isMobile ? 20 : 28,
              isMobile ? 16 : 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.03),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMobile ? 20 : 24),
                topRight: Radius.circular(isMobile ? 20 : 24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    gradient: maroonGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: mseufMaroon.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.timeline_rounded,
                    color: onMaroon,
                    size: isMobile ? 20 : 22,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent University Activity',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Latest updates from MSEUF Candelaria',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: whiteGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: mseufCream.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '${activities.length}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 13,
                      fontWeight: FontWeight.w800,
                      color: onWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, color: surfaceTertiary),
          
          // Activity List
          Container(
            height: isMobile ? 300 : isTablet ? 350 : 400,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final isLast = index == activities.length - 1;
                
                return Column(
                  children: [
                    _buildMSEUFActivityItem(activity, deviceType),
                    if (!isLast) Divider(height: 1, color: surfaceTertiary),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMSEUFActivityItem(Map<String, dynamic> activity, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    final isPriorityHigh = activity['priority'] == 'high';
    final Color activityColor = activity['color'] as Color;
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 20 : 24),
      child: Row(
        children: [
          // Enhanced Icon Container
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  activityColor.withOpacity(0.15),
                  activityColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPriorityHigh 
                  ? activityColor.withOpacity(0.4)
                  : activityColor.withOpacity(0.2),
                width: isPriorityHigh ? 2.0 : 1.0,
              ),
              boxShadow: isPriorityHigh ? [
                BoxShadow(
                  color: activityColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ] : null,
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: activityColor,
              size: isMobile ? 20 : isTablet ? 22 : 24,
            ),
          ),
          SizedBox(width: isMobile ? 14 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity['title'] as String,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: activityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: activityColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        activity['category'] as String,
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 10,
                          fontWeight: FontWeight.w600,
                          color: activityColor,
                        ),
                      ),
                    ),
                    if (isPriorityHigh) ...[
                      SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: errorColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: errorColor.withOpacity(0.3),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  activity['subtitle'] as String,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity['time'] as String,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isPriorityHigh) ...[
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [errorColor.withOpacity(0.1), errorColor.withOpacity(0.05)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'HIGH',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: errorColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ==================== OTHER SCREENS ====================
  Widget _buildReservationHistoryScreen(dynamic authService) {
    return ReservationHistoryScreen(userId: authService.currentUser!.id);
  }

  Widget _buildApprovalLogsContent(AuthService authService) {
    if (authService.roleId != 'R02' && authService.roleId != 'R03') {
      return _buildAccessDeniedWidget('view approval logs');
    }
    if (!authService.isAuthenticated || authService.currentUser == null || authService.token == null) {
      return _buildAuthenticationRequiredWidget();
    }
    return ApprovalLogsScreen(
      approverId: authService.currentUser!.id,
      token: authService.token!,
    );
  }

  Widget _buildAnalyticsContent() {
    final authService = context.read<AuthService>();
    if (!authService.isAuthenticated || authService.currentUser == null) {
      return Center(
        child: Text(
          'Please log in to view appointment status',
          style: TextStyle(
            fontSize: 16,
            color: errorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return ReservationStatusTrackerScreen(
      userId: authService.currentUser!.id,
    );
  }

  Widget _buildManageUsersContent() {
    return ViewUsersScreen();
  }

  Widget _buildAppointmentManagerContent() {
    final authService = context.read<AuthService>();
    if (!authService.isAuthenticated || authService.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Center(child: Text('Redirecting to login...'));
    }
    if (authService.currentUser!.roleId != 'R02' && authService.currentUser!.roleId != 'R03') {
      return _buildAccessDeniedWidget('manage appointments');
    }
    return ReservationApprovalScreen(
      approverId: authService.currentUser!.id, 
      token: authService.token ?? '',
    );
  }

  Widget _buildManageResourcesContent() {
    return ViewResourcesScreen();
  }

  Widget _buildManageResourcesContentForUser() {
    return ViewResourcesScreenForUser();
  }

  Widget _buildAccessDeniedWidget(String feature) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: surfaceGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: errorColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: errorColor.withOpacity(0.1),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [errorColor.withOpacity(0.1), errorColor.withOpacity(0.05)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                color: errorColor,
                size: 48,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Access Restricted',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: mseufMaroonDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You do not have permission to $feature.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Contact your administrator if you need access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticationRequiredWidget() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: surfaceGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: warningColor.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: warningColor.withOpacity(0.1),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: warningColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.login_rounded,
                color: warningColor,
                size: 48,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Authentication Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: mseufMaroonDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please log in to continue using the MSEUFCI portal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final authService = context.read<AuthService>();
    if (!authService.isAuthenticated || authService.currentUser == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
  }

  // ==================== UTILITY METHODS ====================
  String _getRoleDisplayName(String? roleId) {
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

  String _getUserInitials(String name) {
    return name
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .take(2)
        .join('');
  }

  String _getPageTitle(DeviceType deviceType) {

    switch (deviceType) {
      case DeviceType.mobile:
        return 'MSEUFCI';

      case DeviceType.tablet:
      case DeviceType.laptop:
        return 'MSEUF Candelaria Inc.';

      default:
        return 'Manuel S. Enverga University Foundation - Candelaria Inc.';
    }
  }

  void _showModernLogoutDialog(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    final double dialogWidth = isMobile 
        ? MediaQuery.of(context).size.width * 0.85
        : isTablet 
            ? MediaQuery.of(context).size.width * 0.6
            : 400;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 24 : 28),
          ),
          elevation: 12,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Container(
            width: dialogWidth,
            padding: EdgeInsets.all(isMobile ? 24 : 28),
            decoration: BoxDecoration(
              gradient: surfaceGradient,
              borderRadius: BorderRadius.circular(isMobile ? 24 : 28),
              border: Border.all(color: surfaceTertiary, width: 1),
              boxShadow: [
                BoxShadow(
                  color: mseufMaroon.withOpacity(0.12),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced Icon
                Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        errorColor.withOpacity(0.1),
                        errorColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
                    border: Border.all(color: errorColor.withOpacity(0.2), width: 1.5),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: errorColor,
                    size: isMobile ? 32 : 36,
                  ),
                ),
                
                SizedBox(height: isMobile ? 20 : 24),
                
                // MSEUF Branded Title
                Column(
                  children: [
                    Text(
                      'Sign Out of MSEUFCI Portal',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 22,
                        fontWeight: FontWeight.w800,
                        color: mseufMaroonDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: whiteGradient,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: isMobile ? 16 : 20),
                
                // Enhanced Message
                Text(
                  'Are you sure you want to sign out of your MSEUFCI account? You will need to log in again to access your dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                
                SizedBox(height: isMobile ? 24 : 28),
                
                // Enhanced Buttons
                if (isMobile) 
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<AuthService>().logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: errorColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                            shadowColor: errorColor.withOpacity(0.3),
                          ),
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: surfaceTertiary, width: 1.5),
                            ),
                            backgroundColor: surfaceSecondary,
                          ),
                          child: Text(
                            'Stay Logged In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else 
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: surfaceTertiary, width: 1.5),
                            ),
                            backgroundColor: surfaceSecondary,
                          ),
                          child: Text(
                            'Stay Logged In',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<AuthService>().logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: errorColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                            shadowColor: errorColor.withOpacity(0.3),
                          ),
                          child: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
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
}

// Device Type Enum
enum DeviceType {
  mobile,
  tablet,
  laptop,
  desktop,
}