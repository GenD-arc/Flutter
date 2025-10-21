import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../models/unified_reservation_model.dart';

class UnifiedReservationService extends ChangeNotifier {
  static const String _baseUrl = 'http://localhost:4000/api';
  final AuthService _authService;
  
  List<UnifiedReservation> _reservations = [];
  bool _isLoading = false;
  String? _errorMessage;

  UnifiedReservationService(this._authService);

  List<UnifiedReservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<UnifiedReservation> getByStatus(String status) {
    return _reservations
        .where((r) => r.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  UnifiedReservation? getById(String id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // ✅ Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // ✅ Helper method to check if reservation is expired
  bool _isReservationExpired(UnifiedReservation reservation) {
    final now = DateTime.now();
    // Reservation is expired if start date has passed (not including today)
    return reservation.dateFrom.isBefore(now) && 
           !_isSameDay(reservation.dateFrom, now);
  }

  // ============================================
  // CORE METHOD: Fetch User Reservations
  // This replaces the inefficient double-call approach
  // ============================================
  Future<void> fetchUserReservations(String userId) async {
    final token = _authService.token;
    if (token == null || token.isEmpty) {
      _errorMessage = 'Authentication required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = _buildHeaders(token);

      // Step 1: Fetch basic reservations
      final reservationsResponse = await http.get(
        Uri.parse('$_baseUrl/user/viewReservation/$userId'),
        headers: headers,
      );

      debugPrint('Reservations API status: ${reservationsResponse.statusCode}');

      if (reservationsResponse.statusCode == 200) {
        final List<dynamic> reservationsData = json.decode(reservationsResponse.body);
        debugPrint('Found ${reservationsData.length} reservations');
        
        List<UnifiedReservation> loadedReservations = [];
        
        for (var reservationJson in reservationsData) {
          try {
            final reservationId = reservationJson['id'].toString();
            
            final statusResponse = await http.get(
              Uri.parse('$_baseUrl/reservations/status/$reservationId'),
              headers: headers,
            );
            
            if (statusResponse.statusCode == 200) {
              final statusData = json.decode(statusResponse.body) as Map<String, dynamic>;
              
              // Merge both responses with explicit type casting
              final mergedData = <String, dynamic>{
                ...(reservationJson as Map<String, dynamic>),
                ...statusData,
                // Prefer status endpoint data for these fields
                'daily_slots': statusData['daily_slots'] ?? reservationJson['daily_slots'] ?? [],
                'approvals': statusData['approvals'] ?? [],
              };
              
              loadedReservations.add(UnifiedReservation.fromJson(mergedData));
            } else {
              // If status endpoint fails, use basic reservation data
              loadedReservations.add(UnifiedReservation.fromJson(reservationJson as Map<String, dynamic>));
            }
          } catch (e) {
            debugPrint('Error processing reservation ${reservationJson['id']}: $e');
            // Still add the basic reservation even if status fetch fails
            try {
              loadedReservations.add(UnifiedReservation.fromJson(reservationJson as Map<String, dynamic>));
            } catch (parseError) {
              debugPrint('Failed to parse reservation: $parseError');
            }
          }
        }
        
        // ✅ FILTER: Auto-mark expired pending reservations (UI-side safety)
        // This is a defensive measure in case the backend cleanup job hasn't run yet
        final now = DateTime.now();
        for (var i = 0; i < loadedReservations.length; i++) {
          final reservation = loadedReservations[i];
          
          // If reservation is pending and expired, show it as cancelled (read-only)
          if (reservation.status.toLowerCase() == 'pending' && 
              _isReservationExpired(reservation)) {
            debugPrint('⚠️ Warning: Pending reservation ${reservation.id} is expired');
            // Note: We keep it in the list but the UI should show it as expired
            // The actual cancellation happens server-side via cron job
          }
        }
        
        _reservations = loadedReservations;
        _reservations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        debugPrint('Successfully loaded ${_reservations.length} reservations');
        
      } else if (reservationsResponse.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please log in again.';
      } else if (reservationsResponse.statusCode == 404) {
        _reservations = [];
      } else {
        _errorMessage = 'Failed to fetch reservations: ${reservationsResponse.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Network error: ${e.toString()}';
      debugPrint('Error fetching reservations: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================
  // Cancel Reservation
  // ============================================
  Future<bool> cancelReservation(String reservationId) async {
    final token = _authService.token;
    if (token == null || token.isEmpty) {
      _errorMessage = 'Authentication required';
      notifyListeners();
      return false;
    }

    try {
      final headers = _buildHeaders(token);
      
      final response = await http.patch(
        Uri.parse('$_baseUrl/user/cancelReservation/$reservationId/cancel'),
        headers: headers,
      );

      debugPrint('Cancel reservation status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        
        if (responseData['success'] == true) {
          // Update local state
          final index = _reservations.indexWhere((r) => r.id == reservationId);
          if (index != -1) {
            final updatedSteps = _reservations[index].approvalSteps.map((step) {
              if (step.status.toLowerCase() == 'pending') {
                return step.copyWith(status: 'cancelled');
              }
              return step;
            }).toList();

            _reservations[index] = _reservations[index].copyWith(
              status: 'cancelled',
              updatedAt: DateTime.now().toUtc(),
              approvalSteps: updatedSteps,
            );
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
        // Handle specific error messages (like "already started")
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        _errorMessage = responseData['error'] ?? 'Cannot cancel this reservation';
        notifyListeners();
        return false;
      } else {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        _errorMessage = responseData['error'] ?? 'Failed to cancel reservation';
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

  // ============================================
  // Fetch Single Reservation Details
  // ============================================
  Future<UnifiedReservation?> fetchReservationDetails(String reservationId) async {
    final token = _authService.token;
    if (token == null || token.isEmpty) return null;

    try {
      final headers = _buildHeaders(token);
      
      final response = await http.get(
        Uri.parse('$_baseUrl/reservations/status/$reservationId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return UnifiedReservation.fromJson(data);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error fetching reservation details: $e');
      return null;
    }
  }

  // ============================================
  // Fetch Daily Slots (if needed separately)
  // ============================================
  Future<List<DailySlot>> fetchDailySlots(String reservationId) async {
    final token = _authService.token;
    if (token == null || token.isEmpty) return [];

    try {
      final headers = _buildHeaders(token);
      
      final response = await http.get(
        Uri.parse('$_baseUrl/reservations/$reservationId/daily-slots'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> slotsData = data['daily_slots'] ?? [];
        
        return slotsData
            .map((slot) => DailySlot.fromJson(slot as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error fetching daily slots: $e');
      return [];
    }
  }

  // ============================================
  // Utility Methods
  // ============================================
  
  Future<void> refresh(String userId) async {
    await fetchUserReservations(userId);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    _reservations = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  int get pendingCount => getByStatus('pending').length;
  int get approvedCount => getByStatus('approved').length;
  int get rejectedCount => getByStatus('rejected').length;
  int get cancelledCount => getByStatus('cancelled').length;
  int get totalCount => _reservations.length;
  
  // ✅ New: Get expired pending reservations count (for UI warnings)
  int get expiredPendingCount => _reservations
      .where((r) => 
          r.status.toLowerCase() == 'pending' && 
          _isReservationExpired(r))
      .length;
}