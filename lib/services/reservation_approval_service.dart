import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/reservation_approval_model.dart';
import '../models/reservation_history_model.dart';

class ReservationApprovalService with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<ReservationApproval> _pendingReservations = [];
  ReservationHistory? _currentHistory;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ReservationApproval> get pendingReservations => _pendingReservations;
  ReservationHistory? get currentHistory => _currentHistory;

  static const String _baseUrl = 'http://localhost:4000';

  /// Fetch all pending reservations for an approver (with optional resource filtering)
  Future<bool> fetchPendingReservations(
    String approverId, 
    String token,
    {String? resourceId}
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔍 Fetching pending reservations for approver: $approverId');
        if (resourceId != null) {
          print('🔍 Filtering by resource: $resourceId');
        }
        print('🔍 Using token: ${token.isNotEmpty ? '${token.substring(0, 20)}...' : 'NO TOKEN'}');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/viewPendingReservations/$approverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          _pendingReservations = [];
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
          return true;
        }

        try {
          final dynamic jsonData = jsonDecode(response.body);
          List<ReservationApproval> allReservations = [];

          if (jsonData is List) {
            allReservations = jsonData
                .map((json) => ReservationApproval.fromJson(json))
                .toList();
          } else if (jsonData is Map<String, dynamic>) {
            final List<dynamic>? dataList =
                jsonData['data'] ?? jsonData['reservations'];
            if (dataList != null) {
              allReservations = dataList
                  .map((json) => ReservationApproval.fromJson(json))
                  .toList();
            }
          }

          // ✅ FILTER 1: Remove expired reservations (date_from has passed)
          final now = DateTime.now();
          allReservations = allReservations.where((reservation) {
            // Allow if start date is today or in the future
            return reservation.dateFrom.isAfter(now) || 
                   _isSameDay(reservation.dateFrom, now);
          }).toList();

          if (kDebugMode && allReservations.isNotEmpty) {
            print('🗓️ Filtered out expired reservations. Remaining: ${allReservations.length}');
          }

          // ✅ FILTER 2: Apply resource filtering if provided
          if (resourceId != null && resourceId.isNotEmpty) {
            _pendingReservations = allReservations
                .where((reservation) => reservation.facilityId == resourceId)
                .toList();
            
            if (kDebugMode) {
              print('🔍 Filtered from ${allReservations.length} to ${_pendingReservations.length} reservations');
            }
          } else {
            _pendingReservations = allReservations;
          }
          
          if (kDebugMode) {
            print('✅ Parsed ${_pendingReservations.length} valid reservations');
          }

          _errorMessage = null;
        } catch (jsonError) {
          _errorMessage = 'Invalid response format from server';
          _pendingReservations = [];
          if (kDebugMode) {
            print('❌ JSON Parse Error: $jsonError');
            print('Response body: ${response.body}');
          }
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please login again.';
        _pendingReservations = [];
      } else if (response.statusCode == 403) {
        _errorMessage = 'Access denied. You do not have permission to view these reservations.';
        _pendingReservations = [];
      } else {
        _errorMessage = _parseErrorResponse(
          response.body,
          'Failed to fetch pending reservations (${response.statusCode})',
        );
        _pendingReservations = [];
      }

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _errorMessage = 'Error fetching reservations: ${_formatError(e)}';
      _pendingReservations = [];
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('❌ Network Error: $e');
      }
      return false;
    }
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Process approval action with optional comment
  Future<bool> processApproval(
      String approvalId, 
      String approverId, 
      String action, 
      String token, 
      {String? comment}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final requestBody = {
        'approval_id': approvalId,
        'approver_id': approverId,
        'action': action,
      };

      // Add comment if provided
      if (comment != null && comment.trim().isNotEmpty) {
        requestBody['comment'] = comment.trim();
      }

      if (kDebugMode) {
        print('📤 Sending approval request:');
        print('   Approval ID: $approvalId');
        print('   Action: $action');
        print('   Comment: ${comment ?? 'None'}');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/approveReservation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('📥 Approval response status: ${response.statusCode}');
        print('📥 Approval response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        _errorMessage = null;
        if (kDebugMode) {
          final responseData = jsonDecode(response.body);
          print('✅ Approval processed: ${responseData['message']}');
        }
      } else if (response.statusCode == 400) {
        // ✅ Handle expired reservation error specifically
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['auto_cancelled'] == true) {
            _errorMessage = 'This reservation has expired and was automatically cancelled.';
          } else {
            _errorMessage = errorData['message'] ?? errorData['error'] ?? 'Cannot process this approval';
          }
        } catch (_) {
          _errorMessage = 'Cannot process this approval - reservation may have expired';
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Session expired. Please login again.';
      } else if (response.statusCode == 403) {
        _errorMessage = 'You do not have permission to approve this reservation.';
      } else if (response.statusCode == 404) {
        _errorMessage = 'Approval not found or already processed.';
      } else {
        _errorMessage = _parseErrorResponse(
          response.body,
          'Failed to process approval (${response.statusCode})',
        );
      }

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _errorMessage = 'Error processing approval: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('❌ Process Approval Error: $e');
      }
      return false;
    }
  }

  /// Fetch reservation history
  Future<bool> fetchReservationHistory(String reservationId, String token) async {
    _isLoading = true;
    _errorMessage = null;
    _currentHistory = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔍 Fetching history for reservation: $reservationId');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/reservations/history/$reservationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final jsonData = jsonDecode(response.body);
          _currentHistory = ReservationHistory.fromJson(jsonData);
          _errorMessage = null;
          
          if (kDebugMode) {
            print('✅ History loaded successfully');
          }
        } catch (jsonError) {
          _errorMessage = 'Invalid history response format';
          _currentHistory = null;
          if (kDebugMode) {
            print('❌ History JSON Parse Error: $jsonError');
            print('Response body: ${response.body}');
          }
        }
      } else {
        _errorMessage = _parseErrorResponse(
          response.body,
          'Failed to fetch reservation history (${response.statusCode})',
        );
        _currentHistory = null;
      }

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _errorMessage = 'Error fetching history: ${_formatError(e)}';
      _currentHistory = null;
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('❌ History Network Error: $e');
      }
      return false;
    }
  }

  /// Fetch daily slots for a reservation
  Future<Map<String, dynamic>?> fetchDailySlots(String reservationId) async {
    try {
      if (kDebugMode) {
        print('🔍 Fetching daily slots for reservation: $reservationId');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/reservations/$reservationId/daily-slots'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('📥 Daily slots response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ Loaded ${data['total_days']} daily slots');
        }
        return data;
      } else {
        if (kDebugMode) {
          print('❌ Failed to fetch daily slots: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching daily slots: $e');
      }
      return null;
    }
  }

  /// Fetch full reservation details (includes daily slots and approvals)
  Future<Map<String, dynamic>?> fetchFullReservationDetails(
      String reservationId, String token) async {
    try {
      if (kDebugMode) {
        print('🔍 Fetching full details for reservation: $reservationId');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/reservations/$reservationId/full-details'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ Full details loaded successfully');
          print('   Days: ${data['summary']['total_days']}');
          print('   Approval steps: ${data['summary']['approval_steps']}');
        }
        return data;
      } else {
        if (kDebugMode) {
          print('❌ Failed to fetch full details: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching full details: $e');
      }
      return null;
    }
  }

  /// Clear error state
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear cached reservations
  void clearReservations() {
    _pendingReservations = [];
    notifyListeners();
  }

  /// Clear cached history
  void clearHistory() {
    _currentHistory = null;
    notifyListeners();
  }

  /// Reset all state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _pendingReservations = [];
    _currentHistory = null;
    notifyListeners();
  }

  String _parseErrorResponse(String responseBody, String defaultMessage) {
    try {
      if (responseBody.isEmpty) return defaultMessage;

      final errorBody = jsonDecode(responseBody);
      return errorBody['error']?.toString() ??
          errorBody['message']?.toString() ??
          defaultMessage;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing error response: $e');
        print('Response body: $responseBody');
      }
      return defaultMessage;
    }
  }

  String _formatError(dynamic error) {
    if (error is TimeoutException) {
      return 'Request timed out. Please check your connection.';
    } else if (error is FormatException) {
      return 'Invalid response format from server.';
    } else if (error.toString().contains('SocketException')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return error.toString();
    }
  }
}