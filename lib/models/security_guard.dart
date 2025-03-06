class SecurityGuard {
  final String id;
  final String username;
  final String password; // Should be hashed in production
  final String firstName;
  final String lastName;
  final DateTime registrationDate;
  final bool isActive;

  SecurityGuard({
    required this.id,
    required this.username,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.registrationDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'username': username,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'registrationDate': registrationDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory SecurityGuard.fromMap(Map<String, dynamic> map) {
    return SecurityGuard(
      id: map['_id'],
      username: map['username'],
      password: map['password'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      registrationDate: DateTime.parse(map['registrationDate']),
      isActive: map['isActive'] ?? true,
    );
  }
}