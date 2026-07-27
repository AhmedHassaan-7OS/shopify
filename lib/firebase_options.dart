// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDYnrIGJzjBcedSxotNNUCRz_ypjLjoAGU',
    appId: '1:802072150133:android:423034ea11b9baf452f83c',
    messagingSenderId: '802072150133',
    projectId: 'shopify-44702',
    storageBucket: 'shopify-44702.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1pXUk4iMkPXm4ia1glWyTL0TbEovhN0k',
    appId: '1:802072150133:ios:7936d92300ea35cf52f83c',
    messagingSenderId: '802072150133',
    projectId: 'shopify-44702',
    storageBucket: 'shopify-44702.firebasestorage.app',
    iosClientId:
        '802072150133-7aik3se95ed4rfsvlphofksqc1ni9v1l.apps.googleusercontent.com',
    iosBundleId: 'com.example.shopify',
  );
}
