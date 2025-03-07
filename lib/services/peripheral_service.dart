import 'package:mongo_dart/mongo_dart.dart';
import '../models/peripherals.dart';

class PeripheralService {
  late Db _db;
  late DbCollection _peripheralsCollection;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _db = await Db.create('mongodb://localhost:27017/equipment_control');
      await _db.open();
      _peripheralsCollection = _db.collection('peripherals');
      _isInitialized = true;
    } catch (e) {
      print('Error al conectar con MongoDB: $e');
      rethrow;
    }
  }

  // Obtener todos los periféricos
  Future<List<Peripheral>> getAllPeripherals() async {
    await initialize();
    final results = await _peripheralsCollection.find().toList();
    return results.map((e) => Peripheral.fromMap(e)).toList();
  }

  // Obtener periférico por ID
  Future<Peripheral?> getPeripheralById(String id) async {
    await initialize();
    final result = await _peripheralsCollection.findOne(where.eq('_id', ObjectId.parse(id)));
    if (result == null) return null;
    return Peripheral.fromMap(result);
  }

  // Obtener periféricos por tipo
  Future<List<Peripheral>> getPeripheralsByType(String type) async {
    await initialize();
    final results = await _peripheralsCollection.find(where.eq('type', type)).toList();
    return results.map((e) => Peripheral.fromMap(e)).toList();
  }

  // Obtener periféricos por equipmentId
  Future<List<Peripheral>> getPeripheralsByEquipment(String equipmentId) async {
    await initialize();
    final results = await _peripheralsCollection.find(where.eq('equipmentId', equipmentId)).toList();
    return results.map((e) => Peripheral.fromMap(e)).toList();
  }

  // Crear un nuevo periférico
  Future<String> addPeripheral(Peripheral peripheral) async {
    await initialize();
    final result = await _peripheralsCollection.insertOne(peripheral.toMap());
    return result.id.toString();
  }

  // Actualizar un periférico
  Future<bool> updatePeripheral(String id, Map<String, dynamic> updates) async {
    await initialize();
    try {
      var modifier = ModifierBuilder();
      updates.forEach((key, value) {
        modifier.set(key, value);
      });
      
      final result = await _peripheralsCollection.updateOne(
        where.eq('_id', ObjectId.parse(id)),
        modifier
      );
      return result.isSuccess;
    } catch (e) {
      print('Error al actualizar el periférico: $e');
      return false;
    }
  }

  // Eliminar un periférico
  Future<bool> deletePeripheral(String id) async {
    await initialize();
    try {
      final result = await _peripheralsCollection.deleteOne(
        where.eq('_id', ObjectId.parse(id))
      );
      return result.isSuccess;
    } catch (e) {
      print('Error al eliminar el periférico: $e');
      return false;
    }
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _db.close();
      _isInitialized = false;
    }
  }
}