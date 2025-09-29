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
  static const Color cardBackground = Color(0xFFFFFBFF);

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

  // Enhanced category-to-theme mapping with comprehensive resource types
  static const Map<String, Map<String, dynamic>> _categoryThemes = {
    'Facility': {
      'colors': [Color(0xFF8B0000), Color(0xFF6B1D1D), Color(0xFF4A1E1E)],
      'icon': Icons.business_rounded,
      'priority': 4,
      'description': 'Buildings & Infrastructure',
    },
    'Room': {
      'colors': [Color(0xFF0D7377), Color(0xFF14A085), Color(0xFF329D9C)],
      'icon': Icons.meeting_room_rounded,
      'priority': 3,
      'description': 'Classrooms & Spaces',
    },
    'Vehicle': {
      'colors': [Color(0xFFE65100), Color(0xFFFF9800), Color(0xFFFFB74D)],
      'icon': Icons.directions_car_rounded,
      'priority': 3,
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
                Expanded(child: _buildResourceList()),
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

  Widget _buildResourceList() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        widget.isMobile ? 16 : 20,
        0,
        widget.isMobile ? 16 : 20,
        widget.isMobile ? 16 : 20,
      ),
      itemCount: widget.resources.length,
      itemBuilder: (context, index) {
        final resource = widget.resources[index];
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
                child: _buildEnhancedResourceCard(resource, isSelected, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedResourceCard(Resource resource, bool isSelected, int index) {
    final theme = _categoryThemes[resource.category] ?? _categoryThemes['Other']!;
    final colors = theme['colors'] as List<Color>;
    
    return Container(
      margin: EdgeInsets.only(bottom: widget.isMobile ? 16 : 20),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => widget.onResourceTap(resource),
          onLongPress: () => widget.onResourceLongPress(resource.id),
          hoverColor: primaryMaroon.withOpacity(0.04),
          splashColor: primaryMaroon.withOpacity(0.1),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..scale(isSelected ? 1.02 : 1.0)
              ..translate(0.0, isSelected ? -2.0 : 0.0),
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
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? primaryMaroon.withOpacity(0.6)
                    : Colors.grey[200]!.withOpacity(0.8),
                width: isSelected ? 2.5 : 1.5,
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
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
              child: Row(
                children: [
                  _buildPremiumResourceIcon(resource, colors, theme['icon'] as IconData),
                  SizedBox(width: widget.isMobile ? 16 : 20),
                  Expanded(
                    child: _buildEnhancedResourceInfo(resource, theme),
                  ),
                  SizedBox(width: 12),
                  widget.isSelectionMode
                      ? _buildCustomCheckbox(isSelected)
                      : _buildPremiumCategoryBadge(resource, colors, theme['priority'] as int),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumResourceIcon(Resource resource, List<Color> colors, IconData categoryIcon) {
    final firstLetter = resource.name.isNotEmpty ? resource.name[0].toUpperCase() : 'R';
    
    return Stack(
      children: [
        Container(
          width: widget.isMobile ? 56 : 64,
          height: widget.isMobile ? 56 : 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colors[0].withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              firstLetter,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.isMobile ? 18 : 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colors[0].withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              categoryIcon,
              size: widget.isMobile ? 12 : 14,
              color: colors[0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedResourceInfo(Resource resource, Map<String, dynamic> theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          resource.name,
          style: TextStyle(
            fontSize: widget.isMobile ? 16 : 18,
            fontWeight: FontWeight.w700,
            color: darkMaroon,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primaryMaroon.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: primaryMaroon.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Text(
            'ID: ${resource.id}',
            style: TextStyle(
              fontSize: widget.isMobile ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: primaryMaroon,
              letterSpacing: 0.2,
            ),
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: widget.isMobile ? 14 : 16,
              color: Colors.grey[500],
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                theme['description'] as String,
                style: TextStyle(
                  fontSize: widget.isMobile ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (!widget.isMobile && resource.description != null && resource.description!.isNotEmpty) ...[
          SizedBox(height: 6),
          Text(
            resource.description!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildCustomCheckbox(bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: widget.isMobile ? 24 : 28,
      height: widget.isMobile ? 24 : 28,
      decoration: BoxDecoration(
        gradient: isSelected ? LinearGradient(
          colors: [primaryMaroon, lightMaroon],
        ) : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? primaryMaroon : Colors.grey[400]!,
          width: 2,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ] : null,
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: widget.isMobile ? 16 : 18,
            )
          : null,
    );
  }

  Widget _buildPremiumCategoryBadge(Resource resource, List<Color> colors, int priority) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 12 : 16,
        vertical: widget.isMobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (priority >= 4) ...[
            Icon(
              Icons.priority_high_rounded,
              color: Colors.white,
              size: widget.isMobile ? 12 : 14,
            ),
            SizedBox(width: 4),
          ] else if (priority >= 3) ...[
            Icon(
              Icons.star_rounded,
              color: Colors.white,
              size: widget.isMobile ? 12 : 14,
            ),
            SizedBox(width: 4),
          ],
          Text(
            resource.category,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 12 : 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}