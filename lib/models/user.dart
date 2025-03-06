class User {
  final String id;
  final String cardId; // ID de la tarjeta de Identidad
  final String firstName;
  final String lastName;
  final DateTime registrationDate;

  User({
    required this.id,
    required this.cardId,
    required this.firstName,
    required this.lastName,
    required this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'cardId': cardId,
      'firstName': firstName,
      'lastName': lastName,
      'registrationDate': registrationDate.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'],
      cardId: map['cardId'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      registrationDate: DateTime.parse(map['registrationDate']),
    );
  }
}