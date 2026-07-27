class Formatters {
  const Formatters._();

  static const String currencySymbol = r'$';

  static const double _exponentialThreshold = 1e21;

  static String price(double value) {
    final safe = (!value.isFinite || value.isNegative || value.isNaN)
        ? 0.0
        : value;
    return '$currencySymbol${_toFixed(safe, 2)}';
  }

  static String rating(double value) {
    final safe = (!value.isFinite || value.isNaN) ? 0.0 : value;
    return _toFixed(safe, 1);
  }

  static String _toFixed(double value, int fractionDigits) {
    if (value.abs() < _exponentialThreshold) {
      return value.toStringAsFixed(fractionDigits);
    }
    final integerPart = BigInt.from(value).toString();
    return '$integerPart.${'0' * fractionDigits}';
  }
}
