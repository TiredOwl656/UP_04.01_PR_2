import 'package:flutter/foundation.dart';
import 'package:pr_2_clothing_store/core/api_exceptions.dart';
import '../models/product_category.dart';
import '../repositories/category_repository.dart';
import 'product_list_notifier.dart' show LoadStatus;

class CategoryListNotifier extends ChangeNotifier {
  final CategoryRepository _repository;
  CategoryListNotifier(this._repository);

  List<ProductCategory> _items = [];
  LoadStatus _status = LoadStatus.idle;
  String? _error;

  List<ProductCategory> get items => List.unmodifiable(_items);
  LoadStatus get status => _status;
  String? get error => _error;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _items = await _repository.findAll();
      _status = LoadStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = LoadStatus.error;
    } catch (e) {
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> create(ProductCategory c) async {
    await _repository.create(c);
    await load();
  }

  Future<void> update(ProductCategory c) async {
    await _repository.update(c);
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