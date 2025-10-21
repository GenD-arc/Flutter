import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/approval_logs_model.dart';
import '../services/approval_logs_service.dart';
import 'package:flutter/rendering.dart'; // For AnimatedRotation

class ApprovalLogsScreen extends StatefulWidget {
  final String approverId;
  final String token;

  const ApprovalLogsScreen({
    Key? key,
    required this.approverId,
    required this.token,
  }) : super(key: key);

  @override
  _ApprovalLogsScreenState createState() => _ApprovalLogsScreenState();
}

class _ApprovalLogsScreenState extends State<ApprovalLogsScreen>
    with TickerProviderStateMixin {
  // Enhanced Maroon Color Palette (aligned with DashboardScreen)
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color lightMaroon = Color(0xFFB71C1C);
  static const Color cardBackground = Color(0xFFFFFBFF);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF737373);
  static const Color errorColor = Color(0xFFDC2626);

  // Responsive breakpoints (aligned with DashboardScreen)
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  List<ApprovalLog> approvalLogs = [];
  List<ApprovalLog> filteredLogs = [];
  bool isLoading = true;
  String? error;
  String selectedFilter = 'All';
  String searchQuery = '';
  DateTimeRange? selectedDateRange;

  final Map<String, bool> _expandedCards = {};
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  final ApprovalLogsService _service = ApprovalLogsService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fetchApprovalLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Device type detection (aligned with DashboardScreen)
  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < desktopBreakpoint) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  Future<void> _fetchApprovalLogs() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final logs = await _service.fetchApprovalLogs(widget.approverId, widget.token);
      setState(() {
        approvalLogs = logs;
        _applyFilters();
        isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<ApprovalLog> results = List.from(approvalLogs);

    // Apply action filter
    if (selectedFilter != 'All') {
      results = results.where((log) =>
        log.action?.toLowerCase() == selectedFilter.toLowerCase()
      ).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      results = results.where((log) {
        final searchLower = searchQuery.toLowerCase();
        return (log.resourceName?.toLowerCase().contains(searchLower) ?? false) ||
               (log.requesterName?.toLowerCase().contains(searchLower) ?? false) ||
               (log.purpose?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    // Apply date range filter
    if (selectedDateRange != null) {
      results = results.where((log) {
        try {
          final actionDate = DateTime.parse(log.actionDate ?? '');
          return actionDate.isAfter(selectedDateRange!.start.subtract(Duration(days: 1))) &&
                 actionDate.isBefore(selectedDateRange!.end.add(Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    setState(() {
      filteredLogs = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = _getDeviceType(context);
    final isMobile = deviceType == DeviceType.mobile;
    final isTablet = deviceType == DeviceType.tablet;

    return Scaffold(
      backgroundColor: warmGray,
      body: Column(
        children: [
          _buildSearchAndFilters(isMobile, isTablet),
          _buildFilterTabs(isMobile, isTablet),
          Expanded(
            child: FadeTransition(
              opacity: _fadeController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutCubic,
                )),
                child: _buildContent(isMobile, isTablet),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildApprovalLogCard(ApprovalLog log, bool isMobile, bool isTablet, int index) {
  final isApproved = log.action?.toLowerCase() == 'approved';
  final actionColor = isApproved ? Colors.green : Colors.red;
  final hasDetailedSchedule = log.dailySlots.isNotEmpty;
  final isMultiDay = hasDetailedSchedule ? log.dailySlots.length > 1 : false;
  final cardKey = log.reservationId ?? 'card_$index';
  final isExpanded = _expandedCards[cardKey] ?? false;

  return AnimatedContainer(
    duration: Duration(milliseconds: 300 + (index * 50)),
    margin: EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white, cardBackground],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey[200]!, width: 1),
      boxShadow: [
        BoxShadow(
          color: actionColor.withOpacity(0.05),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _expandedCards[cardKey] = !isExpanded;
          });
        },
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row (always visible)
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          actionColor.withOpacity(0.15),
                          actionColor.withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: actionColor.withOpacity(0.1),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      isApproved ? Icons.check_circle_outline : Icons.cancel_outlined,
                      color: actionColor,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.resourceName ?? 'Unknown Resource',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : isTablet ? 15 : 16,
                            fontWeight: FontWeight.w700,
                            color: darkMaroon,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          'Requested by ${log.requesterName ?? 'Unknown User'}',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : isTablet ? 13 : 14,
                            color: textTertiary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action badge and expand icon
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              actionColor.withOpacity(0.15),
                              actionColor.withOpacity(0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: actionColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          log.action?.toUpperCase() ?? 'UNKNOWN',
                          style: TextStyle(
                            fontSize: isMobile ? 10 : isTablet ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: actionColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      AnimatedRotation(
                        duration: Duration(milliseconds: 300),
                        turns: isExpanded ? 0.5 : 0,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: primaryMaroon,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              
              // Collapsible Content
              AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                firstChild: _buildSummaryContent(log, isMobile, isTablet),
                secondChild: _buildExpandedContent(log, isMobile, isTablet),
              ),
              
              // Footer Badges (always visible)
              SizedBox(height: 8),
              _buildFooterBadges(log, isMobile, isTablet),
            ],
          ),
        ),
      ),
    ),
  );
}

// Summary content (collapsed state)
Widget _buildSummaryContent(ApprovalLog log, bool isMobile, bool isTablet) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
              _buildDetailRow('Date Range', _formatDateTime(log), isMobile, isTablet),
            if (log.purpose != null) ...[
              Divider(height: 16, color: Colors.grey[300]),
              _buildDetailRow('Purpose', log.purpose.toString(), isMobile, isTablet),
            ],
            if (log.actionDate != null) ...[
              Divider(height: 16, color: Colors.grey[300]),
              _buildDetailRow(
                'Reviewed on',
                _formatActionDate(log.actionDate),
                isMobile,
                isTablet,
              ),
            ],
          ],
        ),
      ),
      SizedBox(height: 8),
      // Hint text to show it's expandable
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: primaryMaroon.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primaryMaroon.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_rounded, size: 14, color: primaryMaroon),
            SizedBox(width: 6),
            Text(
              'Tap to view full details',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: primaryMaroon,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// Expanded content (when card is expanded)
Widget _buildExpandedContent(ApprovalLog log, bool isMobile, bool isTablet) {
  final hasDetailedSchedule = log.dailySlots.isNotEmpty;
  final isMultiDay = hasDetailedSchedule ? log.dailySlots.length > 1 : false;

  return Column(
    children: [
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey[50]!,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            // Date Range
            _buildDetailRow('Date Range', log.formattedDateTime, isMobile, isTablet),
            
            // Enhanced: Show schedule summary for multi-day reservations
            if (hasDetailedSchedule && isMultiDay) ...[
              Divider(height: 16, color: Colors.grey[300]),
              _buildDetailRow(
                'Schedule', 
                '${log.dailySlots.length} day(s) • ${_getFirstSlotTime(log)}', 
                isMobile, 
                isTablet
              ),
            ],
            
            // Show detailed daily slots
            if (hasDetailedSchedule) ...[
              Divider(height: 16, color: Colors.grey[300]),
              _buildDailySlotsSection(log, isMobile, isTablet),
            ],
            
            // Resource Location
            if (log.resourceLocation != null) ...[
              Divider(height: 16, color: Colors.grey[300]),
              _buildDetailRow('Location', log.resourceLocation.toString(), isMobile, isTablet),
            ],
            
            // Purpose
            if (log.purpose != null) ...[
              Divider(height: 16, color: Colors.grey[300]),
              _buildDetailRow('Purpose', log.purpose.toString(), isMobile, isTablet),
            ],
            
            // Action Date
            if (log.actionDate != null) ...[
              Divider(height: 16, color: Colors.grey[300]),
              _buildDetailRow(
                'Reviewed on',
                _formatActionDate(log.actionDate),
                isMobile,
                isTablet,
              ),
            ],
            
            // Notes/Comments
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              Divider(height: 16, color: Colors.grey[300]),
              _buildDetailRow('Review Notes', log.notes.toString(), isMobile, isTablet),
            ],
          ],
        ),
      ),
    ],
  );
}

// Helper method to get time from first slot
String _getFirstSlotTime(ApprovalLog log) {
  if (log.dailySlots.isEmpty) return 'No time specified';
  
  try {
    final firstSlot = log.dailySlots.first as Map<String, dynamic>;
    final startTime = firstSlot['start_time']?.toString() ?? '';
    final endTime = firstSlot['end_time']?.toString() ?? '';
    
    if (startTime.isNotEmpty && endTime.isNotEmpty) {
      final start = DateFormat('hh:mm a').format(
        DateTime.parse('2000-01-01 $startTime'),
      );
      final end = DateFormat('hh:mm a').format(
        DateTime.parse('2000-01-01 $endTime'),
      );
      return '$start - $end';
    }
    return '$startTime - $endTime';
  } catch (_) {
    return 'Time not specified';
  }
}

// Footer badges (separated for reusability)
Widget _buildFooterBadges(ApprovalLog log, bool isMobile, bool isTablet) {
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            'ID: ${log.reservationId ?? 'Unknown'}',
            style: TextStyle(
              fontSize: isMobile ? 10 : isTablet ? 11 : 12,
              color: textTertiary,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
      SizedBox(width: 6),
      if (log.stepOrder != null) ...[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            'Step ${log.stepOrder}',
            style: TextStyle(
              fontSize: isMobile ? 10 : isTablet ? 11 : 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 6),
      ],
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.purple[200]!),
        ),
        child: Text(
          log.resourceType ?? 'Resource',
          style: TextStyle(
            fontSize: isMobile ? 10 : isTablet ? 11 : 12,
            color: Colors.purple[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

  Widget _buildSearchAndFilters(bool isMobile, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: 12),
      child: Column(
        children: [
          Container(
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
                  searchQuery = value;
                });
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Search by resource, requester, or purpose...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: isMobile ? 14 : isTablet ? 15 : 16, // Aligned with body text
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: primaryMaroon),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchQuery = '';
                          });
                          _applyFilters();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showDateRangePicker,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: selectedDateRange != null
                          ? primaryMaroon.withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selectedDateRange != null
                            ? primaryMaroon.withOpacity(0.3)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          color: selectedDateRange != null
                              ? primaryMaroon
                              : Colors.grey[600],
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            selectedDateRange != null
                                ? '${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}'
                                : 'Select date range',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : isTablet ? 15 : 16, // Aligned with body text
                              fontWeight: FontWeight.w500,
                              color: selectedDateRange != null
                                  ? primaryMaroon
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (searchQuery.isNotEmpty || selectedDateRange != null) ...[
                SizedBox(width: 8),
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Icon(
                      Icons.filter_alt_off_rounded,
                      color: Colors.red[600],
                      size: 18,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isMobile, bool isTablet) {
  // Tab configurations with icons and colors
  final List<Map<String, dynamic>> tabConfigs = [
    {
      'title': 'All',
      'value': 'All',
      'icon': Icons.list_alt_rounded,
      'color': Color(0xFF5D4037),
    },
    {
      'title': 'Approved',
      'value': 'Approved',
      'icon': Icons.check_circle_outline,
      'color': Color(0xFF2E7D32),
    },
    {
      'title': 'Rejected',
      'value': 'Rejected',
      'icon': Icons.cancel_outlined,
      'color': Color(0xFFD32F2F),
    },
  ];

  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: isMobile ? 12 : 16,
      vertical: isMobile ? 8 : 12,
    ),
    decoration: BoxDecoration(
      color: cardBackground,
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabConfigs.map((config) {
          final isSelected = selectedFilter == config['value'];
          final tabColor = config['color'] as Color;
          final icon = config['icon'] as IconData;
          final title = config['title'] as String;
          final value = config['value'] as String;
          
          // Calculate count
          final count = value == 'All'
              ? filteredLogs.length
              : filteredLogs.where((log) => 
                  log.action?.toLowerCase() == value.toLowerCase()
                ).length;

          return Padding(
            padding: EdgeInsets.only(right: isMobile ? 6 : 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedFilter = value;
                  });
                  _applyFilters();
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : isTablet ? 14 : 16,
                    vertical: isMobile ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? tabColor.withOpacity(0.12) : warmGray,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected 
                          ? tabColor.withOpacity(0.4) 
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Icon(
                        icon,
                        size: isMobile ? 16 : 18,
                        color: isSelected ? tabColor : Colors.grey[600],
                      ),
                      SizedBox(width: isMobile ? 6 : 8),
                      
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : isTablet ? 14 : 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? tabColor : Colors.grey[700],
                          letterSpacing: 0.2,
                        ),
                      ),
                      
                      // Count Badge
                      SizedBox(width: isMobile ? 6 : 8),
                      Container(
                        constraints: BoxConstraints(minWidth: isMobile ? 24 : 28),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 6 : 8,
                          vertical: isMobile ? 2 : 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [primaryMaroon, lightMaroon],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : tabColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? primaryMaroon.withOpacity(0.3)
                                : tabColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$count',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : tabColor,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}


  Widget _buildContent(bool isMobile, bool isTablet) {
    if (isLoading) {
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
            SizedBox(height: 16),
            Text(
              'Loading approval logs...',
              style: TextStyle(
                color: textTertiary,
                fontSize: isMobile ? 14 : isTablet ? 15 : 16, // Aligned with body text
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, cardBackground],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: errorColor,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'Error Loading Logs',
                style: TextStyle(
                  fontSize: isMobile ? 18 : isTablet ? 20 : 22, // Aligned with titles
                  fontWeight: FontWeight.w800,
                  color: errorColor,
                ),
              ),
              SizedBox(height: 6),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: isMobile ? 12 : isTablet ? 13 : 14, // Aligned with secondary body text
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchApprovalLogs,
                icon: Icon(Icons.refresh_rounded),
                label: Text(
                  'Retry',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 15, // Aligned with button text
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

    if (filteredLogs.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, cardBackground],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  searchQuery.isNotEmpty || selectedDateRange != null
                      ? Icons.search_off_rounded
                      : Icons.history_outlined,
                  color: Colors.grey[400],
                  size: 48,
                ),
              ),
              SizedBox(height: 16),
              Text(
                searchQuery.isNotEmpty || selectedDateRange != null
                    ? 'No matching logs found'
                    : 'No approval logs found',
                style: TextStyle(
                  fontSize: isMobile ? 18 : isTablet ? 20 : 22, // Aligned with titles
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                searchQuery.isNotEmpty || selectedDateRange != null
                    ? 'Try adjusting your search or filters'
                    : 'You haven\'t reviewed any reservations yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textTertiary,
                  fontSize: isMobile ? 12 : isTablet ? 13 : 14, // Aligned with secondary body text
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (searchQuery.isNotEmpty || selectedDateRange != null) ...[
                SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: Icon(Icons.clear_all_rounded),
                  label: Text(
                    'Clear Filters',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 15, // Aligned with button text
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryMaroon,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: primaryMaroon,
      onRefresh: _fetchApprovalLogs,
      child: ListView.builder(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        itemCount: filteredLogs.length,
        itemBuilder: (context, index) {
          return _buildApprovalLogCard(filteredLogs[index], isMobile, isTablet, index);
        },
      ),
    );
  }

Widget _buildDailySlotsSection(ApprovalLog log, bool isMobile, bool isTablet) {
  final dailySlots = log.dailySlots;
  final isMultiDay = dailySlots.length > 1;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Schedule Header
      Row(
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: primaryMaroon),
          SizedBox(width: 8),
          Text(
            'Detailed Schedule',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              fontWeight: FontWeight.w600,
              color: darkMaroon,
            ),
          ),
          Spacer(),
          if (isMultiDay) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primaryMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${dailySlots.length} days',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: FontWeight.w700,
                  color: primaryMaroon,
                ),
              ),
            ),
          ],
        ],
      ),
      SizedBox(height: 8),
      
      // Daily Slots List
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: dailySlots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value as Map<String, dynamic>;
            final isLast = index == dailySlots.length - 1;
            final slotDate = _parseSlotDate(slot);
            final startTime = slot['start_time']?.toString() ?? '';
            final endTime = slot['end_time']?.toString() ?? '';
            
            String formatTime(String time) {
              try {
                return DateFormat('hh:mm a').format(DateTime.parse('2000-01-01 $time'));
              } catch (_) {
                return time;
              }
            }
            
            String formatSlotDate(DateTime? date) {
              if (date == null) return 'Invalid date';
              return DateFormat('MMMM dd, yyyy').format(date);
            }
            
            return Container(
              decoration: BoxDecoration(
                border: isLast ? null : Border(
                  bottom: BorderSide(color: Colors.grey[100]!),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryMaroon.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: primaryMaroon.withOpacity(0.2)),
                      ),
                      child: Text(
                        'Day ${index + 1}',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w700,
                          color: primaryMaroon,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    // Date and Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatSlotDate(slotDate),
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 15,
                              fontWeight: FontWeight.w600,
                              color: darkMaroon,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 14, color: textTertiary),
                              SizedBox(width: 4),
                              Text(
                                '${formatTime(startTime)} - ${formatTime(endTime)}',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 13,
                                  color: textTertiary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

// Add this helper method to your screen class
DateTime? _parseSlotDate(Map<String, dynamic> slotData) {
  try {
    final dateString = slotData['slot_date']?.toString();
    if (dateString == null) return null;
    final date = DateTime.parse(dateString);
    return date.add(const Duration(hours: 8)); // Convert to PH time
  } catch (_) {
    return null;
  }
}

  Widget _buildDetailRow(String label, String value, bool isMobile, bool isTablet) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: isMobile ? 80 : 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 14 : isTablet ? 15 : 16, // Aligned with body text
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : isTablet ? 15 : 16, // Aligned with body text
              color: darkMaroon,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: primaryMaroon,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      _applyFilters();
    }
  }

  void _clearAllFilters() {
    setState(() {
      searchQuery = '';
      selectedDateRange = null;
      selectedFilter = 'All';
    });
    _searchController.clear();
    _applyFilters();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(ApprovalLog log) {
  // ✅ Use the new formattedDateTime getter from the model
  return log.formattedDateTime;
}

String _formatActionDate(String? dateTime) {
  if (dateTime == null) return 'Not specified';

  try {
    final parsedDate = DateTime.parse(dateTime);
    // ✅ Use Philippine time formatting (UTC+8)
    final phTime = parsedDate.toUtc().add(const Duration(hours: 8));
    return DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(phTime);
  } catch (e) {
    return dateTime.toString();
  }
}

}

enum DeviceType {
  mobile,
  tablet,
  laptop,
  desktop,
}