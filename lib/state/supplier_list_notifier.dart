import 'package:flutter/foundation.dart';
import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';
import 'product_list_notifier.dart' show LoadStatus;

class SupplierListNotifier extends ChangeNotifier {
  final SupplierRepository _repository;
  SupplierListNotifier(this._repository);

  List<Supplier> _items = [];
  LoadStatus _status = LoadStatus.idle;
  String? _error;

  List<Supplier> get items => List.unmodifiable(_items);
  LoadStatus get status => _status;
  String? get error => _error;

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _items = await _repository.findAll();
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить поставщиков: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> create(Supplier s) async {
    await _repository.create(s);
    await load();
  }

  Future<void> update(Supplier s) async {
    await _repository.update(s);
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