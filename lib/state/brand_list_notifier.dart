import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/brand.dart';
import '../models/brand_query.dart';
import '../models/page_result.dart';
import '../repositories/brand_repository.dart';
import 'product_list_notifier.dart' show LoadStatus;

class BrandListNotifier extends ChangeNotifier {
  final BrandRepository _repository;
  BrandListNotifier(this._repository);

  BrandQuery _query = const BrandQuery();
  PageResult<Brand> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  Timer? _debounce;

  BrandQuery get query => _query;
  PageResult<Brand> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;

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
      _error = 'Не удалось загрузить список брендов: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(BrandQuery next) async {
    _query = next;
    await load();
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      applyQuery(_query.copyWith(search: value, page: 1));
    });
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