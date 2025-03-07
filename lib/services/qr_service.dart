import 'dart:convert';
import '../models/user.dart';
import '../models/equipment.dart';

class QRService {
  // Genera un código QR único basado en el número de serie y el ID del usuario
  String generateUniqueQRCode(String serialNumber, String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Create a unique identifier
    final uniqueId = '$serialNumber-$userId-$timestamp';
    
    return uniqueId;
  }
  
  String generateCompleteQRCode(User user, Equipment equipment) {
    // Create a comprehensive data object
    final qrData = {
      'user': {
        'id': user.id,
        'cardId': user.cardId,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'registrationDate': user.registrationDate.toIso8601String(),
      },
      'equipment': {
        'id': equipment.id,
        'serialNumber': equipment.serialNumber,
        'assignmentDate': equipment.assignmentDate.toIso8601String(),
        'peripherals': equipment.peripherals.map((p) => {
          'types': p.types,
        }).toList(),
      },
    };
    
    // Convert to JSON string and encode to base64 to make it more compact
    return base64Encode(utf8.encode(jsonEncode(qrData)));
  }
}