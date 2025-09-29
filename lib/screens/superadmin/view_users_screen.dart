import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../utils/user_utils.dart';
import '../../utils/device_type.dart';
import '../widgets/user_list_widget.dart';
import '../widgets/user_tabs_widget.dart';
import 'add_user_screen.dart';
import 'edit_user_screen.dart';

class ViewUsersScreen extends StatefulWidget {
  const ViewUsersScreen({super.key});

  @override
  State<ViewUsersScreen> createState() => _ViewUsersScreenState();
}

class _ViewUsersScreenState extends State<ViewUsersScreen>
    with SingleTickerProviderStateMixin {
      
  // Enhanced Maroon Color Palette (aligned with ApprovalLogsScreen)
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color cardBackground = Color(0xFFFFFBFF);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF737373);
  static const Color errorColor = Color(0xFFDC2626);

  // Responsive breakpoints (aligned with ApprovalLogsScreen)
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  static const LinearGradient maroonGradient = LinearGradient(
    colors: [darkMaroon, primaryMaroon, lightMaroon],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, cardBackground],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  final Set<String> _selectedRoles = {
    'User',
    'Admin',
    'Super Admin',
    'Organization',
    'Adviser',
    'Staff'
  };

  // Enhanced search implementation
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  late TabController _tabController;
  final Set<String> _selectedUserIds = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Device type detection (aligned with ApprovalLogsScreen)
  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < desktopBreakpoint) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  void _loadUsers() {
    final roleIds = _selectedRoles
        .map((roleType) => {
              'User': 'R01',
              'Admin': 'R02',
              'Super Admin': 'R03',
              'Organization': 'R01',
              'Adviser': 'R01',
              'Staff': 'R01',
            }[roleType])
        .whereType<String>()
        .toSet()
        .toList();

    context.read<UserService>().fetchUsers(
          status: "",
          roleIds: roleIds,
        );
  }

  // Enhanced filtering method that combines search with other filters
  List<User> _getFilteredUsers(List<User> users, String tab) {
    List<User> filtered = users.where((user) {
      switch (tab) {
        case "All":
          return user.active;
        case "Users":
          return user.active && user.roleId == "R01";
        case "Admin":
          return user.active && user.roleId == "R02";
        case "Super Admin":
          return user.active && user.roleId == "R03";
        case "Archived":
          return !user.active;
        default:
          return true;
      }
    }).toList();

    // Apply enhanced search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        return (user.name.toLowerCase().contains(query)) ||
               (user.id.toLowerCase().contains(query)) ||
               (user.department.toLowerCase().contains(query)) ||
               (user.roleType.toLowerCase().contains(query)) ||
               (user.username?.toLowerCase().contains(query) ?? false) ||
               (user.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  // Clear all filters method
  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
    });
    _searchController.clear();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedUserIds.clear();
      }
    });
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      if (_selectedUserIds.contains(userId)) {
        _selectedUserIds.remove(userId);
      } else {
        _selectedUserIds.add(userId);
      }
      if (_selectedUserIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAllUsers(List<User> users) {
    setState(() {
      _selectedUserIds.addAll(users.map((u) => u.id));
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedUserIds.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _editUser(User user) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditUserScreen(user: user),
      ),
    );

    if (result == true) {
      _loadUsers();
    }
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await _showDeleteConfirmationDialog(
      title: 'Delete User',
      message: 'Are you sure you want to delete "${user.name}"? This action cannot be undone.',
    );

    if (confirmed == true) {
      final userService = Provider.of<UserService>(context, listen: false);
      final success = await userService.deleteUser(user.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userService.errorMessage ?? 'Failed to delete user'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteSelectedUsers() async {
    if (_selectedUserIds.isEmpty) return;

    final confirmed = await _showDeleteConfirmationDialog(
      title: 'Delete Users',
      message: 'Are you sure you want to delete ${_selectedUserIds.length} selected user(s)? This action cannot be undone.',
    );

    if (confirmed == true) {
      final userService = Provider.of<UserService>(context, listen: false);
      final success = await userService.deleteMultipleUsers(_selectedUserIds.toList());

      if (success) {
        setState(() {
          _selectedUserIds.clear();
          _isSelectionMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Users deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userService.errorMessage ?? 'Failed to delete users'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _softDeleteUser(User user) async {
    final confirmed = await _showDeleteConfirmationDialog(
      title: 'Archive User',
      message: 'Are you sure you want to archive "${user.name}"? You can restore it later.',
    );

    if (confirmed == true) {
      final userService = Provider.of<UserService>(context, listen: false);
      final success = await userService.softDeleteUser(user.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User archived successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () async {
                final restoreSuccess = await userService.restoreUser(user.id);
                if (restoreSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User restored successfully'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(userService.errorMessage ?? 'Failed to restore user'),
                      backgroundColor: errorColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userService.errorMessage ?? 'Failed to archive user'),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmationDialog({
    required String title,
    required String message,
  }) async {
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            color: darkMaroon,
            fontSize: isMobile ? 18 : isTablet ? 20 : 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: textTertiary,
            fontSize: isMobile ? 14 : isTablet ? 15 : 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        ),
        backgroundColor: cardBackground,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: darkMaroon,
                fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserOptionsPopup(User user) {
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

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
                child: Container(color: Colors.transparent),
              ),
            ),
            Center(
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 350),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : isTablet ? 24 : 32,
                          vertical: isMobile ? 24 : isTablet ? 32 : 40,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: isMobile ? double.infinity : 400,
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                        ),
                        child: Material(
                          color: cardBackground,
                          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.08),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildUserHeader(user, isMobile, isTablet),
                                Flexible(
                                  child: SingleChildScrollView(
                                    physics: const ClampingScrollPhysics(),
                                    child: _buildOptionsSection(user, isMobile, isTablet),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserHeader(User user, bool isMobile, bool isTablet) {
    const Map<String, List<Color>> roleColors = {
      'User': [primaryMaroon, darkMaroon, lightMaroon],
      'Admin': [Color(0xFF0D7377), Color(0xFF14A085), Color(0xFF329D9C)],
      'Super Admin': [Color(0xFF7B1FA2), Color(0xFF9C27B0), Color(0xFFBA68C8)],
      'Organization': [Color(0xFF1565C0), Color(0xFF1976D2), Color(0xFF42A5F5)],
      'Adviser': [Color(0xFF2E7D32), Color(0xFF388E3C), Color(0xFF66BB6A)],
      'Staff': [Color(0xFFE65100), Color(0xFFFF9800), Color(0xFFFFB74D)],
    };

    final colors = roleColors[user.roleType] ?? roleColors['User']!;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
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
            width: isMobile ? 48 : isTablet ? 56 : 64,
            height: isMobile ? 48 : isTablet ? 56 : 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                UserUtils.getUserInitials(user.name),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 8 : isTablet ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 16 : isTablet ? 18 : 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'ID: ${user.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  user.department,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : isTablet ? 8 : 10,
              vertical: isMobile ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: user.active ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: user.active ? Colors.green.withOpacity(0.5) : Colors.orange.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              user.active ? 'Active' : 'Archived',
              style: TextStyle(
                color: user.active ? Colors.green[100] : Colors.orange[100],
                fontSize: isMobile ? 10 : isTablet ? 11 : 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(User user, bool isMobile, bool isTablet) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.edit_rounded,
                  label: 'Edit',
                  color: primaryMaroon,
                  onTap: () {
                    Navigator.pop(context);
                    _editUser(user);
                  },
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
              ),
              SizedBox(width: isMobile ? 8 : isTablet ? 12 : 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.info_outline_rounded,
                  label: 'Details',
                  color: const Color(0xFF1565C0),
                  onTap: () {
                    Navigator.pop(context);
                    _showUserDetails(user);
                  },
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : isTablet ? 12 : 16),
          _buildActionTile(
            icon: user.active ? Icons.archive_rounded : Icons.restore_rounded,
            title: user.active ? 'Archive User' : 'Restore User',
            subtitle: user.active ? 'Move to archived users' : 'Restore to active users',
            color: user.active ? Colors.orange : Colors.green,
            onTap: () {
              Navigator.pop(context);
              if (user.active) {
                _softDeleteUser(user);
              } else {
                final userService = Provider.of<UserService>(context, listen: false);
                userService.restoreUser(user.id).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('User restored successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    _loadUsers();
                  }
                });
              }
            },
            isMobile: isMobile,
            isTablet: isTablet,
          ),
          Divider(
            height: isMobile ? 16 : isTablet ? 20 : 24,
            thickness: 1,
            color: primaryMaroon.withOpacity(0.1),
          ),
          _buildActionTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete User',
            subtitle: 'Permanently remove user',
            color: errorColor,
            onTap: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            isMobile: isMobile,
            isTablet: isTablet,
            isDanger: true,
          ),
          SizedBox(height: isMobile ? 8 : isTablet ? 12 : 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 10 : isTablet ? 12 : 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                ),
                backgroundColor: Colors.grey[50],
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  color: textTertiary,
                  fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
    required bool isTablet,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 12 : isTablet ? 14 : 16,
          horizontal: isMobile ? 8 : isTablet ? 12 : 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, cardBackground],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : isTablet ? 10 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isMobile ? 18 : isTablet ? 20 : 22,
              ),
            ),
            SizedBox(height: isMobile ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isMobile,
    required bool isTablet,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : isTablet ? 16 : 20,
          vertical: isMobile ? 10 : isTablet ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: isDanger ? errorColor.withOpacity(0.05) : cardBackground,
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          border: isDanger
              ? Border.all(color: errorColor.withOpacity(0.1), width: 1)
              : Border.all(color: primaryMaroon.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 6 : isTablet ? 8 : 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isMobile ? 16 : isTablet ? 18 : 20,
              ),
            ),
            SizedBox(width: isMobile ? 8 : isTablet ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDanger ? errorColor : textPrimary,
                      fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textTertiary,
                      fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textTertiary,
              size: isMobile ? 12 : isTablet ? 14 : 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(User user) {
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(isMobile ? 12 : 16)),
      ),
      backgroundColor: cardBackground,
      builder: (context) => Container(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: isMobile ? 8 : isTablet ? 12 : 16),
              decoration: BoxDecoration(
                color: textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              user.name,
              style: TextStyle(
                fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                fontWeight: FontWeight.w800,
                color: darkMaroon,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ID: ${user.id}',
              style: TextStyle(
                fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                fontWeight: FontWeight.w600,
                color: textTertiary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Department: ${user.department}',
              style: TextStyle(
                fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                fontWeight: FontWeight.w600,
                color: textTertiary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Role: ${user.roleType}',
              style: TextStyle(
                fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                fontWeight: FontWeight.w600,
                color: textTertiary,
              ),
            ),
            if (user.username != null) ...[
              SizedBox(height: 8),
              Text(
                'Username: ${user.username}',
                style: TextStyle(
                  fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: textTertiary,
                ),
              ),
            ],
            if (user.email != null) ...[
              SizedBox(height: 8),
              Text(
                'Email: ${user.email}',
                style: TextStyle(
                  fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: textTertiary,
                ),
              ),
            ],
            SizedBox(height: isMobile ? 12 : isTablet ? 16 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: darkMaroon,
                      fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _editUser(user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryMaroon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                    ),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserService>().users;
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Scaffold(
      backgroundColor: warmGray,
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search users...',
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(Icons.search_rounded, color: primaryMaroon, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: Colors.grey[400], size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: TextStyle(
              fontSize: isMobile ? 14 : isTablet ? 15 : 16,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: darkMaroon,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            (isMobile ? 48 : isTablet ? 56 : 64) + // tabs height
            (_searchQuery.isNotEmpty ? 50 : 0) // search indicator height when active
          ),
          child: Column(
            children: [
              Container(
                height: 1,
                color: primaryMaroon.withOpacity(0.1),
              ),
              // Search indicator when active
              if (_searchQuery.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: primaryMaroon.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: primaryMaroon.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: primaryMaroon,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Searching for: "${_searchQuery}"',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: primaryMaroon,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: _clearAllFilters,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Icon(
                            Icons.clear_all_rounded,
                            color: Colors.red[600],
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              UserTabsWidget(
                tabController: _tabController,
                counts: {
                  "All": _getFilteredUsers(users, "All").length,
                  "Users": _getFilteredUsers(users, "Users").length,
                  "Admin": _getFilteredUsers(users, "Admin").length,
                  "Super Admin": _getFilteredUsers(users, "Super Admin").length,
                  "Archived": _getFilteredUsers(users, "Archived").length,
                },
                deviceType: deviceType,
              ),
            ],
          ),
        ),
        actions: [
          _buildAppBarAction(
            icon: Icons.refresh,
            onPressed: _loadUsers,
            tooltip: 'Refresh',
            color: primaryMaroon,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
          _buildAppBarAction(
            icon: _isSelectionMode ? Icons.cancel : Icons.select_all,
            onPressed: _toggleSelectionMode,
            tooltip: _isSelectionMode ? 'Cancel Selection' : 'Select Users',
            color: primaryMaroon,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
          if (_isSelectionMode && _selectedUserIds.isNotEmpty)
            _buildAppBarAction(
              icon: Icons.delete,
              onPressed: _deleteSelectedUsers,
              tooltip: 'Delete Selected',
              color: errorColor,
              isMobile: isMobile,
              isTablet: isTablet,
            ),
        ],
      ),
      body: Consumer<UserService>(
        builder: (context, userService, child) {
          if (userService.isLoading) {
            return _buildLoadingState(deviceType);
          }

          if (userService.errorMessage != null) {
            return _buildErrorState(userService.errorMessage!, deviceType);
          }

          final filteredUsers = _getFilteredUsers(userService.users, _tabController.index == 0
              ? "All"
              : _tabController.index == 1
                  ? "Users"
                  : _tabController.index == 2
                      ? "Admin"
                      : _tabController.index == 3
                          ? "Super Admin"
                          : "Archived");

          if (filteredUsers.isEmpty && _searchQuery.isEmpty) {
            return _buildEmptyState(deviceType);
          }

          return _buildMainContent(userService, filteredUsers, deviceType);
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: maroonGradient,
          borderRadius: BorderRadius.circular(isMobile ? 24 : isTablet ? 28 : 32),
          boxShadow: [
            BoxShadow(
              color: primaryMaroon.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddUserScreen()),
          ).then((result) {
            if (result == true) _loadUsers();
          }),
          backgroundColor: Colors.transparent,
          elevation: 0,
          mini: isMobile,
          tooltip: 'Add User',
          child: Icon(
            Icons.person_add_rounded,
            size: isMobile ? 20 : isTablet ? 24 : 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required Color color,
    required bool isMobile,
    required bool isTablet,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 4 : isTablet ? 6 : 8, vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            height: isMobile ? 32 : isTablet ? 36 : 40,
            width: isMobile ? 32 : isTablet ? 36 : 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isMobile ? 16 : isTablet ? 18 : 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(UserService userService, List<User> filteredUsers, DeviceType deviceType) {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUserList(_getFilteredUsers(userService.users, "All")),
              _buildUserList(_getFilteredUsers(userService.users, "Users")),
              _buildUserList(_getFilteredUsers(userService.users, "Admin")),
              _buildUserList(_getFilteredUsers(userService.users, "Super Admin")),
              _buildUserList(_getFilteredUsers(userService.users, "Archived")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserList(List<User> users) {
    final deviceType = _getDeviceType(context);

    // Show "no results" message if search is active but no results
    if (users.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoSearchResultsState(deviceType);
    }

    return UserListWidget(
      users: users,
      selectedUserIds: _selectedUserIds,
      isSelectionMode: _isSelectionMode,
      onUserTap: (user) => _isSelectionMode
          ? _toggleUserSelection(user.id)
          : _showUserOptionsPopup(user),
      onUserLongPress: _toggleUserSelection,
      onSelectAll: () => _selectAllUsers(users),
      onClearSelection: _clearSelection,
      deviceType: deviceType,
    );
  }

  Widget _buildNoSearchResultsState(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : isTablet ? 24 : 32),
        decoration: BoxDecoration(
          gradient: surfaceGradient,
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: Colors.grey[400],
                size: isMobile ? 40 : isTablet ? 48 : 56,
              ),
            ),
            SizedBox(height: isMobile ? 12 : isTablet ? 16 : 20),
            Text(
              'No matching users found',
              style: TextStyle(
                fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try adjusting your search term or clear the search.',
              style: TextStyle(
                color: textTertiary,
                fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 12 : isTablet ? 16 : 20),
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: Icon(Icons.clear_all_rounded),
              label: Text(
                'Clear Search',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: primaryMaroon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryMaroon),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: isMobile ? 12 : isTablet ? 16 : 20),
          Text(
            'Loading users...',
            style: TextStyle(
              color: textTertiary,
              fontSize: isMobile ? 14 : isTablet ? 15 : 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : isTablet ? 24 : 32),
        decoration: BoxDecoration(
          gradient: surfaceGradient,
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          border: Border.all(
            color: Colors.red[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: errorColor,
              size: isMobile ? 40 : isTablet ? 48 : 56,
            ),
            SizedBox(height: isMobile ? 12 : isTablet ? 16 : 20),
            Text(
              'Error Loading Users',
              style: TextStyle(
                fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                fontWeight: FontWeight.w800,
                color: errorColor,
              ),
            ),
            SizedBox(height: 6),
            Text(
              errorMessage,
              style: TextStyle(
                color: textSecondary,
                fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 12 : isTablet ? 16 : 20),
            ElevatedButton.icon(
              onPressed: _loadUsers,
              icon: Icon(Icons.refresh_rounded),
              label: Text(
                'Retry',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryMaroon,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(DeviceType deviceType) {
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Center(
      child: Container(
        padding: EdgeInsets.all(isMobile ? 12 : isTablet ? 16 : 20),
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : isTablet ? 24 : 32),
        decoration: BoxDecoration(
          gradient: surfaceGradient,
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.group_off,
                color: Colors.grey[400],
                size: isMobile ? 40 : isTablet ? 48 : 56,
              ),
            ),
            SizedBox(height: isMobile ? 12 : isTablet ? 16 : 20),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try adjusting your filters or add a new user.',
              style: TextStyle(
                color: textTertiary,
                fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 12 : isTablet ? 16 : 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddUserScreen()),
              ).then((result) {
                if (result == true) _loadUsers();
              }),
              icon: Icon(Icons.person_add_rounded),
              label: Text(
                'Add New User',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryMaroon,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}