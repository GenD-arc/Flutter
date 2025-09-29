import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  // Enhanced Color Palette (matching your existing design)
  static const Color primaryMaroon = Color(0xFF8B0000);
  static const Color darkMaroon = Color(0xFF4A1E1E);
  static const Color warmGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFBFF);

  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  
  bool _isSubmitting = false;
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

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

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null || _startTime == null || _endTime == null) {
      _showSnackBar('Please select both start and end dates/times', Colors.red);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get authentication token
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        _showSnackBar('Authentication required. Please login again.', Colors.red);
        setState(() => _isSubmitting = false);
        return;
      }

      final startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );

      final endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      // Validate dates
      if (endDateTime.isBefore(startDateTime)) {
        _showSnackBar('End date/time must be after start date/time', Colors.red);
        setState(() => _isSubmitting = false);
        return;
      }

      final requestData = {
        'f_id': widget.selectedResource.id,
        'requester_id': widget.userId,
        'purpose': _purposeController.text.trim(),
        'date_from': startDateTime.toIso8601String(),
        'date_to': endDateTime.toIso8601String(),
      };

      print('🔍 Submitting reservation with token: ${token.substring(0, 20)}...');
      print('🔍 Request data: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse('http://localhost:4000/api/user/requestReservation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Added the missing token!
        },
        body: jsonEncode(requestData),
      ).timeout(const Duration(seconds: 30));

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _showSnackBar(responseData['message'] ?? 'Reservation submitted successfully!', Colors.green);
        Navigator.pop(context, true); // Return true to indicate success
      } else if (response.statusCode == 401) {
        _showSnackBar('Session expired. Please login again.', Colors.red);
        // Optionally navigate to login screen
      } else {
        final error = jsonDecode(response.body);
        _showSnackBar(error['error'] ?? 'Failed to submit reservation', Colors.red);
      }
    } catch (e) {
      print('❌ Reservation submission error: $e');
      if (e.toString().contains('TimeoutException')) {
        _showSnackBar('Request timeout. Please try again.', Colors.red);
      } else if (e.toString().contains('SocketException')) {
        _showSnackBar('Network error. Please check your connection.', Colors.red);
      } else {
        _showSnackBar('Network error. Please try again.', Colors.red);
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showConflictDialog(Map<String, dynamic> conflictData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final conflicts = conflictData['conflicts'] as List<dynamic>;
        
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Resource Not Available'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conflictData['message'] ?? 'The resource has conflicting reservations.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              if (conflicts.isNotEmpty) ...[
                Text(
                  'Existing Reservations:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ...conflicts.map((conflict) => Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Purpose: ${conflict['purpose']}'),
                      Text('Reserved by: ${conflict['reserved_by']}'),
                      Text('From: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(conflict['reserved_from']).toUtc().add(Duration(hours: 8)))}'),
                      Text('To: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(conflict['reserved_to']).toUtc().add(Duration(hours: 8)))}'),
                    ],
                  ),
                )).toList(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
      ),
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
              primary: primaryMaroon,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryMaroon,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Widget _buildResourceHeader(bool isMobile) {
    const Map<String, List<Color>> categoryColors = {
      'Facility': [Color(0xFF8B0000), Color(0xFF4A1E1E)],
      'Room': [Color(0xFF00897B), Color(0xFF004D40)],
      'Vehicle': [Color(0xFFFFA000), Color(0xFFC67100)],
      'Other': [Color(0xFFF57C00), Color(0xFFBF360C)],
    };

    final colors = categoryColors[widget.selectedResource.category] ?? categoryColors['Other']!;

    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isMobile ? 60 : 70,
            height: isMobile ? 60 : 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isMobile ? 15 : 18),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(
                widget.selectedResource.name.split(' ').map((word) => word[0]).take(2).join(''),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 28,
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
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'ID: ${widget.selectedResource.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  widget.selectedResource.category,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required String dateText,
    required String timeText,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w600,
            color: darkMaroon,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onDateTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryMaroon, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dateText,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: dateText == 'Select Date' ? Colors.grey[500] : darkMaroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: onTimeTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: primaryMaroon, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          timeText,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: timeText == 'Select Time' ? Colors.grey[500] : darkMaroon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Scaffold(
      backgroundColor: warmGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: darkMaroon),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Book Resource',
          style: TextStyle(
            color: darkMaroon,
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resource Header Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: primaryMaroon.withOpacity(0.1),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildResourceHeader(isMobile),
                        Padding(
                          padding: EdgeInsets.all(isMobile ? 20 : 24),
                          child: Text(
                            widget.selectedResource.description.isEmpty 
                              ? 'No description available' 
                              : widget.selectedResource.description,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Booking Form Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 20 : 24),
                    decoration: BoxDecoration(
                      color: cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: primaryMaroon.withOpacity(0.08),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservation Details',
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 22,
                            fontWeight: FontWeight.w700,
                            color: darkMaroon,
                          ),
                        ),
                        SizedBox(height: 24),

                        // Purpose Field
                        Text(
                          'Purpose of Reservation',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: darkMaroon,
                          ),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _purposeController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Please describe the purpose of your reservation...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryMaroon, width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Purpose is required';
                            }
                            if (value.trim().length < 10) {
                              return 'Purpose must be at least 10 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 24),

                        // Start Date & Time
                        _buildDateTimeSelector(
                          label: 'Start Date & Time',
                          dateText: _startDate != null 
                            ? DateFormat('MMM dd, yyyy').format(_startDate!) 
                            : 'Select Date',
                          timeText: _startTime != null 
                            ? _startTime!.format(context) 
                            : 'Select Time',
                          onDateTap: () => _selectDate(context, true),
                          onTimeTap: () => _selectTime(context, true),
                          isMobile: isMobile,
                        ),

                        SizedBox(height: 20),

                        // End Date & Time
                        _buildDateTimeSelector(
                          label: 'End Date & Time',
                          dateText: _endDate != null 
                            ? DateFormat('MMM dd, yyyy').format(_endDate!) 
                            : 'Select Date',
                          timeText: _endTime != null 
                            ? _endTime!.format(context) 
                            : 'Select Time',
                          onDateTap: () => _selectDate(context, false),
                          onTimeTap: () => _selectTime(context, false),
                          isMobile: isMobile,
                        ),

                        SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitReservation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryMaroon,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                vertical: isMobile ? 16 : 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Resource class (should match your existing Resource model)
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