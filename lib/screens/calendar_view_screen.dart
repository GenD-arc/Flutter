import 'package:flutter/material.dart';
import '../models/availability_checker_model.dart';
import '../services/availability_checker_services.dart';

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
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFBFF);

  DateTime _currentMonth = DateTime.now();
  DateTime? _selectedDate;
  List<ScheduleItem> _selectedDateReservations = [];
  bool _isLoadingMonth = false;
  bool _isCheckingAvailability = false;
  String? _errorMessage;
  
  // Store calendar data by month for caching
  final Map<String, Map<String, List<ScheduleItem>>> _monthlyCalendarData = {};
  
  final AvailabilityService _availabilityService = AvailabilityService();

  // Philippines timezone offset (UTC+8)
  static const Duration philippinesOffset = Duration(hours: 8);

  // Status colors with enhanced visibility
  static const Map<String, Color> statusColors = {
    'approved': Color(0xFF4CAF50),
    'pending': Color(0xFFFF9800), 
    'cancelled': Color(0xFF9E9E9E),
    'rejected': Color(0xFFF44336),
  };

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  // Convert UTC DateTime to Philippines time
  DateTime _toPhilippinesTime(DateTime utcTime) {
    return utcTime.add(philippinesOffset);
  }

  // Convert Philippines time to UTC for API calls
  DateTime _toUtcTime(DateTime philippinesTime) {
    return philippinesTime.subtract(philippinesOffset);
  }

  // Get current time in Philippines
  DateTime _nowInPhilippines() {
    return DateTime.now().toUtc().add(philippinesOffset);
  }

  String _getMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadMonthlyData() async {
    final monthKey = _getMonthKey(_currentMonth);
    
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

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Column(
        children: [
          // Calendar header with month navigation
          _buildCalendarHeader(),
          
          // Loading indicator or error message
          if (_isLoadingMonth)
            Container(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryMaroon),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Loading calendar...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
                  SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadMonthlyData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryMaroon,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Try Again'),
                  ),
                ],
              ),
            )
          else
            // Calendar grid
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildCalendarGrid(),
                    if (_selectedDate != null) _buildSelectedDateInfo(),
                    _buildLegend(),
                    _buildMonthlyStats(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    final philippinesNow = _nowInPhilippines();
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: _isLoadingMonth ? null : () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                    _selectedDate = null;
                    _selectedDateReservations = [];
                  });
                  _loadMonthlyData();
                },
                icon: Icon(Icons.chevron_left, color: primaryMaroon),
              ),
              Column(
                children: [
                  Text(
                    _getMonthYearString(_currentMonth),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkMaroon,
                    ),
                  ),
                  if (_isLoadingMonth)
                    SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryMaroon),
                      ),
                    ),
                ],
              ),
              IconButton(
                onPressed: _isLoadingMonth ? null : () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                    _selectedDate = null;
                    _selectedDateReservations = [];
                  });
                  _loadMonthlyData();
                },
                icon: Icon(Icons.chevron_right, color: primaryMaroon),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Current Philippines time display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primaryMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Current: ${_getPhilippinesTimeString(philippinesNow)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryMaroon,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          ...List.generate((daysInMonth + startingWeekday + 6) ~/ 7, (weekIndex) {
            return _buildWeekRow(weekIndex, daysInMonth, startingWeekday);
          }),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Container(
      decoration: BoxDecoration(
        color: primaryMaroon.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: weekdays.map((day) {
          return Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: darkMaroon,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeekRow(int weekIndex, int daysInMonth, int startingWeekday) {
    return Row(
      children: List.generate(7, (dayIndex) {
        final dayNumber = weekIndex * 7 + dayIndex - startingWeekday + 1;
        
        if (dayNumber <= 0 || dayNumber > daysInMonth) {
          return Expanded(child: Container(height: 70));
        }

        final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
        final dayReservations = _getReservationsForDate(date);
        final isSelected = _selectedDate != null && 
                          _selectedDate!.year == date.year &&
                          _selectedDate!.month == date.month &&
                          _selectedDate!.day == date.day;
        final isToday = _isToday(date);
        final isPastDate = _isPastDate(date);

        return Expanded(
          child: GestureDetector(
            onTap: () => _onDateTapped(date),
            child: Container(
              height: 70,
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: isSelected 
                    ? primaryMaroon.withOpacity(0.2)
                    : isToday 
                        ? primaryMaroon.withOpacity(0.1)
                        : isPastDate
                            ? Colors.grey.withOpacity(0.05)
                            : Colors.transparent,
                border: isSelected 
                    ? Border.all(color: primaryMaroon, width: 2)
                    : isToday
                        ? Border.all(color: primaryMaroon, width: 1)
                        : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                          ? primaryMaroon 
                          : isPastDate 
                              ? Colors.grey[400]
                              : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  _buildDayIndicators(dayReservations),
                  if (dayReservations.isNotEmpty)
                    Text(
                      '${dayReservations.length}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayIndicators(List<ScheduleItem> reservations) {
    if (reservations.isEmpty) {
      return Container(height: 12);
    }

    // Group by status and show colored dots (max 4 dots)
    final statusCounts = <String, int>{};
    for (final reservation in reservations) {
      statusCounts[reservation.status.toLowerCase()] = 
          (statusCounts[reservation.status.toLowerCase()] ?? 0) + 1;
    }

    final statusEntries = statusCounts.entries.toList();
    final maxDots = 4;
    
    return Container(
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...statusEntries.take(maxDots).map((entry) {
            return Container(
              width: 4,
              height: 4,
              margin: EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: statusColors[entry.key] ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }).toList(),
          if (statusEntries.length > maxDots)
            Text(
              '...',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    if (_selectedDate == null) return Container();

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: primaryMaroon, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getFormattedDate(_selectedDate!),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkMaroon,
                  ),
                ),
              ),
              if (_isPastDate(_selectedDate!))
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PAST',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          
          if (_isCheckingAvailability)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryMaroon),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Checking availability...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else if (_selectedDateReservations.isEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isPastDate(_selectedDate!)
                          ? 'No reservations were scheduled for this date'
                          : 'Available - No reservations for this date',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Reservations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkMaroon,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryMaroon.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedDateReservations.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryMaroon,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ..._selectedDateReservations.map((reservation) => 
                  _buildReservationCard(reservation)).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(ScheduleItem reservation) {
    final statusColor = statusColors[reservation.status.toLowerCase()] ?? Colors.grey;
    final isMultiDay = _isMultiDayReservation(reservation);
    
    // Convert times to Philippines timezone for display
    final startPhTime = _toPhilippinesTime(reservation.dateFrom);
    final endPhTime = _toPhilippinesTime(reservation.dateTo);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  reservation.status.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isMultiDay) ...[
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'MULTI-DAY',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isMultiDay 
                        ? '${_getDateString(startPhTime)} - ${_getDateString(endPhTime)}'
                        : '${_getPhilippinesTimeString(startPhTime)} - ${_getPhilippinesTimeString(endPhTime)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'PST',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            reservation.purpose,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.person, size: 14, color: Colors.grey[600]),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  reservation.reservedBy,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Text(
                'ID: ${reservation.reservationId}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Legend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkMaroon,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: statusColors.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    final monthKey = _getMonthKey(_currentMonth);
    final monthData = _monthlyCalendarData[monthKey] ?? {};
    
    if (monthData.isEmpty) return Container();

    // Calculate statistics
    int totalReservations = 0;
    final statusCounts = <String, int>{};
    
    for (final dayReservations in monthData.values) {
      for (final reservation in dayReservations) {
        totalReservations++;
        final status = reservation.status.toLowerCase();
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryMaroon.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Statistics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkMaroon,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Total\nReservations', totalReservations.toString(), primaryMaroon),
              SizedBox(width: 12),
              _buildStatCard('Busy\nDays', monthData.length.toString(), Colors.orange),
              SizedBox(width: 12),
              _buildStatCard('Available\nDays', (DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day - monthData.length).toString(), Colors.green),
            ],
          ),
          if (statusCounts.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              'Status Breakdown',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkMaroon,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: statusCounts.entries.map((entry) {
                final percentage = (entry.value / totalReservations * 100).round();
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (statusColors[entry.key] ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (statusColors[entry.key] ?? Colors.grey).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${entry.key.toUpperCase()}: ${entry.value} ($percentage%)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColors[entry.key] ?? Colors.grey,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ScheduleItem> _getReservationsForDate(DateTime date) {
    final monthKey = _getMonthKey(_currentMonth);
    final monthData = _monthlyCalendarData[monthKey] ?? {};
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return monthData[dateKey] ?? [];
  }

  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    
    return dateOnly.isAtSameMomentAs(startOnly) ||
           dateOnly.isAtSameMomentAs(endOnly) ||
           (dateOnly.isAfter(startOnly) && dateOnly.isBefore(endOnly));
  }

  bool _isToday(DateTime date) {
    final today = _nowInPhilippines();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  bool _isPastDate(DateTime date) {
    final today = _nowInPhilippines();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    return dateOnly.isBefore(todayOnly);
  }

  bool _isMultiDayReservation(ScheduleItem reservation) {
    // Convert to Philippines time for comparison
    final startPhTime = _toPhilippinesTime(reservation.dateFrom);
    final endPhTime = _toPhilippinesTime(reservation.dateTo);
    
    final startDate = DateTime(
      startPhTime.year,
      startPhTime.month,
      startPhTime.day,
    );
    final endDate = DateTime(
      endPhTime.year,
      endPhTime.month,
      endPhTime.day,
    );
    return !startDate.isAtSameMomentAs(endDate);
  }

  void _onDateTapped(DateTime date) async {
    final dayReservations = _getReservationsForDate(date);
    
    setState(() {
      _selectedDate = date;
      _selectedDateReservations = dayReservations;
      _isCheckingAvailability = false;
    });

    // Provide immediate feedback with cached data
    // No need for additional API call since we have the data
    print('📅 Selected date: ${_getFormattedDate(date)}');
    print('📊 Found ${dayReservations.length} reservations for this date');
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getFormattedDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Philippines-specific time formatting
  String _getPhilippinesTimeString(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $amPm';
  }

  String _getDateString(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  // Full Philippines date-time string
  String _getFullPhilippinesDateTime(DateTime dateTime) {
    final phTime = _toPhilippinesTime(dateTime);
    return '${_getDateString(phTime)} ${_getPhilippinesTimeString(phTime)} PST';
  }
}