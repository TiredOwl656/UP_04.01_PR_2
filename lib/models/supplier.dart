class Supplier {
  final int id;
  final String name;
  final String country;
  final String email;
  final String phone;
  final DateTime? deletedAt;

  const Supplier({
    required this.id,
    required this.name,
    required this.country,
    required this.email,
    required this.phone,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Supplier copyWith({
    String? name,
    String? country,
    String? email,
    String? phone,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) =>
      Supplier(
        id: id,
        name: name ?? this.name,
        country: country ?? this.country,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
        'email': email,
        'phone': phone,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        country: json['country'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        deletedAt: json['deletedAt'] == null
            ? null
            : DateTime.tryParse(json['deletedAt'] as String),
      );
}