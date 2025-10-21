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
  final Function(User) onEditUser;
  final Function(User) onDeleteUser;
  final Function(User) onSoftDeleteUser;
  final Function(User) onRestoreUser;

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
    required this.onEditUser,
    required this.onDeleteUser,
    required this.onSoftDeleteUser,
    required this.onRestoreUser,
  }) : super(key: key);

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  final Map<String, bool> _hoverStates = {};
  String? _expandedMenuUserId;

  // Enhanced color palette
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color cardBackground = Color(0xFFFFFBFF);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF737373);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color successColor = Color(0xFF059669);
  static const Color warningColor = Color(0xFFEA580C);
  static const Color infoColor = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;

    return Column(
      children: [
        // Selection Header
        if (widget.isSelectionMode) _buildSelectionHeader(isMobile, isTablet),
        
        // User List
        Expanded(
          child: ListView.builder(
            itemCount: widget.users.length,
            itemBuilder: (context, index) {
              final user = widget.users[index];
              return _UserListItem(
                user: user,
                isSelected: widget.selectedUserIds.contains(user.id),
                isSelectionMode: widget.isSelectionMode,
                isHovered: _hoverStates[user.id] ?? false,
                isMenuExpanded: _expandedMenuUserId == user.id,
                deviceType: widget.deviceType,
                onTap: () => widget.onUserTap(user),
                onLongPress: () => widget.onUserLongPress(user.id),
                onHover: (isHovering) => setState(() {
                  if (isHovering) {
                    _hoverStates[user.id] = true;
                  } else {
                    _hoverStates.remove(user.id);
                  }
                }),
                onMenuToggle: (isExpanded) => setState(() {
                  _expandedMenuUserId = isExpanded ? user.id : null;
                }),
                onEditUser: widget.onEditUser,
                onDeleteUser: widget.onDeleteUser,
                onSoftDeleteUser: widget.onSoftDeleteUser,
                onRestoreUser: widget.onRestoreUser,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionHeader(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : isTablet ? 16 : 20,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: primaryMaroon.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: primaryMaroon.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${widget.selectedUserIds.length} selected',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: primaryMaroon,
              fontSize: isMobile ? 14 : isTablet ? 15 : 16,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: widget.onSelectAll,
            child: Text(
              'Select All',
              style: TextStyle(
                color: primaryMaroon,
                fontSize: isMobile ? 13 : isTablet ? 14 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          TextButton(
            onPressed: widget.onClearSelection,
            child: Text(
              'Clear',
              style: TextStyle(
                color: textTertiary,
                fontSize: isMobile ? 13 : isTablet ? 14 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListItem extends StatefulWidget {
  final User user;
  final bool isSelected;
  final bool isSelectionMode;
  final bool isHovered;
  final bool isMenuExpanded;
  final DeviceType deviceType;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(bool) onHover;
  final Function(bool) onMenuToggle;
  final Function(User) onEditUser;
  final Function(User) onDeleteUser;
  final Function(User) onSoftDeleteUser;
  final Function(User) onRestoreUser;

  const _UserListItem({
    required this.user,
    required this.isSelected,
    required this.isSelectionMode,
    required this.isHovered,
    required this.isMenuExpanded,
    required this.deviceType,
    required this.onTap,
    required this.onLongPress,
    required this.onHover,
    required this.onMenuToggle,
    required this.onEditUser,
    required this.onDeleteUser,
    required this.onSoftDeleteUser,
    required this.onRestoreUser,
  });

  @override
  State<_UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<_UserListItem> {
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF737373);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color successColor = Color(0xFF059669);
  static const Color warningColor = Color(0xFFEA580C);
  static const Color infoColor = Color(0xFF1565C0);
  static const Color borderColor = Color(0xFFE5E7EB);

  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _showActions = widget.deviceType == DeviceType.mobile;
  }

  @override
  void didUpdateWidget(_UserListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deviceType == DeviceType.mobile && !_showActions) {
      _showActions = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = widget.deviceType == DeviceType.mobile;
    final isTablet = widget.deviceType == DeviceType.tablet;

    final bool shouldShowActions = true;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : isTablet ? 12 : 16,
        vertical: isMobile ? 4 : 6,
      ),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onHover: widget.onHover,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            border: Border.all(
              color: widget.isSelected 
                  ? primaryMaroon.withOpacity(0.3)
                  : borderColor,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (widget.isHovered || widget.isSelected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
          child: Row(
            children: [
              // Selection Checkbox
              if (widget.isSelectionMode) ...[
                _buildCheckbox(isMobile),
                SizedBox(width: isMobile ? 12 : 16),
              ],
              
              // User Avatar
              _buildUserAvatar(isMobile, isTablet),
              SizedBox(width: isMobile ? 12 : 16),
              
              // User Info
              Expanded(
                child: _buildUserInfo(isMobile, isTablet),
              ),
              
              // Action Buttons
                _buildActionButtons(isMobile, isTablet),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isMobile) {
    return Container(
      width: isMobile ? 20 : 24,
      height: isMobile ? 20 : 24,
      decoration: BoxDecoration(
        color: widget.isSelected ? primaryMaroon : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: widget.isSelected ? primaryMaroon : textTertiary,
          width: 2,
        ),
      ),
      child: widget.isSelected
          ? Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: isMobile ? 14 : 16,
            )
          : null,
    );
  }

  Widget _buildUserAvatar(bool isMobile, bool isTablet) {
    return Container(
      width: isMobile ? 40 : isTablet ? 48 : 56,
      height: isMobile ? 40 : isTablet ? 48 : 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryMaroon, darkMaroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
      ),
      child: Center(
        child: Text(
          UserUtils.getUserInitials(widget.user.name),
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 14 : isTablet ? 16 : 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name and Role
        Row(
          children: [
            Expanded(
              child: Text(
                widget.user.name,
                style: TextStyle(
                  fontSize: isMobile ? 16 : isTablet ? 17 : 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 8,
                vertical: isMobile ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: _getRoleColor(widget.user.roleType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _getRoleColor(widget.user.roleType).withOpacity(0.3),
                ),
              ),
              child: Text(
                widget.user.roleType,
                style: TextStyle(
                  color: _getRoleColor(widget.user.roleType),
                  fontSize: isMobile ? 10 : isTablet ? 11 : 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 4 : 6),
        
        // Department and Status
        Row(
          children: [
            Expanded(
              child: Text(
                widget.user.department,
                style: TextStyle(
                  fontSize: isMobile ? 13 : isTablet ? 14 : 15,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 8,
                vertical: isMobile ? 2 : 3,
              ),
              decoration: BoxDecoration(
                color: widget.user.active 
                    ? successColor.withOpacity(0.1)
                    : warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.user.active ? successColor : warningColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    widget.user.active ? 'Active' : 'Archived',
                    style: TextStyle(
                      color: widget.user.active ? successColor : warningColor,
                      fontSize: isMobile ? 10 : 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        // User ID (only on larger screens)
        if (!isMobile) ...[
          SizedBox(height: 4),
          Text(
            'ID: ${widget.user.id}',
            style: TextStyle(
              fontSize: isTablet ? 12 : 13,
              color: textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile, bool isTablet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit Button
          _ActionButton(
            icon: Icons.edit_rounded,
            tooltip: 'Edit User',
            color: infoColor,
            isMobile: isMobile,
            onPressed: () => _showEditUser(),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          
          // Archive/Restore Button
          _ActionButton(
            icon: widget.user.active 
                ? Icons.archive_rounded 
                : Icons.restore_rounded,
            tooltip: widget.user.active ? 'Archive User' : 'Restore User',
            color: widget.user.active ? warningColor : successColor,
            isMobile: isMobile,
            onPressed: () => _showArchiveUser(),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          
          // More Options Menu
          _buildMoreMenu(isMobile, isTablet),
        ],
      ),
    );
  }

  Widget _buildMoreMenu(bool isMobile, bool isTablet) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleMenuAction(value),
      onCanceled: () => widget.onMenuToggle(false),
      onOpened: () => widget.onMenuToggle(true),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, color: errorColor, size: 20),
              SizedBox(width: 12),
              Text('Delete User'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reset_password',
          child: Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: infoColor, size: 20),
              SizedBox(width: 12),
              Text('Reset Password'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'view_details',
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: textTertiary, size: 20),
              SizedBox(width: 12),
              Text('View Details'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: EdgeInsets.all(isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: textTertiary,
          size: isMobile ? 16 : 18,
        ),
      ),
    );
  }

  Widget _buildOverflowMenu(bool isMobile, bool isTablet) {
    return InkWell(
      onTap: () => setState(() => _showActions = true),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 8 : 10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Icon(
          Icons.more_vert_rounded,
          color: textTertiary,
          size: isMobile ? 16 : 18,
        ),
      ),
    );
  }

  Color _getRoleColor(String roleType) {
    switch (roleType) {
      case 'Admin':
        return Color(0xFF0D7377);
      case 'Super Admin':
        return Color(0xFF7B1FA2);
      case 'Organization':
        return Color(0xFF1565C0);
      case 'Adviser':
        return Color(0xFF2E7D32);
      case 'Staff':
        return Color(0xFFE65100);
      default: // User
        return primaryMaroon;
    }
  }

  void _showEditUser() {
  widget.onEditUser(widget.user);
}

  void _showArchiveUser() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        widget.user.active ? 'Archive User' : 'Restore User',
        style: TextStyle(color: primaryMaroon, fontWeight: FontWeight.w700),
      ),
      content: Text(
        widget.user.active
            ? 'Are you sure you want to archive "${widget.user.name}"? They will be moved to archived users.'
            : 'Are you sure you want to restore "${widget.user.name}"? They will be moved to active users.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: textTertiary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _performArchiveAction();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.user.active ? warningColor : successColor,
          ),
          child: Text(
            widget.user.active ? 'Archive' : 'Restore',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

  void _performArchiveAction() {
  if (widget.user.active) {
    widget.onSoftDeleteUser(widget.user);
  } else {
    widget.onRestoreUser(widget.user);
  }
}

  void _handleMenuAction(String action) {
  widget.onMenuToggle(false);
  
  switch (action) {
    case 'delete':
      _showDeleteConfirmation();
      break;
    case 'reset_password':
      _showResetPasswordConfirmation();
      break;
    case 'view_details':
      _showUserDetails();
      break;
  }
}

  void _showDeleteConfirmation() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Delete User',
        style: TextStyle(color: errorColor, fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Are you sure you want to permanently delete "${widget.user.name}"? This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: textTertiary)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _performDeleteAction();
          },
          style: ElevatedButton.styleFrom(backgroundColor: errorColor),
          child: Text('Delete', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

  void _performDeleteAction() {
  widget.onDeleteUser(widget.user);
}

  void _showResetPasswordConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: TextStyle(color: infoColor, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to reset the password for "${widget.user.name}"? They will receive an email with instructions to set a new password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performResetPassword();
            },
            style: ElevatedButton.styleFrom(backgroundColor: infoColor),
            child: Text('Reset Password', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _performResetPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset email sent successfully'),
        backgroundColor: successColor,
      ),
    );
  }

  void _showUserDetails() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.user.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16),
            _DetailRow(label: 'User ID', value: widget.user.id),
            _DetailRow(label: 'Department', value: widget.user.department),
            _DetailRow(label: 'Role', value: widget.user.roleType),
            _DetailRow(label: 'Status', value: widget.user.active ? 'Active' : 'Archived'),
            if (widget.user.username != null)
              _DetailRow(label: 'Username', value: widget.user.username!),
            if (widget.user.email != null)
              _DetailRow(label: 'Email', value: widget.user.email!),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryMaroon,
                  foregroundColor: Colors.white,
                ),
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final bool isMobile;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.isMobile,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 8 : 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            color: color,
            size: isMobile ? 16 : 18,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: const Color(0xFF737373)),
            ),
          ),
        ],
      ),
    );
  }
}