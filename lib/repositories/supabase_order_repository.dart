import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exceptions.dart';
import '../models/order.dart';

class SupabaseOrderRepository {
  final SupabaseClient _db;
  SupabaseOrderRepository(this._db);

  /// Создать заказ текущего покупателя.
  Future<Order> create(
    List<OrderItem> items, {
    int pointsToSpend = 0,
  }) => _guard(() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw const UnauthorizedException();

    final customerRow = await _db
        .from('customers')
        .select('id, bonus_points')
        .eq('user_id', userId)
        .maybeSingle();
    if (customerRow == null) {
      throw const ForbiddenException('Профиль покупателя не найден');
    }
    final customerId = customerRow['id'] as int;
    final availablePoints = (customerRow['bonus_points'] as int?) ?? 0;

    // Ограничение: нельзя списать больше, чем есть
    final toSpend = pointsToSpend.clamp(0, availablePoints);

    // Проверка остатков
    for (final it in items) {
      final product = await _db
          .from('products')
          .select('stock, deleted_at')
          .eq('id', it.productId)
          .maybeSingle();
      if (product == null || product['deleted_at'] != null) {
        throw ConflictException(
          'Товар «${it.productName}» больше не продаётся',
        );
      }
      final stock = product['stock'] as int? ?? 0;
      if (stock < it.quantity) {
        throw ConflictException(
          'Товара «${it.productName}» недостаточно на складе: доступно $stock',
        );
      }
    }

    // Итоговая сумма с учётом списания
    final subtotal = items.fold<double>(
      0,
      (s, it) => s + it.price * it.quantity,
    );
    final total = (subtotal - toSpend).clamp(0, double.infinity);

    // Создаём заказ
    final orderRow = await _db
        .from('orders')
        .insert({
          'customer_id': customerId,
          'total': total,
          'status': 'new',
          'points_spent': toSpend,
        })
        .select()
        .single();

    final orderId = orderRow['id'] as int;

    // Позиции
    await _db
        .from('order_items')
        .insert(
          items
              .map(
                (it) => {
                  'order_id': orderId,
                  'product_id': it.productId,
                  'product_name': it.productName,
                  'quantity': it.quantity,
                  'price': it.price,
                },
              )
              .toList(),
        );

    // Уменьшить остатки
    for (final it in items) {
      final product = await _db
          .from('products')
          .select('stock')
          .eq('id', it.productId)
          .single();
      final newStock = ((product['stock'] as int?) ?? 0) - it.quantity;
      await _db
          .from('products')
          .update({'stock': newStock})
          .eq('id', it.productId);
    }

    // Триггер на orders уже списал/начислил баллы.

    final full = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', orderId)
        .single();
    return _fromRow(full);
  });

  /// Мои заказы — только для customer.
  Future<List<Order>> myOrders() => _guard(() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw const UnauthorizedException();

    final customerRow = await _db
        .from('customers')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (customerRow == null) return const <Order>[];

    final customerId = customerRow['id'] as int;

    final data = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);

    return (data as List).cast<Map<String, dynamic>>().map(_fromRow).toList();
  });

  /// Все заказы — для manager / admin (RLS уже ограничивает).
  Future<List<Order>> all() => _guard(() async {
    final data = await _db
        .from('orders')
        .select('*, order_items(*)')
        .order('created_at', ascending: false);

    return (data as List).cast<Map<String, dynamic>>().map(_fromRow).toList();
  });

  Future<void> cancel(int id) => _guard(() async {
    await _db.from('orders').update({'status': 'cancelled'}).eq('id', id);
  });

  Future<Order> setStatus(int id, String status) => _guard(() async {
    await _db.from('orders').update({'status': status}).eq('id', id);
    final row = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .single();
    return _fromRow(row);
  });

  Future<void> hardDelete(int id) => _guard(() async {
    await _db.from('orders').delete().eq('id', id);
  });

  Future<Order> restore(int id) => _guard(() async {
    await _db.from('orders').update({'status': 'new'}).eq('id', id);
    final row = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .single();
    return _fromRow(row);
  });

  Order _fromRow(Map<String, dynamic> row) {
    final itemsRaw = row['order_items'] as List? ?? const [];
    final items = itemsRaw
        .cast<Map<String, dynamic>>()
        .map(
          (it) => OrderItem(
            productId: it['product_id'] as int? ?? 0,
            productName: it['product_name'] as String? ?? '',
            price: (it['price'] as num?)?.toDouble() ?? 0,
            quantity: it['quantity'] as int? ?? 0,
          ),
        )
        .toList();

    return Order(
      id: row['id'] as int,
      customerId: row['customer_id'] as int? ?? 0,
      customerName: '', // денормализация: см. ниже
      items: items,
      total: (row['total'] as num?)?.toDouble() ?? 0,
      status: row['status'] as String? ?? 'new',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      throw _mapPostgrest(e);
    } on AuthException catch (e) {
      throw UnauthorizedException(e.message);
    } catch (e) {
      throw NetworkException('Ошибка сети: $e');
    }
  }

  ApiException _mapPostgrest(PostgrestException e) {
    if (e.code == '23505') return ConflictException(e.message);
    if (e.code == '42501') return ForbiddenException(e.message);
    if (e.code == 'PGRST116') return const NotFoundException();
    return ServerException(e.message);
  }
}
