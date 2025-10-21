import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
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


  @override
Widget build(BuildContext context) {
  final users = context.watch<UserService>().users;
  final deviceType = _getDeviceType(context);
  final isMobile = deviceType == DeviceType.mobile;
  final isTablet = deviceType == DeviceType.tablet;

  return Scaffold(
    backgroundColor: warmGray,
    appBar: AppBar(
      title: Text(
        'User Management',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: isMobile ? 18 : isTablet ? 20 : 22,
        ),
      ),
      backgroundColor: primaryMaroon,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: false,
      actions: [
        _buildAppBarAction(
          icon: Icons.refresh,
          onPressed: _loadUsers,
          tooltip: 'Refresh',
          isMobile: isMobile,
          isTablet: isTablet,
        ),
        _buildAppBarAction(
          icon: _isSelectionMode ? Icons.cancel : Icons.select_all,
          onPressed: _toggleSelectionMode,
          tooltip: _isSelectionMode ? 'Cancel Selection' : 'Select Users',
          isMobile: isMobile,
          isTablet: isTablet,
        ),
        if (_isSelectionMode && _selectedUserIds.isNotEmpty)
          _buildAppBarAction(
            icon: Icons.delete,
            onPressed: _deleteSelectedUsers,
            tooltip: 'Delete Selected',
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

        // Always show the tab structure, even if there are no users
        return Column(
          children: [
            // Tab Bar - Always Visible
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: UserTabsWidget(
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
            ),
            // Main Content Area
            Expanded(
              child: _buildMainContent(userService, deviceType),
            ),
          ],
        );
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

Widget _buildMainContent(UserService userService, DeviceType deviceType) {
  final isMobile = deviceType == DeviceType.mobile;
  final isTablet = deviceType == DeviceType.tablet;

  // Get users for current tab
  final currentTabUsers = _getFilteredUsers(
    userService.users,
    _tabController.index == 0
        ? "All"
        : _tabController.index == 1
            ? "Users"
            : _tabController.index == 2
                ? "Admin"
                : _tabController.index == 3
                    ? "Super Admin"
                    : "Archived",
  );

  // Check if current tab has any users (ignoring search)
  final currentTabHasUsers = _getCurrentTabHasUsers();

  return Column(
    children: [
      // Search Field
      Padding(
        padding: EdgeInsets.all(isMobile ? 6 : isTablet ? 8 : 12),
        child: Container(
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
              labelText: 'Search Users',
              labelStyle: TextStyle(fontSize: isMobile ? 14 : 16),
              hintText: 'Search by name, ID, department, role...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: isMobile ? 13 : 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: primaryMaroon,
                size: isMobile ? 20 : 24,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: Colors.grey[400],
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
        ),
      ),
      // Search results indicator
      if (_searchQuery.isNotEmpty)
        Container(
          margin: EdgeInsets.symmetric(
            horizontal: isMobile ? 6 : isTablet ? 8 : 12,
          ),
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
                  'Searching for: "$_searchQuery"',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: primaryMaroon,
                  ),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _clearAllFilters,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Icon(
                    Icons.clear_rounded,
                    color: Colors.red[600],
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      // Content Area - Shows either user list or empty state
      Expanded(
        child: _buildContentArea(userService, currentTabUsers, currentTabHasUsers, deviceType),
      ),
    ],
  );
}

Widget _buildContentArea(UserService userService, List<User> currentTabUsers, bool currentTabHasUsers, DeviceType deviceType) {
  // Show no search results if searching and no matches
  if (_searchQuery.isNotEmpty && currentTabUsers.isEmpty) {
    return _buildNoSearchResultsState(deviceType);
  }
  
  // Show empty state if tab is genuinely empty (no search active)
  if (currentTabUsers.isEmpty && _searchQuery.isEmpty && !currentTabHasUsers) {
    return _buildEmptyState(deviceType);
  }

  // Otherwise show the tab content
  return TabBarView(
    controller: _tabController,
    children: [
      _buildUserList(_getFilteredUsers(userService.users, "All")),
      _buildUserList(_getFilteredUsers(userService.users, "Users")),
      _buildUserList(_getFilteredUsers(userService.users, "Admin")),
      _buildUserList(_getFilteredUsers(userService.users, "Super Admin")),
      _buildUserList(_getFilteredUsers(userService.users, "Archived")),
    ],
  );
}

Widget _buildUserList(List<User> users) {
  return UserListWidget(
    users: users,
    selectedUserIds: _selectedUserIds,
    isSelectionMode: _isSelectionMode,
    onUserTap: (user) {
      if (_isSelectionMode) {
        _toggleUserSelection(user.id);
      } else {
        _editUser(user);
      }
    },
    onUserLongPress: _toggleUserSelection,
    onSelectAll: () => _selectAllUsers(users),
    onClearSelection: _clearSelection,
    deviceType: _getDeviceType(context),
    onEditUser: _editUser,
    onDeleteUser: _deleteUser,
    onSoftDeleteUser: _softDeleteUser,
    onRestoreUser: (user) {
      final userService = Provider.of<UserService>(context, listen: false);
      userService.restoreUser(user.id).then((success) {
        if (success) {
          if (mounted) {
            setState(() {
              _tabController.index = 0;
            });
            _loadUsers();
          }
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
      });
    },
  );
}

  Widget _buildAppBarAction({
  required IconData icon,
  required VoidCallback onPressed,
  required String tooltip,
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
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
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

  
bool _getCurrentTabHasUsers() {
  final userService = Provider.of<UserService>(context, listen: false);
  final allUsers = userService.users;
  
  switch (_tabController.index) {
    case 0: // All
      return allUsers.any((user) => user.active);
    case 1: // Users
      return allUsers.any((user) => user.active && user.roleId == "R01");
    case 2: // Admin
      return allUsers.any((user) => user.active && user.roleId == "R02");
    case 3: // Super Admin
      return allUsers.any((user) => user.active && user.roleId == "R03");
    case 4: // Archived
      return allUsers.any((user) => !user.active);
    default:
      return false;
  }
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