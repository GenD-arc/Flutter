import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testing/screens/dialog/unified_reservation_dialogs.dart';
import 'package:testing/services/auth_service.dart';
import 'package:testing/services/unified_reservation_service.dart';
import 'package:testing/models/unified_reservation_model.dart';
import 'package:testing/utils/app_design_system.dart';
import 'package:testing/screens/widgets/unified_reservation_card.dart';

class MyReservationsScreen extends StatefulWidget {
  final String userId;

  const MyReservationsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen>
    with TickerProviderStateMixin {
  late final UnifiedReservationService _reservationService;
  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _viewMode = 'Active'; // 'Active' or 'History'
  String _searchQuery = '';

  final _tabConfigs = [
    ('All', Icons.grid_view_rounded, Color(0xFF5D4037)),
    ('Pending', Icons.schedule_rounded, Color(0xFFF57C00)),
    ('Approved', Icons.check_circle_rounded, Color(0xFF2E7D32)),
    ('Rejected', Icons.cancel_rounded, Color(0xFFC62828)),
    ('Cancelled', Icons.block_rounded, Color(0xFF616161)),
    ('Completed', Icons.done_all_rounded, Color(0xFF1976D2)), // Added Completed tab
  ];

  @override
  void initState() {
    super.initState();
    _reservationService = context.read<UnifiedReservationService>();
    _tabController = TabController(length: _tabConfigs.length, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTabIndex = _tabController.index);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    final authService = context.read<AuthService>();
    if (authService.isAuthenticated &&
        authService.token != null &&
        authService.token!.isNotEmpty) {
      await _reservationService.fetchUserReservations(widget.userId);
    } else {
      _reservationService.clearData();
    }
  }

  List<UnifiedReservation> get _filteredReservations {
    var reservations = _reservationService.reservations;

    // Filter by view mode (Active vs History) - UPDATED
    if (_viewMode == 'Active') {
      // Active: pending or approved reservations that are NOT completed
      reservations = reservations.where((r) => r.isActive).toList();
    } else {
      // History: completed, rejected, or cancelled
      reservations = reservations.where((r) => r.isHistory).toList();
    }

    // Filter by tab status - UPDATED for completed
    final statuses = ['All', 'Pending', 'Approved', 'Rejected', 'Cancelled', 'Completed'];
    final selectedStatus = statuses[_selectedTabIndex];
    
    if (selectedStatus != 'All') {
      if (selectedStatus == 'Completed') {
        reservations = reservations.where((r) => r.isCompleted).toList();
      } else {
        reservations = reservations
            .where((r) => r.status.toLowerCase() == selectedStatus.toLowerCase())
            .toList();
      }
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      reservations = reservations.where((r) {
        return r.resourceName.toLowerCase().contains(query) ||
            r.purpose.toLowerCase().contains(query) ||
            r.facilityId.toLowerCase().contains(query);
      }).toList();
    }

    return reservations;
  }

  int _getCountForTab(int tabIndex) {
    var reservations = _reservationService.reservations;

    // Apply view mode filter first - UPDATED
    if (_viewMode == 'Active') {
      reservations = reservations.where((r) => r.isActive).toList();
    } else {
      reservations = reservations.where((r) => r.isHistory).toList();
    }

    // Then apply tab filter - UPDATED for completed
    switch (tabIndex) {
      case 0: // All
        return reservations.length;
      case 1: // Pending
        return reservations
            .where((r) => r.status.toLowerCase() == 'pending')
            .length;
      case 2: // Approved (only non-completed approved)
        return reservations
            .where((r) => r.status.toLowerCase() == 'approved' && !r.isCompleted)
            .length;
      case 3: // Rejected
        return reservations
            .where((r) => r.status.toLowerCase() == 'rejected')
            .length;
      case 4: // Cancelled
        return reservations
            .where((r) => r.status.toLowerCase() == 'cancelled')
            .length;
      case 5: // Completed
        return reservations
            .where((r) => r.isCompleted)
            .length;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 691.2;

    return Scaffold(
      backgroundColor: AppDesignSystem.warmGray,
      appBar: _buildAppBar(isMobile),
      body: Column(
        children: [
          _buildViewModeToggle(isMobile),
          _buildTabsBar(isMobile),
          if (_viewMode == 'History' || _searchQuery.isNotEmpty)
            _buildSearchBar(isMobile),
          Expanded(
            child: Consumer<UnifiedReservationService>(
              builder: (context, service, child) {
                if (service.isLoading && service.reservations.isEmpty) {
                  return _buildLoadingState();
                }

                if (service.errorMessage != null) {
                  return _buildErrorState(service.errorMessage!, isMobile);
                }

                final filteredReservations = _filteredReservations;

                if (filteredReservations.isEmpty) {
                  return _buildEmptyState(isMobile);
                }

                return _buildReservationsList(filteredReservations, isMobile);
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isMobile) {
    return AppBar(
      title: Text(
        'My Reservations',
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 18 : 21.6,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      backgroundColor: AppDesignSystem.primaryMaroon,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white, size: 21.6),
          onPressed: _loadReservations,
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildViewModeToggle(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14.4 : 18,
        vertical: isMobile ? 10.8 : 14.4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'Active',
                  label: Text('Active'),
                  icon: Icon(Icons.play_circle_outline_rounded, size: 18),
                ),
                ButtonSegment(
                  value: 'History',
                  label: Text('History'),
                  icon: Icon(Icons.history_rounded, size: 18),
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (newSelection) {
                setState(() {
                  _viewMode = newSelection.first;
                  _selectedTabIndex = 0;
                  _tabController.index = 0;
                  _searchQuery = '';
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppDesignSystem.primaryMaroon;
                  }
                  return Colors.transparent;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return AppDesignSystem.darkMaroon;
                }),
                side: WidgetStateProperty.all(
                  BorderSide(color: AppDesignSystem.primaryMaroon, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 14.4 : 18,
        vertical: isMobile ? 10.8 : 14.4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.9),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabConfigs.length, (index) {
            return _buildTabItem(_tabConfigs[index], index, isMobile);
          }),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    (String, IconData, Color) config,
    int index,
    bool isMobile,
  ) {
    final (title, icon, color) = config;
    final isSelected = _selectedTabIndex == index;
    final count = _getCountForTab(index);

    return Padding(
      padding: EdgeInsets.only(right: isMobile ? 7.2 : 10.8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _tabController.animateTo(index),
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.1),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 280),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.12) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color.withOpacity(0.4) : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? color : Colors.grey[600],
                ),
                SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? color : Colors.grey[700],
                  ),
                ),
                SizedBox(width: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.4, vertical: 7.2),
      padding: EdgeInsets.symmetric(horizontal: 14.4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[500], size: 20),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search reservations...',
                hintStyle: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey[500],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: Colors.grey[500], size: 18),
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(
    List<UnifiedReservation> reservations,
    bool isMobile,
  ) {
    return RefreshIndicator(
      onRefresh: _loadReservations,
      color: AppDesignSystem.primaryMaroon,
      child: ListView.builder(
        padding: EdgeInsets.all(isMobile ? 14.4 : 18),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return UnifiedReservationCard(
            reservation: reservation,
            isMobile: isMobile,
            showApprovalProgress: _viewMode == 'Active',
            onTap: () => _showReservationDetails(reservation, isMobile),
            onCancel: reservation.canCancel
                ? () => _showCancelDialog(reservation, isMobile)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: CircularProgressIndicator(
              strokeWidth: 3.6,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppDesignSystem.primaryMaroon),
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Loading reservations...',
            style: TextStyle(
              fontSize: 14.4,
              color: AppDesignSystem.darkMaroon,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage, bool isMobile) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14.4 : 21.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppDesignSystem.errorRed.withOpacity(0.09),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppDesignSystem.errorRed,
                  width: 1.35,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppDesignSystem.errorRed,
                size: 43.2,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Unable to load reservations',
              style: TextStyle(
                fontSize: isMobile ? 18 : 21.6,
                fontWeight: FontWeight.w700,
                color: AppDesignSystem.darkMaroon,
              ),
            ),
            SizedBox(height: 10.8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 10.8 : 12.6,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 21.6),
            ElevatedButton(
              onPressed: _loadReservations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppDesignSystem.primaryMaroon,
                foregroundColor: Colors.white,
                padding:
                    EdgeInsets.symmetric(horizontal: 28.8, vertical: 10.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.8),
                ),
              ),
              child: Text('Try Again', style: TextStyle(fontSize: 14.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    final isFiltered = _searchQuery.isNotEmpty || _selectedTabIndex != 0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14.4 : 21.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(21.6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.15),
                    Colors.blue.withOpacity(0.08)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isFiltered ? Icons.search_off_rounded : Icons.event_note_rounded,
                size: 57.6,
                color: Colors.blue[600],
              ),
            ),
            SizedBox(height: 21.6),
            Text(
              isFiltered
                  ? 'No reservations found'
                  : _viewMode == 'Active'
                      ? 'No active reservations'
                      : 'No reservation history',
              style: TextStyle(
                fontSize: isMobile ? 18 : 21.6,
                fontWeight: FontWeight.w700,
                color: AppDesignSystem.darkMaroon,
              ),
            ),
            SizedBox(height: 10.8),
            Text(
              isFiltered
                  ? 'Try adjusting your search or filter'
                  : _viewMode == 'Active'
                      ? 'Your active reservations will appear here'
                      : 'Your completed reservations will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 12.6 : 14.4,
                color: Colors.grey[600],
              ),
            ),
            if (isFiltered) ...[
              SizedBox(height: 21.6),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _tabController.index = 0;
                  });
                },
                icon: Icon(Icons.clear_all_rounded, size: 16),
                label: Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppDesignSystem.primaryMaroon,
                  foregroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 21.6, vertical: 10.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReservationDetails(
    UnifiedReservation reservation,
    bool isMobile,
  ) {
    showDialog(
      context: context,
      builder: (context) => UnifiedReservationDetailsDialog(
        reservation: reservation,
        isMobile: isMobile,
      ),
    );
  }

  void _showCancelDialog(UnifiedReservation reservation, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => UnifiedCancelReservationDialog(
        reservation: reservation,
        isMobile: isMobile,
        onConfirm: () async {
          _showCancelLoadingDialog();

          final success = await _reservationService
              .cancelReservation(reservation.id);

          Navigator.of(context).pop(); // Close loading dialog

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reservation cancelled successfully'),
                backgroundColor: AppDesignSystem.successGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.8),
                ),
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_reservationService.errorMessage ??
                    'Failed to cancel reservation'),
                backgroundColor: AppDesignSystem.errorRed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.8),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _showCancelLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(21.6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.09),
                blurRadius: 9,
                offset: Offset(0, 3.6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 2.7,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppDesignSystem.errorRed,
                  ),
                ),
              ),
              SizedBox(height: 14.4),
              Text(
                'Cancelling reservation...',
                style: TextStyle(
                  fontSize: 14.4,
                  fontWeight: FontWeight.w600,
                  color: AppDesignSystem.darkMaroon,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}