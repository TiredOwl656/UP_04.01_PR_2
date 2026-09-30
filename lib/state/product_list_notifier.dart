import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/page_result.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import '../repositories/product_repository.dart';

enum LoadStatus { idle, loading, success, error }

class ProductListNotifier extends ChangeNotifier {
  final ProductRepository _repository;

  ProductListNotifier(this._repository);

  ProductQuery _query = const ProductQuery();
  PageResult<Product> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};
  Timer? _debounce;

  ProductQuery get query => _query;
  PageResult<Product> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список товаров: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(ProductQuery next) async {
    _query = next;
    _selected.clear();
    await load();
  }

  /// Пункт 17: поиск с задержкой 300 мс, страница сбрасывается на 1.
  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      applyQuery(_query.copyWith(search: value, page: 1));
    });
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
    notifyListeners();
  }

  void toggleSelectAll() {
    if (_selected.length == _result.items.length) {
      _selected.clear();
    } else {
      _selected
        ..clear()
        ..addAll(_result.items.map((p) => p.id));
    }
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await load();
  }

  Future<void> softDelete(int id) async {
    await _repository.softDelete(id);
    await load();
  }

  Future<void> hardDelete(int id) async {
    await _repository.hardDelete(id);
    await load();
  }

  Future<void> restore(int id) async {
    await _repository.restore(id);
    await load();
  }
}