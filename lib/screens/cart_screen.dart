import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/api_exceptions.dart';
import '../repositories/supabase_order_repository.dart';
import '../state/cart_notifier.dart';
import '../state/product_list_notifier.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _availablePoints = 0;
  bool _usePoints = false;
  bool _loadingPoints = true;

  @override
  void initState() {
    super.initState();
    _loadPoints();
  }

  Future<void> _loadPoints() async {
    try {
      final db = Supabase.instance.client;
      final userId = db.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _loadingPoints = false);
        return;
      }
      final row = await db
          .from('customers')
          .select('bonus_points')
          .eq('user_id', userId)
          .maybeSingle();
      if (!mounted) return;
      setState(() {
        _availablePoints = (row?['bonus_points'] as int?) ?? 0;
        _loadingPoints = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingPoints = false);
    }
  }

  int _pointsToSpend(double subtotal) {
    if (!_usePoints) return 0;
    // Нельзя списать больше, чем есть, и больше, чем сумма заказа
    final maxBySum = subtotal.floor();
    return _availablePoints.clamp(0, maxBySum);
  }

  Future<void> _checkout(BuildContext context) async {
    final cart = context.read<CartNotifier>();
    if (cart.items.isEmpty) return;

    final orderRepo = context.read<SupabaseOrderRepository>();
    final productList = context.read<ProductListNotifier>();

    final subtotal = cart.total;
    final pointsToSpend = _pointsToSpend(subtotal);
    final finalTotal = (subtotal - pointsToSpend).clamp(0, double.infinity);
    final earned = (finalTotal * 0.10).floor();

    try {
      await orderRepo.create(cart.items, pointsToSpend: pointsToSpend);
      cart.clear();
      await productList.load();

      if (!context.mounted) return;
      final message = StringBuffer('Заказ оформлен!');
      if (pointsToSpend > 0) {
        message.write(' Списано $pointsToSpend бонусов.');
      }
      if (earned > 0) {
        message.write(' Начислено $earned бонусов.');
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message.toString())));
      context.go('/orders/my');
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>();
    final subtotal = cart.total;
    final pointsToSpend = _pointsToSpend(subtotal);
    final finalTotal = (subtotal - pointsToSpend).clamp(0, double.infinity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Корзина пуста'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) {
                final it = cart.items[i];
                final limit = cart.limitFor(it.productId);
                return ListTile(
                  title: Text(it.productName),
                  subtitle: Text(
                    '${it.price.toStringAsFixed(0)} ₽ × ${it.quantity} '
                    '(доступно: $limit)',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => cart.decrement(it.productId),
                      ),
                      Text('${it.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final ok = cart.increment(it.productId);
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Достигнут лимит: $limit шт.'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Чекбокс списания баллов
                    if (!_loadingPoints && _availablePoints > 0)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Списать бонусы (доступно: $_availablePoints)',
                        ),
                        subtitle: Text(
                          _usePoints
                              ? 'Будет списано: $pointsToSpend'
                              : 'Не использовать бонусы',
                        ),
                        value: _usePoints,
                        onChanged: (v) =>
                            setState(() => _usePoints = v ?? false),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (pointsToSpend > 0)
                                Text(
                                  'Сумма: ${subtotal.toStringAsFixed(0)} ₽ − '
                                  '$pointsToSpend',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              Text(
                                'Итого: ${finalTotal.toStringAsFixed(0)} ₽',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                'Будет начислено: '
                                '${(finalTotal * 0.10).floor()} бонусов',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Оформить заказ'),
                          onPressed: () => _checkout(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
