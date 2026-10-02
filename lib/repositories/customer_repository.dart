import '../models/customer.dart';

abstract interface class CustomerRepository {
  Future<List<Customer>> findAll();
  Future<Customer?> findById(int id);
  Future<Customer> create(Customer customer);
  Future<Customer> update(Customer customer);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
}