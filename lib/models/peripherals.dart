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
    // Handle the case where 'type' is a Map<String, dynamic> instead of a String
    String typeValue;
    if (map['type'] is Map<String, dynamic>) {
      // If 'type' is a map, extract the actual type string from it
      typeValue = map['type']['type'] ?? '';
    } else if (map['type'] != null) {
      // Otherwise use it directly if not null
      typeValue = map['type'].toString();
    } else {
      // Default value if type is null
      typeValue = '';
    }
    
    return Peripheral(
      id: map['_id'],
      type: typeValue,
      serialNumber: map['serialNumber'],
      isAssigned: map['isAssigned'] ?? false,
      equipmentId: map['equipmentId'],
      registrationDate: map['registrationDate'] != null 
          ? DateTime.parse(map['registrationDate']) 
          : null,
    );
  }
}