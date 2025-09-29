import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/approval_logs_model.dart';

class ApprovalLogsService {
  Future<List<ApprovalLog>> fetchApprovalLogs(String approverId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:4000/api/admin/approval-logs/$approverId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final logs = (data['logs'] as List<dynamic>?)
            ?.map((log) => ApprovalLog.fromJson(log as Map<String, dynamic>))
            .toList() ?? [];
        return logs;
      } else {
        throw Exception('Failed to load approval logs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching approval logs: $e');
    }
  }
}