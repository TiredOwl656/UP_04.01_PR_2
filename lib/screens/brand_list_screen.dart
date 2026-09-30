import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/brand.dart';
import '../state/brand_list_notifier.dart';
import '../widgets/adaptive_entity_view.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/state_views.dart';

class BrandListScreen extends StatefulWidget {
  const BrandListScreen({super.key});

  @override
  State<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends State<BrandListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchCtrl.text = context.read<BrandListNotifier>().query.search;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _go(Map<String, String> params) {
    final qs = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    context.go('/brands?$qs');
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<BrandListNotifier>();
    final q = n.query;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Бренды'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Поиск по названию или стране',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: n.onSearchChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: q.includeDeleted,
                      onChanged: (v) =>
                          _go(q.copyWith(includeDeleted: v ?? false).toQueryParams()),
                    ),
                    const Text('Удалённые'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: buildStateView(
              status: n.status,
              isEmpty: n.result.isEmpty,
              error: n.error,
              onRetry: n.load,
              onData: () => Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AdaptiveEntityView<Brand>(
                        items: n.result.items,
                        idOf: (b) => b.id,
                        sortField: q.sortField,
                        sortAscending: q.sortAscending,
                        onSort: (field) => _go(
                          q
                              .copyWith(
                                sortField: field,
                                sortAscending: field == q.sortField ? !q.sortAscending : true,
                              )
                              .toQueryParams(),
                        ),
                        isDeleted: (b) => b.isDeleted,
                        columns: [
                          TableColumnSpec(
                              label: 'Название', sortField: 'name', build: (b) => Text(b.name)),
                          TableColumnSpec(
                              label: 'Страна',
                              sortField: 'country',
                              build: (b) => Text(b.country)),
                          TableColumnSpec(
                              label: 'Основан',
                              sortField: 'founded',
                              numeric: true,
                              build: (b) => Text('${b.foundedYear}')),
                        ],
                        cardBuilder: (b) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Страна: ${b.country}'),
                            Text('Основан: ${b.foundedYear}'),
                            if (b.isDeleted)
                              const Text('Удалён', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        actions: (b) => [
                          IconButton(
                            icon: const Icon(Icons.open_in_new),
                            tooltip: 'Открыть',
                            onPressed: () => context.go('/brands/${b.id}'),
                          ),
                          if (b.isDeleted)
                            IconButton(
                              icon: const Icon(Icons.restore),
                              onPressed: () => n.restore(b.id),
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => n.softDelete(b.id),
                            ),
                        ],
                      ),
                    ),
                  ),
                  PaginationBar(
                    page: n.result.page,
                    totalPages: n.result.totalPages,
                    total: n.result.total,
                    size: q.size,
                    onPage: (p) => _go(q.withPage(p).toQueryParams()),
                    onSize: (s) => _go(q.copyWith(size: s, page: 1).toQueryParams()),
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