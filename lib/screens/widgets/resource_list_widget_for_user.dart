import 'package:flutter/material.dart';
import '../../services/resource_service.dart';

class ResourceListWidgetForUser extends StatefulWidget {
  final TabController tabController;
  final List<Resource> resources;
  final Function(Resource) onResourceTap;

  const ResourceListWidgetForUser({
    Key? key,
    required this.tabController,
    required this.resources,
    required this.onResourceTap,
  }) : super(key: key);

  @override
  State<ResourceListWidgetForUser> createState() => _ResourceListWidgetForUserState();
}

class _ResourceListWidgetForUserState extends State<ResourceListWidgetForUser>
    with TickerProviderStateMixin {
  // Enhanced Color Palette
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color cardBackground = Color(0xFFFFFBFF);

  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  // Enhanced category-to-theme mapping
  static const Map<String, Map<String, dynamic>> _categoryThemes = {
    'Facility': {
      'colors': [Color(0xFF8B0000), Color(0xFF6B1D1D), Color(0xFF4A1E1E)],
      'icon': Icons.business_rounded,
      'priority': 4,
    },
    'Room': {
      'colors': [Color(0xFF0D7377), Color(0xFF14A085), Color(0xFF329D9C)],
      'icon': Icons.meeting_room_rounded,
      'priority': 3,
    },
    'Vehicle': {
      'colors': [Color(0xFFE65100), Color(0xFFFF9800), Color(0xFFFFB74D)],
      'icon': Icons.directions_car_rounded,
      'priority': 3,
    },
  };

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;

    return FadeTransition(
      opacity: _fadeController,
      child: TabBarView(
        controller: widget.tabController,
        children: [
          _buildEnhancedResourceGrid(context, widget.resources, isMobile, isTablet),
          _buildEnhancedResourceGrid(
            context,
            widget.resources.where((resource) => resource.category == 'Facility').toList(),
            isMobile,
            isTablet,
          ),
          _buildEnhancedResourceGrid(
            context,
            widget.resources.where((resource) => resource.category == 'Room').toList(),
            isMobile,
            isTablet,
          ),
          _buildEnhancedResourceGrid(
            context,
            widget.resources.where((resource) => resource.category == 'Vehicle').toList(),
            isMobile,
            isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedResourceGrid(
    BuildContext context,
    List<Resource> filteredResources,
    bool isMobile,
    bool isTablet,
  ) {
    if (filteredResources.isEmpty) {
      return _buildEnhancedEmptyState(isMobile);
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.all(isMobile ? 16 : isTablet ? 20 : 24),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : isTablet ? 3 : 4,
          childAspectRatio: isMobile ? 0.8 : 0.85, // Slightly increased aspect ratio
          crossAxisSpacing: isMobile ? 16 : 20,
          mainAxisSpacing: isMobile ? 16 : 20,
        ),
        itemCount: filteredResources.length,
        itemBuilder: (context, index) {
          final resource = filteredResources[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (index * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: _buildEnhancedResourceCard(resource, index, isMobile, isTablet),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEnhancedResourceCard(Resource resource, int index, bool isMobile, bool isTablet) {
    final theme = _categoryThemes[resource.category] ?? _categoryThemes['Other']!;
    final colors = theme['colors'] as List<Color>;

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: () => widget.onResourceTap(resource),
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_scaleController.value * 0.05),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cardBackground,
                    Colors.white,
                    Colors.white.withOpacity(0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey[200]!.withOpacity(0.8),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildEnhancedImageSection(resource, colors, theme['icon'] as IconData, isMobile),
                  _buildEnhancedInfoSection(resource, colors, isMobile, isTablet),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedImageSection(Resource resource, List<Color> colors, IconData categoryIcon, bool isMobile) {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Stack(
          children: [
            // Background Pattern - Removed asset dependency
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  // Create a subtle pattern using gradients instead of assets
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    radius: 0.8,
                    center: Alignment.topRight,
                  ),
                ),
              ),
            ),
            
            // Main Image Content
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: resource.imageUrl != null
                    ? Image.network(
                        resource.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return _buildEnhancedLoadingIndicator(colors, isMobile);
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildEnhancedPlaceholder(categoryIcon, colors, isMobile);
                        },
                      )
                    : _buildEnhancedPlaceholder(categoryIcon, colors, isMobile),
              ),
            ),
            
            // Category Icon Overlay
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  categoryIcon,
                  size: isMobile ? 16 : 18,
                  color: colors[0],
                ),
              ),
            ),
            
            // Availability Indicator
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedLoadingIndicator(List<Color> colors, bool isMobile) {
    return Container(
      color: colors[0].withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isMobile ? 24 : 28,
              height: isMobile ? 24 : 28,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPlaceholder(IconData categoryIcon, List<Color> colors, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                categoryIcon,
                size: isMobile ? 32 : 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoSection(Resource resource, List<Color> colors, bool isMobile, bool isTablet) {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 10 : 12), // Reduced padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Added to prevent overflow
              children: [
                // Resource Name
                Text(
                  resource.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 13 : 15, // Slightly reduced
                    color: darkMaroon,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 4), // Reduced spacing
                
                // Resource ID Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryMaroon.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: primaryMaroon.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'ID: ${resource.id}',
                    style: TextStyle(
                      fontSize: isMobile ? 9 : 10, // Slightly reduced
                      fontWeight: FontWeight.w600,
                      color: primaryMaroon,
                    ),
                  ),
                ),
                
                SizedBox(height: 6), // Reduced spacing
                
                // Description - Made flexible to take available space
                Flexible(
                  child: Text(
                    resource.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isMobile ? 11 : 12, // Slightly reduced
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: isMobile ? 2 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: 6), // Reduced spacing
                
                // Category Badge and Action Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: isMobile ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors[0], colors[1]],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          resource.category,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 9 : 10, // Slightly reduced
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.all(isMobile ? 5 : 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryMaroon, lightMaroon],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: primaryMaroon.withOpacity(0.3),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: isMobile ? 12 : 14, // Slightly reduced
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState(bool isMobile) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 24 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryMaroon.withOpacity(0.1),
                    primaryMaroon.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.inventory_outlined,
                size: isMobile ? 48 : 64,
                color: primaryMaroon.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No Resources Found',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w700,
                color: darkMaroon,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There are no resources available\nin this category at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}