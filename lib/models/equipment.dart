import '../models/peripherals.dart';

class Equipment {
  final String id;
  final String name;
  final String description;
  final String userId; // ID del usuario asignado
  final List<Peripheral> peripherals;
  final String qrCode;
  final String? serialNumber; // Número de serie del equipo (opcional)
  final DateTime assignmentDate;

  Equipment({
    required this.id,
    required this.name,
    required this.description,
    required this.userId,
    required this.peripherals,
    required this.qrCode,
    this.serialNumber,
    required this.assignmentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'userId': userId,
      'peripherals': peripherals.map((p) => p.toMap()).toList(),
      'qrCode': qrCode,
      'serialNumber': serialNumber,
      'assignmentDate': assignmentDate.toIso8601String(),
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['_id'],
      name: map['name'],
      description: map['description'],
      userId: map['userId'],
      peripherals: (map['peripherals'] as List)
          .map((p) => Peripheral.fromMap(p))
          .toList(),
      qrCode: map['qrCode'],
      serialNumber: map['serialNumber'],
      assignmentDate: DateTime.parse(map['assignmentDate']),
    );
  }
}