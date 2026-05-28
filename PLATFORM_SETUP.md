# Platform setup (Android / iOS)

The `lib/` Dart code is complete. Generate native projects once Flutter is installed:

## 1. Install Flutter

Download: https://docs.flutter.dev/get-started/install/windows

Add `flutter\bin` to your PATH, then verify:

```powershell
flutter doctor
```

## 2. Generate platform folders

```powershell
cd c:\CURSOR\DTFLUTTER
flutter create . --org com.deite --project-name deite
flutter pub get
```

This creates `android/`, `ios/`, `web/`, etc. without overwriting `lib/`.

## 3. Firebase Android

1. Firebase Console → project **deitedatabase**
2. Add Android app: `com.deite.deite` (or `therapist.deite.app` if you change `applicationId` in `android/app/build.gradle`)
3. Download `google-services.json` → `android/app/`
4. In `android/settings.gradle`, ensure Google services plugin is applied (FlutterFire CLI does this automatically):

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

## 4. Firebase API key (required)

The Web API key is **not** stored in git.

```powershell
Copy-Item lib/config/firebase_secrets.example.dart lib/config/firebase_secrets.dart
# Edit firebase_secrets.dart and set firebaseApiKey from Firebase Console
```

Or pass at run time: `--dart-define=FIREBASE_API_KEY=your_key`

## 5. Run

```powershell
flutter run --dart-define=BACKEND_URL=https://detea-backend.onrender.com
```

## 6. Release signing (optional)

Match the original Capacitor app SHA-1 in Firebase for Google Sign-In on release builds.
