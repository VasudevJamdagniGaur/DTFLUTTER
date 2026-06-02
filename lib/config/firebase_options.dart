import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'firebase_secrets.dart';

/// Firebase config for project `deitedatabase`.
///
/// Android uses the **web API key + authDomain** (same as the Capacitor/React app)
/// so reCAPTCHA can reach `deitedatabase.firebaseapp.com`. The Android [appId]
/// still comes from `google-services.json`.
class DefaultFirebaseOptions {
  static const String androidAppId =
      '1:300613626896:android:96b25a5c6549a45307ae95';

  static String get _webApiKey {
    const fromEnv = String.fromEnvironment('FIREBASE_API_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (firebaseApiKey.isNotEmpty) return firebaseApiKey;
    throw StateError(
      'Firebase API key is not configured. Copy '
      'lib/config/firebase_secrets.example.dart to firebase_secrets.dart '
      'and set firebaseApiKey, or pass --dart-define=FIREBASE_API_KEY=...',
    );
  }

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

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: _webApiKey,
        appId: '1:300613626896:web:eaa1c35b138a2a6c07ae95',
        messagingSenderId: '300613626896',
        projectId: 'deitedatabase',
        authDomain: 'deitedatabase.firebaseapp.com',
        storageBucket: 'deitedatabase.firebasestorage.app',
        measurementId: 'G-CRK45CXML7',
      );

  /// Web key + authDomain (reCAPTCHA) with Android app id (google-services).
  static FirebaseOptions get android => FirebaseOptions(
        apiKey: _webApiKey,
        appId: androidAppId,
        messagingSenderId: '300613626896',
        projectId: 'deitedatabase',
        authDomain: 'deitedatabase.firebaseapp.com',
        storageBucket: 'deitedatabase.firebasestorage.app',
      );

  static FirebaseOptions get ios => android;
  static FirebaseOptions get macos => android;
}
