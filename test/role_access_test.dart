import 'package:flutter_test/flutter_test.dart';
import 'package:pr_2_clothing_store/state/auth_notifier.dart' show Role;

void main() {
  group('Role.fromName', () {
    test('распознаёт admin', () {
      expect(Role.fromName('admin'), Role.admin);
    });

    test('распознаёт manager', () {
      expect(Role.fromName('manager'), Role.manager);
    });

    test('распознаёт customer', () {
      expect(Role.fromName('customer'), Role.customer);
    });

    test('null → customer', () {
      expect(Role.fromName(null), Role.customer);
    });

    test('неизвестное значение → customer', () {
      expect(Role.fromName('superuser'), Role.customer);
    });

    test('label на русском', () {
      expect(Role.customer.label, 'Покупатель');
      expect(Role.manager.label, 'Менеджер');
      expect(Role.admin.label, 'Администратор');
    });
  });
}
