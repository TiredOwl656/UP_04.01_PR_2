import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/brand.dart';
import '../repositories/persistent_product_repository.dart';
import '../repositories/product_repository.dart';
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

  Future<void> _tryDelete(int id, String name) async {
    final productRepo = context.read<ProductRepository>();
    final notifier = context.read<BrandListNotifier>();

    var linked = 0;
    if (productRepo is PersistentProductRepository) {
      linked = await productRepo.countByBrand(id);
    }

    if (linked > 0) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Удаление невозможно'),
          content: Text(
            'На бренд «$name» ссылаются товары: $linked шт.\n'
            'Сначала удалите или переназначьте эти товары.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Понятно'),
            ),
          ],
        ),
      );
      return;
    }

    await notifier.softDelete(id);
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<BrandListNotifier>();
    final q = n.query;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Р‘СЂРµРЅРґС‹'),
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
                      hintText: 'РџРѕРёСЃРє РїРѕ РЅР°Р·РІР°РЅРёСЋ РёР»Рё СЃС‚СЂР°РЅРµ',
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
                    const Text('РЈРґР°Р»С‘РЅРЅС‹Рµ'),
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
                              label: 'РќР°Р·РІР°РЅРёРµ', sortField: 'name', build: (b) => Text(b.name)),
                          TableColumnSpec(
                              label: 'РЎС‚СЂР°РЅР°',
                              sortField: 'country',
                              build: (b) => Text(b.country)),
                          TableColumnSpec(
                              label: 'РћСЃРЅРѕРІР°РЅ',
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
                            Text('РЎС‚СЂР°РЅР°: ${b.country}'),
                            Text('РћСЃРЅРѕРІР°РЅ: ${b.foundedYear}'),
                            if (b.isDeleted)
                              const Text('РЈРґР°Р»С‘РЅ', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        actions: (b) => [
                          IconButton(
                            icon: const Icon(Icons.open_in_new),
                            tooltip: 'РћС‚РєСЂС‹С‚СЊ',
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
                              onPressed: () => _tryDelete(b.id, b.name),
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