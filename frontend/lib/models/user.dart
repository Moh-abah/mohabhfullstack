class User {
  final int id;
  final String username;
  final String name;
  final String phone;
  final String password;
  final String userType;

  User({
    required this.id,
    required this.username,
    required this.name,
    required this.phone,
    required this.password,
    required this.userType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'phone': phone,
      'password': password,
      'user_type': userType,
    };
  }

  static fromJson(json) {}

  UsertoCompanion() {
    return UsertoCompanion();
  }
}
