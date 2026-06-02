import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:google_sign_in/google_sign_in.dart';

/// Web client ID from `google-services.json` (client_type 3) — required for Google Sign-In on Android.
const _googleWebClientId =
    '300613626896-afgue1cj09n7mibt6b84t0qgjkc0avqk.apps.googleusercontent.com';

/// Mirrors `src/services/authService.js`.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId: _googleWebClientId,
            );

  static String authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Cannot reach Firebase. Use an emulator image with Google Play, '
            'check internet, uninstall any old "com.example.deite" build, then '
            'run: flutter clean && flutter run';
      case 'invalid-credential':
      case 'wrong-password':
        return 'Invalid email or password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<AuthResult> signUpUser({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await cred.user?.updateDisplayName(displayName);
      }
      final user = cred.user!;
      return AuthResult.success(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName ?? displayName,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(e.message ?? 'Sign up failed');
    }
  }

  Future<AuthResult> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthService.signInUser: attempting sign-in for $email');
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;
      debugPrint('AuthService.signInUser: success uid=${user.uid}');
      return AuthResult.success(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService.signInUser: FirebaseAuthException code=${e.code} '
        'message=${e.message}',
      );
      return AuthResult.failure(
        authErrorMessage(e),
        code: e.code,
      );
    } catch (e, st) {
      debugPrint('AuthService.signInUser: unexpected error: $e');
      debugPrint('$st');
      return AuthResult.failure(e.toString());
    }
  }

  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return GoogleSignInResult.failure('Sign-in was cancelled.');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      final isNew = userCred.additionalUserInfo?.isNewUser ?? false;
      return GoogleSignInResult.success(
        isNewUser: isNew,
        uid: user?.uid,
        email: user?.email,
        displayName: user?.displayName,
        photoURL: user?.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      return GoogleSignInResult.failure(e.message ?? 'Google sign-in failed');
    } catch (e) {
      return GoogleSignInResult.failure(e.toString());
    }
  }

  Future<AuthResult> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return const AuthResult(
        success: true,
        message: 'Password reset email sent! Please check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Failed to send password reset email.';
      if (e.code == 'user-not-found') {
        msg = 'No account found with this email address.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      } else if (e.code == 'too-many-requests') {
        msg = 'Too many requests. Please try again later.';
      }
      return AuthResult.failure(msg);
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

class AuthResult {
  const AuthResult({
    required this.success,
    this.uid,
    this.email,
    this.displayName,
    this.error,
    this.code,
    this.message,
  });

  const AuthResult.success({
    required String? uid,
    String? email,
    String? displayName,
  }) : this(
          success: true,
          uid: uid,
          email: email,
          displayName: displayName,
        );

  const AuthResult.failure(String error, {String? code})
      : this(success: false, error: error, code: code);

  final bool success;
  final String? uid;
  final String? email;
  final String? displayName;
  final String? error;
  final String? code;
  final String? message;
}

class GoogleSignInResult {
  const GoogleSignInResult({
    required this.success,
    this.isNewUser = false,
    this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.error,
  });

  factory GoogleSignInResult.success({
    required bool isNewUser,
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
  }) {
    return GoogleSignInResult(
      success: true,
      isNewUser: isNewUser,
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
    );
  }

  const GoogleSignInResult.failure(String error)
      : this(success: false, error: error);

  final bool success;
  final bool isNewUser;
  final String? uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? error;
}

final authService = AuthService();
