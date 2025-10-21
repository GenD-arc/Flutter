// services/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

class NotificationService with ChangeNotifier {
  // WebSocket properties
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  
  // Polling properties (existing)
  Timer? _pollingTimer;
  int _unreadCount = 0;
  bool _hasNewReservations = false;
  DateTime? _lastChecked;
  Map<String, int> _resourceNotificationCounts = {};
  Map<String, bool> _resourceHasNew = {};
  
  // For popup notifications
  final List<Map<String, dynamic>> _recentNotifications = [];
  bool _showPopup = false;
  Map<String, dynamic>? _currentPopupNotification;

  // Getters
  int get unreadCount => _unreadCount;
  bool get hasNewReservations => _hasNewReservations;
  Map<String, int> get resourceNotificationCounts => _resourceNotificationCounts;
  Map<String, bool> get resourceHasNew => _resourceHasNew;
  bool get isConnected => _isConnected;
  
  bool get showPopup => _showPopup;
  Map<String, dynamic>? get currentPopupNotification => _currentPopupNotification;
  List<Map<String, dynamic>> get recentNotifications => _recentNotifications;

  static const String _wsBaseUrl = 'ws://localhost:4000';
  static const String _baseUrl = 'http://localhost:4000';
  String? _currentUserId;
  String? _currentToken;

  // 🔔 NEW: Connect to WebSocket for real-time notifications
  void connectWebSocket(String approverId, String token) {
    _currentUserId = approverId;
    _currentToken = token;
    
    try {
      if (kDebugMode) {
        print('🔔 Connecting to WebSocket for user: $approverId');
      }
      
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsBaseUrl?userId=$approverId'),
      );

      _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDisconnect,
      );

      _isConnected = true;
      notifyListeners();
      
      if (kDebugMode) {
        print('✅ WebSocket connected successfully');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ WebSocket connection failed: $e');
      }
      _scheduleReconnect(approverId, token);
      // Fallback to polling if WebSocket fails
      startPolling(approverId, token);
    }
  }

  // 🔔 NEW: Handle incoming WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      final notification = json.decode(message);
      if (kDebugMode) {
        print('🔔 Received real-time notification: ${notification['type']}');
      }
      
      _processRealTimeNotification(notification);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing WebSocket message: $e');
      }
    }
  }

  // 🔔 NEW: Process different types of real-time notifications
  void _processRealTimeNotification(Map<String, dynamic> notification) {
    final type = notification['type'];
    
    switch (type) {
      case 'NEW_RESERVATION':
        _handleNewReservation(notification);
        break;
      case 'RESERVATION_READY_FOR_APPROVAL':
        _handleReservationReadyForApproval(notification);
        break;
      case 'RESERVATION_APPROVED':
      case 'RESERVATION_REJECTED':
        _handleReservationUpdate(notification);
        break;
      case 'RESERVATION_CANCELLED':
        _handleReservationCancelled(notification);
        break;
      default:
        if (kDebugMode) {
          print('🔔 Unknown notification type: $type');
        }
    }
  }

  // 🔔 NEW: Handle new reservation notification
  void _handleNewReservation(Map<String, dynamic> notification) {
    _unreadCount++;
    _hasNewReservations = true;
    
    final facilityId = notification['facility_id']?.toString() ?? '';
    if (facilityId.isNotEmpty) {
      _resourceNotificationCounts[facilityId] = 
          (_resourceNotificationCounts[facilityId] ?? 0) + 1;
      _resourceHasNew[facilityId] = true;
    }
    
    _showNotificationPopup([notification]);
    notifyListeners();
    
    if (kDebugMode) {
      print('🎯 Real-time: New reservation for ${notification['facility_name']}');
      print('🎯 Total pending: $_unreadCount');
    }
  }

  // 🔔 NEW: Handle reservation ready for next approver
  void _handleReservationReadyForApproval(Map<String, dynamic> notification) {
    _unreadCount++;
    _hasNewReservations = true;
    
    final facilityId = notification['facility_id']?.toString() ?? '';
    if (facilityId.isNotEmpty) {
      _resourceNotificationCounts[facilityId] = 
          (_resourceNotificationCounts[facilityId] ?? 0) + 1;
      _resourceHasNew[facilityId] = true;
    }
    
    _showNotificationPopup([notification]);
    notifyListeners();
    
    if (kDebugMode) {
      print('🎯 Real-time: Reservation ready for approval - ${notification['facility_name']}');
      print('🎯 Step ${notification['step_order']} - Total pending: $_unreadCount');
    }
  }

  // 🔔 NEW: Handle reservation updates (approved/rejected)
  void _handleReservationUpdate(Map<String, dynamic> notification) {
    _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
    
    final facilityId = notification['facility_id']?.toString() ?? '';
    if (facilityId.isNotEmpty && _resourceNotificationCounts.containsKey(facilityId)) {
      _resourceNotificationCounts[facilityId] = 
          (_resourceNotificationCounts[facilityId]! - 1).clamp(0, 999);
      
      if (_resourceNotificationCounts[facilityId]! == 0) {
        _resourceNotificationCounts.remove(facilityId);
        _resourceHasNew.remove(facilityId);
      }
    }
    
    notifyListeners();
    
    if (kDebugMode) {
      print('🎯 Real-time: Reservation updated - ${notification['type']}');
      print('🎯 Total pending: $_unreadCount');
    }
  }

  void _handleReservationCancelled(Map<String, dynamic> notification) {
    _handleReservationUpdate(notification);
  }

  // WebSocket error handling
  void _handleWebSocketError(error) {
    if (kDebugMode) {
      print('❌ WebSocket error: $error');
    }
    _isConnected = false;
    notifyListeners();
    
    _scheduleReconnect(_currentUserId, _currentToken);
  }

  void _handleWebSocketDisconnect() {
    if (kDebugMode) {
      print('🔔 WebSocket disconnected');
    }
    _isConnected = false;
    notifyListeners();
    
    _scheduleReconnect(_currentUserId, _currentToken);
  }

  void _scheduleReconnect(String? approverId, String? token) {
    if (approverId == null || token == null) return;
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (kDebugMode) {
        print('🔔 Attempting to reconnect WebSocket...');
      }
      connectWebSocket(approverId, token);
    });
  }

  // 🔔 NEW: Disconnect WebSocket
  void disconnect() {
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _pollingTimer?.cancel();
    _isConnected = false;
    notifyListeners();
  }

  // ✅ KEEP YOUR EXISTING POLLING METHODS (with minor updates)
  void startPolling(String approverId, String token) {
    _pollingTimer?.cancel();
    
    _checkForNewReservations(approverId, token);
    
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _checkForNewReservations(approverId, token),
    );
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _checkForNewReservations(String approverId, String token) async {
    // Skip polling if WebSocket is connected (to reduce server load)
    if (_isConnected) {
      if (kDebugMode) {
        print('🔔 Skipping polling - WebSocket is connected');
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/admin/getAllPendingForApprover/$approverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final previousCount = _unreadCount;
        final previousResourceCounts = Map<String, int>.from(_resourceNotificationCounts);
        
        _unreadCount = data.length;
        
        _resourceNotificationCounts.clear();
        _resourceHasNew.clear();
        
        for (final reservation in data) {
          final facilityId = reservation['facility_id']?.toString() ?? '';
          if (facilityId.isNotEmpty) {
            _resourceNotificationCounts[facilityId] = 
                (_resourceNotificationCounts[facilityId] ?? 0) + 1;
            
            final previousResourceCount = previousResourceCounts[facilityId] ?? 0;
            final currentResourceCount = _resourceNotificationCounts[facilityId] ?? 0;
            
            if (currentResourceCount > previousResourceCount) {
              _resourceHasNew[facilityId] = true;
            }
          }
        }
        
        if (_lastChecked != null) {
          _hasNewReservations = _unreadCount > previousCount;
        } else {
          _hasNewReservations = _unreadCount > 0;
        }
        
        final newReservations = _findNewReservations(data, previousCount);
        if (newReservations.isNotEmpty) {
          _showNotificationPopup(newReservations);
        }
        
        _lastChecked = DateTime.now();
        notifyListeners();
        
        if (kDebugMode) {
          print('🔔 Polling check: $_unreadCount pending reservations');
          print('🔔 Resource counts: $_resourceNotificationCounts');
          print('🔔 New reservations: $_hasNewReservations');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Polling error: $e');
      }
    }
  }

  // ✅ KEEP YOUR EXISTING HELPER METHODS
  List<Map<String, dynamic>> _findNewReservations(List<dynamic> currentReservations, int previousCount) {
    if (_lastChecked == null || previousCount >= currentReservations.length) {
      return [];
    }
    
    final newReservations = <Map<String, dynamic>>[];
    
    for (final reservation in currentReservations) {
      try {
        final createdAt = DateTime.parse(reservation['created_at'].toString()).toLocal();
        if (createdAt.isAfter(_lastChecked!)) {
          newReservations.add(Map<String, dynamic>.from(reservation));
        }
      } catch (e) {
        newReservations.add(Map<String, dynamic>.from(reservation));
      }
    }
    
    return newReservations;
  }

  void _showNotificationPopup(List<Map<String, dynamic>> newReservations) {
    if (newReservations.isEmpty) return;
    
    _recentNotifications.addAll(newReservations);
    if (_recentNotifications.length > 10) {
      _recentNotifications.removeRange(0, _recentNotifications.length - 10);
    }
    
    _currentPopupNotification = newReservations.first;
    _showPopup = true;
    notifyListeners();
    
    if (kDebugMode) {
      print('🎯 Showing popup for: ${_currentPopupNotification?['facility_name']}');
    }
    
    Future.delayed(const Duration(seconds: 5), () {
      _hidePopup();
    });
  }

  void _hidePopup() {
    _showPopup = false;
    _currentPopupNotification = null;
    notifyListeners();
  }

  void closePopup() {
    _hidePopup();
  }

  void viewAllNotifications() {
    _hidePopup();
    markAsRead();
  }

  bool hasNewForResource(String resourceId) {
    return _resourceHasNew[resourceId] == true;
  }

  int getCountForResource(String resourceId) {
    return _resourceNotificationCounts[resourceId] ?? 0;
  }

  void markAsRead() {
    _hasNewReservations = false;
    _resourceHasNew.clear();
    notifyListeners();
  }

  void markResourceAsRead(String resourceId) {
    _resourceHasNew[resourceId] = false;
    notifyListeners();
  }

  void resetAll() {
    _unreadCount = 0;
    _hasNewReservations = false;
    _resourceNotificationCounts.clear();
    _resourceHasNew.clear();
    _lastChecked = null;
    _recentNotifications.clear();
    _hidePopup();
    notifyListeners();
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }
}