import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart'; // For MIME type handling

class Resource {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? imageUrl;

  Resource({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.imageUrl,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['f_id']?.toString() ?? '',
      name: json['f_name']?.toString() ?? '',
      description: json['f_description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
    );
  }
}

class ResourceService with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Resource> _resources = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Resource> get resources => _resources;

  // Configurable API base URL (replace with your production URL)
  static const String _baseUrl = 'http://localhost:4000';//'https://flutter-backend-v1.onrender.com'

  Future<bool> addResource({
    required String id,
    required String name,
    required String description,
    required String category,
    File? image,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/superadmin/addResources'),
      );

      request.fields['f_id'] = id;
      request.fields['f_name'] = name;
      request.fields['f_description'] = description;
      request.fields['category'] = category;

      if (kIsWeb && imageBytes != null) {
        // Validate MIME type for web
        final filename = _validateImageName(imageName);
        if (filename == null) {
          _errorMessage = 'Only JPEG and PNG images are allowed';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'f_image',
            imageBytes,
            filename: filename,
            contentType: MediaType('image', filename.endsWith('.png') ? 'png' : 'jpeg'),
          ),
        );
      } else if (!kIsWeb && image != null) {
        final extension = image.path.toLowerCase();
        if (!_isValidImageExtension(extension)) {
          _errorMessage = 'Only JPEG and PNG images are allowed';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        request.files.add(
          await http.MultipartFile.fromPath('f_image', image.path),
        );
      }

      final response = await request.send().timeout(Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        await fetchResources(); // Refresh resources to include the new one
        return true;
      } else {
        _errorMessage = _parseErrorResponse(responseBody, 'Failed to add resource');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding resource: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateResource({
    required String id,
    String? name,
    String? description,
    String? category,
    File? image,
    Uint8List? imageBytes,
    String? imageName,
    bool isFullUpdate = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      var request = http.MultipartRequest(
        isFullUpdate ? 'PUT' : 'PATCH',
        Uri.parse('$_baseUrl/api/superadmin/updateResource/$id'),
      );

      if (name != null) request.fields['f_name'] = name;
      if (description != null) request.fields['f_description'] = description;
      if (category != null) request.fields['category'] = category;

      if (kIsWeb && imageBytes != null) {
        final filename = _validateImageName(imageName);
        if (filename == null) {
          _errorMessage = 'Only JPEG and PNG images are allowed';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        request.files.add(
          http.MultipartFile.fromBytes(
            'f_image',
            imageBytes,
            filename: filename,
            contentType: MediaType('image', filename.endsWith('.png') ? 'png' : 'jpeg'),
          ),
        );
      } else if (!kIsWeb && image != null) {
        final extension = image.path.toLowerCase();
        if (!_isValidImageExtension(extension)) {
          _errorMessage = 'Only JPEG and PNG images are allowed';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        request.files.add(
          await http.MultipartFile.fromPath('f_image', image.path),
        );
      }

      final response = await request.send().timeout(Duration(seconds: 30));
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        await fetchResources(); // Refresh resources
        return true;
      } else {
        _errorMessage = _parseErrorResponse(responseBody, 'Failed to update resource');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating resource: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteResource(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/superadmin/deleteResource/$id'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        await fetchResources(); // Refresh resources
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseErrorResponse(response.body, 'Failed to delete resource');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting resource: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMultipleResources(List<String> ids) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/superadmin/deleteResource'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'ids': ids}),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        await fetchResources(); // Refresh resources
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseErrorResponse(response.body, 'Failed to delete resources');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting resources: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> softDeleteResource(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/superadmin/deleteResource/$id/soft-delete'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        await fetchResources(); // Refresh resources
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseErrorResponse(response.body, 'Failed to soft delete resource');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error soft deleting resource: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreResource(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/superadmin/deleteResource/$id/restore'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        await fetchResources(); // Refresh resources
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseErrorResponse(response.body, 'Failed to restore resource');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error restoring resource: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchResources([List<String>? categories]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_baseUrl/api/superadmin/viewResources').replace(
        queryParameters: categories != null && categories.isNotEmpty
            ? {'categories': categories.join(',')}
            : null,
      );
      final response = await http.get(uri).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _resources = data.map((json) => Resource.fromJson(json)).toList();
        if (_resources.isEmpty) {
          _errorMessage = 'No resources found';
        }
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Failed to load resources: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error fetching resources: ${_formatError(e)}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to clear error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Validate image name for web
  String? _validateImageName(String? imageName) {
    if (imageName == null) return 'image.jpg';
    final lowercaseName = imageName.toLowerCase();
    if (lowercaseName.endsWith('.jpg') || lowercaseName.endsWith('.jpeg') || lowercaseName.endsWith('.png')) {
      return imageName;
    }
    return null;
  }

  // Validate image extension for non-web
  bool _isValidImageExtension(String extension) {
    return extension.endsWith('.jpg') || extension.endsWith('.jpeg') || extension.endsWith('.png');
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
    if (error is SocketException) {
      return 'Network error: Unable to connect to the server';
    } else if (error is TimeoutException) {
      return 'Request timed out: Please check your connection';
    } else {
      return error.toString();
    }
  }
}