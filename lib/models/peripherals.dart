class Peripheral {
  final String? id;
  final String type; // mouse, teclado, base refrigerante, etc.
  final String? serialNumber;
  final bool isAssigned;
  final String? equipmentId;
  final DateTime? registrationDate;

  Peripheral({
    this.id,
    required this.type,
    this.serialNumber,
    required this.isAssigned,
    this.equipmentId,
    this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'serialNumber': serialNumber,
      'isAssigned': isAssigned,
      'equipmentId': equipmentId,
      'registrationDate': registrationDate?.toIso8601String(),
    };
  }

  factory Peripheral.fromMap(Map<String, dynamic> map) {
    return Peripheral(
      id: map['_id'],
      type: map['type'],
      serialNumber: map['serialNumber'],
      isAssigned: map['isAssigned'] ?? false,
      equipmentId: map['equipmentId'],
      registrationDate: map['registrationDate'] != null 
          ? DateTime.parse(map['registrationDate']) 
          : null,
    );
  }
}