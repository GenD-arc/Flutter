import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WorkflowStep {
  final String? id;
  final String userId;
  final int stepOrder;
  final String? name;
  final String? department;
  final String? roleType;

  WorkflowStep({
    this.id,
    required this.userId,
    required this.stepOrder,
    this.name,
    this.department,
    this.roleType,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> json) {
    return WorkflowStep(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      stepOrder: json['step_order']?.toInt() ?? 0,
      name: json['name']?.toString(),
      department: json['department']?.toString(),
      roleType: json['role_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'step_order': stepOrder,
    };
  }

  WorkflowStep copyWith({
    String? id,
    String? userId,
    int? stepOrder,
    String? name,
    String? department,
    String? roleType,
  }) {
    return WorkflowStep(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stepOrder: stepOrder ?? this.stepOrder,
      name: name ?? this.name,
      department: department ?? this.department,
      roleType: roleType ?? this.roleType,
    );
  }
}

class WorkflowService with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<WorkflowStep> _workflowSteps = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<WorkflowStep> get workflowSteps => _workflowSteps;

  // Configurable API base URL
  static const String _baseUrl = 'http://localhost:4000';

  Future<bool> createOrUpdateWorkflow({
    required String facilityId,
    required List<WorkflowStep> steps,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/superadmin/workflows'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'f_id': facilityId,
          'steps': steps.map((step) => step.toJson()).toList(),
        }),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseErrorResponse(response.body, 'Failed to create workflow');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating workflow: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchWorkflowByFacility(String facilityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/superadmin/workflows/$facilityId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _workflowSteps = data.map((json) => WorkflowStep.fromJson(json)).toList();
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 404) {
        _workflowSteps = [];
        _errorMessage = 'No workflow defined for this facility';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _errorMessage = _parseErrorResponse(response.body, 'Failed to fetch workflow');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error fetching workflow: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteWorkflow(String facilityId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/superadmin/workflows/$facilityId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        _workflowSteps = [];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseErrorResponse(response.body, 'Failed to delete workflow');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting workflow: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearWorkflow() {
    _workflowSteps = [];
    notifyListeners();
  }

  // Parse error response
  String _parseErrorResponse(String responseBody, String defaultMessage) {
    try {
      final errorBody = jsonDecode(responseBody);
      return errorBody['error']?.toString() ?? defaultMessage;
    } catch (_) {
      return defaultMessage;
    }
  }

  // Format error for user-friendly message
  String _formatError(dynamic error) {
    if (error is TimeoutException) {
      return 'Request timed out: Please check your connection';
    } else {
      return error.toString();
    }
  }
}