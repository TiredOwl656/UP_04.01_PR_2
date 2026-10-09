class OrderItem {
  final int productId;
  final String productName;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        productId: j['productId'] as int? ?? 0,
        productName: j['productName'] as String? ?? '',
        price: (j['price'] as num?)?.toDouble() ?? 0,
        quantity: j['quantity'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
      };
}

class Order {
  final int id;
  final int customerId;
  final String customerName;
  final List<OrderItem> items;
  final double total;
  final String status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  String get statusLabel => switch (status) {
        'new' => 'Новый',
        'confirmed' => 'Подтверждён',
        'packed' => 'Собран',
        'shipped' => 'Отправлен',
        'delivered' => 'Доставлен',
        'cancelled' => 'Отменён',
        _ => status,
      };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as int? ?? 0,
        customerId: j['customerId'] as int? ?? 0,
        customerName: j['customerName'] as String? ?? '',
        items: (j['items'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map(OrderItem.fromJson)
                .toList() ??
            const [],
        total: (j['total'] as num?)?.toDouble() ?? 0,
        status: j['status'] as String? ?? 'new',
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}