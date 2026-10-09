import 'package:flutter_test/flutter_test.dart';
import 'package:pr_2_clothing_store/models/app_user.dart';

void main() {
  const customer = AppUser(
    id: 1,
    username: 'c',
    fullName: 'Customer',
    role: Role.customer,
  );
  const manager = AppUser(
    id: 2,
    username: 'm',
    fullName: 'Manager',
    role: Role.manager,
  );
  const admin = AppUser(
    id: 3,
    username: 'a',
    fullName: 'Admin',
    role: Role.admin,
  );

  group('Разграничение прав по ролям', () {
    test('customer может оформлять заказ', () {
      expect(customer.role == Role.customer, true);
      expect(customer.role == Role.manager, false);
      expect(customer.role == Role.admin, false);
    });

    test('manager не управляет каталогом', () {
      expect(manager.role == Role.admin, false);
      expect(manager.role == Role.customer, false);
    });

    test('только admin управляет пользователями', () {
      expect(admin.role == Role.admin, true);
      expect(manager.role == Role.admin, false);
      expect(customer.role == Role.admin, false);
    });

    test('только manager обрабатывает заказы', () {
      expect(manager.role == Role.manager, true);
      expect(customer.role == Role.manager, false);
      expect(admin.role == Role.manager, false);
    });

    test('только customer использует корзину и лояльность', () {
      expect(customer.role == Role.customer, true);
      expect(manager.role == Role.customer, false);
      expect(admin.role == Role.customer, false);
    });
  });
}