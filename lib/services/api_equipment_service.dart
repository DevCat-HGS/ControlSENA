import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/equipment.dart';

class ApiEquipmentService {
  final String baseUrl = 'http://10.0.2.2:3000/api';

  // Get all equipment
  Future<List<Equipment>> getAllEquipment() async {
    final response = await http.get(Uri.parse('$baseUrl/equipment'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Equipment.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load equipment');
    }
  }

  // Get equipment by ID
  Future<Equipment?> getEquipmentById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/equipment/$id'));
    
    if (response.statusCode == 200) {
      return Equipment.fromMap(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load equipment');
    }
  }

  // Get equipment by QR code
  Future<Equipment?> getEquipmentByQR(String qrCode) async {
    final response = await http.get(Uri.parse('$baseUrl/equipment/qr/$qrCode'));
    
    if (response.statusCode == 200) {
      return Equipment.fromMap(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load equipment');
    }
  }

  // Get equipment by user ID
  Future<List<Equipment>> getEquipmentByUserId(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/equipment/user/$userId'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Equipment.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load equipment for user');
    }
  }

  // Create equipment
  Future<Equipment> addEquipment(Equipment equipment) async {
    try {
      print('DEBUG API: Preparando datos para enviar al servidor');
      final equipmentMap = equipment.toMap()..remove('_id');
      print('DEBUG API: Datos a enviar: ${json.encode(equipmentMap)}');
      
      print('DEBUG API: Enviando solicitud POST a $baseUrl/equipment');
      final response = await http.post(
        Uri.parse('$baseUrl/equipment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(equipmentMap),
      );
      
      print('DEBUG API: Respuesta recibida con código ${response.statusCode}');
      print('DEBUG API: Cuerpo de la respuesta: ${response.body}');
      
      if (response.statusCode == 201) {
        print('DEBUG API: Equipo creado exitosamente');
        return Equipment.fromMap(json.decode(response.body));
      } else {
        print('DEBUG API: Error al crear equipo. Código: ${response.statusCode}, Respuesta: ${response.body}');
        throw Exception('Failed to create equipment: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      print('DEBUG API: Excepción al crear equipo: $e');
      print('DEBUG API: Stack trace: $stackTrace');
      throw Exception('Exception: Failed to create equipment: $e');
    }
  }

  // Update equipment
  Future<bool> updateEquipment(String id, Map<String, dynamic> updates) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/equipment/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updates),
    );
    
    return response.statusCode == 200;
  }

  // Delete equipment
  Future<bool> deleteEquipment(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/equipment/$id'));
    return response.statusCode == 200;
  }
}