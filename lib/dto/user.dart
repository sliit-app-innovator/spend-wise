class UserDto {
  int? id;
  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final String email;

  UserDto({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.password,
    required this.email,
  });

  // Converts User object to a map to store in Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'password': password,
      'email': email
    };
  }

  Map<String, Object?> toJsonSQL() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'password': password,
      'email': email
    };
  }

  static UserDto fromJson(Map<String, dynamic> json) {
    return UserDto(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        username: json['username'],
        password: json['password'],
        email: json['email']);
  }
}
