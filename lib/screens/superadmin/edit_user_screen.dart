import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../utils/device_type.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  // MSEUFCI Color Palette
  static const Color mseufMaroon = Color(0xFF8B0000);
  static const Color mseufMaroonDark = Color(0xFF4A1E1E);
  static const Color mseufMaroonLight = Color(0xFFB71C1C);
  static const Color mseufWhite = Color(0xFFFFFFFF);
  static const Color mseufOffWhite = Color(0xFFFAFAFA);
  static const Color mseufCream = Color(0xFFF8F6F4);
  static const Color backgroundPrimary = Color(0xFFFAFAFA);
  static const Color backgroundSecondary = Color(0xFFF5F5F5);
  static const Color surfacePrimary = Color(0xFFFFFBFF);
  static const Color surfaceSecondary = Color(0xFFFBFBFB);
  static const Color surfaceTertiary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFF404040);
  static const Color textTertiary = Color(0xFF737373);
  static const Color onMaroon = Color(0xFFFFFFFF);
  static const Color successColor = Color(0xFF059669);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color infoColor = Color(0xFF2563EB);

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

  // Responsive breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Layout constraints
  static const double maxTabletWidth = 600;
  static const double maxLaptopWidth = 1200;
  static const double maxDesktopWidth = 1600;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'R01';
  bool _isFullUpdate = true;

  final Map<String, String> _roles = {
    'R01': 'User',
    'R02': 'Admin',
    'R03': 'Super Admin',
  };

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _departmentController.text = widget.user.department;
    _usernameController.text = widget.user.username ?? '';
    _emailController.text = widget.user.email ?? '';
    _selectedRole = widget.user.roleId;
    _loadUserDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _hasChanges() {
    return _nameController.text != widget.user.name ||
           _departmentController.text != widget.user.department ||
           _usernameController.text != (widget.user.username ?? '') ||
           _emailController.text != (widget.user.email ?? '') ||
           _selectedRole != widget.user.roleId;
  }

  Future<void> _loadUserDetails() async {
    final userDetails = await context.read<UserService>().getUserById(widget.user.id);
    if (userDetails != null && mounted) {
      setState(() {
        _usernameController.text = userDetails.username ?? '';
        _emailController.text = userDetails.email ?? '';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildMSEUFSnackBar(
          message: 'No changes detected',
          color: infoColor,
          icon: Icons.info_rounded,
        ),
      );
      return;
    }

    final userService = Provider.of<UserService>(context, listen: false);

    final userData = _isFullUpdate
        ? {
            'name': _nameController.text,
            'department': _departmentController.text,
            'username': _usernameController.text,
            'email': _emailController.text,
            'role_id': _selectedRole,
            'role_type': _roles[_selectedRole]!,
          }
        : {
            if (_nameController.text != widget.user.name) 'name': _nameController.text,
            if (_departmentController.text != widget.user.department) 'department': _departmentController.text,
            if (_usernameController.text != (widget.user.username ?? '')) 'username': _usernameController.text,
            if (_emailController.text != (widget.user.email ?? '')) 'email': _emailController.text,
            if (_selectedRole != widget.user.roleId) 'role_id': _selectedRole,
            if (_selectedRole != widget.user.roleId) 'role_type': _roles[_selectedRole]!,
          };

    final success = await userService.updateUser(widget.user.id, userData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildMSEUFSnackBar(
          message: 'User updated successfully',
          color: successColor,
          icon: Icons.check_circle_rounded,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildMSEUFSnackBar(
          message: userService.errorMessage ?? 'Failed to update user',
          color: errorColor,
          icon: Icons.error_rounded,
        ),
      );
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
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.all(16),
      elevation: 8,
      duration: Duration(seconds: 3),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < desktopBreakpoint) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  _LayoutType _getLayoutType(BuildContext context) {
    final deviceType = _getDeviceType(context);
    if (deviceType == DeviceType.mobile) return _LayoutType.mobile;
    if (deviceType == DeviceType.tablet) return _LayoutType.tablet;
    if (deviceType == DeviceType.laptop) return _LayoutType.laptop;
    return _LayoutType.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final layoutType = _getLayoutType(context);
    return Scaffold(
      backgroundColor: backgroundPrimary,
      appBar: _buildMSEUFAppBar(layoutType),
      body: Consumer<UserService>(
        builder: (context, userService, child) {
          return _buildResponsiveLayout(layoutType, userService);
        },
      ),
    );
  }

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

  Widget _buildMobileLayout(UserService userService) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundPrimary, backgroundSecondary.withOpacity(0.3)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _buildFormContainer(userService, _LayoutType.mobile),
    );
  }

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
          constraints: BoxConstraints(maxWidth: maxTabletWidth),
          child: _buildFormContainer(userService, _LayoutType.tablet),
        ),
      ),
    );
  }

  Widget _buildLaptopLayout(UserService userService) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _buildFormContainer(userService, _LayoutType.laptop),
                ),
                SizedBox(width: 24),
                Container(
                  width: 300,
                  child: _buildSidebar(_LayoutType.laptop),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(UserService userService) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: _buildFormContainer(userService, _LayoutType.desktop),
                ),
                SizedBox(width: 32),
                Container(
                  width: 350,
                  child: _buildSidebar(_LayoutType.desktop),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer(UserService userService, _LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isTablet = layoutType == _LayoutType.tablet;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxFormWidth = layoutType == _LayoutType.desktop || layoutType == _LayoutType.laptop
        ? screenWidth * 0.6
        : maxTabletWidth;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxFormWidth,
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
          padding: EdgeInsets.all(isMobile ? 24 : isTablet ? 28 : screenWidth * 0.02),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildHeader(layoutType),
                    ),
                    SizedBox(width: isMobile ? 12 : 16),
                    Expanded(
                      flex: 2,
                      child: _buildUserIdCard(layoutType),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 20 : 24),
                _buildUpdateModeIndicator(layoutType),
                SizedBox(height: isMobile ? 20 : 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: layoutType == _LayoutType.desktop
                        ? _buildDesktopFormFields(layoutType)
                        : _buildMobileFormFields(layoutType),
                  ),
                ),
                SizedBox(height: isMobile ? 28 : 32),
                _buildActionButtons(userService.isLoading, layoutType),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopFormFields(_LayoutType layoutType) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldPadding = screenWidth * 0.01;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: fieldPadding),
                child: _buildMSEUFFormField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_rounded,
                  validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                  layoutType: layoutType,
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: fieldPadding),
                child: _buildMSEUFFormField(
                  controller: _departmentController,
                  label: 'Department',
                  icon: Icons.business_rounded,
                  validator: (value) => value!.isEmpty ? 'Please enter a department' : null,
                  layoutType: layoutType,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: fieldPadding),
                child: _buildMSEUFFormField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Icons.account_circle_rounded,
                  validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
                  layoutType: layoutType,
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: fieldPadding),
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
            ),
          ],
        ),
        SizedBox(height: 18),
        _buildMSEUFRoleDropdown(layoutType),
      ],
    );
  }

  Widget _buildMobileFormFields(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMSEUFFormField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person_rounded,
          validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
          layoutType: layoutType,
        ),
        SizedBox(height: isMobile ? 16 : 18),
        _buildMSEUFFormField(
          controller: _departmentController,
          label: 'Department',
          icon: Icons.business_rounded,
          validator: (value) => value!.isEmpty ? 'Please enter a department' : null,
          layoutType: layoutType,
        ),
        SizedBox(height: isMobile ? 16 : 18),
        _buildMSEUFFormField(
          controller: _usernameController,
          label: 'Username',
          icon: Icons.account_circle_rounded,
          validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
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
        _buildMSEUFRoleDropdown(layoutType),
      ],
    );
  }

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
                        'Edit User',
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
                              'Update user details',
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
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _isFullUpdate = value == 'full';
                    });
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'full',
                      child: Row(
                        children: [
                          Icon(Icons.update_rounded, size: 20, color: mseufMaroon),
                          SizedBox(width: 8),
                          Text(
                            'Full Update',
                            style: TextStyle(color: mseufMaroonDark, fontWeight: FontWeight.w600),
                          ),
                          if (_isFullUpdate)
                            Icon(Icons.check, color: mseufMaroon, size: 16),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'partial',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 20, color: mseufMaroon),
                          SizedBox(width: 8),
                          Text(
                            'Partial Update',
                            style: TextStyle(color: mseufMaroonDark, fontWeight: FontWeight.w600),
                          ),
                          if (!_isFullUpdate)
                            Icon(Icons.check, color: mseufMaroon, size: 16),
                        ],
                      ),
                    ),
                  ],
                  icon: Icon(Icons.more_vert_rounded, color: mseufMaroon),
                  color: surfacePrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: mseufMaroon.withOpacity(0.2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(_LayoutType layoutType) {
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
          Container(
            width: isMobile ? 36 : 40,
            height: isMobile ? 36 : 40,
            decoration: BoxDecoration(
              color: onMaroon,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.edit_rounded,
                color: mseufMaroon,
                size: isMobile ? 20 : 22,
              ),
            ),
          ),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit User',
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
                  'Update user details',
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
        ],
      ),
    );
  }

  Widget _buildSidebar(_LayoutType layoutType) {
    final isDesktop = layoutType == _LayoutType.desktop;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 200),
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
                        'User Summary',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w700,
                          color: mseufMaroonDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildSummaryItem('User ID', widget.user.id, layoutType),
                  _buildSummaryItem('Role', _roles[_selectedRole] ?? '', layoutType, valueColor: _getRoleColor(_selectedRole)),
                  if (_nameController.text.isNotEmpty)
                    _buildSummaryItem('Name', _nameController.text, layoutType),
                  if (_departmentController.text.isNotEmpty)
                    _buildSummaryItem('Department', _departmentController.text, layoutType),
                  if (_usernameController.text.isNotEmpty)
                    _buildSummaryItem('Username', _usernameController.text, layoutType),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 180),
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
                        'Guidance',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w700,
                          color: mseufMaroonDark,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, color: successColor, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ensure all fields are correctly filled.',
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, color: successColor, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select full or partial update mode.',
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded, color: successColor, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Verify changes before saving.',
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildSummaryItem(String label, String value, _LayoutType layoutType, {Color? valueColor}) {
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
              color: valueColor ?? mseufMaroonDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
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
              'User roles determine system access levels. Super Admins have full system control, Admins can manage users, and regular users have limited access.',
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

  Widget _buildUpdateModeIndicator(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _isFullUpdate ? mseufMaroon.withOpacity(0.1) : infoColor.withOpacity(0.1),
            _isFullUpdate ? mseufMaroon.withOpacity(0.05) : infoColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFullUpdate ? mseufMaroon : infoColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (_isFullUpdate ? mseufMaroon : infoColor).withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _isFullUpdate ? mseufMaroon.withOpacity(0.15) : infoColor.withOpacity(0.15),
                  _isFullUpdate ? mseufMaroon.withOpacity(0.08) : infoColor.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _isFullUpdate ? Icons.update_rounded : Icons.edit_rounded,
              color: _isFullUpdate ? mseufMaroon : infoColor,
              size: isMobile ? 18 : 20,
            ),
          ),
          SizedBox(width: 8),
          Text(
            _isFullUpdate ? 'Full Update Mode' : 'Partial Update Mode',
            style: TextStyle(
              color: _isFullUpdate ? mseufMaroon : infoColor,
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 12 : 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUserIdCard(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 10),
      decoration: BoxDecoration(
        gradient: surfaceGradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: mseufMaroon.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.15),
                  mseufMaroon.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.badge_rounded,
              color: mseufMaroon,
              size: isMobile ? 18 : 20,
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ID',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  widget.user.id,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: mseufMaroonDark,
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

  Widget _buildMSEUFFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required _LayoutType layoutType,
  }) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isTablet = layoutType == _LayoutType.tablet;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.015;
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
        validator: validator,
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: mseufMaroonDark,
          fontSize: isMobile ? 14 : isTablet ? 15 : 13,
          overflow: TextOverflow.ellipsis,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textTertiary,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : isTablet ? 14 : 11,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: padding, left: padding, top: padding, bottom: padding),
            padding: EdgeInsets.all(isMobile ? 8 : isTablet ? 10 : 6),
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
              size: isMobile ? 18 : isTablet ? 20 : 16,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: isMobile ? 16 : isTablet ? 18 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMSEUFRoleDropdown(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isTablet = layoutType == _LayoutType.tablet;
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.015;
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
      child: DropdownButtonFormField<String>(
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
                            fontSize: isMobile ? 14 : isTablet ? 15 : 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedRole = value!;
          });
        },
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: mseufMaroonDark,
          fontSize: isMobile ? 14 : isTablet ? 15 : 13,
        ),
        decoration: InputDecoration(
          labelText: 'Role',
          labelStyle: TextStyle(
            color: textTertiary,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : isTablet ? 14 : 11,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: padding, left: padding, top: padding, bottom: padding),
            padding: EdgeInsets.all(isMobile ? 8 : isTablet ? 10 : 6),
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
              Icons.admin_panel_settings_rounded,
              color: mseufMaroon,
              size: isMobile ? 18 : isTablet ? 20 : 16,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: padding,
            vertical: isMobile ? 16 : isTablet ? 18 : 12,
          ),
        ),
        dropdownColor: surfacePrimary,
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: mseufMaroon,
          size: isMobile ? 24 : isTablet ? 26 : 20,
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading, _LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isTablet = layoutType == _LayoutType.tablet;
    return Row(
      children: [
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
              onPressed: isLoading ? null : () => Navigator.pop(context),
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
                  Icon(
                    Icons.arrow_back_rounded,
                    color: mseufMaroon,
                    size: isMobile ? 18 : 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Cancel',
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
        Expanded(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [mseufMaroonDark, mseufMaroon, mseufMaroonLight],
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
              onPressed: isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: onMaroon,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : isTablet ? 18 : 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: isLoading
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
                          Icons.save_rounded,
                          color: onMaroon,
                          size: isMobile ? 18 : 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Save Changes',
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
}

enum _LayoutType {
  mobile,
  tablet,
  laptop,
  desktop,
}