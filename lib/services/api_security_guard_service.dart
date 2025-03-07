import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/security_guard.dart';

class ApiSecurityGuardService {
  final String baseUrl = 'http://localhost:3000/api';

  // Get all security guards
  Future<List<SecurityGuard>> getAllSecurityGuards() async {
    final response = await http.get(Uri.parse('$baseUrl/securityGuards'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SecurityGuard.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load security guards');
    }
  }

  // Get security guard by ID
  Future<SecurityGuard?> getSecurityGuardById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/securityGuards/$id'));
    
    if (response.statusCode == 200) {
      return SecurityGuard.fromMap(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load security guard');
    }
  }

  // Get security guard by username
  Future<SecurityGuard?> getSecurityGuardByUsername(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/securityGuards/username/$username'));
    
    if (response.statusCode == 200) {
      return SecurityGuard.fromMap(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load security guard');
    }
  }

  // Create security guard
  Future<SecurityGuard> addSecurityGuard(SecurityGuard securityGuard) async {
    final response = await http.post(
      Uri.parse('$baseUrl/securityGuards'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(securityGuard.toMap()..remove('_id')),
    );
    
    if (response.statusCode == 201) {
      return SecurityGuard.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to create security guard');
    }
  }

  // Update security guard
  Future<bool> updateSecurityGuard(String id, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/securityGuards/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );
    
    return response.statusCode == 200;
  }

  // Delete security guard
  Future<bool> deleteSecurityGuard(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/securityGuards/$id'));
    return response.statusCode == 200;
  }
}