class V {
  static String? Function(String?) required(String label) =>
      (v) => (v == null || v.trim().isEmpty) ? '$label обязательно' : null;

  static String? Function(String?) maxLength(int max, String label) =>
      (v) => (v != null && v.length > max)
          ? '$label не длиннее $max символов'
          : null;

  static String? Function(String?) minLength(int min, String label) =>
      (v) => (v != null && v.isNotEmpty && v.length < min)
          ? '$label не короче $min символов'
          : null;

  static String? Function(String?) intRange(int min, int max, String label) =>
      (v) {
        if (v == null || v.isEmpty) return null;
        final n = int.tryParse(v);
        if (n == null) return '$label — целое число';
        if (n < min || n > max) return '$label: от $min до $max';
        return null;
      };

  static String? Function(String?) positiveNumber(String label) => (v) {
        if (v == null || v.isEmpty) return null;
        final n = double.tryParse(v.replaceAll(',', '.'));
        if (n == null) return '$label — число';
        if (n <= 0) return '$label должно быть больше нуля';
        return null;
      };

  static String? Function(String?) email() => (v) {
        if (v == null || v.isEmpty) return null;
        final re = RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\-\.]+$');
        return re.hasMatch(v) ? null : 'Некорректный email';
      };

  static String? Function(String?) phone() => (v) {
        if (v == null || v.isEmpty) return null;
        final re = RegExp(r'^(\+7|8)\d{10}$');
        return re.hasMatch(v.replaceAll(RegExp(r'[\s\-\(\)]'), ''))
            ? null
            : 'Телефон в формате +7XXXXXXXXXX';
      };

  static String? Function(String?) year() => intRange(1900, 2100, 'Год');

  static String? Function(String?) compose(
          List<String? Function(String?)> validators) =>
      (v) {
        for (final validator in validators) {
          final result = validator(v);
          if (result != null) return result;
        }
        return null;
      };
}