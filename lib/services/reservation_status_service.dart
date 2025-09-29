import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/reservation_status_model.dart';

class ReservationStatusService extends ChangeNotifier {
  static const String _baseUrl = 'http://localhost:4000/api'; // Update this to your API base URL
  
  List<UserReservationStatus> _userReservations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserReservationStatus> get userReservations => _userReservations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Fetch user reservations with status tracking
  Future<void> fetchUserReservations(String userId, {String? token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        _errorMessage = 'Authentication token is required';
        _isLoading = false;
        notifyListeners();
        return;
      }

      debugPrint('Fetching reservations for user: $userId');
      
      // First get user's reservations
      final reservationsResponse = await http.get(
        Uri.parse('$_baseUrl/user/viewReservation/$userId'),
        headers: headers,
      );

      debugPrint('Reservations response status: ${reservationsResponse.statusCode}');
      debugPrint('Reservations response body: ${reservationsResponse.body}');

      if (reservationsResponse.statusCode == 200) {
        final List<dynamic> reservationsData = json.decode(reservationsResponse.body);
        debugPrint('Found ${reservationsData.length} reservations');
        
        List<UserReservationStatus> reservationStatusList = [];
        
        for (var reservation in reservationsData) {
          try {
            debugPrint('Fetching status for reservation ID: ${reservation['id']}');
            
            final statusResponse = await http.get(
              Uri.parse('$_baseUrl/reservations/status/${reservation['id']}'),
              headers: headers,
            );
            
            debugPrint('Status response for ${reservation['id']}: ${statusResponse.statusCode}');
            debugPrint('Status response body: ${statusResponse.body}');
            
            if (statusResponse.statusCode == 200) {
              final statusData = json.decode(statusResponse.body);
              final userReservation = _convertToUserReservationStatus(reservation, statusData);
              reservationStatusList.add(userReservation);
            } else {
              debugPrint('Failed to get status for reservation ${reservation['id']}');
            }
          } catch (e) {
            debugPrint('Error fetching status for reservation ${reservation['id']}: $e');
          }
        }
        
        _userReservations = reservationStatusList;
        debugPrint('Total reservations with status: ${_userReservations.length}');
        
        // Sort by creation date (newest first)
        _userReservations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        
      } else if (reservationsResponse.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please log in again.';
      } else if (reservationsResponse.statusCode == 404) {
        _userReservations = [];
        _errorMessage = null;
        debugPrint('No reservations found (404)');
      } else {
        _errorMessage = 'Failed to fetch reservations: ${reservationsResponse.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      debugPrint('Error fetching user reservations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Helper method to convert API response to UserReservationStatus
  UserReservationStatus _convertToUserReservationStatus(Map<String, dynamic> reservation, Map<String, dynamic> statusData) {
    // Convert approvals to ApprovalStep objects
    List<ApprovalStep> approvalSteps = [];

    if (statusData['approvals'] != null && statusData['approvals'] is List && statusData['approvals'].isNotEmpty) {
      for (var approval in statusData['approvals']) {
        approvalSteps.add(ApprovalStep(
          id: '${approval['step_order']}',
          stepOrder: approval['step_order'] ?? 0,
          approverName: approval['approver_name'] ?? 'Unknown Approver',
          approverRole: 'Approver',
          status: approval['status'] ?? 'pending',
          comment: approval['comment'],
          actedAt: approval['acted_at'] != null ? DateTime.parse(approval['acted_at']).toUtc() : null,
        ));
      }
    } else {
      // Add a default approval step or handle the case
      approvalSteps.add(ApprovalStep(
        id: 'default',
        stepOrder: 1,
        approverName: 'System',
        approverRole: 'System',
        status: 'pending',
        comment: null,
        actedAt: null,
      ));
    }

    // Parse dateFrom and dateTo
    DateTime dateFrom = DateTime.now().toUtc();
    DateTime dateTo = DateTime.now().toUtc();
    
    try {
      if (statusData['date_from'] != null) {
        dateFrom = DateTime.parse(statusData['date_from']).toUtc();
      } else if (reservation['date_from'] != null) {
        dateFrom = DateTime.parse(reservation['date_from']).toUtc();
      }
    } catch (e) {
      debugPrint('Error parsing date_from: $e');
    }

    try {
      if (statusData['date_to'] != null) {
        dateTo = DateTime.parse(statusData['date_to']).toUtc();
      } else if (reservation['date_to'] != null) {
        dateTo = DateTime.parse(reservation['date_to']).toUtc();
      }
    } catch (e) {
      debugPrint('Error parsing date_to: $e');
    }

    return UserReservationStatus(
      id: reservation['id'].toString(),
      resourceName: statusData['resource_name'] ?? reservation['resource_name'] ?? 'Unknown Resource',
      purpose: statusData['purpose'] ?? reservation['purpose'] ?? '',
      currentStatus: statusData['reservation_status'] ?? reservation['status'] ?? 'pending',
      approvalSteps: approvalSteps,
      createdAt: reservation['created_at'] != null 
          ? DateTime.parse(reservation['created_at']).toUtc() 
          : DateTime.now().toUtc(),
      updatedAt: reservation['updated_at'] != null 
          ? DateTime.parse(reservation['updated_at']).toUtc() 
          : null,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  // Helper method to parse dates safely
  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now().toUtc();
    try {
      String dateString = value.toString();
      debugPrint('Raw date string: $dateString');
      DateTime parsed = DateTime.parse(dateString).toUtc();
      debugPrint('Stored as UTC: $parsed');
      return parsed;
    } catch (e) {
      debugPrint('Error parsing date $value: $e');
      return DateTime.now().toUtc();
    }
  }

  // Fetch specific reservation details
  Future<UserReservationStatus?> fetchReservationDetails(String reservationId, {String? token}) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/reservations/status/$reservationId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Convert the single reservation status response to UserReservationStatus
        List<ApprovalStep> approvalSteps = [];
        if (responseData['approvals'] != null) {
          for (var approval in responseData['approvals']) {
            approvalSteps.add(ApprovalStep(
              id: '${approval['step_order']}',
              stepOrder: approval['step_order'],
              approverName: approval['approver_name'],
              approverRole: 'Approver',
              status: approval['status'],
              comment: null,
              actedAt: approval['acted_at'] != null ? DateTime.parse(approval['acted_at']).toUtc() : null,
            ));
          }
        }

        // Parse dateFrom and dateTo
        DateTime dateFrom = DateTime.now().toUtc();
        DateTime dateTo = DateTime.now().toUtc();

        try {
          if (responseData['date_from'] != null) {
            dateFrom = DateTime.parse(responseData['date_from']).toUtc();
          }
        } catch (e) {
          debugPrint('Error parsing date_from: $e');
        }

        try {
          if (responseData['date_to'] != null) {
            dateTo = DateTime.parse(responseData['date_to']).toUtc();
          }
        } catch (e) {
          debugPrint('Error parsing date_to: $e');
        }

        return UserReservationStatus(
          id: responseData['reservation_id'].toString(),
          resourceName: responseData['resource_name'] ?? 'Resource',
          purpose: responseData['purpose'] ?? '',
          currentStatus: responseData['reservation_status'] ?? 'pending',
          approvalSteps: approvalSteps,
          createdAt: DateTime.now().toUtc(), // Not available in this endpoint
          dateFrom: dateFrom,
          dateTo: dateTo,
        );
      } else {
        debugPrint('Failed to fetch reservation details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching reservation details: $e');
      return null;
    }
  }

  Future<bool> cancelReservation(String reservationId, {String? token}) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
      };
      
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      } else {
        _errorMessage = 'Authentication token is required';
        notifyListeners();
        return false;
      }

      debugPrint('Cancelling reservation: $reservationId');
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/user/cancelReservation/$reservationId/cancel'),
        headers: headers,
      );

      debugPrint('Cancel response status: ${response.statusCode}');
      debugPrint('Cancel response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final index = _userReservations.indexWhere((r) => r.id == reservationId);
          if (index != -1) {
            // Create a new list of approval steps with updated status
            final updatedSteps = _userReservations[index].approvalSteps.map((step) {
              if (step.status.toLowerCase() == 'pending') {
                return step.copyWith(status: 'cancelled');
              }
              return step;
            }).toList();

            // Update the reservation with new status and steps
            _userReservations[index] = _userReservations[index].copyWith(
              currentStatus: 'cancelled',
              updatedAt: DateTime.now().toUtc(),
              approvalSteps: updatedSteps,
            );
            notifyListeners();
          }
          _errorMessage = null;
          notifyListeners();
          return true;
        } else {
          _errorMessage = responseData['error'] ?? 'Failed to cancel reservation';
          notifyListeners();
          return false;
        }
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        _errorMessage = responseData['error'] ?? 'Cannot cancel this reservation';
        notifyListeners();
        return false;
      } else if (response.statusCode == 403) {
        _errorMessage = 'You can only cancel your own reservations';
        notifyListeners();
        return false;
      } else if (response.statusCode == 404) {
        _errorMessage = 'Reservation not found';
        notifyListeners();
        return false;
      } else {
        _errorMessage = 'Failed to cancel reservation: ${response.statusCode}';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      debugPrint('Error cancelling reservation: $e');
      notifyListeners();
      return false;
    }
  }

  // Refresh reservations for a user
  Future<void> refreshUserReservations(String userId, {String? token}) async {
    await fetchUserReservations(userId, token: token);
  }

  // Get reservation by ID from cached data
  UserReservationStatus? getReservationById(String reservationId) {
    try {
      return _userReservations.firstWhere((reservation) => reservation.id == reservationId);
    } catch (e) {
      return null;
    }
  }

  // Get reservations by status
  List<UserReservationStatus> getReservationsByStatus(String status) {
    return _userReservations.where((reservation) => 
        reservation.currentStatus.toLowerCase() == status.toLowerCase()).toList();
  }

  // Get pending reservations count
  int get pendingReservationsCount {
    return getReservationsByStatus('pending').length;
  }

  // Get approved reservations count
  int get approvedReservationsCount {
    return getReservationsByStatus('approved').length;
  }

  // Get rejected reservations count
  int get rejectedReservationsCount {
    return getReservationsByStatus('rejected').length;
  }

  // Clear all cached data
  void clearData() {
    _userReservations = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}