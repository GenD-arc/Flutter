import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/screens/admin_dashboard_resources.dart';
import 'package:testing/screens/my_reservations_screen.dart';
import 'package:testing/screens/reservation_approval_screen.dart';
import 'package:testing/screens/approval_logs_screen.dart' hide DeviceType;
import 'package:testing/screens/view_resources_screen.dart';
import 'package:testing/screens/view_resources_screen_for_user.dart';
import 'package:testing/screens/public_calendar_screen.dart'  hide DeviceType;
import 'package:testing/screens/widgets/dashboard_overview_widgets.dart';
import 'package:testing/services/resource_service.dart';
import '../services/auth_service.dart';
import 'superadmin/view_users_screen.dart';
import 'widgets/dashboard_widgets.dart';
import '/services/today_status_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  bool _hasLoadedResources = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 720),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 540),
      vsync: this,
    );
    _fadeController.forward();
    _slideController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _propagateTokenToServices();
      // Initialize today status auto-refresh
      final statusService = context.read<TodayStatusService>();
      statusService.fetchTodayStatus();
      statusService.startAutoRefresh();
    });
  }

  void _propagateTokenToServices() {
    final authService = context.read<AuthService>();
    final resourceService = context.read<ResourceService>();
    
    if (authService.isAuthenticated && authService.token != null) {
      resourceService.setToken(authService.token!);
      
      if ((authService.roleId == 'R02' || authService.roleId == 'R03') && !_hasLoadedResources) {
        _loadAdminResources();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final deviceType = DashboardWidgets.getDeviceType(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DashboardColors.backgroundPrimary,
      body: Row(
        children: [
          if (deviceType == DeviceType.laptop || deviceType == DeviceType.desktop)
            DashboardWidgets.buildDesktopSidebar(
              context,
              authService, 
              deviceType, 
              _selectedIndex, 
              _handleNavigation,
            ),
          
          Expanded(
            child: Column(
              children: [
                DashboardWidgets.buildModernTopBar(
                  context,
                  authService, 
                  deviceType, 
                  _selectedIndex,
                  _scaffoldKey,
                ),
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
      bottomNavigationBar: (deviceType == DeviceType.mobile || deviceType == DeviceType.tablet)
          ? _buildBottomNavigationBar(authService, deviceType)
          : null,
    );
  }

  Widget _buildDailyActivitiesWidget(bool isMobile) {
    return Consumer<TodayStatusService>(
      builder: (context, statusService, _) {
        // Detect device type with proper breakpoints
        final screenWidth = MediaQuery.of(context).size.width;
        final isDesktop = screenWidth >= 1200;
        final isLaptop = screenWidth >= 900 && screenWidth < 1200;
        final isTablet = screenWidth >= 600 && screenWidth < 900;
        
        // Responsive heights
        final containerHeight = isMobile 
            ? 300.0 
            : (isTablet ? 350.0 : (isLaptop ? 380.0 : 400.0));
        
        // Responsive sizes
        final headerPadding = isMobile 
            ? 14.0 
            : (isTablet ? 16.0 : (isLaptop ? 13.0 : 14.0));
        
        final iconSize = isMobile 
            ? 18.0 
            : (isTablet ? 20.0 : (isLaptop ? 17.0 : 18.0));
        
        final headerFontSize = isMobile 
            ? 14.0 
            : (isTablet ? 16.0 : (isLaptop ? 14.0 : 15.0));
        
        final loadingSize = isMobile 
            ? 28.0 
            : (isTablet ? 28.0 : (isLaptop ? 26.0 : 28.0));
        
        final loadingTextSize = isMobile 
            ? 14.0 
            : (isTablet ? 14.0 : (isLaptop ? 13.0 : 13.0));
        
        // Handle loading state
        if (statusService.isLoading && statusService.todayStatus == null) {
          return Container(
            height: containerHeight,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE5E7EB), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: loadingSize,
                    height: loadingSize,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B0000)),
                      strokeWidth: 2.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Loading activities...',
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontSize: loadingTextSize,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle error state
        if (statusService.errorMessage != null && statusService.todayStatus == null) {
          return Container(
            height: containerHeight,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE5E7EB), width: 1),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline, 
                      color: Color(0xFFDC2626), 
                      size: isLaptop || isDesktop ? 28 : 32
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Could not load activities',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: isLaptop ? 13 : (isDesktop ? 13 : 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      statusService.errorMessage ?? 'Unknown error',
                      style: TextStyle(
                        color: Color(0xFFDC2626).withOpacity(0.8),
                        fontSize: isLaptop ? 11 : (isDesktop ? 12 : 12),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final status = statusService.todayStatus;
        
        // Handle empty state
        if (status == null) {
          return Container(
            height: containerHeight,
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE5E7EB), width: 1),
            ),
            child: Center(
              child: Text(
                'No activities data available',
                style: TextStyle(
                  color: Color(0xFF737373), 
                  fontSize: isLaptop ? 12 : (isDesktop ? 13 : 14)
                ),
              ),
            ),
          );
        }

        // Build the actual activities section
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(headerPadding),
                decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        const Color.fromARGB(255, 113, 29, 29),
        Color(0xFF8B0000),
        Color(0xFFB71C1C),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: [0.0, 0.5, 1.0],
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
  ),
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      color: Colors.white,
                      size: iconSize,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Today\'s Activities',
                        style: TextStyle(
                          fontSize: headerFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Color(0xFFE5E7EB)),
              
              // Content
              if (status.dailyNews.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No approved activities today',
                      style: TextStyle(
                        color: Color(0xFF737373), 
                        fontSize: isLaptop ? 11 : (isDesktop ? 12 : 12)
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: containerHeight,
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: false,
                    itemCount: status.dailyNews.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Color(0xFFE5E7EB)),
                    itemBuilder: (context, index) {
                      final activity = status.dailyNews[index];
                      return ActivityItemStateful(
                        activity: activity,
                        isMobile: isMobile,
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(AuthService authService, DeviceType deviceType) {
    return DashboardWidgets.buildResponsiveBottomNavBar(
      context,
      authService,
      deviceType,
      _selectedIndex,
      _handleNavigation,
    );
  }

  Widget _buildMainContent(AuthService authService) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.09),
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
      return _buildAuthenticationRequiredWidget();
    }

    switch (_selectedIndex) {
      case 0: return _buildEnhancedDashboardContent(authService);
      case 1: return _buildAppointmentManagerContent();
      case 2: return _buildManageUsersContent();
      case 3: return _buildManageResourcesContent();
      case 5: return _buildPublicCalendarContent();
      case 6: return _buildMyReservationsScreen(authService);
      case 7: return _buildApprovalLogsContent(authService);
      case 8: return _buildManageResourcesContentForUser();
      default: return _buildEnhancedDashboardContent(authService);
    }
  }

  // ============================================================
  // MAIN DASHBOARD CONTENT - REORGANIZED LAYOUT
  // ============================================================

  Widget _buildEnhancedDashboardContent(AuthService authService) {
    final deviceType = DashboardWidgets.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    final isLaptop = deviceType == DeviceType.laptop;
    final isDesktop = deviceType == DeviceType.desktop;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Welcome Banner (Always at top)
          Container(
            padding: EdgeInsets.all(isMobile ? 14.4 : isTablet ? 18 : 21.6),
            child: DashboardWidgets.buildMSEUFWelcomeBanner(authService, deviceType),
          ),
          
          SizedBox(height: isMobile ? 16 : 24),
          
          // Conditional Layout: Vertical for Mobile/Tablet, Horizontal for Laptop/Desktop
          if (isMobile || isTablet)
            // ============ MOBILE & TABLET: VERTICAL STACK ============
            _buildVerticalLayout(authService, isMobile, isTablet)
          else
            // ============ LAPTOP & DESKTOP: HORIZONTAL LAYOUT ============
            _buildHorizontalLayout(authService, isLaptop, isDesktop),
          
          SizedBox(height: isMobile ? 16 : 24),
        ],
      ),
    );
  }

  // ============ VERTICAL LAYOUT (Mobile & Tablet) ============
  Widget _buildVerticalLayout(AuthService authService, bool isMobile, bool isTablet) {
    return Column(
      children: [
        // 1. Available Resources Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResourcesHeader(authService, isMobile, isTablet),
              const SizedBox(height: 16),
              SizedBox(
                height: 500,
                child: _buildDashboardResourcesSection(authService),
              ),
            ],
          ),
        ),
        
        SizedBox(height: isMobile ? 16 : 24),
        
        // 2. Today's Approved Activities Section
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
          child: _buildDailyActivitiesWidget(isMobile),
        ),
        
        SizedBox(height: isMobile ? 16 : 24),
        
        // 3. Resource Availability Status Cards (At bottom) with consistent sizing
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24),
          child: DashboardOverviewSection(
            isMobile: isMobile,
            isTablet: isTablet,
          ),
        ),
      ],
    );
  }

  // ============ HORIZONTAL LAYOUT (Laptop & Desktop) ============
  Widget _buildHorizontalLayout(AuthService authService, bool isLaptop, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Available Resources (65% width)
          Expanded(
            flex: 65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResourcesHeader(authService, false, false),
                const SizedBox(height: 16),
                SizedBox(
                  height: isLaptop ? 550 : 600,
                  child: _buildDashboardResourcesSection(authService),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Right Side: Today's Activities + Status Cards (35% width)
          Expanded(
            flex: 35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resource Availability Status Cards with consistent sizing
                DashboardOverviewSection(
                  isMobile: false,
                  isTablet: false,
                  isLaptop: isLaptop,
                  isDesktop: isDesktop,
                ),
                const SizedBox(height: 24),
                // Today's Approved Activities
                _buildDailyActivitiesWidget(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ UNIFORM RESOURCES HEADER ============
  Widget _buildResourcesHeader(AuthService authService, bool isMobile, bool isTablet) {
    final headerPadding = isMobile ? 14.0 : (isTablet ? 16.0 : 14.0);
    final iconSize = isMobile ? 18.0 : (isTablet ? 20.0 : 18.0);
    final headerFontSize = isMobile ? 14.0 : (isTablet ? 16.0 : 15.0);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(headerPadding),
      decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color.fromARGB(255, 113, 29, 29),
          Color(0xFF8B0000),
          Color(0xFFB71C1C),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
      child: Row(
        children: [
          Icon(
            Icons.assignment_rounded,
            color: Colors.white,
            size: iconSize,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              authService.roleId == 'R01' 
                ? 'Available Resources' 
                : 'My Assigned Resources',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: iconSize),
            onPressed: () {
              if (authService.roleId == 'R01') {
                context.read<ResourceService>().fetchResources(['Facility', 'Room', 'Vehicle']);
              } else {
                _loadAdminResources();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardResourcesSection(AuthService authService) {
    final resourceService = context.watch<ResourceService>();
    
    if (resourceService.isLoading && resourceService.resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(DashboardColors.mseufMaroon),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading resources...',
              style: TextStyle(
                color: DashboardColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (resourceService.errorMessage != null && resourceService.resources.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: DashboardColors.errorColor,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              resourceService.errorMessage!,
              style: TextStyle(
                color: DashboardColors.errorColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (authService.roleId == 'R01') {
                  resourceService.fetchResources(['Facility', 'Room', 'Vehicle']);
                } else {
                  _loadAdminResources();
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (authService.roleId == 'R01') {
      return ClipRect(
        child: ViewResourcesScreenForUser(),
      );
    } else if (authService.roleId == 'R02' || authService.roleId == 'R03') {
      return AdminDashboardResources();
    } else {
      return Center(
        child: Text(
          'No resources available for your role',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }
  }

  void _loadAdminResources() {
    final authService = context.read<AuthService>();
    final resourceService = context.read<ResourceService>();
    
    if (authService.currentUser != null && !resourceService.isLoading) {
      resourceService.fetchResourcesByApprover(authService.currentUser!.id).then((_) {
        if (mounted) {
          setState(() {
            _hasLoadedResources = true;
          });
        }
      });
    }
  }

  Widget _buildPublicCalendarContent() {
    return const PublicCalendarScreen();
  }

  Widget _buildMyReservationsScreen(AuthService authService) {
    return MyReservationsScreen(userId: authService.currentUser!.id);
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

  Widget _buildManageUsersContent() {
    return const ViewUsersScreen();
  }

  Widget _buildAppointmentManagerContent() {
    final authService = context.read<AuthService>();
    if (!authService.isAuthenticated || authService.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final authService = context.read<AuthService>();
        await authService.logout();
      });
      return const Center(child: Text('Redirecting to login...'));
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
    return const ViewResourcesScreen();
  }

  Widget _buildManageResourcesContentForUser() {
    return const ViewResourcesScreenForUser();
  }

  Widget _buildAccessDeniedWidget(String feature) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(25.2),
        decoration: BoxDecoration(
          gradient: DashboardColors.surfaceGradient,
          borderRadius: BorderRadius.circular(21.6),
          border: Border.all(color: DashboardColors.errorColor.withOpacity(0.3), width: 1.35),
          boxShadow: [
            BoxShadow(
              color: DashboardColors.errorColor.withOpacity(0.1),
              blurRadius: 14.4,
              offset: const Offset(0, 5.4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: DashboardColors.errorColor,
              size: 43.2,
            ),
            const SizedBox(height: 14.4),
            const Text(
              'Access Denied',
              style: TextStyle(
                fontSize: 16.2,
                color: DashboardColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7.2),
            Text(
              'You do not have permission to $feature.',
              style: const TextStyle(
                fontSize: 12.6,
                color: DashboardColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
                borderRadius: BorderRadius.circular(10.8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
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
                  child: const Text(
                    'Back to Dashboard',
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
      ),
    );
  }

  Widget _buildAuthenticationRequiredWidget() {
    final deviceType = DashboardWidgets.getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;

    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 18 : 21.6),
        decoration: BoxDecoration(
          gradient: DashboardColors.surfaceGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DashboardColors.errorColor.withOpacity(0.3), width: 1.35),
          boxShadow: [
            BoxShadow(
              color: DashboardColors.errorColor.withOpacity(0.1),
              blurRadius: 14.4,
              offset: const Offset(0, 5.4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.login_rounded,
              color: DashboardColors.errorColor,
              size: 43.2,
            ),
            const SizedBox(height: 14.4),
            const Text(
              'Authentication Required',
              style: TextStyle(
                fontSize: 16.2,
                color: DashboardColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7.2),
            const Text(
              'Please log in to access this feature.',
              style: TextStyle(
                fontSize: 12.6,
                color: DashboardColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final authService = context.read<AuthService>();
                  await authService.logout();
                },
                borderRadius: BorderRadius.circular(10.8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
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
                  child: const Text(
                    'Go to Login',
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
      ),
    );
  }

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
      _fadeController.reset();
      _slideController.reset();
      _fadeController.forward();
      _slideController.forward();
    });
  }
}