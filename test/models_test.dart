import 'package:flutter_test/flutter_test.dart';
import 'package:pr_2_clothing_store/models/app_user.dart';
import 'package:pr_2_clothing_store/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('пустой JSON не падает', () {
      final p = Product.fromJson({});
      expect(p.name, '');
      expect(p.categoryIds, isEmpty);
      expect(p.price, 0);
    });

    test('корректный JSON разбирается', () {
      final p = Product.fromJson({
        'id': 1,
        'name': 'Kurtka',
        'sku': 'NW-1001',
        'brandId': 1,
        'supplierId': 2,
        'categoryIds': [1, 2],
        'size': 'L',
        'color': 'Black',
        'price': 12990,
        'stock': 5,
        'year': 2023,
      });
      expect(p.name, 'Kurtka');
      expect(p.categoryIds, [1, 2]);
      expect(p.price, 12990);
      expect(p.stock, 5);
    });
  });

  group('Role.fromName', () {
    test('admin распознаётся', () {
      expect(Role.fromName('admin'), Role.admin);
    });
    test('manager распознаётся', () {
      expect(Role.fromName('manager'), Role.manager);
    });
    test('неизвестное значение — customer', () {
      expect(Role.fromName('unknown'), Role.customer);
    });
  });
}