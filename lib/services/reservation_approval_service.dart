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

  static const String _baseUrl = 'http://localhost:4000'; // Replace with server IP when needed

  /// Fetch all pending reservations for an approver
  Future<bool> fetchPendingReservations(String approverId, String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('🔍 Fetching pending reservations for approver: $approverId');
        print('🔍 Using token: ${token.isNotEmpty ? '${token.substring(0, 20)}...' : 'NO TOKEN'}');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/viewPendingReservations/$approverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

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

          if (jsonData is List) {
            _pendingReservations = jsonData
                .map((json) => ReservationApproval.fromJson(json))
                .toList();
          } else if (jsonData is Map<String, dynamic>) {
            final List<dynamic>? dataList =
                jsonData['data'] ?? jsonData['reservations'];
            if (dataList != null) {
              _pendingReservations = dataList
                  .map((json) => ReservationApproval.fromJson(json))
                  .toList();
            } else {
              _pendingReservations = [];
            }
          } else {
            _pendingReservations = [];
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

      final response = await http.post(
        Uri.parse('$_baseUrl/api/admin/approveReservation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        _errorMessage = null;
        if (kDebugMode) {
          final responseData = jsonDecode(response.body);
          print('✅ Approval processed: ${responseData['message']}');
        }
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
      return 'Request timed out: Please check your connection';
    } else if (error is FormatException) {
      return 'Invalid response format from server';
    } else {
      return error.toString();
    }
  }
}