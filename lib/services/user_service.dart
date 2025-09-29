import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService with ChangeNotifier {
  // Configurable API base URL (replace with your production URL)
  static const String _baseUrl = 'http://localhost:4000';//'https://flutter-backend-v1.onrender.com'
  
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _authToken;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get authToken => _authToken;

  Future<void> fetchUsers({String status = "active", List<String>? roleIds}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final uri = Uri.parse('$_baseUrl/api/superadmin/viewUsers').replace(
      queryParameters: {
        if (status.isNotEmpty) 'status': status,
        if (roleIds != null && roleIds.isNotEmpty) 'role_id': roleIds.join(','),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_authToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      _users = data.map((json) => User.fromJson(json)).toList();
    } else {
      _errorMessage = 'Failed to load users';
    }
  } catch (error) {
    _errorMessage = 'Error: $error';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

Future<Map<String, int>> fetchUserCounts() async {
  try {
    final uri = Uri.parse('$_baseUrl/api/superadmin/viewUsers/counts');
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $_authToken'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'active': data['activeCount'] ?? 0,
        'archived': data['archivedCount'] ?? 0,
        'total': data['totalCount'] ?? 0,
      };
    } else {
      throw Exception('Failed to fetch counts');
    }
  } catch (error) {
    print('Error fetching counts: $error');
    return {'active': 0, 'archived': 0, 'total': 0};
  }
}


  Future<User?> getUserById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/superadmin/updateUser/$userId'),
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Failed to get user details');
      }
    } catch (error) {
      _errorMessage = 'Error fetching user: $error';
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/superadmin/updateUser/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final updatedUser = await getUserById(userId);
        if (updatedUser != null) {
          final index = _users.indexWhere((user) => user.id == userId);
          if (index != -1) {
            _users[index] = updatedUser;
          }
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? 'Failed to update user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Error updating user: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/superadmin/deleteUser/$userId'),
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      if (response.statusCode == 200) {
        _users.removeWhere((user) => user.id == userId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? 'Failed to delete user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Error deleting user: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMultipleUsers(List<String> userIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/superadmin/deleteUser/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({'userIds': userIds}),
      );

      if (response.statusCode == 200) {
        _users.removeWhere((user) => userIds.contains(user.id));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? 'Failed to delete users';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Error deleting users: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addUser({
    required String id,
    required String name,
    required String department,
    required String username,
    required String email,
    required String password,
    required String roleId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userData = {
        'id': id,
        'name': name,
        'department': department,
        'username': username,
        'email': email,
        'password': password,
        'role_id': roleId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/superadmin/addUser'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        await fetchUsers();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? 'Failed to add user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Error adding user: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

 Future<bool> softDeleteUser(String userId) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await http.patch(
      Uri.parse('$_baseUrl/api/superadmin/deleteUser/$userId/deactivate'), 
      headers: {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken', 
      },
    );

    if (response.statusCode == 200) {

  _users = _users.map((user) {
    if (user.id == userId) {
      return user.copyWith(active: false); 
    }
    return user;
  }).toList();

  _isLoading = false;
  notifyListeners();
  return true;
}
else {
      String errorMsg = 'Failed to soft delete user (status: ${response.statusCode})';
      if (response.body.isNotEmpty) {
        if (response.headers['content-type']?.contains('application/json') == true) {
          try {
            final errorBody = jsonDecode(response.body);
            errorMsg = errorBody['error'] ?? errorMsg;
          } catch (parseError) {
            errorMsg += ' (Parse error: $parseError, body: ${response.body.substring(0, 100)})';
          }
        } else {
          errorMsg += ': ${response.body.substring(0, 200)}...';
        }
      }
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  } catch (e) {
    _errorMessage = 'Network error during soft delete: $e';
    _isLoading = false;
    notifyListeners();
    return false;
  }
}

  Future<bool> restoreUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/superadmin/deleteUser/$userId/restore'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        await fetchUsers();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? 'Failed to restore user';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = 'Error restoring user: $error';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<LoginResponse?> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        _authToken = loginResponse.token;
        // Store token in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _authToken!);
        _isLoading = false;
        notifyListeners();
        return loginResponse;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (error) {
      _errorMessage = 'Error during login: $error';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    notifyListeners();
  }

  Future<void> logout() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _users = [];
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}