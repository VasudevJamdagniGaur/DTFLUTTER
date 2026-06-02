import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;

import '../config/firebase_options.dart';
import '../config/firebase_secrets.dart';

/// Direct Identity Toolkit sign-in (same HTTP API the Capacitor/web app uses).
class FirebaseIdentityToolkit {
  static const _base = 'https://identitytoolkit.googleapis.com/v1';

  static String get _webApiKey {
    const fromEnv = String.fromEnvironment('FIREBASE_API_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return firebaseApiKey;
  }

  static List<String> get _apiKeysToTry => [
        if (_webApiKey.isNotEmpty) _webApiKey,
        DefaultFirebaseOptions.androidApiKeyFromGoogleServices,
      ].toSet().toList();

  static Future<IdentityToolkitSignInResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (_apiKeysToTry.isEmpty) {
      return const IdentityToolkitSignInResult.failure(
        'Firebase API key is missing in firebase_secrets.dart',
        underlyingError: 'firebaseApiKey is empty',
      );
    }

    Object? lastError;
    for (final apiKey in _apiKeysToTry) {
      final uri = Uri.parse('$_base/accounts:signInWithPassword?key=$apiKey');
      try {
        debugPrint('IdentityToolkit: POST $uri (key suffix ...${apiKey.substring(apiKey.length - 6)})');
        final res = await http
            .post(
              uri,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': email,
                'password': password,
                'returnSecureToken': true,
              }),
            )
            .timeout(const Duration(seconds: 30));

        final Map<String, dynamic> body = res.body.isNotEmpty
            ? jsonDecode(res.body) as Map<String, dynamic>
            : {};

        if (res.statusCode != 200) {
          final err = body['error'] as Map<String, dynamic>?;
          final message = err?['message']?.toString() ?? 'Sign in failed';
          final details = err?['errors']?.toString();
          debugPrint(
            'IdentityToolkit HTTP ${res.statusCode}: message=$message details=$details body=${res.body}',
          );
          // Wrong API key restrictions — try next key.
          if (message == 'API_KEY_INVALID' ||
              message == 'API_KEY_HTTP_REFERRER_BLOCKED' ||
              message == 'API_KEY_ANDROID_APP_BLOCKED') {
            lastError = message;
            continue;
          }
          return IdentityToolkitSignInResult.failure(
            _mapErrorMessage(message),
            code: _mapErrorCode(message),
            underlyingError: 'HTTP ${res.statusCode}: $message${details != null ? ' $details' : ''}',
          );
        }

        debugPrint('IdentityToolkit: sign-in OK for uid=${body['localId']}');
        return IdentityToolkitSignInResult.success(
          localId: body['localId'] as String,
          email: body['email'] as String?,
          idToken: body['idToken'] as String,
          refreshToken: body['refreshToken'] as String,
        );
      } on SocketException catch (e, st) {
        lastError = e;
        debugPrint('IdentityToolkit SocketException (key ...${apiKey.substring(apiKey.length - 6)}): $e');
        debugPrint('$st');
      } on HttpException catch (e, st) {
        lastError = e;
        debugPrint('IdentityToolkit HttpException: $e');
        debugPrint('$st');
      } on TimeoutException catch (e, st) {
        lastError = e;
        debugPrint('IdentityToolkit TimeoutException: $e');
        debugPrint('$st');
      } catch (e, st) {
        lastError = e;
        debugPrint('IdentityToolkit unexpected: $e');
        debugPrint('$st');
      }
    }

    return IdentityToolkitSignInResult.failure(
      _messageForTransportError(lastError),
      code: 'network-request-failed',
      underlyingError: lastError?.toString() ?? 'unknown',
    );
  }

  static String _messageForTransportError(Object? error) {
    if (error is SocketException) {
      return 'No internet on this device/emulator. Open Chrome on the emulator and load google.com, then try again.';
    }
    if (error is TimeoutException) {
      return 'Connection to Firebase timed out. Check emulator Wi‑Fi and try again.';
    }
    if (error == 'API_KEY_INVALID' ||
        error == 'API_KEY_HTTP_REFERRER_BLOCKED' ||
        error == 'API_KEY_ANDROID_APP_BLOCKED') {
      return 'Firebase API key is blocked for this app. Check Google Cloud API key restrictions.';
    }
    if (kIsWeb) {
      return 'Network error during sign in. Check your connection.';
    }
    return 'Could not reach Firebase Auth servers. Check emulator internet.';
  }

  static String _mapErrorMessage(String apiMessage) {
    switch (apiMessage) {
      case 'EMAIL_NOT_FOUND':
        return 'No account found with this email.';
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password. Please try again.';
      case 'USER_DISABLED':
        return 'This account has been disabled.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Too many attempts. Try again later.';
      case 'INVALID_EMAIL':
        return 'Invalid email address.';
      default:
        return 'Sign in failed ($apiMessage).';
    }
  }

  static String? _mapErrorCode(String apiMessage) {
    switch (apiMessage) {
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'invalid-credential';
      case 'EMAIL_NOT_FOUND':
        return 'user-not-found';
      case 'INVALID_EMAIL':
        return 'invalid-email';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'too-many-requests';
      default:
        return null;
    }
  }
}

class IdentityToolkitSignInResult {
  const IdentityToolkitSignInResult._({
    required this.success,
    this.localId,
    this.email,
    this.idToken,
    this.refreshToken,
    this.error,
    this.code,
    this.underlyingError,
  });

  const IdentityToolkitSignInResult.success({
    required String localId,
    String? email,
    required String idToken,
    required String refreshToken,
  }) : this._(
          success: true,
          localId: localId,
          email: email,
          idToken: idToken,
          refreshToken: refreshToken,
        );

  const IdentityToolkitSignInResult.failure(
    String message, {
    String? code,
    String? underlyingError,
  }) : this._(
          success: false,
          error: message,
          code: code,
          underlyingError: underlyingError,
        );

  final bool success;
  final String? localId;
  final String? email;
  final String? idToken;
  final String? refreshToken;
  final String? error;
  final String? code;
  final String? underlyingError;
}
