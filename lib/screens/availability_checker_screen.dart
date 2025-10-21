import 'package:flutter/material.dart';
import '../models/availability_checker_model.dart';
import '../services/availability_checker_services.dart';
import 'view_schedule_screen.dart';
import 'calendar_view_screen.dart'; // Import the new calendar screen

class AvailabilityCheckerScreen extends StatefulWidget {
  final AvailabilityResource resource;

  const AvailabilityCheckerScreen({Key? key, required this.resource}) : super(key: key);

  @override
  _AvailabilityCheckerScreenState createState() => _AvailabilityCheckerScreenState();
}

class _AvailabilityCheckerScreenState extends State<AvailabilityCheckerScreen>
    with TickerProviderStateMixin {
  // Enhanced Color Palette
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFBFF);

  bool _isLoading = false;
  List<ScheduleItem> _schedule = [];
  String? _errorMessage;
  bool _isCalendarView = false; // Toggle between list and calendar view

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final AvailabilityService _availabilityService = AvailabilityService();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward();
    _loadSchedule(); // Load schedule on init
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _schedule = []; // Clear schedule to prevent stale data
    });

    try {
      print('📡 Starting schedule load for resource: ${widget.resource.id}');
      final schedule = await _availabilityService.loadSchedule(widget.resource.id);
      
      // Process schedule to detect completed reservations
      final processedSchedule = _processCompletedReservations(schedule ?? []);
      
      setState(() {
        _schedule = processedSchedule;
        _isLoading = false;
      });

      print('✅ Final schedule count: ${_schedule.length}');
      for (int i = 0; i < _schedule.length; i++) {
        final isCompleted = _isReservationCompleted(_schedule[i]);
        print('✅ Final schedule item $i status: "${_schedule[i].status}" - Completed: $isCompleted');
      }
    } catch (e) {
      print('❌ Error loading schedule: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _schedule = []; // Ensure schedule is empty on error
      });
    }
  }

  /// Process reservations to detect completed ones
  List<ScheduleItem> _processCompletedReservations(List<ScheduleItem> schedule) {
    return schedule.map((reservation) {
      // For display purposes, we'll keep the original status but add completion detection
      // The actual completion display will be handled in the UI components
      return reservation;
    }).toList();
  }

  /// Check if a reservation is completed (approved and end date has passed)
  bool _isReservationCompleted(ScheduleItem reservation) {
    final status = reservation.status.toLowerCase();
    if (status != 'approved') return false;
    
    final now = DateTime.now().toUtc();
    return reservation.dateTo.isBefore(now);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: warmGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cardBackground, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryMaroon.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resource Availability',
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.w800,
                color: darkMaroon,
              ),
            ),
            Text(
              widget.resource.name,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          // View toggle button
          Container(
            margin: EdgeInsets.only(right: 8),
            child: ToggleButtons(
              children: [
                Tooltip(
                  message: 'List View',
                  child: Icon(Icons.list, size: 20),
                ),
                Tooltip(
                  message: 'Calendar View',
                  child: Icon(Icons.calendar_month, size: 20),
                ),
              ],
              isSelected: [!_isCalendarView, _isCalendarView],
              onPressed: (int index) {
                setState(() {
                  _isCalendarView = index == 1;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedBorderColor: primaryMaroon,
              selectedColor: Colors.white,
              fillColor: primaryMaroon,
              color: primaryMaroon,
              borderColor: primaryMaroon.withOpacity(0.3),
              constraints: BoxConstraints(
                minHeight: 36,
                minWidth: 36,
              ),
            ),
          ),
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: primaryMaroon),
            onPressed: _isLoading ? null : () {
              _loadSchedule();
            },
          ),
        ],
      ),
      body: SlideTransition(
        position: _slideAnimation,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryMaroon),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading schedule...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                        SizedBox(height: 16),
                        Text(
                          'Error',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadSchedule,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryMaroon,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : _isCalendarView
                    ? _buildCalendar(widget.resource)
                    : ViewScheduleScreen(
                        schedule: _schedule,
                      ),
      ),
    );
  }

  Widget _buildCalendar(AvailabilityResource res) {
    return OptimizedCalendarViewScreen(resource: res);
  }
}