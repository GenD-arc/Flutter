// screens/public_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/availability_checker_services.dart';
import '../models/availability_checker_model.dart';
import '../utils/calendar_constants.dart';
import '../utils/philippines_time_utils.dart';
import '../utils/calendar_helpers.dart';
import 'widgets/calendar/calendar_header.dart';
import 'widgets/calendar/calendar_grid.dart';
import 'widgets/calendar/calendar_filters.dart';
import 'widgets/calendar/reservation_card.dart';
import 'widgets/calendar/calendar_legends.dart';
import 'widgets/calendar/calendar_stats.dart';
import 'widgets/calendar/calendar_states.dart';

class PublicCalendarScreen extends StatefulWidget {
  const PublicCalendarScreen({super.key});

  @override
  State<PublicCalendarScreen> createState() => _PublicCalendarScreenState();
}

class _PublicCalendarScreenState extends State<PublicCalendarScreen> 
    with TickerProviderStateMixin {
  
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  List<ScheduleItem> _selectedDateReservations = [];
  bool _isLoadingMonth = false;
  String? _errorMessage;
  String _searchQuery = '';
  Set<String> _activeFilters = {'All'};
  late AnimationController _animationController;
  bool _vibrationEnabled = true;
  
  final Map<String, Map<String, List<ScheduleItem>>> _monthlyCalendarData = {};
  final AvailabilityService _availabilityService = AvailabilityService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: CalendarAnimations.normal,
      vsync: this,
    );
    _loadMonthlyData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMonthlyData() async {
    final monthKey = PhilippinesTimeUtils.getMonthKey(_currentMonth);
    
    if (_monthlyCalendarData.containsKey(monthKey)) {
      return;
    }

    setState(() {
      _isLoadingMonth = true;
      _errorMessage = null;
    });

    try {
      final calendarData = await _availabilityService.loadPublicCalendarData(monthKey);
      
      setState(() {
        _monthlyCalendarData[monthKey] = calendarData;
        _isLoadingMonth = false;
      });
      
      print('✅ Loaded PUBLIC calendar data for $monthKey: ${calendarData.length} days with reservations');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingMonth = false;
      });
      print('❌ Error loading public monthly data: $e');
    }
  }

  void _onDateTapped(DateTime date) async {
    if (_vibrationEnabled) {
      HapticFeedback.lightImpact();
    }
    
    _animationController.forward(from: 0);
    
    final dayReservations = CalendarHelpers.getReservationsForDate(
      _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
      date,
    );
    final filteredReservations = CalendarHelpers.filterReservations(
      dayReservations,
      _searchQuery,
      _activeFilters,
    );
    
    setState(() {
      _selectedDate = date;
      _selectedDateRange = null;
      _selectedDateReservations = filteredReservations;
    });

    print('📅 Selected date: ${PhilippinesTimeUtils.formatDateWithWeekday(date)}');
    print('📊 Found ${filteredReservations.length} filtered reservations for this date');
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _updateSelectedDateReservations();
    });
  }

  void _onFilterChanged(Set<String> filters) {
    setState(() {
      _activeFilters = filters;
      _updateSelectedDateReservations();
    });
  }

  void _updateSelectedDateReservations() {
    if (_selectedDate != null) {
      final dayReservations = CalendarHelpers.getReservationsForDate(
        _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
        _selectedDate!,
      );
      final filteredReservations = CalendarHelpers.filterReservations(
        dayReservations,
        _searchQuery,
        _activeFilters,
      );
      setState(() {
        _selectedDateReservations = filteredReservations;
      });
    } else if (_selectedDateRange != null) {
      final rangeReservations = CalendarHelpers.getReservationsForDateRange(
        _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
        _selectedDateRange!.start,
        _selectedDateRange!.end,
      );
      final filteredReservations = CalendarHelpers.filterReservations(
        rangeReservations,
        _searchQuery,
        _activeFilters,
      );
      setState(() {
        _selectedDateReservations = filteredReservations;
      });
    }
  }

  void _jumpToCurrentDate() {
    setState(() {
      _currentMonth = DateTime.now();
      _selectedDate = DateTime.now();
      _selectedDateRange = null;
    });
    _loadMonthlyData();
  }

  void _showCurrentWeek() {
    final now = PhilippinesTimeUtils.now();
    final startOfWeek = PhilippinesTimeUtils.getStartOfWeek(now);
    final endOfWeek = PhilippinesTimeUtils.getEndOfWeek(now);
    
    setState(() {
      _selectedDateRange = DateTimeRange(
        start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        end: DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day),
      );
      _selectedDate = null;
    });
    
    _updateSelectedDateReservations();
  }

  Future<void> _showMonthYearPicker() async {
    final deviceType = CalendarBreakpoints.getDeviceType(context);
    final isMobile = CalendarBreakpoints.isMobile(context);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: isMobile ? 0.9 : 1.0,
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _currentMonth = DateTime(picked.year, picked.month);
        _selectedDate = null;
        _selectedDateRange = null;
      });
      _loadMonthlyData();
    }
  }

  void _navigateMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + direction);
      _selectedDate = null;
      _selectedDateRange = null;
    });
    _loadMonthlyData();
  }

  Future<void> _onRefresh() async {
    await _loadMonthlyData();
  }

  Widget _buildDetailsPanel(DeviceType deviceType) {
    final monthKey = PhilippinesTimeUtils.getMonthKey(_currentMonth);
    final monthData = _monthlyCalendarData[monthKey] ?? {};
    
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with fixed height
          Container(
            padding: CalendarDimensions.getPadding(deviceType),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, 
                  color: CalendarColors.primaryMaroon, 
                  size: CalendarTextSizes.getBodySize(deviceType),
                ),
                SizedBox(width: CalendarDimensions.getSpacing(deviceType)),
                Text(
                  'Reservation Details',
                  style: TextStyle(
                    fontSize: CalendarTextSizes.getTitleSize(deviceType),
                    fontWeight: FontWeight.bold,
                    color: CalendarColors.darkMaroon,
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable content area
          Expanded(
            child: DateInfoWidget(
              selectedDate: _selectedDate,
              selectedDateRange: _selectedDateRange,
              reservations: _selectedDateReservations,
              deviceType: deviceType,
              // ✅ CHANGED: Pass displayDate to ReservationCard
              reservationBuilder: (reservation) => ReservationCard(
                reservation: reservation,
                deviceType: deviceType,
                showResourceInfo: true,
                displayDate: _selectedDate, // Pass the selected date
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceType = CalendarBreakpoints.getDeviceType(context);
    final isMobile = CalendarBreakpoints.isMobile(context);
    final isTablet = CalendarBreakpoints.isTablet(context);
    
    return Scaffold(
      backgroundColor: CalendarColors.warmGray,
      appBar: AppBar(
        title: Text(
          'Resource Calendar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: CalendarTextSizes.getTitleSize(deviceType),
          ),
        ),
        backgroundColor: CalendarColors.primaryMaroon,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        actions: [
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: isMobile ? 4 : isTablet ? 6 : 8, 
              vertical: 6
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                onTap: _jumpToCurrentDate,
                child: AnimatedContainer(
                  duration: CalendarAnimations.slow,
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
                    Icons.today,
                    color: Colors.white,
                    size: isMobile ? 16 : isTablet ? 18 : 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildResponsiveLayout(deviceType),
    );
  }

  Widget _buildResponsiveLayout(DeviceType deviceType) {
    final isMobile = CalendarBreakpoints.isMobile(context);
    final isTablet = CalendarBreakpoints.isTablet(context);
    
    if (isMobile) {
      return _buildMobileLayout(deviceType);
    } else if (isTablet) {
      return _buildTabletLayout(deviceType);
    } else {
      return _buildDesktopLayout(deviceType);
    }
  }

  Widget _buildMobileLayout(DeviceType deviceType) {
    return RefreshIndicator.adaptive(
      onRefresh: _onRefresh,
      color: CalendarColors.primaryMaroon,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            CalendarHeader(
              currentMonth: _currentMonth,
              onPreviousMonth: () => _navigateMonth(-1),
              onNextMonth: () => _navigateMonth(1),
              onMonthYearPicker: _showMonthYearPicker,
              onJumpToToday: _jumpToCurrentDate,
              onShowCurrentWeek: _showCurrentWeek,
              isLoading: _isLoadingMonth,
              deviceType: deviceType,
            ),
            
            CalendarFilters(
              searchQuery: _searchQuery,
              activeFilters: _activeFilters,
              onSearchChanged: _onSearchChanged,
              onFiltersChanged: _onFilterChanged,
              deviceType: deviceType,
            ),
            
            if (_isLoadingMonth && _monthlyCalendarData.isEmpty)
              CalendarLoadingState(deviceType: deviceType)
            else if (_errorMessage != null && _monthlyCalendarData.isEmpty)
              CalendarErrorState(
                errorMessage: _errorMessage,
                onRetry: _loadMonthlyData,
                deviceType: deviceType,
              )
            else if (_monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)]?.isEmpty ?? true)
              CalendarEmptyState(
                onAction: _jumpToCurrentDate,
                actionLabel: 'View Today',
                deviceType: deviceType,
              )
            else
              Column(
                children: [
                  CalendarGrid(
                    currentMonth: _currentMonth,
                    selectedDate: _selectedDate,
                    selectedDateRange: _selectedDateRange,
                    monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                    onDateTapped: _onDateTapped,
                    deviceType: deviceType,
                    enableHapticFeedback: _vibrationEnabled,
                    showResourceIndicators: true,
                  ),
                  
                  if (_selectedDate != null || _selectedDateRange != null) 
                    DateInfoWidget(
                      selectedDate: _selectedDate,
                      selectedDateRange: _selectedDateRange,
                      reservations: _selectedDateReservations,
                      deviceType: deviceType,
                      // ✅ CHANGED: Pass displayDate to ReservationCard
                      reservationBuilder: (reservation) => ReservationCard(
                        reservation: reservation,
                        deviceType: deviceType,
                        showResourceInfo: true,
                        displayDate: _selectedDate, // Pass the selected date
                      ),
                    ),
                  
                  StatusLegend(deviceType: deviceType),
                  SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                  ResourceLegend(deviceType: deviceType),
                  SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                  MonthlyStatsWidget(
                    monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                    deviceType: deviceType,
                    showResourceBreakdown: true,
                  ),
                  SizedBox(height: CalendarDimensions.getSpacing(deviceType) * 2),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(DeviceType deviceType) {
    return RefreshIndicator.adaptive(
      onRefresh: _onRefresh,
      color: CalendarColors.primaryMaroon,
      backgroundColor: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  CalendarHeader(
                    currentMonth: _currentMonth,
                    onPreviousMonth: () => _navigateMonth(-1),
                    onNextMonth: () => _navigateMonth(1),
                    onMonthYearPicker: _showMonthYearPicker,
                    onJumpToToday: _jumpToCurrentDate,
                    onShowCurrentWeek: _showCurrentWeek,
                    isLoading: _isLoadingMonth,
                    deviceType: deviceType,
                  ),
                  
                  CalendarFilters(
                    searchQuery: _searchQuery,
                    activeFilters: _activeFilters,
                    onSearchChanged: _onSearchChanged,
                    onFiltersChanged: _onFilterChanged,
                    deviceType: deviceType,
                  ),
                  
                  if (_isLoadingMonth && _monthlyCalendarData.isEmpty)
                    CalendarLoadingState(deviceType: deviceType)
                  else if (_errorMessage != null && _monthlyCalendarData.isEmpty)
                    CalendarErrorState(
                      errorMessage: _errorMessage,
                      onRetry: _loadMonthlyData,
                      deviceType: deviceType,
                    )
                  else if (_monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)]?.isEmpty ?? true)
                    CalendarEmptyState(
                      onAction: _jumpToCurrentDate,
                      actionLabel: 'View Today',
                      deviceType: deviceType,
                    )
                  else
                    Column(
                      children: [
                        CalendarGrid(
                          currentMonth: _currentMonth,
                          selectedDate: _selectedDate,
                          selectedDateRange: _selectedDateRange,
                          monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                          onDateTapped: _onDateTapped,
                          deviceType: deviceType,
                          enableHapticFeedback: _vibrationEnabled,
                          showResourceIndicators: true,
                        ),
                        
                        StatusLegend(deviceType: deviceType),
                        SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                        ResourceLegend(deviceType: deviceType),
                        SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                        MonthlyStatsWidget(
                          monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                          deviceType: deviceType,
                          showResourceBreakdown: true,
                        ),
                        SizedBox(height: CalendarDimensions.getSpacing(deviceType) * 2),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            color: Colors.grey[200],
          ),
          Expanded(
            flex: 1,
            child: _buildDetailsPanel(deviceType),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(DeviceType deviceType) {
    return RefreshIndicator.adaptive(
      onRefresh: _onRefresh,
      color: CalendarColors.primaryMaroon,
      backgroundColor: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  CalendarHeader(
                    currentMonth: _currentMonth,
                    onPreviousMonth: () => _navigateMonth(-1),
                    onNextMonth: () => _navigateMonth(1),
                    onMonthYearPicker: _showMonthYearPicker,
                    onJumpToToday: _jumpToCurrentDate,
                    onShowCurrentWeek: _showCurrentWeek,
                    isLoading: _isLoadingMonth,
                    deviceType: deviceType,
                  ),
                  
                  CalendarFilters(
                    searchQuery: _searchQuery,
                    activeFilters: _activeFilters,
                    onSearchChanged: _onSearchChanged,
                    onFiltersChanged: _onFilterChanged,
                    deviceType: deviceType,
                  ),
                  
                  if (_isLoadingMonth && _monthlyCalendarData.isEmpty)
                    CalendarLoadingState(deviceType: deviceType)
                  else if (_errorMessage != null && _monthlyCalendarData.isEmpty)
                    CalendarErrorState(
                      errorMessage: _errorMessage,
                      onRetry: _loadMonthlyData,
                      deviceType: deviceType,
                    )
                  else if (_monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)]?.isEmpty ?? true)
                    CalendarEmptyState(
                      onAction: _jumpToCurrentDate,
                      actionLabel: 'View Today',
                      deviceType: deviceType,
                    )
                  else
                    Column(
                      children: [
                        CalendarGrid(
                          currentMonth: _currentMonth,
                          selectedDate: _selectedDate,
                          selectedDateRange: _selectedDateRange,
                          monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                          onDateTapped: _onDateTapped,
                          deviceType: deviceType,
                          enableHapticFeedback: _vibrationEnabled,
                          showResourceIndicators: true,
                        ),
                        
                        StatusLegend(deviceType: deviceType),
                        SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                        ResourceLegend(deviceType: deviceType),
                        SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                        MonthlyStatsWidget(
                          monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                          deviceType: deviceType,
                          showResourceBreakdown: true,
                        ),
                        SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            color: Colors.grey[200],
          ),
          Expanded(
            flex: 2,
            child: _buildDetailsPanel(deviceType),
          ),
        ],
      ),
    );
  }
}