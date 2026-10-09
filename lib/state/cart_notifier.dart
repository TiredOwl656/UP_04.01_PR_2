import 'package:flutter/foundation.dart';

import '../models/order.dart';

class CartNotifier extends ChangeNotifier {
  final List<OrderItem> _items = [];

  List<OrderItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  double get total => _items.fold(0, (s, it) => s + it.subtotal);

  void add(OrderItem item) {
    final i = _items.indexWhere((x) => x.productId == item.productId);
    if (i == -1) {
      _items.add(item);
    } else {
      _items[i] = OrderItem(
        productId: _items[i].productId,
        productName: _items[i].productName,
        price: _items[i].price,
        quantity: _items[i].quantity + 1,
      );
    }
    notifyListeners();
  }

  void increment(int productId) {
    final i = _items.indexWhere((x) => x.productId == productId);
    if (i == -1) return;
    _items[i] = OrderItem(
      productId: _items[i].productId,
      productName: _items[i].productName,
      price: _items[i].price,
      quantity: _items[i].quantity + 1,
    );
    notifyListeners();
  }

  void decrement(int productId) {
    final i = _items.indexWhere((x) => x.productId == productId);
    if (i == -1) return;
    if (_items[i].quantity <= 1) {
      _items.removeAt(i);
    } else {
      _items[i] = OrderItem(
        productId: _items[i].productId,
        productName: _items[i].productName,
        price: _items[i].price,
        quantity: _items[i].quantity - 1,
      );
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}