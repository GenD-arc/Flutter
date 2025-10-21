import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/services/today_status_service.dart';
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
  // Professional Design System
  static const _colorPrimary = Color(0xFF8B0000);
  static const _colorSurface = Color(0xFFFAFAFA);
  static const _colorCard = Color(0xFFFFFFFF);
  static const _colorTextPrimary = Color(0xFF1A1A1A);
  static const _colorTextSecondary = Color(0xFF6B7280);
  static const _colorBorder = Color(0xFFE5E7EB);
  static const _colorSuccess = Color(0xFF059669);

  late AnimationController _fadeController;
  late AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  static const _categoryConfig = {
    'Facility': {
      'gradient': [Color(0xFF8B0000), Color(0xFFA52A2A)],
      'icon': Icons.business_rounded,
      'accentColor': Color(0xFF8B0000),
    },
    'Room': {
      'gradient': [Color(0xFF0F766E), Color(0xFF14B8A6)],
      'icon': Icons.meeting_room_rounded,
      'accentColor': Color(0xFF0F766E),
    },
    'Vehicle': {
      'gradient': [Color(0xFFEA580C), Color(0xFFFB923C)],
      'icon': Icons.directions_car_rounded,
      'accentColor': Color(0xFFEA580C),
    },
  };

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: Container(
        color: _colorSurface,
        child: TabBarView(
          controller: widget.tabController,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildResourceGrid(widget.resources),
            _buildResourceGrid(_filterByCategory('Facility')),
            _buildResourceGrid(_filterByCategory('Room')),
            _buildResourceGrid(_filterByCategory('Vehicle')),
          ],
        ),
      ),
    );
  }

  List<Resource> _filterByCategory(String category) {
    return widget.resources.where((r) => r.category == category).toList();
  }

  Widget _buildResourceGrid(List<Resource> resources) {
    if (resources.isEmpty) return _buildEmptyState();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid parameters
        final width = constraints.maxWidth;
        int crossAxisCount;
        double spacing;
        double padding;
        double childAspectRatio;
        
        if (width < 600) {
          // Mobile
          crossAxisCount = 2;
          spacing = 12.0;
          padding = 16.0;
          childAspectRatio = 0.82;
        } else if (width < 900) {
          // Tablet
          crossAxisCount = 3;
          spacing = 14.0;
          padding = 18.0;
          childAspectRatio = 0.85;
        } else if (width < 1200) {
          // Laptop
          crossAxisCount = 4;
          spacing = 16.0;
          padding = 20.0;
          childAspectRatio = 0.82;
        } else {
          // Desktop
          crossAxisCount = 5;
          spacing = 18.0;
          padding = 24.0;
          childAspectRatio = 0.82;
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(padding),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildResourceCard(resources[index], index),
                  childCount: resources.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResourceCard(Resource resource, int index) {
    final config = _categoryConfig[resource.category] ?? _categoryConfig['Facility']!;
    final gradient = config['gradient'] as List<Color>;
    final icon = config['icon'] as IconData;
    final accentColor = config['accentColor'] as Color;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildCardContent(resource, gradient, icon, accentColor),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(Resource resource, List<Color> gradient, IconData icon, Color accentColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onResourceTap(resource),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: _colorCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _colorBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardImage(resource, gradient, icon),
              _buildCardInfo(resource, accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(Resource resource, List<Color> gradient, IconData icon) {
    return Expanded(
      child: Stack(
        children: [
          // Image Container
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: resource.imageUrl != null
                  ? Image.network(
                      resource.imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return _buildImagePlaceholder(icon, gradient);
                      },
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(icon, gradient),
                    )
                  : _buildImagePlaceholder(icon, gradient),
            ),
          ),
          
          // Overlay Badges
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusBadge(resource),
                _buildCategoryBadge(icon, gradient[0]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(IconData icon, List<Color> gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 48,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Resource resource) {
    // Get availability status from TodayStatusService
    final statusService = Provider.of<TodayStatusService>(context, listen: false);
    final todayStatus = statusService.todayStatus;
    
    // Determine resource status
    Color badgeColor = _colorSuccess;
    String badgeText = 'Available';
    IconData badgeIcon = Icons.check_circle_rounded;

    // In _buildStatusBadge method, add this:
print('🔍 Resource ID: ${resource.id}');
if (todayStatus != null) {
  print('📊 Fully Available IDs: ${todayStatus.fullyAvailable.map((r) => r.resourceId).join(", ")}');
  print('🟡 Partially Available IDs: ${todayStatus.partiallyAvailable.map((r) => r.resourceId).join(", ")}');
  print('🔴 Not Available IDs: ${todayStatus.notAvailable.map((r) => r.resourceId).join(", ")}');
}
    
    if (todayStatus != null) {
      // Check if fully available
      final isFullyAvailable = todayStatus.fullyAvailable.any((r) => r.resourceId == resource.id);
      
      // Check if partially available
      final partialResource = todayStatus.partiallyAvailable.firstWhere(
        (r) => r.resourceId == resource.id,
        orElse: () => ResourceAvailabilityStatus(
          resourceId: '',
          resourceName: '',
          category: '',
          status: 'unknown',
        ),
      );
      
      // Check if not available
      final isNotAvailable = todayStatus.notAvailable.any((r) => r.resourceId == resource.id);
      
      if (isNotAvailable) {
        badgeColor = const Color(0xFFDC2626);
        badgeText = 'Fully Booked';
        badgeIcon = Icons.block_rounded;
      } else if (partialResource.resourceId.isNotEmpty) {
        badgeColor = const Color(0xFFD97706);
        badgeText = 'Booked';
        badgeIcon = Icons.pending_actions_rounded;
      }
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 6),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badgeColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildCardInfo(Resource resource, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resource.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _colorTextPrimary,
              letterSpacing: -0.3,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'ID: ${resource.id}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentColor.withOpacity(0.8),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resource.description,
            style: const TextStyle(
              fontSize: 13,
              color: _colorTextSecondary,
              height: 1.4,
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _colorPrimary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _colorPrimary.withOpacity(0.1),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: _colorPrimary.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Resources Available',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _colorTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'There are no resources in this category.\nPlease check back later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _colorTextSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}