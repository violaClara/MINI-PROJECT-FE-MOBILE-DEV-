class User {
  final int? id;
  final String email;
  final String password;
  final DateTime memberSince;

  User({
    this.id,
    required this.email,
    required this.password,
    required this.memberSince,
  });

  // Convert a User into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'member_since': memberSince.toIso8601String(),
    };
  }

  // Create a User from a Map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      password: map['password'],
      memberSince: DateTime.parse(map['member_since']),
    );
  }

  // Return the username extracted from the email (everything before '@')
  String get username {
    int index = email.indexOf('@');
    if (index == -1) return email;
    return email.substring(0, index);
  }
}
