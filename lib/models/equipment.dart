import '../models/peripherals.dart';

class Equipment {
  final String id;
  final String serialNumber;
  final String userId; // ID del usuario asignado
  final List<Peripheral> peripherals;
  final String qrCode;
  final DateTime assignmentDate;

  Equipment({
    required this.id,
    required this.serialNumber,
    required this.userId,
    required this.peripherals,
    required this.qrCode,
    required this.assignmentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'serialNumber': serialNumber,
      'userId': userId,
      'peripherals': peripherals.map((p) => p.toMap()).toList(),
      'qrCode': qrCode,
      'assignmentDate': assignmentDate.toIso8601String(),
    };
  }

  factory Equipment.fromMap(Map<String, dynamic> map) {
    return Equipment(
      id: map['_id'],
      serialNumber: map['serialNumber'],
      userId: map['userId'],
      peripherals: (map['peripherals'] as List)
          .map((p) => Peripheral.fromMap(p))
          .toList(),
      qrCode: map['qrCode'],
      assignmentDate: DateTime.parse(map['assignmentDate']),
    );
  }
}