class AccessLog {
  final String id;
  final String equipmentId;
  final String userId;
  final DateTime timestamp;
  final String accessType; // "entry" o "exit"

  AccessLog({
    required this.id,
    required this.equipmentId,
    required this.userId,
    required this.timestamp,
    required this.accessType,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'equipmentId': equipmentId,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'accessType': accessType,
    };
  }

  factory AccessLog.fromMap(Map<String, dynamic> map) {
    return AccessLog(
      id: map['_id'],
      equipmentId: map['equipmentId'],
      userId: map['userId'],
      timestamp: DateTime.parse(map['timestamp']),
      accessType: map['accessType'],
    );
  }
}