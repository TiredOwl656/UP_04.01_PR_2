import '../data/seed_data.dart';
import '../models/brand.dart';
import '../models/brand_query.dart';
import '../models/page_result.dart';
import 'brand_repository.dart';

class InMemoryBrandRepository implements BrandRepository {
  final List<Brand> _brands = [...seedBrands];

  @override
  Future<PageResult<Brand>> find(BrandQuery q) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var rows = _brands.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows
          .where((b) =>
              b.name.toLowerCase().contains(needle) ||
              b.country.toLowerCase().contains(needle))
          .toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'country' => a.country.toLowerCase().compareTo(b.country.toLowerCase()),
        'founded' => a.foundedYear.compareTo(b.foundedYear),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Brand>[] : rows.sublist(from, to);

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Brand?> findById(int id) async {
    final i = _brands.indexWhere((b) => b.id == id);
    return i == -1 ? null : _brands[i];
  }

  @override
  Future<void> softDelete(int id) async {
    final i = _brands.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Бренд $id не найден');
    _brands[i] = _brands[i].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _brands.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final i = _brands.indexWhere((b) => b.id == id);
    if (i == -1) throw StateError('Бренд $id не найден');
    _brands[i] = _brands[i].copyWith(clearDeletedAt: true);
  }
}