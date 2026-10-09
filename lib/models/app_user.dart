enum Role {
  customer('Покупатель'),
  manager('Менеджер'),
  admin('Администратор');

  final String label;
  const Role(this.label);

  static Role fromName(String name) => switch (name) {
        'admin' => Role.admin,
        'manager' => Role.manager,
        _ => Role.customer,
      };
}

class AppUser {
  final int id;
  final String username;
  final String fullName;
  final Role role;

  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        role: Role.fromName(json['role'] as String? ?? 'customer'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'role': role.name,
      };
}