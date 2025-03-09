class Peripheral {
  final String? id;
  final Map<String, bool> types; // Map of peripheral types and their boolean values
  final String? serialNumber;
  final bool isAssigned;
  final String? equipmentId;
  final DateTime? registrationDate;

  Peripheral({
    this.id,
    required this.types,
    this.serialNumber,
    this.isAssigned = true,
    this.equipmentId,
    this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    // Convertir el mapa de tipos a un formato que el backend pueda entender
    // El backend espera un String para 'type', así que tomamos la primera clave del mapa
    String type = types.keys.isNotEmpty ? types.keys.first : '';
    
    return {
      'type': type, // Enviamos solo el primer tipo como String
      'serialNumber': serialNumber,
      'isAssigned': isAssigned,
      'equipmentId': equipmentId,
      'registrationDate': registrationDate?.toIso8601String(),
    };
  }

  factory Peripheral.fromMap(Map<String, dynamic> map) {
    Map<String, bool> typesMap = {};
    
    // Manejar diferentes formatos de datos que pueden venir del backend
    if (map['types'] is Map) {
      typesMap = Map<String, bool>.from(map['types']);
    } else if (map['type'] is String && map['type'].toString().isNotEmpty) {
      // Si 'type' es un String, lo convertimos a nuestro formato de mapa
      typesMap[map['type'].toString()] = true;
    }

    return Peripheral(
      id: map['_id'],
      types: typesMap,
      serialNumber: map['serialNumber'],
      isAssigned: map['isAssigned'] ?? true,
      equipmentId: map['equipmentId'],
      registrationDate: map['registrationDate'] != null 
          ? DateTime.parse(map['registrationDate']) 
          : null,
    );
  }
}