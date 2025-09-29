import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testing/models/availability_checker_model.dart';
import 'package:testing/screens/widgets/resource_list_widget_for_user.dart';
import 'package:testing/services/resource_service.dart';
import 'package:testing/screens/widgets/resource_tabs_widget.dart';
import 'package:testing/screens/view_resources_screen.dart';
import 'package:testing/screens/availability_checker_screen.dart'; // Add this import
import 'package:testing/services/auth_service.dart';
import 'package:testing/screens/reservation_request_screen.dart' as ReservationScreen; // Use alias

class ViewResourcesScreenForUser extends StatefulWidget {

  const ViewResourcesScreenForUser({
    super.key,
  });

  @override
  State<ViewResourcesScreenForUser> createState() => _ViewResourcesScreenState();
}

class _ViewResourcesScreenState extends State<ViewResourcesScreenForUser> 
    with TickerProviderStateMixin {
  // Enhanced Color Palette
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFBFF);

  final Set<String> _selectedCategories = {'Facility', 'Room', 'Vehicle'};
  String _searchQuery = '';
  late TabController _tabController;
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadResources());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _loadResources() {
    context.read<ResourceService>().fetchResources(_selectedCategories.toList());
  }

  List<Resource> _getFilteredResources(List<Resource> resources) {
    if (_searchQuery.isEmpty) return resources;

    return resources.where((resource) {
      final query = _searchQuery.toLowerCase();
      return resource.name.toLowerCase().contains(query) ||
             resource.id.toLowerCase().contains(query) ||
             resource.description.toLowerCase().contains(query) ||
             resource.category.toLowerCase().contains(query);
    }).toList();
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
              : Border.all(color: color.withOpacity(0.1), width: 1),
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
                      color: isDanger ? Colors.red[700] : darkMaroon,
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

  Widget _buildResourceHeader(Resource resource, bool isMobile) {
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
        Row(
          children: [
            Expanded(
              child: Text(
                'Description:',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: darkMaroon,
                ),
              ),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.copy,
                size: isMobile ? 20 : 24,
                color: primaryMaroon,
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
        SizedBox(height: 4),
        Text(
          resource.description.isEmpty ? 'No description available' : resource.description,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildActionTile(
          icon: Icons.calendar_view_day_rounded,
          title: 'View Availability',
          subtitle: 'Check availability and view schedule',
          color: Colors.blue[700]!,
          onTap: () {
            // Create a mapped resource for the availability checker
            final mappedResource = AvailabilityResource(
              id: resource.id,
              name: resource.name,
              category: resource.category,
              description: resource.description,
            );
            
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AvailabilityCheckerScreen(
                  resource: mappedResource,
                ),
              ),
            );
          },
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildActionTile(
          icon: Icons.event_rounded,
          title: 'Book This Resource',
          subtitle: 'Schedule an appointment for this resource',
          color: primaryMaroon,
          onTap: () async {
            final authService = context.read<AuthService>();
            final userId = authService.currentUser?.id;
            if (userId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please log in to book a resource'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            // Map ResourceService Resource to ReservationRequestScreen Resource
            final mappedResource = ReservationScreen.Resource(
              id: resource.id,
              name: resource.name,
              description: resource.description,
              category: resource.category,
            );
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReservationScreen.ReservationRequestScreen(
                  userId: userId,
                  selectedResource: mappedResource,
                ),
              ),
            );
            if (result == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reservation submitted successfully!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  duration: Duration(seconds: 2),
                ),
              );
              Navigator.pop(context); // Close the dialog
              _loadResources(); // Refresh resources
            }
          },
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 12 : 16,
                horizontal: isMobile ? 24 : 32,
              ),
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

  void _showResourceDetails(Resource resource) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Scaffold(
      backgroundColor: warmGray,
      appBar: _buildEnhancedAppBar(isMobile),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<ResourceService>(
          builder: (context, resourceService, child) {
            if (resourceService.isLoading) {
              return _buildEnhancedLoadingState(isMobile);
            }

            if (resourceService.errorMessage != null) {
              return _buildEnhancedErrorState(resourceService.errorMessage!, isMobile);
            }

            final filteredResources = _getFilteredResources(resourceService.resources);

            if (filteredResources.isEmpty) {
              return _buildEnhancedEmptyState(isMobile);
            }

            return SlideTransition(
              position: _slideAnimation,
              child: _buildEnhancedMainContent(filteredResources, isMobile),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildEnhancedAppBar(bool isMobile) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardBackground,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryMaroon.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book Appointment',
            style: TextStyle(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w800,
              color: darkMaroon,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            'Select available resources',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
      actions: [
        _buildEnhancedAppBarAction(
          icon: Icons.refresh_rounded,
          onPressed: _loadResources,
          tooltip: 'Refresh Resources',
          isMobile: isMobile,
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEnhancedAppBarAction({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required bool isMobile,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryMaroon, lightMaroon],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: primaryMaroon.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                icon,
                color: Colors.white,
                size: isMobile ? 20 : 22,
              ),
              onPressed: onPressed,
              tooltip: tooltip,
              padding: EdgeInsets.all(8),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedMainContent(List<Resource> filteredResources, bool isMobile) {
    return Column(
      children: [
        _buildEnhancedStatsHeader(filteredResources.length, isMobile),
        _buildEnhancedTabsSection(filteredResources, isMobile),
        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(
              isMobile ? 16 : 20,
              0,
              isMobile ? 16 : 20,
              isMobile ? 16 : 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardBackground, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: primaryMaroon.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ResourceListWidgetForUser(
              tabController: _tabController,
              resources: filteredResources,
              onResourceTap: (resource) {
                _showResourceDetails(resource);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedStatsHeader(int totalResources, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 20,
        isMobile ? 16 : 20,
        isMobile ? 16 : 20,
        0,
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryMaroon,
            Color(0xFF7B1538),
            lightMaroon,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: isMobile ? 28 : 32,
            ),
          ),
          SizedBox(width: isMobile ? 16 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalResources',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Available Resources',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTabsSection(List<Resource> resources, bool isMobile) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isMobile ? 16 : 20,
        isMobile ? 16 : 20,
        isMobile ? 16 : 20,
        isMobile ? 16 : 20,
      ),
      child: ResourceTabsWidget(
        tabController: _tabController,
        resources: resources,
      ),
    );
  }

  Widget _buildEnhancedLoadingState(bool isMobile) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 32 : 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 24 : 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryMaroon.withOpacity(0.1),
                    primaryMaroon.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: SizedBox(
                width: isMobile ? 48 : 64,
                height: isMobile ? 48 : 64,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryMaroon),
                  strokeWidth: 4,
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading Resources',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w700,
                color: darkMaroon,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please wait while we fetch available resources...',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedErrorState(String error, bool isMobile) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(isMobile ? 24 : 32),
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cardBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: isMobile ? 48 : 64,
                color: Colors.red[600],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Something Went Wrong',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w700,
                color: darkMaroon,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadResources,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 16 : 18,
                    horizontal: isMobile ? 24 : 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: isMobile ? 20 : 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState(bool isMobile) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(isMobile ? 24 : 32),
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cardBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey[200]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: primaryMaroon.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 8),
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
                    primaryMaroon.withOpacity(0.1),
                    primaryMaroon.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.inventory_outlined,
                size: isMobile ? 48 : 64,
                color: primaryMaroon.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No Resources Available',
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.w700,
                color: darkMaroon,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'There are currently no resources available for booking.\nPlease check back later or contact support.',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadResources,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryMaroon,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 16 : 18,
                    horizontal: isMobile ? 24 : 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: isMobile ? 20 : 22,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}