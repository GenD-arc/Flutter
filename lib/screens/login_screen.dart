import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/screens/dashboard_screen.dart';
import 'package:testing/services/resource_service.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
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
  static const Color surfacePrimary = Color(0xFFFFFBFF); // Pure white for cards and panels
  static const Color surfaceSecondary = Color(0xFFFBFBFB); // Very subtle off-white for secondary surfaces
  static const Color surfaceTertiary = Color(0xFFF0F0F0); // Light gray for dividers and borders
  
  // Text and Content Colors (using warmer tones to complement maroon)
  static const Color textPrimary = Color(0xFF1F1F1F); // Near black for primary text
  static const Color textSecondary = Color(0xFF4A4A4A); // Medium gray for secondary text
  static const Color textTertiary = Color(0xFF737373); // Light gray for tertiary text
  static const Color textDisabled = Color(0xFFA3A3A3); // Very light gray for disabled elements
  
  // On-Brand Colors (for text on colored backgrounds)
  static const Color onMaroon = Color(0xFFFFFFFF); // White text on maroon
  static const Color onWhite = Color(0xFF1F1F1F); // Dark text on white
  static const Color onSurface = Color(0xFF1F1F1F); // Dark text on light surfaces
  
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

  // Responsive breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _logoAnimation;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );
    _logoController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Safe animation start with mounted check
    _startAnimations();
  }

  void _startAnimations() {
    if (!mounted) return;
    
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted && !_isDisposed) {
        _logoController.forward();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    // Stop all animations first
    _fadeController.stop();
    _slideController.stop();
    _pulseController.stop();
    _logoController.stop();
    
    // Then dispose them
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _logoController.dispose();
    
    // Dispose text controllers
    _identifierController.dispose();
    _passwordController.dispose();
    
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

  void _showEnhancedErrorDialog(String message) {
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: mseufMaroon.withOpacity(0.2),
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 24 : 28)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 24 : 28),
            decoration: BoxDecoration(
              gradient: surfaceGradient,
              borderRadius: BorderRadius.circular(isMobile ? 24 : 28),
              border: Border.all(color: errorColor.withOpacity(0.2), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: errorColor.withOpacity(0.15),
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
                    border: Border.all(
                      color: errorColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: errorColor,
                    size: isMobile ? 32 : 36,
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 24),
                Text(
                  'Authentication Failed',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 22,
                    fontWeight: FontWeight.w800,
                    color: mseufMaroonDark,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: mseufCream.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: mseufMaroon.withOpacity(0.2), width: 1),
                  ),
                  child: Text(
                    'Please verify your MSEUFCI credentials and try again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor,
                      foregroundColor: onMaroon,
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: errorColor.withOpacity(0.3),
                    ),
                    child: Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this to your LoginScreen's login button onPressed handler

Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  final authService = context.read<AuthService>();
  final resourceService = context.read<ResourceService>(); // Add this line
  
  // Call the login method
  final success = await authService.login(
    _identifierController.text.trim(),
    _passwordController.text,
  );

  if (!mounted) return;

  if (success) {
    // ✅ ADD THIS: Set the token in ResourceService after successful login
    if (authService.token != null) {
      resourceService.setToken(authService.token!);
      print('✅ Token set in ResourceService');
    }
    
    // Navigate to dashboard and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
      (route) => false,
    );
  } else {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(authService.errorMessage ?? 'Login failed'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final screenSize = MediaQuery.of(context).size;
    final isLandscape = screenSize.width > screenSize.height;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(255, 113, 29, 29),
              mseufMaroon,
              mseufMaroonLight,
              mseufMaroon.withOpacity(0.9),
              mseufMaroonDark,
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Enhanced Background Elements with MSEUF branding
            ...List.generate(8, (index) {
              return Positioned(
                top: (index * 120.0) - 60 + (isLandscape ? -40 : 0),
                right: (index.isEven ? -120 : null),
                left: (index.isOdd ? -120 : null),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value * (0.6 + (index * 0.08)),
                      child: Container(
                        width: 180 + (index * 30.0),
                        height: 180 + (index * 30.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              mseufWhite.withOpacity(0.02 + (index * 0.005)),
                              mseufCream.withOpacity(0.015 + (index * 0.003)),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: mseufWhite.withOpacity(0.03),
                            width: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            
            // Floating University Elements
            Positioned(
              top: screenSize.height * 0.15,
              right: 40,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _pulseAnimation.value * 0.1,
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            mseufWhite.withOpacity(0.08),
                            mseufCream.withOpacity(0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: mseufWhite.withOpacity(0.1), width: 1),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: mseufWhite.withOpacity(0.4),
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            Positioned(
              bottom: screenSize.height * 0.2,
              left: 30,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_pulseAnimation.value * 0.08,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            mseufWhite.withOpacity(0.06),
                            mseufCream.withOpacity(0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: mseufWhite.withOpacity(0.08), width: 1),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: mseufWhite.withOpacity(0.3),
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Main Content
            SafeArea(
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(deviceType),
                    vertical: isLandscape ? 16.0 : max(32.0, MediaQuery.of(context).viewInsets.bottom + 16.0),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: _getMaxCardWidth(deviceType)),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildLoginCard(deviceType),
                      ),
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

  Widget _buildLoginCard(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    return Container(
      decoration: BoxDecoration(
        color: surfacePrimary,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(_getCardPadding(deviceType)),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEnhancedLogo(deviceType),
              SizedBox(height: isMobile ? 16 : isTablet ? 16 : 16),
              _buildEnhancedWelcomeSection(deviceType),
              SizedBox(height: isMobile ? 28 : isTablet ? 28 : 28),
              _buildEnhancedFormFields(deviceType),
              SizedBox(height: isMobile ? 24 : isTablet ? 24 : 24),
              _buildEnhancedLoginButton(deviceType),
              SizedBox(height: isMobile ? 16 : 16),
              _buildMSEUFFooter(deviceType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedLogo(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    return AnimatedBuilder(
      animation: _logoAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoAnimation.value,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.08),
                  mseufMaroon.withOpacity(0.04),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: mseufMaroon.withOpacity(0.15),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: mseufMaroon.withOpacity(0.1),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: maroonGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: mseufMaroon.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    size: 32,
                    color: onMaroon,
                  ),
                ),
                if (!isMobile) ...[
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MSEUFCI',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 20,
                          fontWeight: FontWeight.w900,
                          color: mseufMaroonDark,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: mseufAccentGradient,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedWelcomeSection(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    return Column(
      children: [
        // University Branding Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                mseufMaroon.withOpacity(0.1),
                mseufMaroon.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: mseufMaroon.withOpacity(0.2), width: 1.5),
          ),
          child: Text(
            'MSEUF CANDELARIA INC.',
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w800,
              color: mseufMaroon,
              letterSpacing: 1.5,
            ),
          ),
        ),
        
        SizedBox(height: isMobile ? 16 : 20),
        
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: isMobile ? 28 : isTablet ? 32 : 36,
            fontWeight: FontWeight.w900,
            color: mseufMaroonDark,
            letterSpacing: 0.5,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: 12),
        
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: whiteGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: surfaceTertiary, width: 1),
            boxShadow: [
              BoxShadow(
                color: mseufCream.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'University Resource Management Portal',
            style: TextStyle(
              fontSize: isMobile ? 13 : isTablet ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: textSecondary,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
      ],
    );
  }

  Widget _buildEnhancedFormFields(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    return Column(
      children: [
        _buildPremiumTextField(
          controller: _identifierController,
          label: 'Username or Email',
          hint: 'Enter your MSEUFCI credentials',
          icon: Icons.person_rounded,
          deviceType: deviceType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your username or email';
            }
            return null;
          },
        ),
        
        SizedBox(height: isMobile ? 20 : isTablet ? 24 : 28),
        
        _buildPremiumTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Enter your secure password',
          icon: Icons.lock_rounded,
          isPassword: true,
          deviceType: deviceType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    required DeviceType deviceType,
    String? Function(String?)? validator,
  }) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.04),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: TextStyle(
          fontSize: isMobile ? 15 : isTablet ? 16 : 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.2,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
            color: textSecondary,
            fontSize: isMobile ? 14 : isTablet ? 15 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          hintStyle: TextStyle(
            color: textTertiary,
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(left: 4, right: 12),
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.08),
                  mseufMaroon.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: mseufMaroon.withOpacity(0.1), width: 1),
            ),
            child: Icon(
              icon,
              color: mseufMaroon,
              size: isMobile ? 20 : isTablet ? 22 : 24,
            ),
          ),
          suffixIcon: isPassword
              ? Container(
                  margin: EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            surfaceSecondary,
                            surfaceTertiary.withOpacity(0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: surfaceTertiary, width: 1),
                      ),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: textSecondary,
                        size: isMobile ? 16 : 18,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
            borderSide: BorderSide(
              color: surfaceTertiary,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
            borderSide: BorderSide(
              color: surfaceTertiary,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
            borderSide: BorderSide(
              color: mseufMaroon,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
            borderSide: BorderSide(
              color: errorColor,
              width: 2.0,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
            borderSide: BorderSide(
              color: errorColor,
              width: 2.5,
            ),
          ),
          filled: true,
          fillColor: backgroundPrimary,
          contentPadding: EdgeInsets.symmetric(
            vertical: isMobile ? 18 : isTablet ? 20 : 22,
            horizontal: 16,
          ),
          errorStyle: TextStyle(
            color: errorColor,
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildEnhancedLoginButton(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;
    
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Container(
          width: double.infinity,
          height: isMobile ? 56 : isTablet ? 60 : 64,
          decoration: BoxDecoration(
            gradient: authService.isLoading 
              ? LinearGradient(
                  colors: [textDisabled, textTertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : maroonGradient,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
            boxShadow: authService.isLoading ? null : [
              BoxShadow(
                color: mseufMaroon.withOpacity(0.3),
                blurRadius: 16,
                offset: Offset(0, 6),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: mseufMaroonDark.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: authService.isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: onMaroon,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMobile ? 16 : 18),
              ),
              elevation: 0,
              splashFactory: InkRipple.splashFactory,
            ),
            child: authService.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: isMobile ? 20 : 24,
                        height: isMobile ? 20 : 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(onMaroon),
                          strokeWidth: 2.5,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Authenticating...',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : isTablet ? 17 : 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: onMaroon.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.login_rounded,
                          size: isMobile ? 18 : isTablet ? 20 : 22,
                          color: onMaroon,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Sign In to MSEUFCI',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : isTablet ? 17 : 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMSEUFFooter(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundSecondary.withOpacity(0.3),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceTertiary.withOpacity(0.5), width: 1),
      ),
      child: Column(
        children: [
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Manuel S. Enverga University Foundation',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  color: textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.08),
                  mseufMaroon.withOpacity(0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: mseufMaroon.withOpacity(0.15), width: 1),
            ),
            child: Text(
              'Candelaria Campus © ${DateTime.now().year}',
              style: TextStyle(
                fontSize: isMobile ? 9 : 10,
                color: textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for responsive design
  double _getHorizontalPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 20.0;
      case DeviceType.tablet:
        return 40.0;
      case DeviceType.laptop:
        return 60.0;
      case DeviceType.desktop:
        return 80.0;
    }
  }

  double _getMaxCardWidth(DeviceType deviceType) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth * 0.8;
      case DeviceType.tablet:
        return screenWidth * 0.6;
      case DeviceType.laptop:
        return screenWidth * 0.35;
      case DeviceType.desktop:
        return screenWidth * 0.35;
    }
  }

  double _getCardPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.tablet:
        return 20.0;
      case DeviceType.laptop:
        return 24.0;
      case DeviceType.desktop:
        return 24.0;
    }
  }
}

// Device Type Enum (matching DashboardScreen)
enum DeviceType {
  mobile,
  tablet,
  laptop,
  desktop,
}