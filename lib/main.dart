import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app.dart';
import 'core/constants/api_constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _initializeGoogleSignIn();

  runApp(const ShopifyApp());
}

Future<void> _initializeGoogleSignIn() async {
  final String? iosClientId = defaultTargetPlatform == TargetPlatform.iOS
      ? DefaultFirebaseOptions.ios.iosClientId
      : null;

  try {
    await GoogleSignIn.instance.initialize(
      clientId: iosClientId,
      serverClientId: ApiConstants.googleServerClientId,
    );
  } catch (error, stackTrace) {
    debugPrint('فشل تهيئة Google Sign-In: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}
