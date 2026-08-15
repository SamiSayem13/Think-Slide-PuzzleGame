import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static bool _isLocalGuest = false;
  static final ValueNotifier<bool> localGuestNotifier = ValueNotifier<bool>(false);

  static User? get currentUser => _auth.currentUser;

  static bool get isAnonymous => (_auth.currentUser?.isAnonymous ?? false) || _isLocalGuest;
  
  static bool get isLocalGuest => _isLocalGuest;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLocalGuest = prefs.getBool('isLocalGuest') ?? false;
    localGuestNotifier.value = _isLocalGuest;
  }

  static Future<void> setLocalGuest(bool value) async {
    _isLocalGuest = value;
    localGuestNotifier.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLocalGuest', value);
  }

  static Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("Error signing in anonymously: $e");
      return null;
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        return await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint("Error signing in with Google: $e");
      return null;
    }
  }

  static Future<void> signOut() async {
    await setLocalGuest(false);
    await DatabaseService.clearLocalProgress();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
