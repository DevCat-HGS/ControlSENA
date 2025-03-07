import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/access_log.dart';

class ApiAccessLogService {
  final String baseUrl = 'http://localhost:3000/api';

  // Get all access logs
  Future<List<AccessLog>> getAllAccessLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/accessLogs'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AccessLog.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load access logs');
    }
  }

  // Get access log by ID
  Future<AccessLog?> getAccessLogById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/accessLogs/$id'));
    
    if (response.statusCode == 200) {
      return AccessLog.fromMap(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load access log');
    }
  }

  // Get access logs by equipment ID
  Future<List<AccessLog>> getAccessLogsByEquipment(String equipmentId) async {
    final response = await http.get(Uri.parse('$baseUrl/accessLogs/equipment/$equipmentId'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AccessLog.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load access logs for equipment');
    }
  }

  // Get access logs by date
  Future<List<AccessLog>> getAccessLogsByDate(DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
    final response = await http.get(Uri.parse('$baseUrl/accessLogs/date/$dateString'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AccessLog.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load access logs for date');
    }
  }

  // Create access log
  Future<AccessLog> logAccess(AccessLog log) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accessLogs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(log.toMap()..remove('_id')),
    );
    
    if (response.statusCode == 201) {
      return AccessLog.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to create access log');
    }
  }

  // Determine access type (entry/exit)
  Future<String> determineAccessType(String equipmentId, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/accessLogs/type/$equipmentId/$userId')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['accessType'];
    } else {
      throw Exception('Failed to determine access type');
    }
  }
}