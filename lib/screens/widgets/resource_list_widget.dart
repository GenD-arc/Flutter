import 'package:flutter/material.dart';
import '../../services/resource_service.dart';

class ResourceListWidget extends StatefulWidget {
  final List<Resource> resources;
  final Set<String> selectedResourceIds;
  final bool isSelectionMode;
  final Function(Resource) onResourceTap;
  final Function(String) onResourceLongPress;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final bool isMobile;
  final bool isTablet;

  const ResourceListWidget({
    Key? key,
    required this.resources,
    required this.selectedResourceIds,
    required this.isSelectionMode,
    required this.onResourceTap,
    required this.onResourceLongPress,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.isMobile,
    required this.isTablet,
  }) : super(key: key);

  @override
  State<ResourceListWidget> createState() => _ResourceListWidgetState();
}

class _ResourceListWidgetState extends State<ResourceListWidget> with TickerProviderStateMixin {
  // Enhanced Color Palette
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successGreen = Color(0xFF059669);

  late AnimationController _listAnimationController;
  late AnimationController _selectionAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _selectionAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _listAnimationController.forward();
    if (widget.isSelectionMode) {
      _selectionAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(ResourceListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelectionMode != oldWidget.isSelectionMode) {
      if (widget.isSelectionMode) {
        _selectionAnimationController.forward();
      } else {
        _selectionAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _selectionAnimationController.dispose();
    super.dispose();
  }

  // Enhanced category-to-theme mapping
  static const Map<String, Map<String, dynamic>> _categoryThemes = {
    'Facility': {
      'gradient': [Color(0xFF8B0000), Color(0xFFA52A2A)],
      'icon': Icons.business_rounded,
      'accentColor': Color(0xFF8B0000),
      'description': 'Buildings & Infrastructure',
    },
    'Room': {
      'gradient': [Color(0xFF0F766E), Color(0xFF14B8A6)],
      'icon': Icons.meeting_room_rounded,
      'accentColor': Color(0xFF0F766E),
      'description': 'Classrooms & Spaces',
    },
    'Vehicle': {
      'gradient': [Color(0xFFEA580C), Color(0xFFFB923C)],
      'icon': Icons.directions_car_rounded,
      'accentColor': Color(0xFFEA580C),
      'description': 'Transportation Assets',
    },
  };

  @override
  Widget build(BuildContext context) {
    if (widget.resources.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _listAnimationController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _listAnimationController,
              curve: Curves.easeOutCubic,
            )),
            child: Column(
              children: [
                _buildSelectionControls(),
                Expanded(child: _buildResourceGrid()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 24 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(widget.isMobile ? 20 : 24),
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
              Icons.inventory_2_outlined,
              size: widget.isMobile ? 48 : 64,
              color: primaryMaroon.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'No Resources Found',
            style: TextStyle(
              fontSize: widget.isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: darkMaroon,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'There are currently no resources to display.\nTry adjusting your filters or search criteria.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.isMobile ? 14 : 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionControls() {
    return AnimatedBuilder(
      animation: _selectionAnimationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _selectionAnimationController,
          child: Container(
            margin: EdgeInsets.fromLTRB(
              widget.isMobile ? 16 : 20,
              widget.isMobile ? 12 : 16,
              widget.isMobile ? 16 : 20,
              widget.isMobile ? 8 : 12,
            ),
            padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryMaroon.withOpacity(0.08),
                  primaryMaroon.withOpacity(0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: primaryMaroon.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryMaroon.withOpacity(0.1),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryMaroon.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_rounded,
                    color: primaryMaroon,
                    size: widget.isMobile ? 18 : 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${widget.selectedResourceIds.length} Resources Selected',
                  style: TextStyle(
                    fontSize: widget.isMobile ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    color: darkMaroon,
                    letterSpacing: 0.2,
                  ),
                ),
                Spacer(),
                _buildSelectionButton(
                  onPressed: widget.onSelectAll,
                  label: 'Select All',
                  icon: Icons.select_all_rounded,
                  isPrimary: true,
                ),
                SizedBox(width: 12),
                _buildSelectionButton(
                  onPressed: widget.onClearSelection,
                  label: 'Clear',
                  icon: Icons.clear_rounded,
                  isPrimary: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectionButton({
    required VoidCallback onPressed,
    required String label,
    required IconData icon,
    required bool isPrimary,
  }) {
    final colors = isPrimary 
      ? [primaryMaroon, lightMaroon]
      : [Colors.red[600]!, Colors.red[700]!];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isMobile ? 12 : 16,
            vertical: widget.isMobile ? 8 : 10,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: widget.isMobile ? 16 : 18,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isMobile ? 12 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceGrid() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 2 : width < 900 ? 3 : width < 1200 ? 4 : 5;
    final spacing = width < 600 ? 16.0 : 20.0;
    final padding = width < 600 ? 16.0 : 24.0;

    return Container(
      color: surfaceColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(padding),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.82,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildResourceCard(widget.resources[index], index),
                childCount: widget.resources.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(Resource resource, int index) {
    final theme = _categoryThemes[resource.category] ?? _categoryThemes['Facility']!;
    final gradient = theme['gradient'] as List<Color>;
    final icon = theme['icon'] as IconData;
    final accentColor = theme['accentColor'] as Color;
    final isSelected = widget.selectedResourceIds.contains(resource.id);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: _buildCardContent(resource, gradient, icon, accentColor, isSelected),
          ),
        );
      },
    );
  }

  Widget _buildCardContent(Resource resource, List<Color> gradient, IconData icon, Color accentColor, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onResourceTap(resource),
        onLongPress: () => widget.onResourceLongPress(resource.id),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scale(isSelected ? 1.02 : 1.0)
            ..translate(0.0, isSelected ? -2.0 : 0.0),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primaryMaroon.withOpacity(0.6) : borderColor,
              width: isSelected ? 2.5 : 1,
            ),
            boxShadow: [
              if (isSelected) ...[
                BoxShadow(
                  color: primaryMaroon.withOpacity(0.2),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardImage(resource, gradient, icon),
                  _buildCardInfo(resource, accentColor),
                ],
              ),
              // Selection checkbox in top-right corner
              if (widget.isSelectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _buildCustomCheckbox(isSelected),
                ),
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
              child: resource.imageUrl != null && resource.imageUrl!.isNotEmpty
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
                _buildStatusBadge(),
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

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: successGreen,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Available',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textPrimary,
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _buildCardInfo(Resource resource, Color accentColor) {
    final theme = _categoryThemes[resource.category] ?? _categoryThemes['Facility']!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resource.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.3,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6),
          Text(
            'ID: ${resource.id}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: accentColor.withOpacity(0.8),
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            theme['description'] as String,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              height: 1.4,
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (resource.description != null && resource.description!.isNotEmpty) ...[
            SizedBox(height: 6),
            Text(
              resource.description!,
              style: TextStyle(
                fontSize: 12,
                color: textSecondary.withOpacity(0.8),
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        gradient: isSelected ? LinearGradient(
          colors: [primaryMaroon, lightMaroon],
        ) : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? primaryMaroon : Colors.grey[400]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
          if (isSelected)
            BoxShadow(
              color: primaryMaroon.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
        ],
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            )
          : null,
    );
  }
}