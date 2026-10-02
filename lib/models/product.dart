class Product {
  final int id;
  final String name;
  final String sku;
  final int brandId;
  final int supplierId;
  final List<int> categoryIds;
  final String size;
  final String color;
  final double price;
  final int stock;
  final int year;
  final DateTime? deletedAt;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.brandId,
    required this.supplierId,
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
    int? supplierId,
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
      supplierId: supplierId ?? this.supplierId,
      categoryIds: categoryIds ?? this.categoryIds,
      size: size ?? this.size,
      color: color ?? this.color,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      year: year ?? this.year,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'brandId': brandId,
        'supplierId': supplierId,
        'categoryIds': categoryIds,
        'size': size,
        'color': color,
        'price': price,
        'stock': stock,
        'year': year,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        sku: json['sku'] as String? ?? '',
        brandId: json['brandId'] as int? ?? 0,
        supplierId: json['supplierId'] as int? ?? 0,
        categoryIds:
            (json['categoryIds'] as List?)?.cast<int>() ?? const <int>[],
        size: json['size'] as String? ?? '',
        color: json['color'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        stock: json['stock'] as int? ?? 0,
        year: json['year'] as int? ?? 0,
        deletedAt: json['deletedAt'] == null
            ? null
            : DateTime.tryParse(json['deletedAt'] as String),
      );
}