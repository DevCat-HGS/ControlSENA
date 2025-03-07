import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class ApiUserService {
  final String baseUrl = 'http://localhost:3000/api';

  // Get all users
  Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Get user by ID
  Future<User?> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    
    if (response.statusCode == 200) {
      return User.fromMap(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load user');
    }
  }

  // Get user by card ID
  Future<User?> getUserByCardId(String cardId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/card/$cardId'));
    
    if (response.statusCode == 200) {
      return User.fromMap(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load user');
    }
  }

  // Create user
  Future<User> addUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(user.toMap()..remove('_id')),
    );
    
    if (response.statusCode == 201) {
      return User.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to create user');
    }
  }

  // Update user
  Future<bool> updateUser(String id, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );
    
    return response.statusCode == 200;
  }

  // Delete user
  Future<bool> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
    return response.statusCode == 200;
  }
}