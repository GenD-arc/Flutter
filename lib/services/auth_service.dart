import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  static const String _baseUrl = 'http://localhost:4000';
  
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _token;
  User? _currentUser;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get token => _token;
  User? get currentUser => _currentUser;
  String? get userName => _currentUser?.name;
  String? get roleId => _currentUser?.roleId;
  String? get errorMessage => _errorMessage;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await checkAuthStatus();
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final Map<String, dynamic> error = json.decode(response.body) as Map<String, dynamic>;
      switch (response.statusCode) {
        case 401:
          return error['message'] ?? 'Invalid username or password.';
        case 403:
          return error['message'] ?? 'Your account has been deactivated. Please contact the administrator.';
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
    if (!_isDisposed) {
      Future.microtask(() => notifyListeners());
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  String _cleanToken(String rawToken) {
    return rawToken.replaceAll('"', '').trim();
  }

  bool _isValidJWTFormat(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return false;
    if (parts.any((part) => part.isEmpty)) return false;
    if (token.length < 50) return false;
    return true;
  }

  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      _safeNotifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? storedToken = prefs.getString('token');
      
      _token = storedToken != null ? _cleanToken(storedToken) : null;
      
      final userId = prefs.getString('user_id');
      final name = prefs.getString('user_name');
      final roleId = prefs.getString('role_id');
      final username = prefs.getString('username');

      if (_token != null && userId != null && name != null && roleId != null && _isValidJWTFormat(_token!)) {
        _currentUser = User(
          id: userId,
          name: name,
          department: prefs.getString('department') ?? '',
          roleId: roleId,
          roleType: _mapRoleIdToRoleType(roleId),
          username: username,
          email: prefs.getString('email'),
          active: prefs.getBool('active') ?? true,
        );
        _isAuthenticated = true;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
        if (_token != null && !_isValidJWTFormat(_token!)) {
          await clearCorruptedToken();
        }
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
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String rawToken = data['token']?.toString() ?? '';
        
        _token = _cleanToken(rawToken);
        
        if (!_isValidJWTFormat(_token!)) {
          _errorMessage = 'Invalid authentication token received from server.';
          _isAuthenticated = false;
          _token = null;
          _currentUser = null;
          _isLoading = false;
          _safeNotifyListeners();
          return false;
        }
        
        _currentUser = User(
          id: data['user_id']?.toString() ?? '',
          name: data['name']?.toString() ?? '',
          department: data['department']?.toString() ?? '',
          roleId: data['role_id']?.toString() ?? '',
          roleType: _mapRoleIdToRoleType(data['role_id']?.toString() ?? ''),
          username: data['username']?.toString(),
          email: data['email']?.toString(),
          active: data['active'] ?? true,
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
        if (_currentUser!.email != null) {
          await prefs.setString('email', _currentUser!.email!);
        }
        await prefs.setBool('active', _currentUser!.active);

        _isLoading = false;
        _safeNotifyListeners();
        return true;
      } else {
        _errorMessage = _extractErrorMessage(response);
        _isAuthenticated = false;
        _token = null;
        _currentUser = null;
        _isLoading = false;
        _safeNotifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: Please check your connection and try again.';
      _isAuthenticated = false;
      _token = null;
      _currentUser = null;
      _isLoading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  String? getAuthToken() {
    return _token;
  }

  Future<void> clearCorruptedToken() async {
    _token = null;
    _isAuthenticated = false;
    _currentUser = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('role_id');
    await prefs.remove('role_type');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('department');
    await prefs.remove('active');
    
    _safeNotifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _currentUser = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _safeNotifyListeners();
  }

  String _mapRoleIdToRoleType(String roleId) {
    final roleMap = {
      'R01': 'User',
      'R02': 'Admin',
      'R03': 'Super Admin',
    };
    return roleMap[roleId] ?? 'Unknown';
  }
}