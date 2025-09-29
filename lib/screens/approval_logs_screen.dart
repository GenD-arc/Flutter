import 'package:flutter/material.dart';
import '../models/approval_logs_model.dart';
import '../services/approval_logs_service.dart';

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
    final filters = ['All', 'Approved', 'Rejected'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: 6),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          final count = filter == 'All'
              ? filteredLogs.length
              : filteredLogs.where((log) => log.action?.toLowerCase() == filter.toLowerCase()).length;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: filter == filters.last ? 0 : 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter = filter;
                  });
                  _applyFilters();
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [primaryMaroon, lightMaroon],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.white, cardBackground],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? primaryMaroon.withOpacity(0.3)
                          : Colors.grey[300]!,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryMaroon.withOpacity(0.15),
                              blurRadius: 6,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        filter,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : isTablet ? 15 : 16, // Aligned with body text
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontSize: isMobile ? 10 : isTablet ? 11 : 12, // Aligned with captions
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white.withOpacity(0.9) : primaryMaroon,
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

  Widget _buildApprovalLogCard(ApprovalLog log, bool isMobile, bool isTablet, int index) {
    final isApproved = log.action?.toLowerCase() == 'approved';
    final actionColor = isApproved ? Colors.green : Colors.red;

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
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                          fontSize: isMobile ? 14 : isTablet ? 15 : 16, // Aligned with body text
                          fontWeight: FontWeight.w700,
                          color: darkMaroon,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Requested by ${log.requesterName ?? 'Unknown User'}',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : isTablet ? 13 : 14, // Aligned with secondary body text
                          color: textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
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
                      fontSize: isMobile ? 10 : isTablet ? 11 : 12, // Aligned with captions
                      fontWeight: FontWeight.w700,
                      color: actionColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
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
                  _buildDetailRow('Date & Time', _formatDateTime(log), isMobile, isTablet),
                  if (log.resourceLocation != null) ...[
                    Divider(height: 16, color: Colors.grey[300]),
                    _buildDetailRow('Description', log.resourceLocation.toString(), isMobile, isTablet),
                  ],
                  if (log.purpose != null) ...[
                    Divider(height: 16, color: Colors.grey[300]),
                    _buildDetailRow('Purpose', log.purpose.toString(), isMobile, isTablet),
                  ],
                  if (log.actionDate != null) ...[
                    Divider(height: 16, color: Colors.grey[300]),
                    _buildDetailRow(
                      'Action Date',
                      _formatActionDate(log.actionDate),
                      isMobile,
                      isTablet,
                    ),
                  ],
                  if (log.notes != null && log.notes!.isNotEmpty) ...[
                    Divider(height: 16, color: Colors.grey[300]),
                    _buildDetailRow('Notes', log.notes.toString(), isMobile, isTablet),
                  ],
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
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
                        fontSize: isMobile ? 10 : isTablet ? 11 : 12, // Aligned with captions
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
                        fontSize: isMobile ? 10 : isTablet ? 11 : 12, // Aligned with captions
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
                      fontSize: isMobile ? 10 : isTablet ? 11 : 12, // Aligned with captions
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w600,
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
    final reservationDate = log.reservationDate;
    final startTime = log.startTime;
    final endTime = log.endTime;

    if (reservationDate == null) return 'Not specified';

    try {
      final formattedDate = DateTime.parse(reservationDate).toLocal();
      final dateStr = '${formattedDate.day}/${formattedDate.month}/${formattedDate.year}';

      if (startTime != null && endTime != null) {
        return '$dateStr, $startTime - $endTime';
      } else {
        return dateStr;
      }
    } catch (e) {
      return reservationDate.toString();
    }
  }

  String _formatActionDate(String? dateTime) {
    if (dateTime == null) return 'Not specified';

    try {
      final parsedDate = DateTime.parse(dateTime).toLocal();
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year} at ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime.toString();
    }
  }
}

// Device Type Enum (aligned with DashboardScreen)
enum DeviceType {
  mobile,
  tablet,
  laptop,
  desktop,
}