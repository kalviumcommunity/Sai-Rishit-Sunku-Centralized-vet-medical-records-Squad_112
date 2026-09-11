import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import '../routes/app_routes.dart';

/// Authentication Service handling Firebase Auth state, role retrieval, and session flow.
class AuthService extends ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  StreamSubscription<User?>? _authSubscription;

  User? _currentUser;
  UserModel? _currentUserModel;
  bool _isInitialized = false;

  AuthService() {
    _initializeAuth();
  }

  FirebaseAuth? get _firebaseAuth {
    if (_auth == null && Firebase.apps.isNotEmpty) {
      _auth = FirebaseAuth.instance;
    }
    return _auth;
  }

  FirebaseFirestore? get _firebaseFirestore {
    if (_firestore == null && Firebase.apps.isNotEmpty) {
      _firestore = FirebaseFirestore.instance;
    }
    return _firestore;
  }

  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser ?? (_firebaseAuth?.currentUser);
  UserModel? get currentUserModel => _currentUserModel;
  bool get isAuthenticated => currentUser != null;
  String get userRole => _currentUserModel?.role ?? 'owner';

  Stream<User?> get authStateChanges =>
      _firebaseAuth?.authStateChanges() ?? const Stream.empty();

  void _initializeAuth() {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;

        _currentUser = _auth!.currentUser;
        if (_currentUser != null) {
          _fetchUserProfile(_currentUser!.uid);
        }

        _authSubscription = _auth!.authStateChanges().listen((User? user) async {
          _currentUser = user;
          if (user != null) {
            await _fetchUserProfile(user.uid);
          } else {
            _currentUserModel = null;
          }
          _isInitialized = true;
          notifyListeners();
        });
      } else {
        _isInitialized = true;
      }
    } catch (e) {
      debugPrint('AuthService: Auth init notice: $e');
      _isInitialized = true;
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    final firestore = _firebaseFirestore;
    if (firestore == null) return;

    try {
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 4));
      if (doc.exists) {
        _currentUserModel = UserModel.fromFirestore(doc);
      } else {
        _currentUserModel = UserModel(
          id: uid,
          name: _currentUserModel?.name ?? _currentUser?.displayName ?? 'Pet Owner',
          email: _currentUserModel?.email ?? _currentUser?.email ?? '',
          role: _currentUserModel?.role ?? 'owner',
          branchId: _currentUserModel?.branchId,
          createdAt: _currentUserModel?.createdAt ?? DateTime.now(),
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('AuthService: Profile fetch note: $e');
      // Fallback in-memory profile so navigation works even if Firestore is not yet seeded
      _currentUserModel ??= UserModel(
        id: uid,
        name: _currentUser?.displayName ?? 'Pet Owner',
        email: _currentUser?.email ?? '',
        role: 'owner',
        createdAt: DateTime.now(),
      );
    }
  }

  /// Determines the appropriate destination route based on authentication and user role.
  Future<String> determineInitialRoute({Duration waitDuration = const Duration(milliseconds: 1800)}) async {
    if (waitDuration > Duration.zero) {
      await Future.delayed(waitDuration);
    }

    if (!isAuthenticated) {
      return AppRoutes.login;
    }

    switch (userRole) {
      case 'vet':
        return AppRoutes.vetSearch;
      case 'admin':
        return AppRoutes.admin;
      case 'owner':
      default:
        return AppRoutes.ownerHome;
    }
  }

  // --- Real Firebase Auth Actions with Timeouts and Error Handling ---

  Future<void> signInWithGoogle() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase is not initialized.');
    }
    UserCredential userCredential;

    if (kIsWeb) {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      googleProvider.addScope('email');
      googleProvider.addScope('profile');
      userCredential = await auth
          .signInWithPopup(googleProvider)
          .timeout(const Duration(seconds: 45));
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled Google sign-in dialog
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await auth
          .signInWithCredential(credential)
          .timeout(const Duration(seconds: 20));
    }

    _currentUser = userCredential.user;
    if (_currentUser != null) {
      final firestore = _firebaseFirestore;
      if (firestore != null) {
        try {
          final doc = await firestore
              .collection('users')
              .doc(_currentUser!.uid)
              .get()
              .timeout(const Duration(seconds: 4));
          if (!doc.exists) {
            final newUser = UserModel(
              id: _currentUser!.uid,
              name: _currentUser!.displayName ?? 'Pet Owner',
              email: _currentUser!.email ?? '',
              role: 'owner',
              createdAt: DateTime.now(),
            );
            await firestore
                .collection('users')
                .doc(_currentUser!.uid)
                .set(newUser.toMap())
                .timeout(const Duration(seconds: 4));
            _currentUserModel = newUser;
          } else {
            _currentUserModel = UserModel.fromFirestore(doc);
          }
        } catch (e) {
          debugPrint('Firestore sync notice: $e');
          _currentUserModel ??= UserModel(
            id: _currentUser!.uid,
            name: _currentUser!.displayName ?? 'Pet Owner',
            email: _currentUser!.email ?? '',
            role: 'owner',
            createdAt: DateTime.now(),
          );
        }
      } else {
        _currentUserModel ??= UserModel(
          id: _currentUser!.uid,
          name: _currentUser!.displayName ?? 'Pet Owner',
          email: _currentUser!.email ?? '',
          role: 'owner',
          createdAt: DateTime.now(),
        );
      }
    }
    notifyListeners();
  }

  /// Email & Password authentication
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase is not initialized.');
    }
    final credential = await auth
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        )
        .timeout(const Duration(seconds: 15));

    _currentUser = credential.user;
    if (_currentUser != null) {
      await _fetchUserProfile(_currentUser!.uid);
    }
    notifyListeners();
  }

  /// Alias for backward compatibility
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await signInWithEmail(email: email, password: password);
  }

  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
    required String role,
    String? branchId,
  }) async {
    final auth = _firebaseAuth;
    if (auth == null) {
      throw Exception('Firebase is not initialized.');
    }
    final firestore = _firebaseFirestore;

    final credential = await auth
        .createUserWithEmailAndPassword(
          email: email,
          password: password,
        )
        .timeout(const Duration(seconds: 12));

    final user = credential.user;
    if (user != null) {
      final newUser = UserModel(
        id: user.uid,
        name: name,
        email: email,
        role: role,
        branchId: branchId,
        createdAt: DateTime.now(),
      );

      _currentUser = user;
      _currentUserModel = newUser;

      // Attempt to save profile to Firestore with timeout so it never blocks registration or navigation
      if (firestore != null) {
        try {
          await firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toMap())
              .timeout(const Duration(seconds: 3));
        } catch (e) {
          debugPrint('Firestore registration notice (non-blocking): $e');
        }
      }
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      }
    } catch (e) {
      debugPrint('Google sign-out notice: $e');
    }
    await _firebaseAuth?.signOut();
    _currentUser = null;
    _currentUserModel = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
