import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Mirrors `src/services/authService.js`.
class AuthService {
  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

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
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;
      return AuthResult.success(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        e.message ?? 'Sign in failed',
        code: e.code,
      );
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

  const GoogleSignInResult.success({
    required this.isNewUser,
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
  }) : this(
          success: true,
          isNewUser: isNewUser,
          uid: uid,
          email: email,
          displayName: displayName,
          photoURL: photoURL,
        );

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
