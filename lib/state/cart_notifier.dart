import 'package:flutter/foundation.dart';

import '../models/order.dart';

class CartNotifier extends ChangeNotifier {
  final List<OrderItem> _items = [];
  // Храним лимит остатка на складе для каждого товара.
  final Map<int, int> _stockLimits = {};

  List<OrderItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  double get total => _items.fold(0, (s, it) => s + it.subtotal);

  int limitFor(int productId) => _stockLimits[productId] ?? 0;

  bool add(OrderItem item, {required int stockLimit}) {
    _stockLimits[item.productId] = stockLimit;
    final i = _items.indexWhere((x) => x.productId == item.productId);
    if (i == -1) {
      if (stockLimit <= 0) return false;
      _items.add(item);
    } else {
      if (_items[i].quantity >= stockLimit) return false;
      _items[i] = OrderItem(
        productId: _items[i].productId,
        productName: _items[i].productName,
        price: _items[i].price,
        quantity: _items[i].quantity + 1,
      );
    }
    notifyListeners();
    return true;
  }

  bool increment(int productId) {
    final i = _items.indexWhere((x) => x.productId == productId);
    if (i == -1) return false;
    final limit = _stockLimits[productId] ?? 0;
    if (_items[i].quantity >= limit) return false;
    _items[i] = OrderItem(
      productId: _items[i].productId,
      productName: _items[i].productName,
      price: _items[i].price,
      quantity: _items[i].quantity + 1,
    );
    notifyListeners();
    return true;
  }

  void decrement(int productId) {
    final i = _items.indexWhere((x) => x.productId == productId);
    if (i == -1) return;
    if (_items[i].quantity <= 1) {
      _items.removeAt(i);
      _stockLimits.remove(productId);
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
    _stockLimits.clear();
    notifyListeners();
  }
}
