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
    return {
      'types': types,
      'serialNumber': serialNumber,
      'isAssigned': isAssigned,
      'equipmentId': equipmentId,
      'registrationDate': registrationDate?.toIso8601String(),
    };
  }

  factory Peripheral.fromMap(Map<String, dynamic> map) {
    Map<String, bool> typesMap = {};
    if (map['types'] is Map) {
      typesMap = Map<String, bool>.from(map['types']);
    } else if (map['type'] is Map<String, dynamic>) {
      // Handle legacy format
      typesMap[map['type']['type'] ?? ''] = true;
    } else if (map['type'] != null) {
      // Handle legacy format
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