class Product {
  final int id;
  final String name;
  final String sku;          // артикул (аналог ISBN)
  final int brandId;
  final List<int> categoryIds;
  final String size;         // XS..XXL
  final String color;
  final double price;
  final int stock;           // остаток на складе
  final int year;            // год коллекции
  final DateTime? deletedAt;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.brandId,
    required this.categoryIds,
    required this.size,
    required this.color,
    required this.price,
    required this.stock,
    required this.year,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  bool get inStock => stock > 0;

  Product copyWith({
    String? name,
    String? sku,
    int? brandId,
    List<int>? categoryIds,
    String? size,
    String? color,
    double? price,
    int? stock,
    int? year,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      brandId: brandId ?? this.brandId,
      categoryIds: categoryIds ?? this.categoryIds,
      size: size ?? this.size,
      color: color ?? this.color,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      year: year ?? this.year,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}