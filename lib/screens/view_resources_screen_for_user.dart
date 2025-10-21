import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testing/models/availability_checker_model.dart';
import 'package:testing/screens/widgets/resource_list_widget_for_user.dart';
import 'package:testing/services/resource_service.dart';
import 'package:testing/screens/widgets/resource_tabs_widget.dart';
import 'package:testing/screens/view_resources_screen.dart';
import 'package:testing/screens/availability_checker_screen.dart';
import 'package:testing/services/auth_service.dart';
import 'package:testing/screens/reservation_request_screen.dart' as ReservationScreen;

class ViewResourcesScreenForUser extends StatefulWidget {
  
  const ViewResourcesScreenForUser({
    super.key
  });

  @override
  State<ViewResourcesScreenForUser> createState() => _ViewResourcesScreenState();
}

class _ViewResourcesScreenState extends State<ViewResourcesScreenForUser> 
    with TickerProviderStateMixin {
      bool _isMounted = true;
  // Updated color palette to match dashboard exactly
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color backgroundPrimary = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color borderColor = Color(0xFFE5E7EB);

  final Set<String> _selectedCategories = {'Facility', 'Room', 'Vehicle'};
  String _searchQuery = '';
  late TabController _tabController;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 720),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 540),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.27),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_isMounted) {
      _loadResources();
    }
  });
  }

  @override
  void dispose() {
    _isMounted = false;
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, Color.lerp(color, Colors.black, 0.1)!],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Replace the _showResourceDetails and related methods with this enhanced version

void _showResourceDetails(Resource resource) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isMobile = screenWidth < 600;

  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isMobile ? 12 : 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 600,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Material(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            elevation: 16,
            child: _buildEnhancedResourceDetailsContent(resource, isMobile),
          ),
        ),
      );
    },
  );
}

Widget _buildEnhancedResourceDetailsContent(Resource resource, bool isMobile) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Enhanced Header with gradient and close button
      _buildEnhancedHeader(resource, isMobile),
      
      // Scrollable content
      Flexible(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: _buildEnhancedDetailsBody(resource, isMobile),
        ),
      ),
      
      // Sticky action buttons
      _buildActionButtonsSection(resource, isMobile),
    ],
  );
}

Widget _buildEnhancedHeader(Resource resource, bool isMobile) {
  final Map<String, List<Color>> categoryColors = {
    'Facility': [Color(0xFF8B0000), Color(0xFF5C0000)],
    'Room': [Color(0xFF00897B), Color(0xFF004D40)],
    'Vehicle': [Color(0xFFFFA000), Color(0xFF8C5A00)],
    'Other': [Color(0xFFF57C00), Color(0xFFC67100)],
  };

  final colors = categoryColors[resource.category] ?? categoryColors['Other']!;

  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    padding: EdgeInsets.fromLTRB(
      isMobile ? 20 : 24,
      isMobile ? 20 : 24,
      isMobile ? 12 : 16,
      isMobile ? 20 : 24,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with initials
            Container(
              width: isMobile ? 56 : 64,
              height: isMobile ? 56 : 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  ResourceUtils.getResourceInitials(resource.name),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 22 : 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            SizedBox(width: isMobile ? 14 : 16),
            // Title and metadata
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
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      resource.category,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: isMobile ? 12 : 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Close button
            SizedBox(width: 4),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        // Resource ID with copy button
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tag_rounded, color: Colors.white.withOpacity(0.8), size: 16),
              SizedBox(width: 6),
              Text(
                'ID: ${resource.id}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontFamily: 'Courier',
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: resource.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Resource ID copied'),
                      backgroundColor: Colors.green[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildEnhancedDetailsBody(Resource resource, bool isMobile) {
  return Padding(
    padding: EdgeInsets.all(isMobile ? 16 : 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description Section
        if (resource.description.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Description',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 14),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Text(
                  resource.description,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: textSecondary,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 18 : 20),
            ],
          )
        else
          SizedBox.shrink(),

        // Features Section
        _buildFeaturesSection(isMobile),
      ],
    ),
  );
}

Widget _buildFeaturesSection(bool isMobile) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Features & Actions',
        style: TextStyle(
          fontSize: isMobile ? 13 : 14,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
      ),
      SizedBox(height: 10),
      _buildFeatureItem(
        icon: Icons.calendar_view_day_rounded,
        title: 'Availability Checker',
        description: 'View real-time availability',
        isMobile: isMobile,
      ),
      SizedBox(height: 8),
      _buildFeatureItem(
        icon: Icons.notes_rounded,
        title: 'Detailed History',
        description: 'Check booking history',
        isMobile: isMobile,
      ),
    ],
  );
}

Widget _buildFeatureItem({
  required IconData icon,
  required String title,
  required String description,
  required bool isMobile,
}) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14, vertical: isMobile ? 10 : 12),
    decoration: BoxDecoration(
      color: Color(0xFFFAFBFC),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: borderColor, width: 1),
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryMaroon.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryMaroon, size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionButtonsSection(Resource resource, bool isMobile) {
  return Container(
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: borderColor, width: 1)),
      color: surfaceColor,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    padding: EdgeInsets.all(isMobile ? 12 : 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final authService = context.read<AuthService>();
              final userId = authService.currentUser?.id;
              if (userId == null) {
                if (!_isMounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please log in to book a resource'),
                    backgroundColor: Colors.red[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              
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
              
              if (!_isMounted) return;
              
              if (result == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reservation submitted successfully!'),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
                _loadResources();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryMaroon,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 12 : 14,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Book This Resource',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isMobile ? 10 : 12),
        // Secondary action button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
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
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryMaroon,
              side: BorderSide(color: primaryMaroon, width: 1.5),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 12 : 14,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_view_day_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Check Availability',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
  
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<ResourceService>(
        builder: (context, resourceService, child) {
          if (resourceService.isLoading) {
            return _buildEnhancedLoadingState();
          }

          if (resourceService.errorMessage != null) {
            return _buildEnhancedErrorState(resourceService.errorMessage!);
          }

          final filteredResources = _getFilteredResources(resourceService.resources);

          if (filteredResources.isEmpty) {
            return _buildEnhancedEmptyState();
          }

          return SlideTransition(
            position: _slideAnimation,
              child: Column(
                children: [
                  // Tabs Section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: ResourceTabsWidget(
                      tabController: _tabController,
                      resources: filteredResources,
                    ),
                  ),
                  
                  // Resources List
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12),
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
                  SizedBox(height: 16),
                ],
              ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedLoadingState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryMaroon.withOpacity(0.1),
                primaryMaroon.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryMaroon),
              strokeWidth: 3,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Loading Resources',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Fetching available resources...',
          style: TextStyle(
            fontSize: 13,
            color: textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

  Widget _buildEnhancedErrorState(String error) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 36,
                  color: Colors.red[600],
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Unable to Load',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                error,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadResources,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryMaroon,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildEnhancedEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryMaroon.withOpacity(0.1),
                      primaryMaroon.withOpacity(0.05),
                  ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.inventory_outlined,
                  size: 36,
                  color: primaryMaroon.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'No Resources',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                'No resources available for booking',
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadResources,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryMaroon,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
    );
  }
}