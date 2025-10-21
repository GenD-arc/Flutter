import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ResourceAvailabilityStatus {
  final String resourceId;
  final String resourceName;
  final String category;
  final String status; // 'fully_available', 'partially_available', 'not_available'
  final List<String>? timeSlots;
  final String? statusMessage;
  final int? reservationCount;

  ResourceAvailabilityStatus({
    required this.resourceId,
    required this.resourceName,
    required this.category,
    required this.status,
    this.timeSlots,
    this.statusMessage,
    this.reservationCount,
  });

  factory ResourceAvailabilityStatus.fromJson(Map<String, dynamic> json) {
    return ResourceAvailabilityStatus(
      resourceId: json['resource_id'] ?? '',
      resourceName: json['resource_name'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? 'unknown',
      timeSlots: List<String>.from(json['time_slots'] ?? []),
      statusMessage: json['status'] ?? '',
      reservationCount: json['reservation_count'] ?? json['pending_count'] ?? 0,
    );
  }
}

class DailyActivityNews {
  final String reservationId;
  final String resourceName;
  final String resourceCategory;
  final String purpose;
  final String timeSlots;
  final String requesterName;
  final bool approvedToday;
  final String approvalSteps;
  final int dayNumber;
  final int totalDays;

  DailyActivityNews({
    required this.reservationId,
    required this.resourceName,
    required this.resourceCategory,
    required this.purpose,
    required this.timeSlots,
    required this.requesterName,
    required this.approvedToday,
    required this.approvalSteps,
    this.dayNumber = 1,
    this.totalDays = 1,
  });

  factory DailyActivityNews.fromJson(Map<String, dynamic> json) {
    return DailyActivityNews(
      reservationId: json['reservation_id']?.toString() ?? '',
      resourceName: json['resource_name'] ?? '',
      resourceCategory: json['resource_category'] ?? '',
      purpose: json['purpose'] ?? '',
      timeSlots: json['time_slots'] ?? 'All day',
      requesterName: json['requester'] ?? 'Unknown',
      approvedToday: json['approved_today'] ?? false,
      approvalSteps: json['approval_steps'] ?? '0/0',
      dayNumber: json['day_number'] ?? 1,
      totalDays: json['total_days'] ?? 1,
    );
  }

  String get dayLabel {
    const suffixes = ['st', 'nd', 'rd'];
    final suffix = (dayNumber <= 3) ? suffixes[dayNumber - 1] : 'th';
    return 'Day $dayNumber$suffix';
  }

  String get durationLabel {
    if (totalDays > 1) {
      return '$dayLabel of $totalDays';
    }
    return 'Today';
  }
}

class TodayStatusData {
  final String today;
  final List<ResourceAvailabilityStatus> fullyAvailable;
  final List<ResourceAvailabilityStatus> partiallyAvailable;
  final List<ResourceAvailabilityStatus> notAvailable;
  final List<DailyActivityNews> dailyNews;
  final Map<String, dynamic> summary;

  TodayStatusData({
    required this.today,
    required this.fullyAvailable,
    required this.partiallyAvailable,
    required this.notAvailable,
    required this.dailyNews,
    required this.summary,
  });

  factory TodayStatusData.fromJson(Map<String, dynamic> json) {
    return TodayStatusData(
      today: json['today'] ?? '',
      fullyAvailable: (json['availability_status']?['fully_available'] as List?)
          ?.map((item) => ResourceAvailabilityStatus.fromJson(item))
          .toList() ?? [],
      partiallyAvailable: (json['availability_status']?['partially_available'] as List?)
          ?.map((item) => ResourceAvailabilityStatus.fromJson(item))
          .toList() ?? [],
      notAvailable: (json['availability_status']?['not_available'] as List?)
          ?.map((item) => ResourceAvailabilityStatus.fromJson(item))
          .toList() ?? [],
      dailyNews: (json['daily_news'] as List?)
          ?.map((item) => DailyActivityNews.fromJson(item))
          .toList() ?? [],
      summary: json['summary'] ?? {},
    );
  }
}

class TodayStatusService with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  TodayStatusData? _todayStatus;
  late Timer _refreshTimer;
  bool _isDisposed = false;

  static const String _baseUrl = 'http://localhost:4000';
  static const int _refreshIntervalSeconds = 30;

  TodayStatusService() {
    _refreshTimer = Timer(Duration.zero, () {});
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TodayStatusData? get todayStatus => _todayStatus;

  /// Initialize auto-refresh
  void startAutoRefresh() {
    _refreshTimer.cancel();
    
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshIntervalSeconds),
      (_) {
        if (!_isDisposed) {
          fetchTodayStatus();
        }
      },
    );
  }

  /// Stop auto-refresh
  void stopAutoRefresh() {
    if (_refreshTimer.isActive) {
      _refreshTimer.cancel();
    }
  }

  /// Fetch today's status (public endpoint, no auth needed)
  Future<bool> fetchTodayStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/public/today-status'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _todayStatus = TodayStatusData.fromJson(jsonData);
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to load today\'s status (${response.statusCode})';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error fetching today\'s status: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get availability summary
  Map<String, int> getAvailabilitySummary() {
    if (_todayStatus == null) {
      return {
        'fully_available': 0,
        'partially_available': 0,
        'not_available': 0,
      };
    }

    return {
      'fully_available': _todayStatus!.fullyAvailable.length,
      'partially_available': _todayStatus!.partiallyAvailable.length,
      'not_available': _todayStatus!.notAvailable.length,
    };
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset all data
  void reset() {
    stopAutoRefresh();
    _isLoading = false;
    _errorMessage = null;
    _todayStatus = null;
    notifyListeners();
  }

  String _formatError(dynamic error) {
    if (error is TimeoutException) {
      return 'Request timed out. Please check your connection.';
    } else if (error.toString().contains('SocketException')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return error.toString();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopAutoRefresh();
    super.dispose();
  }
}