import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../models/reservation_model.dart';

class ReservationService {
  static const String baseUrl = 'http://localhost:4000/api/user';

  final AuthService authService;

  ReservationService(this.authService);

  Future<List<Reservation>> getUserReservations(String userId) async {
    final token = authService.token;
    if (token == null) throw Exception('Authentication required');

    final response = await http.get(
      Uri.parse('$baseUrl/viewReservation/$userId'),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed');
    } else {
      throw Exception('Failed to load reservations: ${response.statusCode}');
    }
  }

  Future<void> cancelReservation(int reservationId) async {
    final token = authService.token;
    if (token == null) throw Exception('Authentication required');

    final response = await http.patch(
      Uri.parse('$baseUrl/cancelReservation/$reservationId/cancel'),
      headers: _buildHeaders(token),
    );

    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to cancel reservation');
    }
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}