import 'package:flutter/foundation.dart';

/// Authentication service contract and placeholder implementation.
/// Will be hooked to FirebaseAuth and GoogleSignIn during Auth implementation.
class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _userRole; // 'owner', 'vet', 'admin'

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userRole => _userRole;

  Future<bool> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    // Placeholder - will integrate FirebaseAuth.instance.signInWithEmailAndPassword
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = true;
    _userId = 'demo_user_123';
    _userRole = 'owner';
    notifyListeners();
    return true;
  }

  Future<bool> signInWithGoogle() async {
    // Placeholder - will integrate GoogleSignIn and FirebaseAuth GoogleAuthProvider
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = true;
    _userId = 'demo_google_user_456';
    _userRole = 'owner';
    notifyListeners();
    return true;
  }

  Future<bool> registerWithEmailPassword({
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isAuthenticated = true;
    _userId = 'demo_registered_user_789';
    _userRole = role;
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _userId = null;
    _userRole = null;
    notifyListeners();
  }
}
