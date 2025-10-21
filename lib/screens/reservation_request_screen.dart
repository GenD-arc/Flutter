import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/device_type.dart';

class DailyTimeSlot {
  DateTime date;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  DailyTimeSlot({
    required this.date,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    
    print('🔄 Converting date: $date -> $dateString');
    
    return {
      'date': dateString,
      'start_time': startTime != null 
        ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00'
        : null,
      'end_time': endTime != null
        ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00'
        : null,
    };
  }

  bool isComplete() {
    return startTime != null && endTime != null;
  }
}

class ReservationRequestScreen extends StatefulWidget {
  final String userId;
  final Resource selectedResource;

  const ReservationRequestScreen({
    Key? key,
    required this.userId,
    required this.selectedResource,
  }) : super(key: key);

  @override
  _ReservationRequestScreenState createState() => _ReservationRequestScreenState();
}

class _ReservationRequestScreenState extends State<ReservationRequestScreen>
    with TickerProviderStateMixin {
  // ==================== MSEUFCI OFFICIAL COLOR PALETTE ====================
 
  // Primary MSEUFCI Colors - "Maroon and White Forever"
  static const Color mseufMaroon = Color(0xFF8B0000); // Official MSEUFCI Maroon - primary brand color
  static const Color mseufMaroonDark = Color(0xFF4A1E1E); // Darker maroon for headers and emphasis
  static const Color mseufMaroonLight = Color(0xFFB71C1C); // Lighter maroon for highlights and accents
 
  // Official MSEUFCI White variations
  static const Color mseufWhite = Color(0xFFFFFFFF); // Pure white - secondary brand color
  static const Color mseufOffWhite = Color(0xFFFAFAFA); // Subtle off-white for backgrounds
  static const Color mseufCream = Color(0xFFF8F6F4); // Warm cream for elegant backgrounds
 
  // Neutral Foundation Colors (60% of design)
  static const Color backgroundPrimary = Color(0xFFFAFAFA); // Clean white background
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Slightly off-white
  static const Color surfacePrimary = Color(0xFFFFFBFF); // Pure white for cards and panels
  static const Color surfaceSecondary = Color(0xFFFBFBFB); // Very subtle off-white for secondary surfaces
  static const Color surfaceTertiary = Color(0xFFF0F0F0); // Light gray for dividers and borders
 
  // Text and Content Colors (using warmer tones to complement maroon)
  static const Color textSecondary = Color(0xFF404040); // Secondary text color
  static const Color textTertiary = Color(0xFF737373); // Light gray for tertiary text
 
  // On-Brand Colors (for text on colored backgrounds)
  static const Color onMaroon = Color(0xFFFFFFFF); // White text on maroon
 
  // Semantic Colors (adjusted to work well with maroon and white)
  static const Color successColor = Color(0xFF059669); // Green that complements maroon
  static const Color errorColor = Color(0xFFDC2626); // Red that harmonizes with maroon
  static const Color infoColor = Color(0xFF2563EB); // Blue for information
  static const Color warningColor = Color(0xFFD97706); // Amber for warnings
 
  // Gradients for premium feel using MSEUFCI colors
  static const LinearGradient maroonGradient = LinearGradient(
    colors: [mseufMaroonDark, mseufMaroon, mseufMaroonLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
 
  static const LinearGradient whiteGradient = LinearGradient(
    colors: [mseufWhite, mseufOffWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
 
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surfacePrimary, surfaceSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Responsive breakpoints
  static const double mobileBreakpoint = 768;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Layout constraints
  static const double maxTabletWidth = 600;
  static const double maxLaptopWidth = 1200;
  static const double maxDesktopWidth = 1600;

  // Reservation timing constants
  static const int MIN_ADVANCE_HOURS = 4; // Must book at least 4 hours ahead
  static const int URGENT_CUTOFF_HOURS = 12; // Less than 12 hours = urgent
  static const int SAME_DAY_WARNING_HOURS = 24; // Within 24 hours = same-day

  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  List<DailyTimeSlot> _dailySlots = [];
  
  bool _isSubmitting = false;
  bool _showTimingWarning = false;
  ReservationTiming _reservationTiming = ReservationTiming.normal;
  
  // Wizard state management
  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Purpose & Dates',
    'Time Slots',
    'Review & Submit'
  ];
  
  late AnimationController _fadeController;
  late AnimationController _slideController;

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

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Enhanced device type detection with layout classification
  DeviceType _getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    if (width < desktopBreakpoint) return DeviceType.laptop;
    return DeviceType.desktop;
  }

  // Layout classification for responsive behavior
  _LayoutType _getLayoutType(BuildContext context) {
    final deviceType = _getDeviceType(context);
   
    if (deviceType == DeviceType.mobile) return _LayoutType.mobile;
    if (deviceType == DeviceType.tablet) return _LayoutType.tablet;
    if (deviceType == DeviceType.laptop) return _LayoutType.laptop;
    return _LayoutType.desktop;
  }

  // Wizard navigation methods
  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _fadeController.forward(from: 0.0);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _fadeController.forward(from: 0.0);
    }
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _fadeController.forward(from: 0.0);
  }

  // Step validation methods
  bool _isStep1Valid() {
    return _purposeController.text.trim().isNotEmpty &&
           _purposeController.text.trim().length >= 10 &&
           _startDate != null &&
           _endDate != null;
  }

  bool _isStep2Valid() {
    return _dailySlots.isNotEmpty &&
           _dailySlots.every((slot) => slot.isComplete());
  }

  // Calculate reservation timing with both date AND time
  void _calculateReservationTiming() {
    if (_startDate == null || _dailySlots.isEmpty || _dailySlots[0].startTime == null) {
      setState(() {
        _showTimingWarning = false;
        _reservationTiming = ReservationTiming.normal;
      });
      return;
    }

    // Get the first slot's actual date and time
    final firstSlot = _dailySlots[0];
    final reservationDateTime = DateTime(
      firstSlot.date.year,
      firstSlot.date.month,
      firstSlot.date.day,
      firstSlot.startTime!.hour,
      firstSlot.startTime!.minute,
    );

    final now = DateTime.now();
    final hoursUntilStart = reservationDateTime.difference(now).inHours;
    
    print('🔍 TIMING DEBUG:');
    print('   Now: $now');
    print('   Reservation: $reservationDateTime');
    print('   Hours until start: $hoursUntilStart');

    ReservationTiming timing;
    bool showWarning = false;

    if (hoursUntilStart < MIN_ADVANCE_HOURS) {
      timing = ReservationTiming.tooLate;
      showWarning = true;
    } else if (hoursUntilStart < URGENT_CUTOFF_HOURS) {
      timing = ReservationTiming.urgent;
      showWarning = true;
    } else if (hoursUntilStart < SAME_DAY_WARNING_HOURS) {
      timing = ReservationTiming.sameDay;
      showWarning = true;
    } else {
      timing = ReservationTiming.normal;
      showWarning = false;
    }

    setState(() {
      _reservationTiming = timing;
      _showTimingWarning = showWarning;
    });
  }

  // Get timing warning message
  String _getTimingWarningMessage() {
    switch (_reservationTiming) {
      case ReservationTiming.tooLate:
        return '❌ Too late for online reservation\n\nThis reservation starts in less than $MIN_ADVANCE_HOURS hours. '
               'Please visit the facility office directly for last-minute requests.';
      
      case ReservationTiming.urgent:
        return '⚠️ Urgent Reservation Request\n\nThis reservation starts in less than $URGENT_CUTOFF_HOURS hours. '
               'Approval is not guaranteed and may require:\n'
               '• Phone call confirmation\n'
               '• Immediate payment (if applicable)\n'
               '• Limited facility preparation\n\n'
               'For guaranteed booking, reserve at least 24 hours in advance.';
      
      case ReservationTiming.sameDay:
        return '📋 Same-Day Reservation\n\nThis is a same-day reservation. Please note:\n'
               '• Approval depends on staff availability\n'
               '• Facility may not be fully prepared\n'
               '• Consider visiting the office for faster processing\n\n'
               'Next time, try to reserve 1-2 days in advance for better service.';
      
      case ReservationTiming.normal:
        return '✅ Good timing! Your reservation is well in advance.';
    }
  }

  // Get timing warning color
  Color _getTimingWarningColor() {
    switch (_reservationTiming) {
      case ReservationTiming.tooLate:
        return errorColor;
      case ReservationTiming.urgent:
        return warningColor;
      case ReservationTiming.sameDay:
        return infoColor;
      case ReservationTiming.normal:
        return successColor;
    }
  }

  // Get timing warning icon
  IconData _getTimingWarningIcon() {
    switch (_reservationTiming) {
      case ReservationTiming.tooLate:
        return Icons.block;
      case ReservationTiming.urgent:
        return Icons.warning_rounded;
      case ReservationTiming.sameDay:
        return Icons.info_rounded;
      case ReservationTiming.normal:
        return Icons.check_circle_rounded;
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  DateTime get _currentDateInPh {
    return DateTime.now();
  }

  void _generateDailySlots() {
    if (_startDate == null || _endDate == null) {
      _showMSEUFSnackBar('Please select both start and end dates first', warningColor);
      return;
    }

    final startDateOnly = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final endDateOnly = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
    final currentDateOnly = DateTime(_currentDateInPh.year, _currentDateInPh.month, _currentDateInPh.day);

    if (startDateOnly.isBefore(currentDateOnly)) {
      _showMSEUFSnackBar('Start date cannot be in the past', errorColor);
      return;
    }

    if (endDateOnly.isBefore(startDateOnly)) {
      _showMSEUFSnackBar('End date must be after or equal to start date', errorColor);
      return;
    }

    setState(() {
      _dailySlots.clear();
      DateTime currentDate = startDateOnly;
      
      while (currentDate.isBefore(endDateOnly) || currentDate.isAtSameMomentAs(endDateOnly)) {
        _dailySlots.add(DailyTimeSlot(date: currentDate));
        currentDate = currentDate.add(Duration(days: 1));
      }
      
      // Reset timing warning until times are selected
      _showTimingWarning = false;
      _reservationTiming = ReservationTiming.normal;
    });

    _showMSEUFSnackBar('${_dailySlots.length} day(s) added. Please set time for each day.', successColor);
    
    // Automatically navigate to step 2 after generating slots
    _nextStep();
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_dailySlots.isEmpty) {
      _showMSEUFSnackBar('Please generate daily slots first', errorColor);
      return;
    }

    // Block too-late reservations
    if (_reservationTiming == ReservationTiming.tooLate) {
      _showTimingRestrictionDialog();
      return;
    }

    // Show confirmation for urgent/same-day reservations
    if (_reservationTiming == ReservationTiming.urgent || _reservationTiming == ReservationTiming.sameDay) {
      final shouldProceed = await _showUrgentReservationConfirmation();
      if (!shouldProceed) {
        return;
      }
    }

    final incompleteSlots = _dailySlots.where((slot) => !slot.isComplete()).toList();
    if (incompleteSlots.isNotEmpty) {
      _showMSEUFSnackBar('Please set start and end time for all ${incompleteSlots.length} day(s)', errorColor);
      return;
    }

    for (var slot in _dailySlots) {
      final startMinutes = slot.startTime!.hour * 60 + slot.startTime!.minute;
      final endMinutes = slot.endTime!.hour * 60 + slot.endTime!.minute;
      
      if (endMinutes <= startMinutes) {
        _showMSEUFSnackBar(
          'End time must be after start time for ${DateFormat('MMM dd').format(slot.date)}',
          errorColor
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        _showMSEUFSnackBar('Authentication required. Please login again.', errorColor);
        setState(() => _isSubmitting = false);
        return;
      }

      final requestData = {
        'f_id': widget.selectedResource.id,
        'requester_id': widget.userId,
        'purpose': _purposeController.text.trim(),
        'daily_slots': _dailySlots.map((slot) => slot.toJson()).toList(),
      };

      final response = await http.post(
        Uri.parse('http://localhost:4000/api/user/requestReservation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _showMSEUFSnackBar(responseData['message'] ?? 'Reservation submitted successfully!', successColor);
        Navigator.pop(context, true);
      } else if (response.statusCode == 409) {
        final error = jsonDecode(response.body);
        _showConflictDialog(error);
      } else if (response.statusCode == 401) {
        _showMSEUFSnackBar('Session expired. Please login again.', errorColor);
      } else {
        final error = jsonDecode(response.body);
        _showMSEUFSnackBar(error['error'] ?? 'Failed to submit reservation', errorColor);
      }
    } catch (e) {
      print('❌ Reservation submission error: $e');
      if (e.toString().contains('TimeoutException')) {
        _showMSEUFSnackBar('Request timeout. Please try again.', errorColor);
      } else if (e.toString().contains('SocketException')) {
        _showMSEUFSnackBar('Network error. Please check your connection.', errorColor);
      } else {
        _showMSEUFSnackBar('Network error. Please try again.', errorColor);
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // Show timing restriction dialog for too-late reservations
  void _showTimingRestrictionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.schedule_rounded, color: errorColor),
              SizedBox(width: 8),
              Text('Reservation Not Available Online'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This reservation starts in less than $MIN_ADVANCE_HOURS hours.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Text(
                'For last-minute reservations:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 16, color: mseufMaroon),
                  SizedBox(width: 8),
                  Expanded(child: Text('Visit the facility office directly')),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone_rounded, size: 16, color: mseufMaroon),
                  SizedBox(width: 8),
                  Expanded(child: Text('Call for immediate assistance')),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.warning_rounded, size: 16, color: warningColor),
                  SizedBox(width: 8),
                  Expanded(child: Text('Subject to availability and additional requirements')),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Tip: For future reservations, please book at least $MIN_ADVANCE_HOURS hours in advance.',
                style: TextStyle(fontStyle: FontStyle.italic, color: textTertiary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: mseufMaroon)),
            ),
          ],
        );
      },
    );
  }

  // Show confirmation dialog for urgent/same-day reservations
  Future<bool> _showUrgentReservationConfirmation() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(_getTimingWarningIcon(), color: _getTimingWarningColor()),
              SizedBox(width: 8),
              Text('Confirm Reservation Timing'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getTimingWarningMessage(),
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: surfaceTertiary),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended for better service:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Reserve 1-2 days in advance\n• Visit office for urgent needs\n• Call to confirm availability',
                      style: TextStyle(fontSize: 11, color: textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel', style: TextStyle(color: textTertiary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getTimingWarningColor(),
                foregroundColor: onMaroon,
              ),
              child: Text('Proceed Anyway'),
            ),
          ],
        );
      },
    ) ?? false;
  }


  // Build timing warning widget
  Widget _buildTimingWarning(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;

    if (!_showTimingWarning) {
      // Show pending state when dates are selected but no times yet
      if (_startDate != null && _dailySlots.isNotEmpty && _dailySlots[0].startTime == null) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          decoration: BoxDecoration(
            color: infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: infoColor.withOpacity(0.3), width: 2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.schedule_rounded, color: infoColor, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '⏰ Please set your start time to see reservation timing information',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: _getTimingWarningColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getTimingWarningColor().withOpacity(0.3), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_getTimingWarningIcon(), color: _getTimingWarningColor(), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getTimingWarningMessage(),
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
                if (_reservationTiming == ReservationTiming.tooLate) ...[
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showTimingRestrictionDialog();
                      },
                      icon: Icon(Icons.info_rounded, size: 16),
                      label: Text('What should I do?'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _getTimingWarningColor(),
                        side: BorderSide(color: _getTimingWarningColor()),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showConflictDialog(Map<String, dynamic> conflictData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final conflicts = conflictData['conflicts'] as List<dynamic>;
        
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: warningColor),
              SizedBox(width: 8),
              Text('Time Slot Conflicts'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conflictData['message'] ?? 'Some time slots conflict with existing reservations.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
                if (conflicts.isNotEmpty) ...[
                  Text(
                    'Conflicting Time Slots:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ...conflicts.map((conflict) => Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: warningColor.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${_formatConflictDate(conflict['conflict_date'])}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text('Reserved: ${conflict['conflict_start_time']} - ${conflict['conflict_end_time']}'),
                        Text('Purpose: ${conflict['purpose']}'),
                        Text('Reserved by: ${conflict['reserved_by']}'),
                        Divider(),
                        Text(
                          'Your requested: ${_formatConflictDate(conflict['your_requested_date'])} • ${conflict['your_requested_start']} - ${conflict['your_requested_end']}',
                          style: TextStyle(color: errorColor, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: mseufMaroon)),
            ),
          ],
        );
      },
    );
  }

  String _formatConflictDate(String dateString) {
    try {
      final utcDate = DateTime.parse(dateString);
      final phDate = utcDate.add(Duration(hours: 8));
      return DateFormat('MMM dd, yyyy').format(phDate);
    } catch (e) {
      print('Error formatting conflict date: $e');
      return dateString;
    }
  }

  SnackBar _buildMSEUFSnackBar(String message, Color color) {
    return SnackBar(
      content: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: onMaroon.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info_rounded, color: onMaroon, size: 18),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: onMaroon,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.all(16),
      elevation: 8,
      duration: Duration(seconds: 3),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    );
  }

  void _showMSEUFSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      _buildMSEUFSnackBar(message, color),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: mseufMaroon,
              onPrimary: onMaroon,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final cleanDate = DateTime(picked.year, picked.month, picked.day);
      
      setState(() {
        if (isStartDate) {
          _startDate = cleanDate;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
            _dailySlots.clear();
          }
        } else {
          _endDate = cleanDate;
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _showMSEUFSnackBar('End date must be after or equal to start date', errorColor);
            _endDate = null;
            return;
          }
          _dailySlots.clear(); 
        }
      });
      
      // Recalculate timing when date changes
      _calculateReservationTiming();
      
      print('✅ Selected ${isStartDate ? 'start' : 'end'} date: $cleanDate');
    }
  }

  
// Also ensure the timing calculation is triggered properly
Future<void> _selectTimeForSlot(int index, bool isStartTime) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: mseufMaroon,
            onPrimary: onMaroon,
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      if (isStartTime) {
        _dailySlots[index].startTime = picked;
      } else {
        _dailySlots[index].endTime = picked;
      }
    });

    // Recalculate timing after ANY time is selected (not just first slot)
    _calculateReservationTiming();
  }
}
// Replace the _buildFormContainer method with this simplified version
Widget _buildFormContainer(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final isTablet = layoutType == _LayoutType.tablet;
 
  return Container(
    decoration: BoxDecoration(
      gradient: surfaceGradient,
      borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
      border: Border.all(color: surfaceTertiary, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: mseufMaroon.withOpacity(0.06),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: EdgeInsets.all(isMobile ? 20 : isTablet ? 24 : 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildResourceHeader(layoutType),
            SizedBox(height: isMobile ? 16 : 20),
            
            // Compact Wizard Progress
            _buildWizardProgress(layoutType),
            SizedBox(height: isMobile ? 16 : 20),
            
            // Step Content - No Expanded, just the content
            _buildCurrentStep(layoutType),
          ],
        ),
      ),
    ),
  );
}

// Update all layout methods to use proper constraints
Widget _buildMobileLayout() {
  return Scaffold(
    backgroundColor: backgroundPrimary,
    body: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _buildFormContainer(_LayoutType.mobile),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTabletLayout() {
  return Scaffold(
    backgroundColor: backgroundPrimary,
    body: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxTabletWidth,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: _buildFormContainer(_LayoutType.tablet),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildLaptopLayout() {
  return Scaffold(
    backgroundColor: backgroundPrimary,
    body: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxLaptopWidth,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Content Area (70%)
                    Expanded(
                      flex: 7,
                      child: _buildFormContainer(_LayoutType.laptop),
                    ),
                    SizedBox(width: 24),
                    // Sidebar (30%) - Fixed width to prevent overflow
                    Container(
                      width: 300, // Fixed width for sidebar
                      child: _buildTipsSidebar(_LayoutType.laptop),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildDesktopLayout() {
  return Scaffold(
    backgroundColor: backgroundPrimary,
    body: Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxDesktopWidth,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Content Area
                    Expanded(
                      flex: 8,
                      child: _buildFormContainer(_LayoutType.desktop),
                    ),
                    SizedBox(width: 32),
                    // Enhanced Sidebar - Fixed width
                    Container(
                      width: 350, // Fixed width for desktop sidebar
                      child: _buildTipsSidebar(_LayoutType.desktop),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Update the build method to use the new layout structure
@override
Widget build(BuildContext context) {
  final layoutType = _getLayoutType(context);
 
  return Scaffold(
    backgroundColor: backgroundPrimary,
    appBar: _buildMSEUFAppBar(layoutType),
    body: FadeTransition(
      opacity: _fadeController,
      child: _buildResponsiveLayout(layoutType),
    ),
  );
}

// Make the daily slots section more compact and ensure it doesn't overflow
Widget _buildDailySlotsSection(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      // More compact header
      Row(
        children: [
          Icon(Icons.access_time_rounded, color: mseufMaroon, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Daily Time Slots',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w700,
                color: mseufMaroonDark,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: mseufMaroon.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_dailySlots.where((s) => s.isComplete()).length}/${_dailySlots.length}',
              style: TextStyle(
                color: mseufMaroon,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 12),
      
      // Add a helpful hint for mobile users
      if (isMobile) ...[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: infoColor.withOpacity(0.2)),
          ),
          child: Text(
            '💡 Tap on time slots to set start and end times',
            style: TextStyle(
              fontSize: 12,
              color: textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 12),
      ],
      
      // Daily slots list - Limited to show max 5 at a time with scroll if needed
      if (_dailySlots.length > 5)
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 400, // Maximum height for the slots container
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(
                  _dailySlots.length,
                  (index) => _buildDailySlotCard(index, layoutType),
                ),
              ],
            ),
          ),
        )
      else
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(
              _dailySlots.length,
              (index) => _buildDailySlotCard(index, layoutType),
            ),
          ],
        ),
    ],
  );
}

// Update the daily slot card to be even more compact if needed
Widget _buildDailySlotCard(int index, _LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final slot = _dailySlots[index];
  final isComplete = slot.isComplete();
  
  return Container(
    margin: EdgeInsets.only(bottom: 8), // Reduced margin
    padding: EdgeInsets.all(isMobile ? 10 : 14), // Reduced padding
    decoration: BoxDecoration(
      color: isComplete ? successColor.withOpacity(0.05) : surfaceSecondary,
      borderRadius: BorderRadius.circular(10), // Slightly smaller radius
      border: Border.all(
        color: isComplete ? successColor.withOpacity(0.3) : mseufMaroon.withOpacity(0.2),
        width: 1.2, // Slightly thinner border
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact Header Row
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Smaller padding
              decoration: BoxDecoration(
                color: mseufMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5), // Smaller radius
              ),
              child: Text(
                'Day ${index + 1}',
                style: TextStyle(
                  color: mseufMaroon,
                  fontWeight: FontWeight.bold,
                  fontSize: 10, // Smaller font
                ),
              ),
            ),
            SizedBox(width: 6), // Reduced spacing
            Expanded(
              child: Text(
                DateFormat('EEE, MMM dd').format(slot.date),
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14, // Smaller font
                  fontWeight: FontWeight.w600,
                  color: mseufMaroonDark,
                ),
              ),
            ),
            if (isComplete)
              Icon(Icons.check_circle_rounded, color: successColor, size: 16), // Smaller icon
          ],
        ),
        SizedBox(height: 10), // Reduced spacing
        
        // Compact Time Selection - Horizontal layout
        Row(
          children: [
            // Start Time - More compact
            Expanded(
              child: _buildCompactTimePicker(
                label: 'Start',
                time: slot.startTime,
                onTap: () => _selectTimeForSlot(index, true),
                layoutType: layoutType,
              ),
            ),
            SizedBox(width: 6), // Reduced spacing
            // Arrow separator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Icon(Icons.arrow_forward_rounded, 
                color: textTertiary, 
                size: 14 // Smaller icon
              ),
            ),
            SizedBox(width: 6), // Reduced spacing
            // End Time - More compact
            Expanded(
              child: _buildCompactTimePicker(
                label: 'End',
                time: slot.endTime,
                onTap: () => _selectTimeForSlot(index, false),
                layoutType: layoutType,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
  // Enhanced responsive layout based on device type
  Widget _buildResponsiveLayout(_LayoutType layoutType) {
    switch (layoutType) {
      case _LayoutType.mobile:
        return _buildMobileLayout();
      case _LayoutType.tablet:
        return _buildTabletLayout();
      case _LayoutType.laptop:
        return _buildLaptopLayout();
      case _LayoutType.desktop:
        return _buildDesktopLayout();
    }
  }


// Update the _buildCurrentStep method to remove Expanded from step layouts
Widget _buildCurrentStep(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final isLaptop = layoutType == _LayoutType.laptop;
  final isDesktop = layoutType == _LayoutType.desktop;
  
  switch (_currentStep) {
    case 0:
      return _buildStep1(layoutType);
    case 1:
      return _buildStep2(layoutType);
    case 2:
      return _buildStep3(layoutType);
    default:
      return _buildStep1(layoutType);
  }
}

// Update Step 1 to remove Expanded
Widget _buildStep1(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final isLaptop = layoutType == _LayoutType.laptop;
  final isDesktop = layoutType == _LayoutType.desktop;
  
  if (isLaptop || isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Two-column layout for purpose and date range
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column - Purpose
            Expanded(
              child: _buildPurposeSection(layoutType),
            ),
            SizedBox(width: 24),
            // Right Column - Date Range (now includes navigation buttons)
            Expanded(
              child: _buildDateRangeSection(layoutType),
            ),
          ],
        ),
      ],
    );
  } else {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Purpose Section
        _buildPurposeSection(layoutType),
        SizedBox(height: isMobile ? 20 : 24),
        // Date Range Section (now includes navigation buttons)
        _buildDateRangeSection(layoutType),
      ],
    );
  }
}

// Fix the _buildTipsSidebar method - the condition is incorrect
Widget _buildTipsSidebar(_LayoutType layoutType) {
  final isDesktop = layoutType == _LayoutType.desktop;
  final isLaptop = layoutType == _LayoutType.laptop;
 
  return SingleChildScrollView(
    child: Column(
      children: [
        // Timing Warning/Urgency Section - UPPER PART
        // FIXED: Remove the complex condition and show based on _showTimingWarning
        if (_showTimingWarning || 
            (_currentStep >= 1 && _dailySlots.isNotEmpty && _dailySlots[0].startTime == null))
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16),
            padding: EdgeInsets.all(isLaptop ? 16 : 20),
            decoration: BoxDecoration(
              color: _getTimingWarningColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getTimingWarningColor().withOpacity(0.3), width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _showTimingWarning ? _getTimingWarningIcon() : Icons.schedule_rounded,
                      color: _showTimingWarning ? _getTimingWarningColor() : infoColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _showTimingWarning ? 'Reservation Timing' : 'Timing Info',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 15,
                        fontWeight: FontWeight.w700,
                        color: _showTimingWarning ? _getTimingWarningColor() : infoColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  _showTimingWarning 
                    ? _getTimingWarningMessage()
                    : '⏰ Please set your start time to see reservation timing information',
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : 12,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
                if (_reservationTiming == ReservationTiming.tooLate) ...[
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showTimingRestrictionDialog();
                      },
                      icon: Icon(Icons.info_rounded, size: 14),
                      label: Text('What should I do?'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _getTimingWarningColor(),
                        side: BorderSide(color: _getTimingWarningColor()),
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Reservation Tips Section - LOWER PART
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 180,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [mseufMaroon.withOpacity(0.02), mseufMaroon.withOpacity(0.01)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: mseufMaroon.withOpacity(0.2), width: 1.5),
          ),
          child: Padding(
            padding: EdgeInsets.all(isLaptop ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: mseufMaroon, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Reservation Tips',
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 15,
                        fontWeight: FontWeight.w700,
                        color: mseufMaroonDark,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ..._getReservationTips().map((tip) => Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: successColor, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontSize: isDesktop ? 13 : 12,
                            color: textSecondary,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Also fix the Step 2 and Step 3 methods to ensure timing warnings show in main content for mobile/tablet
Widget _buildStep2(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final isLaptop = layoutType == _LayoutType.laptop;
  final isDesktop = layoutType == _LayoutType.desktop;
  
  // FIXED: Correct the condition for showing timing warning in main content
  final showTimingWarningInMain = (isMobile || layoutType == _LayoutType.tablet) && _showTimingWarning;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Only show timing warning in main content for mobile/tablet
      if (showTimingWarningInMain) ...[
        _buildTimingWarning(layoutType),
        SizedBox(height: isMobile ? 20 : 24),
      ],
      
      // Daily Slots Section
      if (_dailySlots.isNotEmpty) _buildDailySlotsSection(layoutType),
      
      SizedBox(height: isMobile ? 28 : 32),
      
      // Navigation Buttons
      _buildStep2Navigation(layoutType),
    ],
  );
}

Widget _buildStep3(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final isLaptop = layoutType == _LayoutType.laptop;
  final isDesktop = layoutType == _LayoutType.desktop;
  
  // FIXED: Correct the condition for showing timing warning in main content
  final showTimingWarningInMain = (isMobile || layoutType == _LayoutType.tablet) && _showTimingWarning;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Reservation Summary
      _buildReservationSummary(layoutType),
      SizedBox(height: isMobile ? 20 : 24),
      // Only show timing warning in main content for mobile/tablet
      if (showTimingWarningInMain) ...[
        _buildTimingWarning(layoutType),
        SizedBox(height: isMobile ? 20 : 24),
      ],
      SizedBox(height: isMobile ? 28 : 32),
      // Navigation Buttons
      _buildStep3Navigation(layoutType),
    ],
  );
}
  
  // Replace the _buildWizardProgress method with this more compact version
Widget _buildWizardProgress(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final isTablet = layoutType == _LayoutType.tablet;
  
  return Container(
    padding: EdgeInsets.all(isMobile ? 12 : 16),
    decoration: BoxDecoration(
      color: surfaceSecondary,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: surfaceTertiary, width: 1),
    ),
    child: Column(
      children: [
        // Compact Step Indicators
        Row(
          children: List.generate(_stepTitles.length, (index) {
            final isActive = index == _currentStep;
            final isCompleted = index < _currentStep;
            final isLast = index == _stepTitles.length - 1;
            
            return Expanded(
              child: Row(
                children: [
                  // Step Circle - Smaller and more compact
                  Container(
                    width: isMobile ? 28 : 32,
                    height: isMobile ? 28 : 32,
                    decoration: BoxDecoration(
                      color: isActive 
                        ? mseufMaroon 
                        : isCompleted 
                          ? successColor 
                          : surfaceTertiary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check_rounded, color: onMaroon, size: isMobile ? 14 : 16)
                          : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isActive ? onMaroon : textTertiary,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                    ),
                  ),
                  
                  // Connector Line (except for last step)
                  if (!isLast) Expanded(
                    child: Container(
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: isCompleted ? successColor : surfaceTertiary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        
        SizedBox(height: 8),
        
        // Step Titles - Smaller and more compact
        Row(
          children: List.generate(_stepTitles.length, (index) {
            final isActive = index == _currentStep;
            final isCompleted = index < _currentStep;
            
            return Expanded(
              child: Text(
                _stepTitles[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 10 : 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive 
                    ? mseufMaroonDark 
                    : isCompleted 
                      ? successColor 
                      : textTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    ),
  );
}


// Update the Date Range Section to include the navigation buttons
Widget _buildDateRangeSection(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final isLaptop = layoutType == _LayoutType.laptop;
  final isDesktop = layoutType == _LayoutType.desktop;
 
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Select Date Range',
        style: TextStyle(
          fontSize: isMobile ? 18 : 20,
          fontWeight: FontWeight.w700,
          color: mseufMaroonDark,
        ),
      ),
      SizedBox(height: 16),
      
      // Side by side date pickers for ALL layouts
      _buildSideBySideDateRange(layoutType),
        
      SizedBox(height: 16),
      
      // Navigation Buttons (Cancel & Continue) - Replacing the old Generate Slots button
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: mseufMaroon,
                side: BorderSide(color: mseufMaroon),
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isStep1Valid() ? _generateDailySlotsAndNavigate : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isStep1Valid() ? infoColor : surfaceTertiary,
                foregroundColor: onMaroon,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward_rounded, size: isMobile ? 18 : 20),
                  SizedBox(width: 8),
                  Text(
                    'Continue to Time Slots',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// Remove the old _buildStep1Navigation method entirely

// Keep the combined generation and navigation method
void _generateDailySlotsAndNavigate() {
  if (_startDate == null || _endDate == null) {
    _showMSEUFSnackBar('Please select both start and end dates first', warningColor);
    return;
  }

  final startDateOnly = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
  final endDateOnly = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
  final currentDateOnly = DateTime(_currentDateInPh.year, _currentDateInPh.month, _currentDateInPh.day);

  if (startDateOnly.isBefore(currentDateOnly)) {
    _showMSEUFSnackBar('Start date cannot be in the past', errorColor);
    return;
  }

  if (endDateOnly.isBefore(startDateOnly)) {
    _showMSEUFSnackBar('End date must be after or equal to start date', errorColor);
    return;
  }

  setState(() {
    _dailySlots.clear();
    DateTime currentDate = startDateOnly;
    
    while (currentDate.isBefore(endDateOnly) || currentDate.isAtSameMomentAs(endDateOnly)) {
      _dailySlots.add(DailyTimeSlot(date: currentDate));
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    // Reset timing warning until times are selected
    _showTimingWarning = false;
    _reservationTiming = ReservationTiming.normal;
  });

  _showMSEUFSnackBar('${_dailySlots.length} day(s) generated. Please set time for each day.', successColor);
  
  // Navigate to Step 2
  _nextStep();
}

// Remove the old _regenerateDailySlots method since we don't need it anymore
  
  // Step Navigation Buttons
  Widget _buildStep1Navigation(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: mseufMaroon,
              side: BorderSide(color: mseufMaroon),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isStep1Valid() ? _generateDailySlots : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isStep1Valid() ? infoColor : surfaceTertiary,
              foregroundColor: onMaroon,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Continue to Time Slots',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Navigation(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _previousStep,
            style: OutlinedButton.styleFrom(
              foregroundColor: mseufMaroon,
              side: BorderSide(color: mseufMaroon),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Back',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isStep2Valid() ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isStep2Valid() ? infoColor : surfaceTertiary,
              foregroundColor: onMaroon,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Review & Submit',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3Navigation(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _previousStep,
            style: OutlinedButton.styleFrom(
              foregroundColor: mseufMaroon,
              side: BorderSide(color: mseufMaroon),
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Back',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitReservation,
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonGradient.colors.first,
              foregroundColor: onMaroon,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(onMaroon),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Submitting...',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, size: isMobile ? 20 : 22),
                      SizedBox(width: 8),
                      Text(
                        'Submit Reservation',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildReservationSummary(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final hasMultipleDays = _dailySlots.length > 1;
  
  return Container(
    width: double.infinity,
    constraints: BoxConstraints(
      maxHeight: isMobile ? 400 : 500, // Limit maximum height
    ),
    padding: EdgeInsets.all(isMobile ? 16 : 20),
    decoration: BoxDecoration(
      gradient: surfaceGradient,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: surfaceTertiary, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Compact Header
        Row(
          children: [
            Icon(Icons.summarize_rounded, color: mseufMaroon, size: 20),
            SizedBox(width: 8),
            Text(
              'Reservation Summary',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: mseufMaroonDark,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: mseufMaroon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_dailySlots.length} day${_dailySlots.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: mseufMaroon,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16),
        
        // Scrollable Content Area
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Basic Info in Compact Grid
                _buildCompactInfoGrid(layoutType),
                
                SizedBox(height: 16),
                
                // Purpose (truncated)
                _buildCompactPurpose(layoutType),
                
                SizedBox(height: 16),
                
                // Time Slots - Ultra Compact
                _buildCompactTimeSlots(layoutType),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Compact Info Grid - Shows basic info in a 2-column layout
Widget _buildCompactInfoGrid(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: surfaceSecondary,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: surfaceTertiary),
    ),
    child: Column(
      children: [
        // Resource Info
        Row(
          children: [
            _buildCompactInfoItem(
              icon: Icons.place_rounded,
              label: 'Resource',
              value: widget.selectedResource.name,
              layoutType: layoutType,
            ),
            SizedBox(width: 16),
            _buildCompactInfoItem(
              icon: Icons.category_rounded,
              label: 'Category',
              value: widget.selectedResource.category,
              layoutType: layoutType,
            ),
          ],
        ),
        SizedBox(height: 12),
        // Date Range
        Row(
          children: [
            _buildCompactInfoItem(
              icon: Icons.calendar_today_rounded,
              label: 'From',
              value: _startDate != null 
                ? DateFormat('MMM dd').format(_startDate!)
                : 'Not set',
              layoutType: layoutType,
            ),
            SizedBox(width: 16),
            _buildCompactInfoItem(
              icon: Icons.calendar_month_rounded,
              label: 'To',
              value: _endDate != null 
                ? DateFormat('MMM dd').format(_endDate!)
                : 'Not set',
              layoutType: layoutType,
            ),
          ],
        ),
      ],
    ),
  );
}

// Ultra Compact Info Item
Widget _buildCompactInfoItem({
  required IconData icon,
  required String label,
  required String value,
  required _LayoutType layoutType,
}) {
  final isMobile = layoutType == _LayoutType.mobile;
  
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: mseufMaroon),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            fontWeight: FontWeight.w700,
            color: mseufMaroonDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// Compact Purpose Display
Widget _buildCompactPurpose(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final purpose = _purposeController.text;
  
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: surfaceSecondary,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: surfaceTertiary),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_rounded, size: 14, color: mseufMaroon),
            SizedBox(width: 6),
            Text(
              'Purpose',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: mseufMaroonDark,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          purpose.isEmpty ? 'No purpose specified' : purpose,
          style: TextStyle(
            fontSize: isMobile ? 12 : 13,
            color: textSecondary,
            height: 1.4,
          ),
          maxLines: 3, // Limit to 3 lines max
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

// Ultra Compact Time Slots
Widget _buildCompactTimeSlots(_LayoutType layoutType) {
  final isMobile = layoutType == _LayoutType.mobile;
  final completedSlots = _dailySlots.where((s) => s.isComplete()).length;
  
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: surfaceSecondary,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: surfaceTertiary),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with completion status
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 14, color: mseufMaroon),
            SizedBox(width: 6),
            Text(
              'Time Slots',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: mseufMaroonDark,
              ),
            ),
            Spacer(),
            Text(
              '$completedSlots/${_dailySlots.length} complete',
              style: TextStyle(
                fontSize: 10,
                color: completedSlots == _dailySlots.length 
                  ? successColor 
                  : warningColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 12),
        
        // Compact Time Slots List
        Column(
          mainAxisSize: MainAxisSize.min,
          children: _dailySlots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value;
            final isComplete = slot.isComplete();
            
            return Container(
              margin: EdgeInsets.only(bottom: 6),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isComplete ? successColor.withOpacity(0.05) : surfacePrimary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isComplete ? successColor.withOpacity(0.3) : surfaceTertiary,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Day indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: mseufMaroon.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: mseufMaroon,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 8),
                  
                  // Date
                  Expanded(
                    child: Text(
                      DateFormat('MMM dd').format(slot.date),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  
                  // Times
                  Text(
                    slot.isComplete()
                      ? '${slot.startTime!.format(context).replaceAll(' ', '')}-${slot.endTime!.format(context).replaceAll(' ', '')}'
                      : 'Not set',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: slot.isComplete() ? successColor : textTertiary,
                    ),
                  ),
                  
                  SizedBox(width: 4),
                  
                  // Status icon
                  Icon(
                    slot.isComplete() ? Icons.check_circle_rounded : Icons.schedule_rounded,
                    size: 12,
                    color: slot.isComplete() ? successColor : warningColor,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    ),
  );
}

  // Existing helper methods (keep these as they are)
  Widget _buildSummaryItem(String label, String value, _LayoutType layoutType) {
    final isDesktop = layoutType == _LayoutType.desktop;
   
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 13 : 12,
              fontWeight: FontWeight.w600,
              color: textTertiary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 13,
              fontWeight: FontWeight.w700,
              color: mseufMaroonDark,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  List<String> _getReservationTips() {
    return [
      'Book at least 24 hours in advance for best availability',
      'Double-check your time slots for accuracy',
      'Include detailed purpose for faster approval',
      'Contact facility office for urgent requests',
      'Keep your contact information updated',
      'Review all details before submitting',
      'Consider setting reminders for your reservation dates'
    ];
  }

  String _getTimingStatusText() {
    switch (_reservationTiming) {
      case ReservationTiming.tooLate:
        return '⚠️ Too late for online booking';
      case ReservationTiming.urgent:
        return '⏰ Urgent request - approval not guaranteed';
      case ReservationTiming.sameDay:
        return '📋 Same-day reservation';
      case ReservationTiming.normal:
        return '✅ Well in advance';
    }
  }

  // Resource Header
  Widget _buildResourceHeader(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isTablet = layoutType == _LayoutType.tablet;

    const Map<String, List<Color>> categoryColors = {
      'Facility': [mseufMaroonDark, mseufMaroon],
      'Room': [Color(0xFF00897B), Color(0xFF004D40)],
      'Vehicle': [Color(0xFFFFA000), Color(0xFFC67100)],
      'Other': [Color(0xFFF57C00), Color(0xFFBF360C)],
    };

    final colors = categoryColors[widget.selectedResource.category] ?? categoryColors['Other']!;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 60 : 70,
            height: isMobile ? 60 : 70,
            decoration: BoxDecoration(
              color: onMaroon.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(color: onMaroon.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                widget.selectedResource.name.split(' ').map((word) => word[0]).take(2).join(''),
                style: TextStyle(
                  color: onMaroon,
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: isMobile ? 16 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedResource.name,
                  style: TextStyle(
                    color: onMaroon,
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'ID: ${widget.selectedResource.id}',
                  style: TextStyle(
                    color: onMaroon.withOpacity(0.9),
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  widget.selectedResource.description.isEmpty 
                    ? 'No description available' 
                    : widget.selectedResource.description,
                  style: TextStyle(
                    color: onMaroon.withOpacity(0.8),
                    fontSize: isMobile ? 12 : 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Purpose Section
  Widget _buildPurposeSection(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isLaptop = layoutType == _LayoutType.laptop;
    final isDesktop = layoutType == _LayoutType.desktop;
   
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purpose of Reservation',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w700,
            color: mseufMaroonDark,
          ),
        ),
        SizedBox(height: 12),
        _buildMSEUFFormField(
          controller: _purposeController,
          label: 'Describe the purpose of your reservation...',
          icon: Icons.description_rounded,
          maxLines: isLaptop || isDesktop ? 6 : 4, // More lines for desktop
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Purpose is required';
            }
            if (value.trim().length < 10) {
              return 'Purpose must be at least 10 characters';
            }
            return null;
          },
          layoutType: layoutType,
        ),
      ],
    );
  }

  
  // Side by side date range for all layouts
  Widget _buildSideBySideDateRange(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isLaptop = layoutType == _LayoutType.laptop;
    final isDesktop = layoutType == _LayoutType.desktop;
    
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            label: 'Start Date',
            date: _startDate,
            onTap: () => _selectDate(context, true),
            layoutType: layoutType,
          ),
        ),
        SizedBox(width: isLaptop || isDesktop ? 16 : 12), // More space on larger screens
        Expanded(
          child: _buildDatePicker(
            label: 'End Date',
            date: _endDate,
            onTap: () => _selectDate(context, false),
            layoutType: layoutType,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required _LayoutType layoutType,
  }) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 18),
        decoration: BoxDecoration(
          gradient: surfaceGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: mseufMaroon.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: mseufMaroon.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        mseufMaroon.withOpacity(0.15),
                        mseufMaroon.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: mseufMaroon,
                    size: isMobile ? 18 : 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    date != null 
                      ? DateFormat('MMM dd, yyyy').format(date)
                      : 'Select Date',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: date != null ? mseufMaroonDark : textTertiary,
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

  
// New compact time picker widget
Widget _buildCompactTimePicker({
  required String label,
  required TimeOfDay? time,
  required VoidCallback onTap,
  required _LayoutType layoutType,
}) {
  final isMobile = layoutType == _LayoutType.mobile;
  
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: surfacePrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: mseufMaroon.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            time != null 
              ? time.format(context).replaceAll(' ', '') // Remove space for compactness
              : '--:--',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              fontWeight: FontWeight.bold,
              color: time != null ? mseufMaroonDark : textTertiary,
            ),
          ),
        ],
      ),
    ),
  );
}

  // MSEUF-styled AppBar with Enhanced Design
  PreferredSizeWidget _buildMSEUFAppBar(_LayoutType layoutType) {
    final isMobile = layoutType == _LayoutType.mobile;
    final isTablet = layoutType == _LayoutType.tablet;
   
    return PreferredSize(
      preferredSize: Size.fromHeight(isMobile ? 75 : 90),
      child: Container(
        decoration: BoxDecoration(
          gradient: surfaceGradient,
          boxShadow: [
            BoxShadow(
              color: mseufMaroon.withOpacity(0.06),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: isMobile ? 12 : 16,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [surfaceSecondary, surfaceTertiary.withOpacity(0.5)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: mseufMaroon.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mseufMaroon.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: mseufMaroonDark, size: isMobile ? 22 : 24),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.all(8),
                  ),
                ),
                SizedBox(width: 16),
               
                // Enhanced Logo with MSEUF branding
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: whiteGradient,
                    border: Border.all(
                      color: mseufMaroon.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: mseufCream.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surfacePrimary,
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: mseufMaroon,
                      size: isMobile ? 24 : 28,
                    ),
                  ),
                ),
               
                SizedBox(width: 16),
               
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Book Resource',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : isTablet ? 20 : 22,
                          fontWeight: FontWeight.w800,
                          color: mseufMaroonDark,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isMobile) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: maroonGradient,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              '${widget.selectedResource.name} • ${widget.selectedResource.category}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textTertiary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MSEUF Form Field
  Widget _buildMSEUFFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    required _LayoutType layoutType,
  }) {
    final isMobile = layoutType == _LayoutType.mobile;
   
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: surfaceGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mseufMaroon.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: mseufMaroon.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: mseufMaroonDark,
          fontSize: isMobile ? 14 : 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textTertiary,
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 12 : 14,
          ),
          prefixIcon: Container(
            margin: EdgeInsets.only(right: 12, left: 12, top: 12, bottom: 12),
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  mseufMaroon.withOpacity(0.15),
                  mseufMaroon.withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: mseufMaroon,
              size: isMobile ? 18 : 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMobile ? 16 : 18,
          ),
        ),
      ),
    );
  }
}

// Enhanced layout type classification
enum _LayoutType {
  mobile, // < 768px
  tablet, // 768px - 1024px
  laptop, // 1024px - 1440px
  desktop, // > 1440px
}

// Reservation timing enum
enum ReservationTiming {
  tooLate,    // Less than 4 hours
  urgent,     // 4-12 hours
  sameDay,    // 12-24 hours
  normal,     // More than 24 hours
}

class Resource {
  final String id;
  final String name;
  final String description;
  final String category;
  
  Resource({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });
  
  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['f_id'] ?? '',
      name: json['f_name'] ?? '',
      description: json['f_description'] ?? '',
      category: json['category'] ?? 'Other',
    );
  }
}