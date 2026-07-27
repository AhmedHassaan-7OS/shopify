# Shopify — E-Commerce Catalog App

## خطوات الإعداد اليدوية قبل تشغيل التطبيق

### Android
1. تأكد أن `android/app/google-services.json` محمّل من Firebase Console (مشروع `shopify-44702`). الملف موجود بالفعل.
2. سجّل بصمات SHA-1 وSHA-256 لتطبيق أندرويد في Firebase Console:
   - Firebase Console → Project Settings → Your apps → Android → Add fingerprint
   - لاستخراج البصمة: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
3. فعّل مزوّدَي المصادقة في Firebase Console → Authentication → Sign-in method:
   - Email/Password ✓
   - Google ✓ (أضف Web SDK configuration لو مطلوب)

### iOS
1. نزّل `ios/Runner/GoogleService-Info.plist` من Firebase Console (مشروع `shopify-44702`) وضعه في `ios/Runner/`.
2. URL scheme مضاف تلقائيًا في `Info.plist` بقيمة REVERSED_CLIENT_ID.
3. الحد الأدنى لـ iOS deployment target: 13.0 (Firebase Auth).

### تشغيل التطبيق
```bash
flutter pub get
flutter run
```

## ملاحظات
- `flutter analyze` → صفر أخطاء
- State management: Cubit (flutter_bloc 9.1.1), بدون setState لأي منطق أعمال
- الثيم: Lux-Commerce (ESTUDIO) — Material 3، فاتح وداكن
- API: DummyJSON — لا يحتاج مفاتيح
