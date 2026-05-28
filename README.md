# Deite (Flutter)

Flutter port of [VasudevJamdagniGaur/SocialMedia](https://github.com/VasudevJamdagniGaur/SocialMedia) — the **Deite** emotional wellness & social app (originally React + Capacitor + Firebase).

## Features ported

| Area | Status |
|------|--------|
| Firebase Auth (email, Google, password reset) | ✅ |
| Firestore users, chat messages, reflections | ✅ Core |
| Vertex AI backend (`/chat`, `/reflection`) | ✅ |
| Navigation (27 routes + bottom tabs) | ✅ |
| Dashboard, Chat, Community, Wellbeing, Pod | ✅ Functional |
| Pod topic feeds (Google News RSS + Firestore `news`) | ✅ |
| Crew group chat (Firestore real-time) | ✅ |
| Wellbeing charts (Firestore mood/balance) | ✅ |
| Community likes + richer posts | ✅ |
| Tea watchlist (SharedPreferences) | ✅ |
| Share suggestions (Vertex AI) | ✅ |
| Android back navigation | ✅ |
| Reddit Tea feed (`r/BollyBlindsNGossip`) + vertical feed | ✅ |
| Community post image upload (compressed → Storage) | ✅ |
| Profile photo upload | ✅ |
| Help improve via WhatsApp | ✅ |
| Social share tracking (`socialShares`) | ✅ |
| Chat on Firestore `days/{dateId}/messages` (web-compatible) | ✅ |
| Whisper sessions + delete on leave | ✅ |
| Auto reflection + mood chart after chat | ✅ |
| Share suggestions (5 styles × 3 platforms) | ✅ |
| News/article share mode + cached AI posts | ✅ |
| Tweet-style X card + screenshot share | ✅ |
| Chat image attach (picker → Storage → messages) | ✅ |
| `firestoreService.js` full surface (~2800 lines) | 🔲 Incremental |

See [PLATFORM_SETUP.md](PLATFORM_SETUP.md) for `flutter create` + Android/iOS.

## Prerequisites

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.16+)
2. Firebase project `deitedatabase` (same as original app)
3. Optional: Android `google-services.json` from Firebase Console

## Setup

```bash
cd c:\CURSOR\DTFLUTTER

# Generate android/ ios/ if missing (first time only)
flutter create . --org com.deite --project-name deite

flutter pub get

# Run with backend URL (default: https://detea-backend.onrender.com)
flutter run --dart-define=BACKEND_URL=https://detea-backend.onrender.com
```

### Firebase (Android / iOS)

1. In [Firebase Console](https://console.firebase.google.com/) → project **deitedatabase**
2. Add Android app `therapist.deite.app` and download `google-services.json` → `android/app/`
3. For iOS, add `GoogleService-Info.plist` → `ios/Runner/`
4. Or run: `dart pub global activate flutterfire_cli && flutterfire configure`

Web/desktop use `lib/config/firebase_options.dart` (from the original web config).

### Google Sign-In

Register SHA-1/SHA-256 in Firebase for your debug/release keystore (same as the Capacitor Android app).

## Project structure

```
lib/
  config/          # Firebase, backend URL
  core/            # Theme, router, date utils
  models/
  providers/       # ThemeProvider
  services/        # auth, firestore, chat, reflection, vertex API
  screens/         # All routes from App.js
  widgets/         # Bottom navigation, scaffold
```

## Original app reference

The React source was cloned to `_source_rn/` for reference (gitignored). Key originals:

- `src/App.js` — routes
- `src/services/firestoreService.js` — Firestore
- `src/services/chatService.js` — AI companion
- `backend-vertex/` — Express + Gemini API

## Backend

AI calls go to `https://detea-backend.onrender.com` by default:

- `POST /chat` — Detea companion replies
- `POST /reflection` — daily reflection from conversation

Override: `--dart-define=BACKEND_URL=https://your-host`

## Deploy rules

```bash
firebase deploy --only firestore:rules,storage
```

(`firestore.rules` and `storage.rules` copied from the original repo.)

## License

Follow the license of the upstream SocialMedia repository.
