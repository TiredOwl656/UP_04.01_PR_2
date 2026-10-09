import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/order.dart';
import '../repositories/api_order_repository.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  List<Order>? _orders;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await context.read<ApiOrderRepository>().myOrders();
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

  Future<void> _cancel(int id) async {
    try {
      await context.read<ApiOrderRepository>().cancel(id);
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
        appBar: AppBar(title: const Text('Мои заказы')),
        body: Center(child: Text(_error!)),
      );
    }
    if (_orders == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_orders!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Мои заказы')),
        body: const Center(child: Text('Заказов пока нет')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Мои заказы')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _orders!.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, i) {
          final o = _orders![i];
          return ListTile(
            title: Text('Заказ #${o.id} — ${o.statusLabel}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final it in o.items)
                  Text('${it.productName} × ${it.quantity}'),
                Text('Итого: ${o.total.toStringAsFixed(0)} \u20BD'),
              ],
            ),
            trailing: o.status == 'new'
                ? TextButton(
                    onPressed: () => _cancel(o.id),
                    child: const Text('Отменить'),
                  )
                : null,
          );
        },
      ),
    );
  }
}