import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase config from the original SocialMedia / Deite app (`deitedatabase`).
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSqIMCtPOB-ifWC8PUpM52rpFlrP4jbhY',
    appId: '1:300613626896:web:eaa1c35b138a2a6c07ae95',
    messagingSenderId: '300613626896',
    projectId: 'deitedatabase',
    authDomain: 'deitedatabase.firebaseapp.com',
    storageBucket: 'deitedatabase.firebasestorage.app',
    measurementId: 'G-CRK45CXML7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSqIMCtPOB-ifWC8PUpM52rpFlrP4jbhY',
    appId: '1:300613626896:web:eaa1c35b138a2a6c07ae95',
    messagingSenderId: '300613626896',
    projectId: 'deitedatabase',
    storageBucket: 'deitedatabase.firebasestorage.app',
  );

  static const FirebaseOptions ios = android;
  static const FirebaseOptions macos = android;
}
