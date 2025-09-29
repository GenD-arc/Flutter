import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../utils/device_type.dart';
import '../../utils/user_utils.dart';


class UserListWidget extends StatefulWidget {
  final List<User> users;
  final Set<String> selectedUserIds;
  final bool isSelectionMode;
  final Function(User) onUserTap;
  final Function(String) onUserLongPress;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final DeviceType deviceType;

  const UserListWidget({
    Key? key,
    required this.users,
    required this.selectedUserIds,
    required this.isSelectionMode,
    required this.onUserTap,
    required this.onUserLongPress,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.deviceType,
  }) : super(key: key);

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> with TickerProviderStateMixin {
  // MSEUFCI Color Palette from DashboardScreen
  static const Color mseufMaroon = Color(0xFF8B0000);
  static const Color mseufMaroonDark = Color(0xFF4A1E1E);
  static const Color mseufMaroonLight = Color(0xFFB71C1C);
  static const Color mseufWhite = Color(0xFFFFFFFF);
  static const Color surfacePrimary = Color(0xFFFFFBFF);
  static const Color surfaceSecondary = Color(0xFFFBFBFB);
  static const Color surfaceTertiary = Color(0xFFF0F0F0);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF737373);
  static const Color errorColor = Color(0xFFDC2626);

  static const LinearGradient maroonGradient = LinearGradient(
    colors: [mseufMaroonDark, mseufMaroon, mseufMaroonLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  late AnimationController _listAnimationController;
  late AnimationController _selectionAnimationController;

  static const Map<String, Map<String, dynamic>> _roleThemes = {
    'User': {
      'colors': [mseufMaroon, mseufMaroonDark, mseufMaroonLight],
      'icon': Icons.person_rounded,
      'priority': 1,
    },
    'Admin': {
      'colors': [Color(0xFF0D7377), Color(0xFF14A085), Color(0xFF329D9C)],
      'icon': Icons.admin_panel_settings_rounded,
      'priority': 3,
    },
    'Super Admin': {
      'colors': [Color(0xFF7B1FA2), Color(0xFF9C27B0), Color(0xFFBA68C8)],
      'icon': Icons.security_rounded,
      'priority': 4,
    },
    'Organization': {
      'colors': [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
      'icon': Icons.business_rounded,
      'priority': 2,
    },
    'Adviser': {
      'colors': [Color(0xFF2E7D32), Color(0xFF388E3C), Color(0xFF66BB6A)],
      'icon': Icons.school_rounded,
      'priority': 2,
    },
    'Staff': {
      'colors': [Color(0xFFE65100), Color(0xFFFF9800), Color(0xFFFFB74D)],
      'icon': Icons.work_rounded,
      'priority': 2,
    },
  };

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _selectionAnimationController = AnimationController(
      duration: Duration(milliseconds: 350),
      vsync: this,
    );

    _listAnimationController.forward();
    if (widget.isSelectionMode) {
      _selectionAnimationController.forward();
    }
  }

  @override
  void didUpdateWidget(UserListWidget oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
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
            child: Container(
              color: surfacePrimary, // Solid background for list
              child: Column(
                children: [
                  _buildSelectionControls(),
                  Expanded(child: _buildUserList()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: surfacePrimary,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(
                color: mseufMaroon.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: isMobile ? 40 : isTablet ? 48 : 56,
              color: mseufMaroonDark,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'No Users Found',
            style: TextStyle(
              fontSize: isMobile ? 18 : isTablet ? 20 : 22,
              fontWeight: FontWeight.w800,
              color: mseufMaroonDark,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'There are currently no users to display.\nTry adjusting your filters or search criteria.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 12 : isTablet ? 13 : 14,
              color: textSecondary,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionControls() {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;

    return AnimatedBuilder(
      animation: _selectionAnimationController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _selectionAnimationController,
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : isTablet ? 16 : 20,
              vertical: isMobile ? 8 : 12,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : isTablet ? 16 : 20,
              vertical: isMobile ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: surfacePrimary,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(
                color: mseufMaroon.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  color: mseufMaroonDark,
                  size: isMobile ? 16 : isTablet ? 18 : 20,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  '${widget.selectedUserIds.length} Selected',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                    fontWeight: FontWeight.w700,
                    color: mseufMaroonDark,
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
                SizedBox(width: isMobile ? 8 : 12),
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
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;
    final colors = isPrimary
        ? [mseufMaroon, mseufMaroonLight]
        : [errorColor, errorColor.withOpacity(0.8)];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 10 : isTablet ? 12 : 14,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors[0].withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: mseufWhite,
                size: isMobile ? 14 : isTablet ? 16 : 18,
              ),
              SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: mseufWhite,
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : isTablet ? 12 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      itemCount: widget.users.length,
      separatorBuilder: (context, index) => Divider(
        color: mseufMaroon.withOpacity(0.1),
        height: 1,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        final user = widget.users[index];
        final isSelected = widget.selectedUserIds.contains(user.id);

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 350 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: _buildEnhancedUserCard(user, isSelected, index),
            );
          },
        );
      },
    );
  }

  Widget _buildEnhancedUserCard(User user, bool isSelected, int index) {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;
    final theme = _roleThemes[user.roleType] ?? _roleThemes['User']!;
    final colors = theme['colors'] as List<Color>;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onUserTap(user),
        onLongPress: () => widget.onUserLongPress(user.id),
        hoverColor: mseufMaroon.withOpacity(0.03),
        splashColor: mseufMaroon.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : isTablet ? 16 : 20,
            vertical: isMobile ? 10 : isTablet ? 12 : 14,
          ),
          decoration: BoxDecoration(
            color: isSelected ? mseufMaroon.withOpacity(0.05) : surfacePrimary,
            border: Border(
              bottom: BorderSide(
                color: mseufMaroon.withOpacity(0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              _buildPremiumUserAvatar(user, colors, theme['icon'] as IconData),
              SizedBox(width: isMobile ? 8 : isTablet ? 12 : 16),
              Expanded(
                child: _buildEnhancedUserInfo(user),
              ),
              SizedBox(width: 8),
              widget.isSelectionMode
                  ? _buildCustomCheckbox(isSelected)
                  : _buildPremiumRoleBadge(user, colors, theme['priority'] as int),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumUserAvatar(User user, List<Color> colors, IconData roleIcon) {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;

    return Stack(
      children: [
        Container(
          width: isMobile ? 40 : isTablet ? 48 : 56,
          height: isMobile ? 40 : isTablet ? 48 : 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: mseufWhite.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              UserUtils.getUserInitials(user.name),
              style: TextStyle(
                color: mseufWhite,
                fontSize: isMobile ? 16 : isTablet ? 18 : 20,
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
            padding: EdgeInsets.all(isMobile ? 4 : 6),
            decoration: BoxDecoration(
              color: mseufWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors[0].withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              roleIcon,
              size: isMobile ? 10 : isTablet ? 12 : 14,
              color: colors[0],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedUserInfo(User user) {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: TextStyle(
            fontSize: isMobile ? 14 : isTablet ? 15 : 16,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4),
        Text(
          'ID: ${user.id}',
          style: TextStyle(
            fontSize: isMobile ? 10 : isTablet ? 11 : 12,
            fontWeight: FontWeight.w600,
            color: mseufMaroonDark,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.business_rounded,
              size: isMobile ? 12 : isTablet ? 14 : 16,
              color: textTertiary,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                user.department,
                style: TextStyle(
                  fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomCheckbox(bool isSelected) {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;

    return AnimatedContainer(
      duration: Duration(milliseconds: 350),
      width: isMobile ? 20 : isTablet ? 22 : 24,
      height: isMobile ? 20 : isTablet ? 22 : 24,
      decoration: BoxDecoration(
        gradient: isSelected ? maroonGradient : null,
        color: isSelected ? null : surfaceSecondary,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? mseufMaroon : surfaceTertiary,
          width: 1,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              color: mseufWhite,
              size: isMobile ? 14 : isTablet ? 16 : 18,
            )
          : null,
    );
  }

  Widget _buildPremiumRoleBadge(User user, List<Color> colors, int priority) {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : isTablet ? 10 : 12,
        vertical: isMobile ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: mseufWhite.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (priority >= 3) ...[
            Icon(
              Icons.star_rounded,
              color: mseufWhite,
              size: isMobile ? 10 : isTablet ? 12 : 14,
            ),
            SizedBox(width: 4),
          ],
          Text(
            user.roleType,
            style: TextStyle(
              color: mseufWhite,
              fontSize: isMobile ? 10 : isTablet ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}