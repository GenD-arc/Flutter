// screens/optimized_calendar_view_screen.dart
import 'package:flutter/material.dart';
import '../models/availability_checker_model.dart';
import '../services/availability_checker_services.dart';
import '../utils/calendar_constants.dart';
import '../utils/philippines_time_utils.dart';
import '../utils/calendar_helpers.dart';
import 'widgets/calendar/calendar_header.dart';
import 'widgets/calendar/calendar_grid.dart';
import 'widgets/calendar/reservation_card.dart';
import 'widgets/calendar/calendar_legends.dart';
import 'widgets/calendar/calendar_stats.dart';
import 'widgets/calendar/calendar_states.dart';

class OptimizedCalendarViewScreen extends StatefulWidget {
  final AvailabilityResource resource;

  const OptimizedCalendarViewScreen({
    super.key,
    required this.resource,
  });

  @override
  State<OptimizedCalendarViewScreen> createState() => _OptimizedCalendarViewScreenState();
}

class _OptimizedCalendarViewScreenState extends State<OptimizedCalendarViewScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  List<ScheduleItem> _selectedDateReservations = [];
  bool _isLoadingMonth = false;
  bool _isCheckingAvailability = false;
  String? _errorMessage;
  
  // Store calendar data by month for caching
  final Map<String, Map<String, List<ScheduleItem>>> _monthlyCalendarData = {};
  final AvailabilityService _availabilityService = AvailabilityService();

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    final monthKey = PhilippinesTimeUtils.getMonthKey(_currentMonth);
    
    // Return cached data if available
    if (_monthlyCalendarData.containsKey(monthKey)) {
      return;
    }

    setState(() {
      _isLoadingMonth = true;
      _errorMessage = null;
    });

    try {
      // Load optimized calendar data for the month
      final calendarData = await _availabilityService.loadCalendarData(
        widget.resource.id, 
        monthKey
      );
      
      setState(() {
        _monthlyCalendarData[monthKey] = calendarData;
        _isLoadingMonth = false;
      });
      
      print('✅ Loaded calendar data for $monthKey: ${calendarData.length} days with reservations');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingMonth = false;
      });
      print('❌ Error loading monthly data: $e');
    }
  }

  void _onDateTapped(DateTime date) {
    final dayReservations = CalendarHelpers.getReservationsForDate(
      _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
      date,
    );
    
    setState(() {
      _selectedDate = date;
      _selectedDateReservations = dayReservations;
      _isCheckingAvailability = false;
    });

    print('📅 Selected date: ${PhilippinesTimeUtils.formatDateWithWeekday(date)}');
    print('📊 Found ${dayReservations.length} reservations for this date');
  }

  void _navigateMonth(int direction) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + direction);
      _selectedDate = null;
      _selectedDateReservations = [];
    });
    _loadMonthlyData();
  }

  void _jumpToCurrentDate() {
    setState(() {
      _currentMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
    _loadMonthlyData();
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
          // Header with resource info
          Container(
            padding: CalendarDimensions.getPadding(deviceType),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, 
                      color: CalendarColors.primaryMaroon, 
                      size: CalendarTextSizes.getBodySize(deviceType),
                    ),
                    SizedBox(width: CalendarDimensions.getSpacing(deviceType)),
                    Expanded(
                      child: Text(
                        'Reservation Details',
                        style: TextStyle(
                          fontSize: CalendarTextSizes.getTitleSize(deviceType),
                          fontWeight: FontWeight.bold,
                          color: CalendarColors.darkMaroon,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                // Resource info
                Container(
                  padding: EdgeInsets.all(CalendarDimensions.getSpacing(deviceType)),
                  decoration: BoxDecoration(
                    color: CalendarColors.primaryMaroon.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: CalendarColors.getResourceColor(widget.resource.category),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: CalendarDimensions.getSpacing(deviceType)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.resource.name,
                              style: TextStyle(
                                fontSize: CalendarTextSizes.getBodySize(deviceType),
                                fontWeight: FontWeight.bold,
                                color: CalendarColors.darkMaroon,
                              ),
                            ),
                            Text(
                              widget.resource.category,
                              style: TextStyle(
                                fontSize: CalendarTextSizes.getCaptionSize(deviceType),
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Scrollable content area
          Expanded(
            child: DateInfoWidget(
              selectedDate: _selectedDate,
              reservations: _selectedDateReservations,
              deviceType: deviceType,
              // ✅ CHANGED: Pass displayDate to ReservationCard
              reservationBuilder: (reservation) => ReservationCard(
                reservation: reservation,
                deviceType: deviceType,
                showResourceInfo: false, // Don't show resource info since it's already in header
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
      appBar: AppBar(
        title: Text(
          '${widget.resource.name} Calendar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: CalendarTextSizes.getTitleSize(deviceType),
          ),
        ),
        backgroundColor: CalendarColors.primaryMaroon,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildResponsiveLayout(deviceType),
    );
  }

  Widget _buildResponsiveLayout(DeviceType deviceType) {
    final isMobile = CalendarBreakpoints.isMobile(context);
    
    if (isMobile) {
      return _buildMobileLayout(deviceType);
    } else {
      return _buildDesktopLayout(deviceType);
    }
  }

  Widget _buildMobileLayout(DeviceType deviceType) {
    return Column(
      children: [
        // Calendar header with month navigation
        CalendarHeader(
          currentMonth: _currentMonth,
          onPreviousMonth: () => _navigateMonth(-1),
          onNextMonth: () => _navigateMonth(1),
          onMonthYearPicker: () => _showMonthYearPicker(deviceType),
          onJumpToToday: _jumpToCurrentDate,
          isLoading: _isLoadingMonth,
          deviceType: deviceType,
        ),
        
        // Loading indicator or error message
        if (_isLoadingMonth)
          Expanded(
            child: Container(
              padding: CalendarDimensions.getPadding(deviceType),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(CalendarColors.primaryMaroon),
                    ),
                    SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                    Text(
                      'Loading calendar...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_errorMessage != null)
          Expanded(
            child: CalendarErrorState(
              errorMessage: _errorMessage,
              onRetry: _loadMonthlyData,
              deviceType: deviceType,
            ),
          )
        else
          // Calendar grid and details
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CalendarGrid(
                    currentMonth: _currentMonth,
                    selectedDate: _selectedDate,
                    monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                    onDateTapped: _onDateTapped,
                    deviceType: deviceType,
                    enableHapticFeedback: false,
                    showResourceIndicators: false,
                  ),
                  
                  if (_selectedDate != null) 
                    DateInfoWidget(
                      selectedDate: _selectedDate,
                      reservations: _selectedDateReservations,
                      deviceType: deviceType,
                      // ✅ CHANGED: Pass displayDate to ReservationCard
                      reservationBuilder: (reservation) => ReservationCard(
                        reservation: reservation,
                        deviceType: deviceType,
                        showResourceInfo: false,
                        displayDate: _selectedDate, // Pass the selected date
                      ),
                    ),
                  
                  StatusLegend(deviceType: deviceType),
                  SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                  
                  MonthlyStatsWidget(
                    monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                    deviceType: deviceType,
                    showResourceBreakdown: false,
                  ),
                  SizedBox(height: CalendarDimensions.getSpacing(deviceType) * 2),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopLayout(DeviceType deviceType) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Calendar header
              CalendarHeader(
                currentMonth: _currentMonth,
                onPreviousMonth: () => _navigateMonth(-1),
                onNextMonth: () => _navigateMonth(1),
                onMonthYearPicker: () => _showMonthYearPicker(deviceType),
                onJumpToToday: _jumpToCurrentDate,
                isLoading: _isLoadingMonth,
                deviceType: deviceType,
              ),
              
              // Loading indicator or error message
              if (_isLoadingMonth)
                Expanded(
                  child: Container(
                    padding: CalendarDimensions.getPadding(deviceType),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(CalendarColors.primaryMaroon),
                          ),
                          SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                          Text(
                            'Loading calendar...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Expanded(
                  child: CalendarErrorState(
                    errorMessage: _errorMessage,
                    onRetry: _loadMonthlyData,
                    deviceType: deviceType,
                  ),
                )
              else
                // Calendar grid and stats
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CalendarGrid(
                          currentMonth: _currentMonth,
                          selectedDate: _selectedDate,
                          monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                          onDateTapped: _onDateTapped,
                          deviceType: deviceType,
                          enableHapticFeedback: false,
                          showResourceIndicators: false,
                        ),
                        
                        StatusLegend(deviceType: deviceType),
                        SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                        
                        MonthlyStatsWidget(
                          monthData: _monthlyCalendarData[PhilippinesTimeUtils.getMonthKey(_currentMonth)] ?? {},
                          deviceType: deviceType,
                          showResourceBreakdown: false,
                        ),
                        SizedBox(height: CalendarDimensions.getSpacing(deviceType)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Sidebar separator
        Container(
          width: 1,
          color: Colors.grey[200],
        ),
        
        // Details panel
        Expanded(
          flex: 2,
          child: _buildDetailsPanel(deviceType),
        ),
      ],
    );
  }

  Future<void> _showMonthYearPicker(DeviceType deviceType) async {
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
        _selectedDateReservations = [];
      });
      _loadMonthlyData();
    }
  }
}