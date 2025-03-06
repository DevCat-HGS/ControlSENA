import 'package:mongo_dart/mongo_dart.dart';
import '../models/user.dart';
import '../models/equipment.dart';
import '../models/access_log.dart';
import '../models/security_guard.dart';

class DatabaseService {
  late Db _db;
  late DbCollection _usersCollection;
  late DbCollection _equipmentCollection;
  late DbCollection _accessLogCollection;
  
  bool _isInitialized = false;
  // Métodos para celadores (security guards)
  Future<String> addSecurityGuard(SecurityGuard securityGuard) async {
    await initialize();
    final result = await _db.collection('security_guards').insertOne(securityGuard.toMap());
    return result.id.toString();
  }
  
  Future<SecurityGuard?> getSecurityGuardByUsername(String username) async {
    await initialize();
    final result = await _db.collection('security_guards').findOne(where.eq('username', username));
    if (result == null) return null;
    return SecurityGuard.fromMap(result);
  }
  
  Future<List<SecurityGuard>> getAllSecurityGuards() async {
    await initialize();
    final results = await _db.collection('security_guards').find().toList();
    return results.map((e) => SecurityGuard.fromMap(e)).toList();
  }
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Conectar a MongoDB - ajusta la URL según tu configuración
      _db = await Db.create('mongodb://localhost:27017/equipment_control');
      await _db.open();
      
      _usersCollection = _db.collection('users');
      _equipmentCollection = _db.collection('equipment');
      _accessLogCollection = _db.collection('access_logs');
      
      _isInitialized = true;
      print('Conexión a MongoDB establecida correctamente');
    } catch (e) {
      print('Error al conectar con MongoDB: $e');
      // Puedes agregar aquí sugerencias específicas basadas en el error
      if (e.toString().contains('SocketException')) {
        print('Asegúrate de que MongoDB esté instalado y el servicio esté ejecutándose');
        print('Puedes iniciar MongoDB con: mongod --dbpath=<ruta-a-tu-directorio-de-datos>');
      } else if (e.toString().contains('authentication failed')) {
        print('Error de autenticación. Verifica tus credenciales de MongoDB');
      }
      rethrow; // Relanzar la excepción para que los llamadores puedan manejarla
    }
  }
  
  // Métodos para usuarios
  Future<String> addUser(User user) async {
    await initialize();
    final result = await _usersCollection.insertOne(user.toMap());
    return result.id.toString();
  }
  
  Future<User?> getUserByCardId(String cardId) async {
    await initialize();
    final result = await _usersCollection.findOne(where.eq('cardId', cardId));
    if (result == null) return null;
    return User.fromMap(result);
  }
  
  Future<User?> getUserById(String userId) async {
    await initialize();
    final result = await _usersCollection.findOne(where.eq('_id', ObjectId.parse(userId)));
    if (result == null) return null;
    return User.fromMap(result);
  }
  
  Future<List<User>> getAllUsers() async {
    await initialize();
    final results = await _usersCollection.find().toList();
    return results.map((e) => User.fromMap(e)).toList();
  }
  
  // Métodos para equipos
  Future<String> addEquipment(Equipment equipment) async {
    await initialize();
    final result = await _equipmentCollection.insertOne(equipment.toMap());
    return result.id.toString();
  }
  
  Future<Equipment?> getEquipmentByQR(String qrCode) async {
    await initialize();
    final result = await _equipmentCollection.findOne(where.eq('qrCode', qrCode));
    if (result == null) return null;
    return Equipment.fromMap(result);
  }
  
  Future<Equipment?> getEquipmentById(String equipmentId) async {
    await initialize();
    final result = await _equipmentCollection.findOne(where.eq('_id', ObjectId.parse(equipmentId)));
    if (result == null) return null;
    return Equipment.fromMap(result);
  }
  
  Future<List<Equipment>> getEquipmentByUserId(String userId) async {
    await initialize();
    final results = await _equipmentCollection.find(where.eq('userId', userId)).toList();
    return results.map((e) => Equipment.fromMap(e)).toList();
  }
  
  // Métodos para registros de acceso
  Future<String> logAccess(AccessLog log) async {
    await initialize();
    final result = await _accessLogCollection.insertOne(log.toMap());
    return result.id.toString();
  }
  
  Future<List<AccessLog>> getAccessLogsByEquipment(String equipmentId) async {
    await initialize();
    final results = await _accessLogCollection.find(where.eq('equipmentId', equipmentId)).toList();
    return results.map((e) => AccessLog.fromMap(e)).toList();
  }
  
  Future<List<AccessLog>> getAccessLogsByDate(DateTime date) async {
    await initialize();
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final results = await _accessLogCollection.find(
      where.gte('timestamp', startOfDay.toIso8601String())
           .lte('timestamp', endOfDay.toIso8601String())
    ).toList();
    
    return results.map((e) => AccessLog.fromMap(e)).toList();
  }
  
  Future<String> determineAccessType(String equipmentId, String userId) async {
    await initialize();
    
    // Obtener los registros de hoy para este equipo y usuario
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final logs = await _accessLogCollection.find(
      where.eq('equipmentId', equipmentId)
          .eq('userId', userId)
          .gte('timestamp', startOfDay.toIso8601String())
    ).toList();
    
    // Si el número de registros es par, entonces es una entrada
    // Si es impar, entonces es una salida
    return logs.length % 2 == 0 ? 'entry' : 'exit';
  }
  
  Future<void> close() async {
    if (_isInitialized) {
      await _db.close();
      _isInitialized = false;
    }
  }
}