import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;

import '../config/firebase_secrets.dart';

/// Direct Identity Toolkit sign-in (same HTTP API the web app uses).
/// Used when native Android reCAPTCHA fails with [network-request-failed].
class FirebaseIdentityToolkit {
  static const _base = 'https://identitytoolkit.googleapis.com/v1';

  static String get _apiKey {
    const fromEnv = String.fromEnvironment('FIREBASE_API_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return firebaseApiKey;
  }

  static Future<IdentityToolkitSignInResult> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (_apiKey.isEmpty) {
      return const IdentityToolkitSignInResult.failure(
        'Firebase API key is missing in firebase_secrets.dart',
      );
    }

    final uri = Uri.parse('$_base/accounts:signInWithPassword?key=$_apiKey');
    try {
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
        debugPrint('IdentityToolkit signIn failed: $message');
        return IdentityToolkitSignInResult.failure(
          _mapErrorMessage(message),
          code: _mapErrorCode(message),
        );
      }

      return IdentityToolkitSignInResult.success(
        localId: body['localId'] as String,
        email: body['email'] as String?,
        idToken: body['idToken'] as String,
        refreshToken: body['refreshToken'] as String,
      );
    } catch (e, st) {
      debugPrint('IdentityToolkit signIn exception: $e');
      debugPrint('$st');
      return IdentityToolkitSignInResult.failure(
        kIsWeb
            ? 'Network error during sign in. Check your connection.'
            : 'Could not reach Firebase Auth servers. Check emulator internet.',
        code: 'network-request-failed',
      );
    }
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
  }) : this._(
          success: false,
          error: message,
          code: code,
        );

  final bool success;
  final String? localId;
  final String? email;
  final String? idToken;
  final String? refreshToken;
  final String? error;
  final String? code;
}
