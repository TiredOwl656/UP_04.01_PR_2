import 'package:flutter_test/flutter_test.dart';
import 'package:pr_2_clothing_store/validators/validators.dart';

void main() {
  group('V.required', () {
    test('пустая строка отклоняется', () {
      expect(V.required('Поле')(''), isNotNull);
      expect(V.required('Поле')('   '), isNotNull);
    });
    test('непустая строка принимается', () {
      expect(V.required('Поле')('Куртка'), isNull);
    });
  });

  group('V.minLength', () {
    test('слишком короткая строка отклоняется', () {
      expect(V.minLength(3, 'Логин')('ab'), isNotNull);
    });
    test('достаточная строка принимается', () {
      expect(V.minLength(3, 'Логин')('abc'), isNull);
    });
  });

  group('V.email', () {
    test('корректный email принимается', () {
      expect(V.email()('a@b.com'), isNull);
    });
    test('некорректный email отклоняется', () {
      expect(V.email()('abc'), isNotNull);
    });
  });

  group('V.intRange', () {
    test('вне диапазона отклоняется', () {
      expect(V.intRange(1, 5, 'Число')('10'), isNotNull);
    });
    test('в диапазоне принимается', () {
      expect(V.intRange(1, 5, 'Число')('3'), isNull);
    });
  });
}
