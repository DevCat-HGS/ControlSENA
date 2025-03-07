import '../models/user.dart';
import '../models/equipment.dart';
import '../models/access_log.dart';
import '../models/security_guard.dart';
import '../models/peripherals.dart';
import 'api_user_service.dart';
import 'api_equipment_service.dart';
import 'api_peripheral_service.dart';
import 'api_security_guard_service.dart';
import 'api_access_log_service.dart';

class DatabaseService {
  final ApiUserService _apiUserService = ApiUserService();
  final ApiEquipmentService _apiEquipmentService = ApiEquipmentService();
  final ApiPeripheralService _apiPeripheralService = ApiPeripheralService();
  final ApiSecurityGuardService _apiSecurityGuardService = ApiSecurityGuardService();
  final ApiAccessLogService _apiAccessLogService = ApiAccessLogService();
  
  bool _isInitialized = false;
  // Métodos para celadores (security guards)
  Future<String> addSecurityGuard(SecurityGuard securityGuard) async {
    await initialize();
    final result = await _apiSecurityGuardService.addSecurityGuard(securityGuard);
    return result.id;
  }
  
  Future<SecurityGuard?> getSecurityGuardByUsername(String username) async {
    await initialize();
    return await _apiSecurityGuardService.getSecurityGuardByUsername(username);
  }
  
  Future<List<SecurityGuard>> getAllSecurityGuards() async {
    await initialize();
    return await _apiSecurityGuardService.getAllSecurityGuards();
  }
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // No necesitamos conectar a MongoDB directamente, ya que usamos la API
      _isInitialized = true;
      print('Servicios API inicializados correctamente');
    } catch (e) {
      print('Error al inicializar los servicios API: $e');
      rethrow; // Relanzar la excepción para que los llamadores puedan manejarla
    }
  }
  
  // Métodos para usuarios
  Future<String> addUser(User user) async {
    await initialize();
    final result = await _apiUserService.addUser(user);
    return result.id;
  }
  
  Future<User?> getUserByCardId(String cardId) async {
    await initialize();
    return await _apiUserService.getUserByCardId(cardId);
  }
  
  Future<User?> getUserById(String userId) async {
    await initialize();
    return await _apiUserService.getUserById(userId);
  }
  
  Future<List<User>> getAllUsers() async {
    await initialize();
    return await _apiUserService.getAllUsers();
  }
  
  // Métodos para equipos
  Future<String> addEquipment(Equipment equipment) async {
    await initialize();
    final result = await _apiEquipmentService.addEquipment(equipment);
    return result.id;
  }
  
  Future<Equipment?> getEquipmentByQR(String qrCode) async {
    await initialize();
    return await _apiEquipmentService.getEquipmentByQR(qrCode);
  }
  
  Future<Equipment?> getEquipmentById(String equipmentId) async {
    await initialize();
    return await _apiEquipmentService.getEquipmentById(equipmentId);
  }
  
  Future<List<Equipment>> getEquipmentByUserId(String userId) async {
    await initialize();
    return await _apiEquipmentService.getEquipmentByUserId(userId);
  }
  
  // Métodos para registros de acceso
  Future<String> logAccess(AccessLog log) async {
    await initialize();
    final result = await _apiAccessLogService.logAccess(log);
    return result.id;
  }
  
  Future<List<AccessLog>> getAccessLogsByEquipment(String equipmentId) async {
    await initialize();
    return await _apiAccessLogService.getAccessLogsByEquipment(equipmentId);
  }
  
  Future<List<AccessLog>> getAccessLogsByDate(DateTime date) async {
    await initialize();
    return await _apiAccessLogService.getAccessLogsByDate(date);
  }
  
  Future<String> determineAccessType(String equipmentId, String userId) async {
    await initialize();
    return await _apiAccessLogService.determineAccessType(equipmentId, userId);
  }
  
  // Métodos para periféricos
  Future<String> addPeripheral(Peripheral peripheral) async {
    await initialize();
    final result = await _apiPeripheralService.createPeripheral(peripheral);
    return result.id!;
  }

  Future<Peripheral?> getPeripheralById(String id) async {
    await initialize();
    return await _apiPeripheralService.getPeripheralById(id);
  }

  Future<List<Peripheral>> getAllPeripherals() async {
    await initialize();
    return await _apiPeripheralService.getAllPeripherals();
  }

  Future<List<Peripheral>> getPeripheralsByType(String type) async {
    await initialize();
    return await _apiPeripheralService.getPeripheralsByType(type);
  }

  Future<List<Peripheral>> getPeripheralsByEquipment(String equipmentId) async {
    await initialize();
    return await _apiPeripheralService.getPeripheralsByEquipment(equipmentId);
  }

  Future<bool> updatePeripheral(String id, Map<String, dynamic> updates) async {
    await initialize();
    try {
      await _apiPeripheralService.updatePeripheral(id, updates);
      return true;
    } catch (e) {
      print('Error al actualizar el periférico: $e');
      return false;
    }
  }

  Future<bool> deletePeripheral(String id) async {
    await initialize();
    try {
      await _apiPeripheralService.deletePeripheral(id);
      return true;
    } catch (e) {
      print('Error al eliminar el periférico: $e');
      return false;
    }
  }

  Future<void> close() async {
    if (_isInitialized) {
      _isInitialized = false;
    }
  }
}