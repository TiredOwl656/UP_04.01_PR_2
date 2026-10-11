import 'package:flutter_test/flutter_test.dart';
import 'package:pr_2_clothing_store/validators/validators.dart';

void main() {
  group('V.required', () {
    test('пустая строка отклоняется', () {
      expect(V.required('\u041f\u043e\u043b\u0435')(''), isNotNull);
      expect(V.required('\u041f\u043e\u043b\u0435')('   '), isNotNull);
    });
    test('непустая строка принимается', () {
      expect(V.required('\u041f\u043e\u043b\u0435')('\u041a\u0443\u0440\u0442\u043a\u0430'), isNull);
    });
  });

  group('V.minLength', () {
    test('слишком короткая строка отклоняется', () {
      expect(V.minLength(3, '\u041b\u043e\u0433\u0438\u043d')('ab'), isNotNull);
    });
    test('достаточная строка принимается', () {
      expect(V.minLength(3, '\u041b\u043e\u0433\u0438\u043d')('abc'), isNull);
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
      expect(V.intRange(1, 5, '\u0427\u0438\u0441\u043b\u043e')('10'), isNotNull);
    });
    test('в диапазоне принимается', () {
      expect(V.intRange(1, 5, '\u0427\u0438\u0441\u043b\u043e')('3'), isNull);
    });
  });
}