class Review {
  final int id;
  final int productId;
  final int customerId;
  final int rating;
  final String text;
  final String status;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.rating,
    required this.text,
    required this.status,
    required this.createdAt,
  });

  String get statusLabel => switch (status) {
        'approved' => 'Одобрен',
        'rejected' => 'Отклонён',
        _ => 'На модерации',
      };

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id: j['id'] as int? ?? 0,
        productId: j['productId'] as int? ?? 0,
        customerId: j['customerId'] as int? ?? 0,
        rating: j['rating'] as int? ?? 0,
        text: j['text'] as String? ?? '',
        status: j['status'] as String? ?? 'pending',
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}