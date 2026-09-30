class Brand {
  final int id;
  final String name;        // название бренда
  final String country;     // страна
  final int foundedYear;
  final DateTime? deletedAt;

  const Brand({
    required this.id,
    required this.name,
    required this.country,
    required this.foundedYear,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Brand copyWith({
    String? name,
    String? country,
    int? foundedYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Brand(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      foundedYear: foundedYear ?? this.foundedYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}