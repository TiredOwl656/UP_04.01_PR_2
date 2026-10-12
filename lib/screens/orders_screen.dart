import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/order.dart';
import '../repositories/supabase_order_repository.dart';
import '../state/auth_notifier.dart';

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
      final list = await context.read<SupabaseOrderRepository>().all();
      if (!mounted) return;
      setState(() {
        _orders = list;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _orders = [];
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _orders = [];
        _error = 'Ошибка: $e';
      });
    }
  }

  Future<void> _setStatus(int id, String status) async {
    try {
      await context.read<SupabaseOrderRepository>().setStatus(id, status);
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _hardDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить заказ?'),
        content: Text('Заказ #$id будет удалён навсегда.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await context.read<SupabaseOrderRepository>().hardDelete(id);
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказы покупателей'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
            onPressed: _load,
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_error!),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _load,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            )
          : _orders == null
          ? const Center(child: CircularProgressIndicator())
          : _orders!.isEmpty
          ? const Center(child: Text('Заказов нет'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _orders!.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) {
                    final o = _orders![i];
                    return ListTile(
                      title: Text('#${o.id} — ${o.statusLabel}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final it in o.items)
                            Text(
                              '${it.productName} × ${it.quantity} — ${it.price.toStringAsFixed(0)} ₽',
                            ),
                          Text('Итого: ${o.total.toStringAsFixed(0)} ₽'),
                          Text('Создан: ${o.createdAt.toLocal()}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<String>(
                            onSelected: (s) => _setStatus(o.id, s),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'confirmed',
                                child: Text('Подтвердить'),
                              ),
                              PopupMenuItem(
                                value: 'packed',
                                child: Text('Собрать'),
                              ),
                              PopupMenuItem(
                                value: 'shipped',
                                child: Text('Отправить'),
                              ),
                              PopupMenuItem(
                                value: 'delivered',
                                child: Text('Доставлен'),
                              ),
                              PopupMenuItem(
                                value: 'cancelled',
                                child: Text('Отменить'),
                              ),
                            ],
                          ),
                          if (auth.canManageUsers)
                            IconButton(
                              icon: const Icon(Icons.delete_forever),
                              tooltip: 'Удалить навсегда',
                              onPressed: () => _hardDelete(o.id),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
