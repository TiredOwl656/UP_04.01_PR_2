import '../models/supplier.dart';

abstract interface class SupplierRepository {
  Future<List<Supplier>> findAll();
  Future<Supplier?> findById(int id);
  Future<Supplier> create(Supplier supplier);
  Future<Supplier> update(Supplier supplier);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
}