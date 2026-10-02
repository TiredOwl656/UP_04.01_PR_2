import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';
import 'product_list_notifier.dart' show LoadStatus;

class CustomerListNotifier extends ChangeNotifier {
  final CustomerRepository _repository;
  CustomerListNotifier(this._repository);

  List<Customer> _items = [];
  LoadStatus _status = LoadStatus.idle;
  String? _error;

  List<Customer> get items => List.unmodifiable(_items);
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
      _error = 'Не удалось загрузить покупателей: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> create(Customer c) async {
    await _repository.create(c);
    await load();
  }

  Future<void> update(Customer c) async {
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