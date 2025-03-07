import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/peripherals.dart';

class ApiPeripheralService {
  final String baseUrl = 'http://10.0.2.2:3000/api';

  // Get all peripherals
  Future<List<Peripheral>> getAllPeripherals() async {
    final response = await http.get(Uri.parse('$baseUrl/peripherals'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Peripheral.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load peripherals');
    }
  }

  // Get peripheral by ID
  Future<Peripheral> getPeripheralById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/peripherals/$id'));
    
    if (response.statusCode == 200) {
      return Peripheral.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to load peripheral');
    }
  }

  // Get peripherals by equipment ID
  Future<List<Peripheral>> getPeripheralsByEquipment(String equipmentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/peripherals/equipment/$equipmentId')
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Peripheral.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load peripherals for equipment');
    }
  }

  // Get peripherals by type
  Future<List<Peripheral>> getPeripheralsByType(String type) async {
    final response = await http.get(
      Uri.parse('$baseUrl/peripherals/type/$type')
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Peripheral.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load peripherals by type');
    }
  }

  // Create a new peripheral
  Future<Peripheral> createPeripheral(Peripheral peripheral) async {
    final response = await http.post(
      Uri.parse('$baseUrl/peripherals'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(peripheral.toMap())
    );
    
    if (response.statusCode == 201) {
      return Peripheral.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to create peripheral');
    }
  }

  // Update a peripheral
  Future<Peripheral> updatePeripheral(String id, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/peripherals/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates)
    );
    
    if (response.statusCode == 200) {
      return Peripheral.fromMap(json.decode(response.body));
    } else {
      throw Exception('Failed to update peripheral');
    }
  }

  // Delete a peripheral
  Future<void> deletePeripheral(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/peripherals/$id')
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete peripheral');
    }
  }
}