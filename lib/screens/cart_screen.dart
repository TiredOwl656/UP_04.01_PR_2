import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../repositories/api_order_repository.dart';
import '../state/cart_notifier.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context) async {
    final cart = context.read<CartNotifier>();
    if (cart.items.isEmpty) return;
    try {
      await context.read<ApiOrderRepository>().create(cart.items);
      cart.clear();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ оформлен!')),
      );
      context.go('/orders/my');
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Корзина пуста'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) {
                final it = cart.items[i];
                return ListTile(
                  title: Text(it.productName),
                  subtitle: Text(
                      '${it.price.toStringAsFixed(0)} \u20BD × ${it.quantity}'),
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
                        onPressed: () => cart.increment(it.productId),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(
                    'Итого: ${cart.total.toStringAsFixed(0)} \u20BD',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Оформить заказ'),
                    onPressed: () => _checkout(context),
                  ),
                ],
              ),
            ),
    );
  }
}