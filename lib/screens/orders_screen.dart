import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/order.dart';
import '../repositories/api_order_repository.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order>? _orders;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await context.read<ApiOrderRepository>().all();
      if (!mounted) return;
      setState(() {
        _orders = list;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _setStatus(int id, String status) async {
    try {
      await context.read<ApiOrderRepository>().setStatus(id, status);
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Заказы')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_orders == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Заказы покупателей')),
      body: _orders!.isEmpty
          ? const Center(child: Text('Заказов нет'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _orders!.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, i) {
                final o = _orders![i];
                return ListTile(
                  title: Text('#${o.id} — ${o.customerName}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final it in o.items)
                        Text('${it.productName} × ${it.quantity}'),
                      Text('Итого: ${o.total.toStringAsFixed(0)} \u20BD'),
                      Text(
                        'Статус: ${o.statusLabel}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (s) => _setStatus(o.id, s),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'confirmed', child: Text('Подтвердить')),
                      PopupMenuItem(value: 'packed', child: Text('Собрать')),
                      PopupMenuItem(
                          value: 'shipped', child: Text('Отправить')),
                      PopupMenuItem(
                          value: 'delivered', child: Text('Доставлен')),
                      PopupMenuItem(
                          value: 'cancelled', child: Text('Отменить')),
                    ],
                  ),
                );
              },
            ),
    );
  }
}