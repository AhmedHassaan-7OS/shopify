class Validators {
  const Validators._();

  static final RegExp emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static final RegExp phonePattern = RegExp(r'^\+?\d{7,15}$');

  static const int minPasswordLength = 6;

  static String? name(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'الاسم مطلوب';
    }
    return null;
  }

  static String? phone(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    if (!phonePattern.hasMatch(trimmed)) {
      return 'أدخل رقم هاتف صحيحًا من 7 إلى 15 رقمًا';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!emailPattern.hasMatch(trimmed)) {
      return 'أدخل بريدًا إلكترونيًا صحيحًا';
    }
    return null;
  }

  static String? password(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (password.length < minPasswordLength) {
      return 'كلمة المرور يجب أن تكون $minPasswordLength محارف على الأقل';
    }
    return null;
  }
}
