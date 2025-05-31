import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;

  AuthService() {
    // Configure GoogleSignIn with proper settings for web
    try {
      if (kIsWeb) {
        _googleSignIn = GoogleSignIn(
          clientId: '887523662096-j84na4417squsaf7m3ochj13uaqef22l.apps.googleusercontent.com',
        );
      } else {
        _googleSignIn = GoogleSignIn();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Google Sign-In not available: $e');
      }
      _googleSignIn = null;
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if Google Sign-In is available
  bool get isGoogleSignInAvailable => _googleSignIn != null;

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    if (_googleSignIn == null) {
      throw Exception('Google Sign-In not available');
    }
    
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn?.signOut();
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
} 