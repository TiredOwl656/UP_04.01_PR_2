import '../models/product_category.dart';

abstract interface class CategoryRepository {
  Future<List<ProductCategory>> findAll();
  Future<ProductCategory?> findById(int id);
  Future<ProductCategory> create(ProductCategory category);
  Future<ProductCategory> update(ProductCategory category);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
}