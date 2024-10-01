class UserConfigs {
  int? id;
  final String username;
  final String name;
  final String value;

  UserConfigs({
    this.id,
    required this.username,
    required this.name,
    required this.value,
  });

  // Converts User object to a map to store in Firestore
  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'name': name, 'value': value};
  }

  Map<String, Object?> toJsonSQL() {
    return {'id': id, 'username': username, 'name': name, 'value': value};
  }

  static UserConfigs fromJson(Map<String, dynamic> json) {
    return UserConfigs(
        id: json['id'],
        username: json['username'],
        name: json['name'],
        value: json['value']);
  }
}
