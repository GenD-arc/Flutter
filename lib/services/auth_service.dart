import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  static const String _baseUrl = 'http://localhost:4000';
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _token;
  User? _currentUser;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  User? get currentUser => _currentUser;
  String? get userName => _currentUser?.name; // For backward compatibility
  String? get roleId => _currentUser?.roleId; // For backward compatibility
  String? get errorMessage => _errorMessage;

  String _extractErrorMessage(http.Response response) {
    try {
      final Map<String, dynamic> error = json.decode(response.body) as Map<String, dynamic>;
      switch (response.statusCode) {
        case 401:
          return error['message'] ?? 'Invalid username or password.';
        case 403:
          return error['message'] ??
              'Your account has been deactivated. Please contact the administrator.';
        case 500:
          return error['message'] ?? 'Server error. Please try again later.';
        default:
          return error['message'] ?? 'Login failed. Please try again.';
      }
    } catch (e) {
      return 'Login failed (unexpected response format).';
    }
  }

  void _safeNotifyListeners() {
    Future.microtask(() => notifyListeners());
  }

  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      _safeNotifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final userId = prefs.getString('user_id');
      final name = prefs.getString('user_name');
      final roleId = prefs.getString('role_id');
      final username = prefs.getString('username');

      if (_token != null && userId != null && name != null && roleId != null) {
        _currentUser = User(
          id: userId,
          name: name,
          department: '', // Default value
          roleId: roleId,
          roleType: _mapRoleIdToRoleType(roleId), // Map role_id to role_type
          username: username,
          email: null, // Not provided
          active: true, // Default to true
        );
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      _isAuthenticated = false;
      _currentUser = null;
      _errorMessage = 'Error checking auth status: $e';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> login(String identifier, String password) async {
    print('🔍 Login attempt started');
    
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'identifier': identifier,
          'password': password,
        }),
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token']?.toString() ?? '';
        _currentUser = User(
          id: data['user_id']?.toString() ?? '',
          name: data['name']?.toString() ?? '',
          department: '', // Default value
          roleId: data['role_id']?.toString() ?? '',
          roleType: _mapRoleIdToRoleType(data['role_id']?.toString() ?? ''),
          username: data['username']?.toString(),
          email: null, // Not provided
          active: true, // Default to true
        );
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user_id', _currentUser!.id);
        await prefs.setString('user_name', _currentUser!.name);
        await prefs.setString('department', _currentUser!.department);
        await prefs.setString('role_id', _currentUser!.roleId);
        await prefs.setString('role_type', _currentUser!.roleType);
        if (_currentUser!.username != null) {
          await prefs.setString('username', _currentUser!.username!);
        }
        await prefs.setBool('active', _currentUser!.active);

        _isLoading = false;
        _safeNotifyListeners();
        
        print('✅ Login successful: userId=${_currentUser!.id}');
        return true;
      } else {
        _errorMessage = _extractErrorMessage(response);
        print('❌ Login failed: $_errorMessage');
        
        _isLoading = false;
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: Please check your connection and try again.';
      print('❌ Network error: $e');
      
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _currentUser = null;
    _errorMessage = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _safeNotifyListeners();
  }

  // Map role_id to role_type
  String _mapRoleIdToRoleType(String roleId) {
    final roleMap = {
      'R01': 'User',
      'R02': 'Admin',
      'R03': 'Super Admin',
    };
    return roleMap[roleId] ?? 'Unknown';
  }
}