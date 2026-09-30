import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import '../state/product_list_notifier.dart';
import '../widgets/adaptive_entity_view.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/state_views.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = context.read<ProductListNotifier>();
      _searchCtrl.text = notifier.query.search;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _go(ProductQuery q) {
    context.go('/products?${_toQueryString(q.toQueryParams())}');
  }

  String _toQueryString(Map<String, String> m) =>
      m.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<ProductListNotifier>();
    final q = notifier.query;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог товаров'),
        actions: [
          IconButton(
            icon: const Icon(Icons.storefront),
            tooltip: 'Бренды',
            onPressed: () => context.go('/brands'),
          ),
        ],
      ),
      body: Column(
        children: [
          _FiltersPanel(
            searchCtrl: _searchCtrl,
            query: q,
            onSearch: notifier.onSearchChanged,
            onApply: _go,
          ),
          if (notifier.hasSelection)
            _SelectionBar(
              count: notifier.selected.length,
              onClear: () {
                notifier.toggleSelectAll();
              },
              onDelete: () => _confirmDeleteSelected(context, notifier),
            ),
          Expanded(
            child: buildStateView(
              status: notifier.status,
              isEmpty: notifier.result.isEmpty,
              error: notifier.error,
              onRetry: notifier.load,
              onData: () => Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AdaptiveEntityView<Product>(
                        items: notifier.result.items,
                        idOf: (p) => p.id,
                        selected: notifier.selected,
                        onToggleSelect: notifier.toggleSelection,
                        sortField: q.sortField,
                        sortAscending: q.sortAscending,
                        onSort: (field) {
                          final next = q.copyWith(
                            sortField: field,
                            sortAscending: field == q.sortField
                                ? !q.sortAscending
                                : true,
                          );
                          _go(next);
                        },
                        isDeleted: (p) => p.isDeleted,
                        columns: [
                          TableColumnSpec(
                              label: 'Название',
                              sortField: 'name',
                              build: (p) => Text(p.name)),
                          TableColumnSpec(
                              label: 'Артикул',
                              build: (p) => Text(p.sku)),
                          TableColumnSpec(
                              label: 'Год',
                              sortField: 'year',
                              numeric: true,
                              build: (p) => Text('${p.year}')),
                          TableColumnSpec(
                              label: 'Цена',
                              sortField: 'price',
                              numeric: true,
                              build: (p) => Text('${p.price.toStringAsFixed(0)} ₽')),
                          TableColumnSpec(
                              label: 'Остаток',
                              sortField: 'stock',
                              numeric: true,
                              build: (p) => Text('${p.stock}')),
                        ],
                        cardBuilder: (p) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('Артикул: ${p.sku}'),
                            Text('Год: ${p.year} • Размер: ${p.size} • Цвет: ${p.color}'),
                            Text('Цена: ${p.price.toStringAsFixed(0)} ₽ • Остаток: ${p.stock}'),
                            if (p.isDeleted)
                              const Text('Удалён',
                                  style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        actions: (p) => [
                          if (p.isDeleted)
                            IconButton(
                              icon: const Icon(Icons.restore),
                              tooltip: 'Восстановить',
                              onPressed: () => notifier.restore(p.id),
                            )
                          else ...[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Редактировать',
                              onPressed: () =>
                                  context.go('/products/${p.id}'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Логически удалить',
                              onPressed: () => _confirmSoftDelete(context, notifier, p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever),
                              tooltip: 'Удалить навсегда',
                              onPressed: () => _confirmHardDelete(context, notifier, p),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  PaginationBar(
                    page: notifier.result.page,
                    totalPages: notifier.result.totalPages,
                    total: notifier.result.total,
                    size: q.size,
                    onPage: (p) => _go(q.withPage(p)),
                    onSize: (s) => _go(q.copyWith(size: s, page: 1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  final TextEditingController searchCtrl;
  final ProductQuery query;
  final ValueChanged<String> onSearch;
  final ValueChanged<ProductQuery> onApply;

  const _FiltersPanel({
    required this.searchCtrl,
    required this.query,
    required this.onSearch,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Поиск по названию или артикулу',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: onSearch,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Фильтр по категории
              DropdownButton<int?>(
                value: query.categoryId,
                hint: const Text('Категория'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Все категории')),
                  for (final e in categories.entries)
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                ],
                onChanged: (v) => onApply(query.copyWith(categoryId: v)),
              ),
              // Фильтр по бренду
              DropdownButton<int?>(
                value: query.brandId,
                hint: const Text('Бренд'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Все бренды')),
                  for (final b in seedBrands)
                    DropdownMenuItem(value: b.id, child: Text(b.name)),
                ],
                onChanged: (v) => onApply(query.copyWith(brandId: v)),
              ),
              // Диапазон года
              SizedBox(
                width: 90,
                child: TextFormField(
                  initialValue: query.yearFrom?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Год от', isDense: true),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) => onApply(
                    query.copyWith(yearFrom: int.tryParse(v) ?? (v.isEmpty ? null : query.yearFrom)),
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: TextFormField(
                  initialValue: query.yearTo?.toString() ?? '',
                  decoration: const InputDecoration(labelText: 'Год до', isDense: true),
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (v) => onApply(
                    query.copyWith(yearTo: int.tryParse(v) ?? (v.isEmpty ? null : query.yearTo)),
                  ),
                ),
              ),
              // Показ удалённых
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: query.includeDeleted,
                    onChanged: (v) => onApply(query.copyWith(includeDeleted: v ?? false)),
                  ),
                  const Text('Показывать удалённые'),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('Сбросить'),
                onPressed: () {
                  searchCtrl.clear();
                  onApply(const ProductQuery());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectionBar extends StatelessWidget {
  final int count;
  final VoidCallback onClear;
  final VoidCallback onDelete;

  const _SelectionBar({
    required this.count,
    required this.onClear,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Text('Выбрано: $count',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(onPressed: onClear, child: const Text('Снять выделение')),
            FilledButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              label: const Text('Удалить выбранные'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmSoftDelete(
    BuildContext context, ProductListNotifier n, Product p) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Логическое удаление'),
      content: Text('Поместить «${p.name}» в удалённые? Товар можно восстановить.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
      ],
    ),
  );
  if (ok == true) await n.softDelete(p.id);
}

Future<void> _confirmHardDelete(
    BuildContext context, ProductListNotifier n, Product p) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Полное удаление'),
      content: Text('Удалить «${p.name}» навсегда? Действие необратимо.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Удалить навсегда'),
        ),
      ],
    ),
  );
  if (ok == true) await n.hardDelete(p.id);
}

Future<void> _confirmDeleteSelected(
    BuildContext context, ProductListNotifier n) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Множественное удаление'),
      content: Text('Логически удалить выбранные товары (${n.selected.length} шт.)?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить')),
      ],
    ),
  );
  if (ok == true) await n.deleteSelected();
}