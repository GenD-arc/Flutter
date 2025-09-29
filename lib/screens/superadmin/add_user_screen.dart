import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_service.dart';
import '../../utils/device_type.dart';

class AddUserScreen extends StatefulWidget {
  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> with TickerProviderStateMixin {
  // ==================== MSEUFCI OFFICIAL COLOR PALETTE ====================
 
  // Primary MSEUFCI Colors - "Maroon and White Forever"
  static const Color mseufMaroon = Color(0xFF8B0000); // Official MSEUFCI Maroon - primary brand color
  static const Color mseufMaroonDark = Color(0xFF4A1E1E); // Darker maroon for headers and emphasis
  static const Color mseufMaroonLight = Color(0xFFB71C1C); // Lighter maroon for highlights and accents
 
  // Official MSEUFCI White variations
  static const Color mseufWhite = Color(0xFFFFFFFF); // Pure white - secondary brand color
  static const Color mseufOffWhite = Color(0xFFFAFAFA); // Subtle off-white for backgrounds
  static const Color mseufCream = Color(0xFFF8F6F4); // Warm cream for elegant backgrounds
 
  // Neutral Foundation Colors (60% of design)
  static const Color backgroundPrimary = Color(0xFFFAFAFA); // Clean white background
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Slightly off-white
  static const Color surfacePrimary = Color(0xFFFFFBFF); // Pure white for cards and panels
  static const Color surfaceSecondary = Color(0xFFFBFBFB); // Very subtle off-white for secondary surfaces
  static const Color surfaceTertiary = Color(0xFFF0F0F0); // Light gray for dividers and borders
 
  // Text and Content Colors (using warmer tones to complement maroon)
  static const Color textSecondary = Color(0xFF404040); // Secondary text color
  static const Color textTertiary = Color(0xFF737373); // Light gray for tertiary text
 
  // On-Brand Colors (for text on colored backgrounds)
  static const Color onMaroon = Color(0xFFFFFFFF); // White text on maroon
 
  // Semantic Colors (adjusted to work well with maroon and white)
  static const Color successColor = Color(0xFF059669); // Green that complements maroon
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

  bool _isForward = true;

  // Responsive breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Layout constraints
  static const double maxTabletWidth = 600;
  static const double maxLaptopWidth = 1200;
  static const double maxDesktopWidth = 1600;

  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
 
  String _selectedRole = 'R01';
  String _selectedPrefix = 'STF';
  bool _obscurePassword = true;
  int _currentStep = 0;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  final Map<String, String> _rolePrefixes = {
    'STF': 'Staff',
    'ADV': 'Adviser',
    'ORG': 'Organization',
  };
  final Map<String, String> _adminPrefixes = {
    'ADM': 'Administrator',
    'SADM': 'Super Administrator',
  };
  final Map<String, String> _roles = {
    'R01': 'User',
    'R02': 'Admin',
    'R03': 'Super Admin',
  };

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
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _departmentController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Enhanced device type detection with layout classification
  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < desktopBreakpoint) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  // Layout classification for responsive behavior
  _LayoutType _getLayoutType(BuildContext context) {
    final deviceType = _getDeviceType(context);
   
    if (deviceType == DeviceType.mobile) return _LayoutType.mobile;
    if (deviceType == DeviceType.tablet) return _LayoutType.tablet;
    if (deviceType == DeviceType.laptop) return _LayoutType.laptop;
    return _LayoutType.desktop;
  }

  void _generateId() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final initials = name
          .split(' ')
          .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
          .join('');
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
     
      String prefix;
      if (_selectedRole == 'R02') {
        prefix = 'ADM';
      } else if (_selectedRole == 'R03') {
        prefix = 'SADM';
      } else {
        prefix = _selectedPrefix;
      }
     
      setState(() {
        _idController.text = '$prefix-$initials$timestamp';
      });
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _selectedPrefix.isNotEmpty &&
             _idController.text.trim().isNotEmpty &&
             _nameController.text.trim().isNotEmpty &&
             _departmentController.text.trim().isNotEmpty &&
             _selectedRole.isNotEmpty;
    } else if (_currentStep == 1) {
      return _usernameController.text.trim().isNotEmpty &&
             _emailController.text.trim().isNotEmpty &&
             RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text) &&
             _passwordController.text.isNotEmpty &&
             _passwordController.text.length >= 6;
    } else if (_currentStep == 2) {
      return true;
    }
    return false;
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _isForward = true;
        _currentStep++;
      });
      _slideController.forward();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildMSEUFSnackBar(
          message: 'Please fill in all required fields correctly',
          color: errorColor,
          icon: Icons.warning_rounded,
        ),
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _isForward = false;
        _currentStep--;
      });
      _slideController.forward();
    }
  }

  Future<void> _handleAddUser() async {
    if (_formKey.currentState!.validate()) {
      final userService = context.read<UserService>();
     
      final roleType = _rolePrefixes[_selectedPrefix] ?? _roles[_selectedRole]!;
     
      final success = await userService.addUser(
        id: _idController.text.trim(),
        name: _nameController.text.trim(),
        department: _departmentController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        roleId: _selectedRole,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildMSEUFSnackBar(
            message: 'User added successfully!',
            color: successColor,
            icon: Icons.check_circle_rounded,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          _buildMSEUFSnackBar(
            message: userService.errorMessage ?? 'Failed to add user',
            color: errorColor,
            icon: Icons.error_rounded,
          ),
        );
      }
    }
  }

  SnackBar _buildMSEUFSnackBar({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return SnackBar(
      content: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: onMaroon.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: onMaroon, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: onMaroon,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.all(16),
      elevation: 8,
      duration: Duration(seconds: 3),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layoutType = _getLayoutType(context);
   
    return Scaffold(
      backgroundColor: backgroundPrimary,
      appBar: _buildMSEUFAppBar(layoutType),
      body: Consumer<UserService>(
        builder: (context, userService, child) {
          return FadeTransition(
            opacity: _fadeController,
            child: _buildResponsiveLayout(layoutType, userService),
          );
        },
      ),
    );
  }

  // Enhanced responsive layout based on device type
  Widget _buildResponsiveLayout(_LayoutType layoutType, UserService userService) {
    switch (layoutType) {
      case _LayoutType.mobile:
        return _buildMobileLayout(userService);
      case _LayoutType.tablet:
        return _buildTabletLayout(userService);
      case _LayoutType.laptop:
        return _buildLaptopLayout(userService);
      case _LayoutType.desktop:
        return _buildDesktopLayout(userService);
    }
  }

  // Mobile Layout - Full width single column
  Widget _buildMobileLayout(UserService userService) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundPrimary, backgroundSecondary.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: _buildFormContainer(userService, _LayoutType.mobile),
      ),
    );
  }

  // Tablet Layout - Constrained width centered container
  Widget _buildTabletLayout(UserService userService) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundPrimary, backgroundSecondary.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxTabletWidth,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: _buildFormContainer(userService, _LayoutType.tablet),
          ),
        ),
      ),
    );
  }

  // Laptop Layout - Main content + Sidebar with proper constraints
  Widget _buildLaptopLayout(UserService userService) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundPrimary, backgroundSecondary.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxLaptopWidth,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Content Area (70%)
                Expanded(
                  flex: 7,
                  child: _buildFormContainer(userService, _LayoutType.laptop),
                ),
                SizedBox(width: 24),
                // Sidebar (30%) - Fixed width to prevent overflow
                Container(
                  width: 300, // Fixed width for sidebar
                  child: _buildSidebar(_LayoutType.laptop),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Desktop Layout - Multi-column form + Enhanced sidebar with proper constraints
  Widget _buildDesktopLayout(UserService userService) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundPrimary, backgroundSecondary.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxDesktopWidth,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Content Area
                Expanded(
                  flex: 8,
                  child: _buildFormContainer(userService, _LayoutType.desktop),
                ),
                SizedBox(width: 32),
                // Enhanced Sidebar - Fixed width
                Container(
                  width: 350, // Fixed width for desktop sidebar
                  child: _buildSidebar(_LayoutType.desktop),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Form Container - Consistent across all layouts with proper constraints
  Widget _buildFormContainer(UserService userService, _LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isTablet = layoutType == _LayoutType.tablet;
   
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: isMobile ? 0 : 400,
      ),
      child: Container(
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
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 24 : isTablet ? 28 : 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCombinedHeader(layoutType),
                SizedBox(height: isMobile ? 20 : 24),
                Flexible(
                  child: _currentStep == 0
                    ? _buildStep1(layoutType)
                    : _currentStep == 1
                      ? _buildStep2(layoutType)
                      : _buildStep3(layoutType),
                ),
                SizedBox(height: isMobile ? 28 : 32),
                _buildWizardActions(userService, layoutType),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Sidebar with contextual information and proper constraints
  Widget _buildSidebar(_LayoutType layoutType) {
    final isDesktop = layoutType == _LayoutType.desktop;
   
    return SingleChildScrollView(
      child: Column(
        children: [
          // Summary Card
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 200,
            ),
            decoration: BoxDecoration(
              gradient: surfaceGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: surfaceTertiary, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: mseufMaroon.withOpacity(0.06),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 24 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.summarize_rounded, color: mseufMaroon, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Quick Summary',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w700,
                          color: mseufMaroonDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildSummaryItem('User Type', _getDisplayType(), layoutType),
                  _buildSummaryItem('Role', _roles[_selectedRole] ?? '', layoutType),
                  if (_nameController.text.isNotEmpty)
                    _buildSummaryItem('Name', _nameController.text, layoutType),
                  if (_departmentController.text.isNotEmpty)
                    _buildSummaryItem('Department', _departmentController.text, layoutType),
                  if (_currentStep >= 1 && _usernameController.text.isNotEmpty)
                    _buildSummaryItem('Username', _usernameController.text, layoutType),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: successColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: successColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      'Step ${_currentStep + 1} of 3 completed',
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        color: successColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
         
          SizedBox(height: 16),
         
          // Guidance Card
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 180,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mseufMaroon.withOpacity(0.02), mseufMaroon.withOpacity(0.01)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: mseufMaroon.withOpacity(0.2), width: 1.5),
            ),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 24 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline_rounded, color: mseufMaroon, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Step Guidance',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w700,
                          color: mseufMaroonDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  ..._getStepGuidance().map((guidance) => Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: successColor, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            guidance,
                            style: TextStyle(
                              fontSize: isDesktop ? 13 : 12,
                              color: textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
         
          if (isDesktop) ...[
            SizedBox(height: 16),
            _buildAdditionalInfoCard(layoutType),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, _LayoutType layoutType) {
    final isDesktop = layoutType == _LayoutType.desktop;
   
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: textTertiary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 13,
              fontWeight: FontWeight.w700,
              color: mseufMaroonDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<String> _getStepGuidance() {
    switch (_currentStep) {
      case 0:
        return [
          'Select appropriate user type',
          'Fill in basic personal information',
          'Choose the correct role for access levels',
          'User ID will be auto-generated'
        ];
      case 1:
        return [
          'Choose a unique username',
          'Provide a valid email address',
          'Create a strong password (6+ characters)',
          'Credentials will be used for login'
        ];
      case 2:
        return [
          'Review all information carefully',
          'Verify user type and role',
          'Check contact information',
          'Confirm before creating user'
        ];
      default:
        return [];
    }
  }

  Widget _buildAdditionalInfoCard(_LayoutType layoutType) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [infoColor.withOpacity(0.03), infoColor.withOpacity(0.01)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: infoColor.withOpacity(0.2), width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security_rounded, color: infoColor, size: 20),
                SizedBox(width: 8),
                Text(
                  'Access Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: infoColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'User roles determine system access levels. Super Admins have full system control, Admins can manage users, and regular users have limited access based on their type.',
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for dynamic step content
  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Account Details';
      case 2:
        return 'Review & Confirm';
      default:
        return 'User Registration';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Enter user\'s basic details and role';
      case 1:
        return 'Set up login credentials';
      case 2:
        return 'Verify all information before creating the user';
      default:
        return 'Follow the guided steps to create a new user account';
    }
  }

  // Ultra-compact Combined Header - No scrolling needed
  Widget _buildCombinedHeader(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
 
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: mseufMaroon,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Step indicator on left
          Container(
            width: isMobile ? 36 : 40,
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(
              color: onMaroon,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${_currentStep + 1}',
                style: TextStyle(
                  color: mseufMaroon,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
       
          SizedBox(width: isMobile ? 12 : 16),
       
          // Step info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStepTitle(),
                  style: TextStyle(
                    color: onMaroon,
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  _getStepSubtitle(),
                  style: TextStyle(
                    color: onMaroon.withOpacity(0.9),
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
       
          SizedBox(width: isMobile ? 8 : 12),
       
          // Progress dots
          Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: 6),
            decoration: BoxDecoration(
              color: onMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildProgressDot(0, layoutType),
                SizedBox(width: 4),
                _buildProgressDot(1, layoutType),
                SizedBox(width: 4),
                _buildProgressDot(2, layoutType),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Simple progress dots
  Widget _buildProgressDot(int stepIndex, _LayoutType layoutType) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;
 
    return Container(
      width: layoutType == _LayoutType.mobile ? 6 : 8,
      height: layoutType == _LayoutType.mobile ? 6 : 8,
      decoration: BoxDecoration(
        color: isCompleted || isActive ? onMaroon : onMaroon.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  // Step 1 with responsive multi-column layout for desktop - FIXED CONSTRAINTS
  Widget _buildStep1(_LayoutType layoutType) {
    final isDesktop = layoutType == _LayoutType.desktop;
   
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDesktop)
            Flexible(child: _buildDesktopStep1(layoutType))
          else
            Flexible(child: _buildMobileStep1(layoutType)),
        ],
      ),
    );
  }

  Widget _buildDesktopStep1(_LayoutType layoutType) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // First row: Type and ID
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMSEUFDropdown(
                value: _selectedPrefix,
                items: _getAvailablePrefixes().entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedRole == 'R01'
                                ? mseufMaroonDark
                                : textTertiary,
                              fontSize: 15,
                            ),
                          ),
                        ))
                    .toList(),
                label: _selectedRole == 'R01' ? 'Type' : 'Type (Auto-assigned)',
                icon: Icons.category_rounded,
                onChanged: _selectedRole == 'R01' ? (value) {
                  setState(() {
                    _selectedPrefix = value!;
                    _generateId();
                  });
                } : null,
                layoutType: layoutType,
                isEnabled: _selectedRole == 'R01',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildMSEUFFormField(
                controller: _idController,
                label: 'User ID',
                icon: Icons.badge_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an ID';
                  }
                  return null;
                },
                layoutType: layoutType,
                suffixIcon: Container(
                  margin: EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(Icons.refresh_rounded, color: mseufMaroon, size: 22),
                    onPressed: _generateId,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          ],
        ),
       
        SizedBox(height: 18),
       
        // Second row: Name and Department
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMSEUFFormField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_idController.text.isEmpty ||
                      _idController.text.startsWith('$_selectedPrefix-')) {
                    _generateId();
                  }
                },
                layoutType: layoutType,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildMSEUFFormField(
                controller: _departmentController,
                label: 'Department',
                icon: Icons.business_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a department';
                  }
                  return null;
                },
                layoutType: layoutType,
              ),
            ),
          ],
        ),
       
        SizedBox(height: 18),
       
        // Role dropdown (full width)
        _buildMSEUFRoleDropdown(layoutType),
      ],
    );
  }

  Widget _buildMobileStep1(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: _buildMSEUFDropdown(
                value: _selectedPrefix,
                items: _getAvailablePrefixes().entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(
                            entry.value,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedRole == 'R01'
                                ? mseufMaroonDark
                                : textTertiary,
                              fontSize: isMobile ? 14 : 15,
                            ),
                          ),
                        ))
                    .toList(),
                label: _selectedRole == 'R01' ? 'Type' : 'Type (Auto-assigned)',
                icon: Icons.category_rounded,
                onChanged: _selectedRole == 'R01' ? (value) {
                  setState(() {
                    _selectedPrefix = value!;
                    _generateId();
                  });
                } : null,
                layoutType: layoutType,
                isEnabled: _selectedRole == 'R01',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _buildMSEUFFormField(
                controller: _idController,
                label: 'User ID',
                icon: Icons.badge_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an ID';
                  }
                  return null;
                },
                layoutType: layoutType,
                suffixIcon: Container(
                  margin: EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Icon(Icons.refresh_rounded, color: mseufMaroon, size: isMobile ? 20 : 22),
                    onPressed: _generateId,
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
            ),
          ],
        ),
       
        SizedBox(height: isMobile ? 16 : 18),
       
        _buildMSEUFFormField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
          onChanged: (value) {
            if (_idController.text.isEmpty ||
                _idController.text.startsWith('$_selectedPrefix-')) {
              _generateId();
            }
          },
          layoutType: layoutType,
        ),
       
        SizedBox(height: isMobile ? 16 : 18),
       
        _buildMSEUFFormField(
          controller: _departmentController,
          label: 'Department',
          icon: Icons.business_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a department';
            }
            return null;
          },
          layoutType: layoutType,
        ),
       
        SizedBox(height: isMobile ? 16 : 18),
       
        _buildMSEUFRoleDropdown(layoutType),
      ],
    );
  }

  // Step 2 with responsive layout
  Widget _buildStep2(_LayoutType layoutType) {
    final isDesktop = layoutType == _LayoutType.desktop;
   
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDesktop)
          Flexible(child: _buildDesktopStep2(layoutType))
        else
          Flexible(child: _buildMobileStep2(layoutType)),
      ],
    );
  }

  Widget _buildDesktopStep2(_LayoutType layoutType) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildMSEUFFormField(
                controller: _usernameController,
                label: 'Username',
                icon: Icons.account_circle_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                layoutType: layoutType,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildMSEUFFormField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                layoutType: layoutType,
              ),
            ),
          ],
        ),
       
        SizedBox(height: 18),
       
        _buildMSEUFPasswordField(layoutType),
      ],
    );
  }

  Widget _buildMobileStep2(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMSEUFFormField(
          controller: _usernameController,
          label: 'Username',
          icon: Icons.account_circle_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a username';
            }
            return null;
          },
          layoutType: layoutType,
        ),
       
        SizedBox(height: isMobile ? 16 : 18),
       
        _buildMSEUFFormField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          layoutType: layoutType,
        ),
       
        SizedBox(height: isMobile ? 16 : 18),
       
        _buildMSEUFPasswordField(layoutType),
      ],
    );
  }

  // Step 3 remains largely the same but with enhanced typography for larger screens
  Widget _buildStep3(_LayoutType layoutType) {
    final isDesktop = layoutType == _LayoutType.desktop;
   
    return SingleChildScrollView(
     child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDesktop)
          Flexible(child: _buildDesktopStep3(layoutType))
        else
          Flexible(child: _buildMobileStep3(layoutType)),
      ],
    ),
    );
  }

  Widget _buildDesktopStep3(_LayoutType layoutType) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 400,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildReviewSection(
              'Basic Information',
              Icons.person_rounded,
              [
                _buildReviewItem('User Type:', _getDisplayType(), layoutType),
                _buildReviewItem('User ID:', _idController.text, layoutType),
                _buildReviewItem('Full Name:', _nameController.text, layoutType),
                _buildReviewItem('Department:', _departmentController.text, layoutType),
                _buildReviewItem('Role:', _roles[_selectedRole] ?? '', layoutType,
                  valueColor: _getRoleColor(_selectedRole)),
              ],
              layoutType,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildReviewSection(
              'Account Details',
              Icons.account_circle_rounded,
              [
                _buildReviewItem('Username:', _usernameController.text, layoutType),
                _buildReviewItem('Email Address:', _emailController.text, layoutType),
                _buildReviewItem('Password:', _passwordController.text, layoutType,
                  isPassword: true),
              ],
              layoutType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileStep3(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildReviewSection(
          'Basic Information',
          Icons.person_rounded,
          [
            _buildReviewItem('User Type:', _getDisplayType(), layoutType),
            _buildReviewItem('User ID:', _idController.text, layoutType),
            _buildReviewItem('Full Name:', _nameController.text, layoutType),
            _buildReviewItem('Department:', _departmentController.text, layoutType),
            _buildReviewItem('Role:', _roles[_selectedRole] ?? '', layoutType,
              valueColor: _getRoleColor(_selectedRole)),
          ],
          layoutType,
        ),
       
        SizedBox(height: isMobile ? 16 : 20),
       
        _buildReviewSection(
          'Account Details',
          Icons.account_circle_rounded,
          [
            _buildReviewItem('Username:', _usernameController.text, layoutType),
            _buildReviewItem('Email Address:', _emailController.text, layoutType),
            _buildReviewItem('Password:', _passwordController.text, layoutType,
              isPassword: true),
          ],
          layoutType,
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, IconData icon, List<Widget> children, _LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [mseufMaroon.withOpacity(0.02), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mseufMaroon.withOpacity(0.15), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      mseufMaroon.withOpacity(0.15),
                      mseufMaroon.withOpacity(0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: mseufMaroon,
                  size: isMobile ? 20 : 22,
                ),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: mseufMaroonDark,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value, _LayoutType layoutType, {
    bool isPassword = false,
    Color? valueColor,
  }) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return Padding(
      padding: EdgeInsets.only(bottom: isMobile ? 12 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isMobile ? 100 : 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w600,
                color: textTertiary,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPassword
                    ? errorColor.withOpacity(0.3)
                    : surfaceTertiary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value.isEmpty ? 'Not set' : value,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: value.isEmpty
                          ? errorColor
                          : valueColor ?? mseufMaroonDark,
                        fontFamily: isPassword ? 'monospace' : null,
                      ),
                    ),
                  ),
                  if (isPassword) ...[
                    SizedBox(width: 8),
                    Icon(
                      Icons.visibility_rounded,
                      color: errorColor.withOpacity(0.7),
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Wizard Action Buttons - Updated for 3 steps
  Widget _buildWizardActions(UserService userService, _LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isTablet = layoutType == _LayoutType.tablet;
   
    return Row(
      children: [
        // Previous/Cancel Button
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: mseufMaroon.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: mseufMaroon.withOpacity(0.08),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextButton(
              onPressed: userService.isLoading
                ? null
                : _currentStep == 0
                  ? () => Navigator.pop(context)
                  : _previousStep,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : isTablet ? 18 : 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: surfaceSecondary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_currentStep > 0) ...[
                    Icon(
                      Icons.arrow_back_rounded,
                      color: mseufMaroon,
                      size: isMobile ? 18 : 20,
                    ),
                    SizedBox(width: 8),
                  ],
                  Text(
                    _currentStep == 0 ? 'Cancel' : 'Previous',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w700,
                      color: mseufMaroon,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
       
        SizedBox(width: 16),
       
        // Next/Submit Button
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color.fromARGB(255, 113, 29, 29), mseufMaroon, mseufMaroonLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: mseufMaroon.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: userService.isLoading
                ? null
                : _currentStep == 2
                  ? _handleAddUser
                  : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: onMaroon,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : isTablet ? 18 : 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: userService.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(onMaroon),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _currentStep == 2
                            ? Icons.person_add_rounded
                            : Icons.arrow_forward_rounded,
                          color: onMaroon,
                          size: isMobile ? 18 : 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          _currentStep == 2 ? 'Create User' : 'Next Step',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // MSEUF-styled AppBar with Enhanced Design - Updated for 3 steps
  PreferredSizeWidget _buildMSEUFAppBar(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isTablet = layoutType == _LayoutType.tablet;
   
    return PreferredSize(
      preferredSize: Size.fromHeight(isMobile ? 75 : 90),
      child: Container(
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
                    icon: Icon(Icons.arrow_back_rounded, color: mseufMaroonDark, size: isMobile ? 22 : 24),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.all(8),
                  ),
                ),
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
                      width: isMobile ? 32 : isTablet ? 36 : 40,
                      height: isMobile ? 32 : isTablet ? 36 : 40,
                    ),
                  ),
                ),
               
                SizedBox(width: 16),
               
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add New User',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                          fontWeight: FontWeight.w800,
                          color: mseufMaroonDark,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isMobile) ...[
                        SizedBox(height: 4),
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
                              'Step ${_currentStep + 1} of 3',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textTertiary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MSEUF Form Field
  Widget _buildMSEUFFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    required _LayoutType layoutType,
    Widget? suffixIcon,
  }) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mseufMaroon.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: mseufMaroonDark,
          fontSize: isMobile ? 14 : 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textTertiary,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: 12, left: 12, top: 12, bottom: 12),
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.15),
                  mseufMaroon.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: mseufMaroon,
              size: isMobile ? 18 : 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 16 : 18,
          ),
        ),
      ),
    );
  }

  // MSEUF Password Field
  Widget _buildMSEUFPasswordField(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mseufMaroon.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: mseufMaroonDark,
          fontSize: isMobile ? 14 : 15,
        ),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(
            color: textTertiary,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: 12, left: 12, top: 12, bottom: 12),
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.15),
                  mseufMaroon.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.lock_rounded,
              color: mseufMaroon,
              size: isMobile ? 18 : 20,
            ),
          ),
          suffixIcon: Container(
            margin: EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                color: mseufMaroon,
                size: isMobile ? 20 : 22,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              padding: EdgeInsets.all(8),
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 16 : 18,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  // MSEUF Role Dropdown - Updated for proper prefix management
  Widget _buildMSEUFRoleDropdown(_LayoutType layoutType) {
    return _buildMSEUFDropdown(
      value: _selectedRole,
      items: _roles.entries
          .map((entry) => DropdownMenuItem(
                value: entry.key,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getRoleColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: mseufMaroonDark,
                          fontSize: layoutType == _LayoutType.mobile ? 14 : 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
      label: 'Role',
      icon: Icons.admin_panel_settings_rounded,
      onChanged: (value) {
        setState(() {
          _selectedRole = value!;
          // Reset prefix based on role selection
          if (value == 'R02') { // Admin
            _selectedPrefix = 'ADM';
          } else if (value == 'R03') { // Super Admin
            _selectedPrefix = 'SADM';
          } else { // Regular User
            _selectedPrefix = 'STF'; // Default to Staff
          }
          _generateId();
        });
      },
      layoutType: layoutType,
    );
  }

  // MSEUF Dropdown Widget
  Widget _buildMSEUFDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required String label,
    required IconData icon,
    required void Function(String?)? onChanged,
    required _LayoutType layoutType,
    bool isEnabled = true,
  }) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: isEnabled ? surfaceGradient : LinearGradient(
          colors: [surfaceTertiary.withOpacity(0.5), surfaceTertiary.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled
            ? mseufMaroon.withOpacity(0.2)
            : surfaceTertiary.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ] : [],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: isEnabled ? onChanged : null,
        isExpanded: true,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isEnabled ? mseufMaroonDark : textTertiary.withOpacity(0.6),
          fontSize: isMobile ? 14 : 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isEnabled ? textTertiary : textTertiary.withOpacity(0.5),
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: 12, left: 12, top: 12, bottom: 12),
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isEnabled ? [
                  mseufMaroon.withOpacity(0.15),
                  mseufMaroon.withOpacity(0.08),
                ] : [
                  textTertiary.withOpacity(0.1),
                  textTertiary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isEnabled ? mseufMaroon : textTertiary.withOpacity(0.5),
              size: isMobile ? 18 : 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 16 : 18,
          ),
        ),
        dropdownColor: surfacePrimary,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: isEnabled ? mseufMaroon : textTertiary.withOpacity(0.5),
          size: isMobile ? 24 : 26,
        ),
      ),
    );
  }

  // Role Color Utility
  Color _getRoleColor(String roleId) {
    switch (roleId) {
      case 'R01':
        return successColor;
      case 'R02':
        return infoColor;
      case 'R03':
        return errorColor;
      default:
        return textTertiary;
    }
  }

  // Get display type based on role
  String _getDisplayType() {
    if (_selectedRole == 'R02') {
      return 'Administrator';
    } else if (_selectedRole == 'R03') {
      return 'Super Administrator';
    } else {
      return _rolePrefixes[_selectedPrefix] ?? '';
    }
  }

  // Get available prefixes based on current role
  Map<String, String> _getAvailablePrefixes() {
    if (_selectedRole == 'R02') {
      return {'ADM': 'Administrator'};
    } else if (_selectedRole == 'R03') {
      return {'SADM': 'Super Administrator'};
    } else {
      return _rolePrefixes;
    }
  }
}

// Enhanced layout type classification
enum _LayoutType {
  mobile, // < 768px
  tablet, // 768px - 1024px
  laptop, // 1024px - 1440px
  desktop, // > 1440px
}