import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/resource_service.dart';
import '../services/auth_service.dart';
import 'reservation_approval_screen.dart';

class AdminDashboardResources extends StatefulWidget {
  const AdminDashboardResources({super.key});

  @override
  State<AdminDashboardResources> createState() => _AdminDashboardResourcesState();
}

class _AdminDashboardResourcesState extends State<AdminDashboardResources> with TickerProviderStateMixin {
  
  static const _colorPrimary = Color(0xFF8B0000);
  static const _colorSurface = Color(0xFFFAFAFA);
  static const _colorCard = Color(0xFFFFFFFF);
  static const _colorTextPrimary = Color(0xFF1A1A1A);
  static const _colorTextSecondary = Color(0xFF6B7280);
  static const _colorBorder = Color(0xFFE5E7EB);
  static const _colorSuccess = Color(0xFF059669);

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

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.27),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadAdminResources();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadAdminResources() {
    final authService = context.read<AuthService>();
    final resourceService = context.read<ResourceService>();

    if (authService.currentUser != null) {
      resourceService.fetchResourcesByApprover(authService.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Consumer<ResourceService>(
        builder: (context, resourceService, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: Container(
              color: _colorSurface,
              child: _buildContent(resourceService),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(ResourceService resourceService) {
    if (resourceService.isLoading) {
      return _buildLoadingState();
    }

    if (resourceService.errorMessage != null) {
      return _buildErrorState(resourceService.errorMessage!);
    }

    final resources = resourceService.resources;
    if (resources.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResourcesGrid(resources);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _colorPrimary.withOpacity(0.1),
                  _colorPrimary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_colorPrimary),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading Your Resources',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _colorTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Fetching your assigned resources...',
            style: TextStyle(
              fontSize: 13,
              color: _colorTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _colorCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _colorBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 12),
            const Text(
              'Error Loading Resources',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _colorTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _colorTextSecondary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadAdminResources,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _colorCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _colorBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _colorPrimary.withOpacity(0.1),
                    _colorPrimary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: _colorPrimary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Resources Assigned',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _colorTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You are not assigned as an approver for any resources yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: _colorTextSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesGrid(List<Resource> resources) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive grid parameters
        final width = constraints.maxWidth;
        int crossAxisCount;
        double spacing;
        double padding;
        
        if (width < 600) {
          // Mobile
          crossAxisCount = 2;
          spacing = 12.0;
          padding = 16.0;
        } else if (width < 900) {
          // Tablet
          crossAxisCount = 3;
          spacing = 14.0;
          padding = 18.0;
        } else if (width < 1200) {
          // Laptop
          crossAxisCount = 4;
          spacing = 16.0;
          padding = 20.0;
        } else {
          // Desktop
          crossAxisCount = 5;
          spacing = 18.0;
          padding = 24.0;
        }

        return CustomScrollView(
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
                  (context, index) => _buildAdminResourceCard(resources[index], index),
                  childCount: resources.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAdminResourceCard(Resource resource, int index) {
    final theme = _categoryThemes[resource.category] ?? _categoryThemes['Facility']!;
    final gradient = theme['gradient'] as List<Color>;
    final icon = theme['icon'] as IconData;
    final accentColor = theme['accentColor'] as Color;

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
        onTap: () => _showAdminResourceOptions(resource),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: _colorSuccess,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Available',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _colorTextPrimary,
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
            _categoryThemes[resource.category]!['description'] as String,
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

  void _showAdminResourceOptions(Resource resource) {
    showDialog(
      context: context,
      builder: (context) => _AdminResourceDialog(resource: resource),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: _colorPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// Dialog widget remains the same as in your original code
class _AdminResourceDialog extends StatelessWidget {
  final Resource resource;

  const _AdminResourceDialog({required this.resource});

  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successColor = Color(0xFF059669);

  static const Map<String, Map<String, dynamic>> categoryThemes = {
    'Facility': {
      'gradient': [Color(0xFF8B0000), Color(0xFFA52A2A)],
      'icon': Icons.business_rounded,
    },
    'Room': {
      'gradient': [Color(0xFF0F766E), Color(0xFF14B8A6)],
      'icon': Icons.meeting_room_rounded,
    },
    'Vehicle': {
      'gradient': [Color(0xFFEA580C), Color(0xFFFB923C)],
      'icon': Icons.directions_car_rounded,
    },
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, isMobile),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 20),
                  child: _buildContent(isMobile),
                ),
              ),
              _buildActions(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final theme = categoryThemes[resource.category] ?? categoryThemes['Facility']!;
    final gradient = theme['gradient'] as List<Color>;
    final icon = theme['icon'] as IconData;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Row(
        children: [
          _buildAvatar(icon, isMobile),
          SizedBox(width: isMobile ? 14 : 16),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildCategoryBadge(isMobile),
                    const SizedBox(width: 8),
                    _buildStatusBadge(isMobile),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(IconData icon, bool isMobile) {
    return Container(
      width: isMobile ? 56 : 64,
      height: isMobile ? 56 : 64,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: isMobile ? 28 : 32,
      ),
    );
  }

  Widget _buildCategoryBadge(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        resource.category,
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 12 : 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Available',
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (resource.description.isNotEmpty) ...[
          _buildSectionTitle('Description', isMobile),
          const SizedBox(height: 10),
          _buildInfoCard(resource.description, isMobile),
          const SizedBox(height: 20),
        ],
        
        _buildSectionTitle('Admin Actions', isMobile),
        const SizedBox(height: 10),
        _buildActionTile(
          icon: Icons.pending_actions_rounded,
          title: 'Pending Bookings',
          subtitle: 'Review and approve reservation requests',
          color: primaryMaroon,
          isMobile: isMobile,
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          icon: Icons.calendar_today_rounded,
          title: 'View Availability',
          subtitle: 'Check resource schedule and bookings',
          color: successColor,
          isMobile: isMobile,
        ),
        const SizedBox(height: 8),
        _buildActionTile(
          icon: Icons.history_rounded,
          title: 'Booking History',
          subtitle: 'View all past reservations',
          color: const Color(0xFF0F766E),
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isMobile) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isMobile ? 13 : 14,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    );
  }

  Widget _buildInfoCard(String text, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 13 : 14,
          color: textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: textSecondary,
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
    );
  }

  Widget _buildActions(BuildContext context, bool isMobile) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handlePendingBookings(context),
              icon: const Icon(Icons.pending_actions_rounded, size: 18),
              label: const Text('View Pending Bookings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryMaroon,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleAvailability(context),
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: const Text('Check Availability'),
              style: OutlinedButton.styleFrom(
                foregroundColor: successColor,
                side: const BorderSide(color: successColor, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePendingBookings(BuildContext context) {
    final authService = context.read<AuthService>();
    
    if (authService.token == null || authService.currentUser == null) {
      _showSnackBar(
        context,
        'Authentication required. Please log in again.',
        isError: true,
      );
      return;
    }

    Navigator.pop(context);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          ReservationApprovalScreen(
            approverId: authService.currentUser!.id,
            token: authService.token!,
            resourceId: resource.id,
            resourceName: resource.name,
          ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _handleAvailability(BuildContext context) {
    Navigator.pop(context);
    _showSnackBar(
      context,
      'Availability view coming soon for ${resource.name}',
    );
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? primaryMaroon : successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 3 : 2),
      ),
    );
  }
}