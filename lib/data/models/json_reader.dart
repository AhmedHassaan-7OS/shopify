class JsonReader {
  const JsonReader._();

  static Map<String, dynamic> asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic v) => MapEntry(key.toString(), v));
    }
    return <String, dynamic>{};
  }

  static String string(
    Map<String, dynamic> json,
    String key, {
    String fallback = '',
  }) {
    final dynamic value = json[key];
    if (value == null) return fallback;
    if (value is String) return value;
    return value.toString();
  }

  static double doubleValue(
    Map<String, dynamic> json,
    String key, {
    double fallback = 0,
  }) {
    final dynamic value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static int intValue(
    Map<String, dynamic> json,
    String key, {
    int fallback = 0,
  }) {
    final dynamic value = json[key];
    if (value is int) return value;
    if (value is num) {
      if (!value.isFinite) return fallback;
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
      final asDouble = double.tryParse(value);
      if (asDouble != null && asDouble.isFinite) return asDouble.toInt();
    }
    return fallback;
  }

  static List<String> stringList(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is! List) return const <String>[];
    return List<String>.unmodifiable(
      value.where((dynamic e) => e != null).map((dynamic e) => e.toString()),
    );
  }

  static List<Map<String, dynamic>> mapList(
    Map<String, dynamic> json,
    String key,
  ) {
    final dynamic value = json[key];
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((Map e) => asMap(e))
        .toList(growable: false);
  }
}
