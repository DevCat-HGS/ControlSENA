class Peripheral {
  final String type; // mouse, teclado, base refrigerante, etc.
  final String? serialNumber;
  final bool isAssigned;

  Peripheral({
    required this.type,
    this.serialNumber,
    required this.isAssigned,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'serialNumber': serialNumber,
      'isAssigned': isAssigned,
    };
  }

  factory Peripheral.fromMap(Map<String, dynamic> map) {
    return Peripheral(
      type: map['type'],
      serialNumber: map['serialNumber'],
      isAssigned: map['isAssigned'],
    );
  }
}