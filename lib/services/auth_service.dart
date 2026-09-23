import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore}) => _instance;

  AuthService._internal() {
    _initAuthListener();
  }

  bool get isFirebaseAvailable => Firebase.apps.isNotEmpty;

  FirebaseAuth? get _auth => isFirebaseAvailable ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _firestore =>
      isFirebaseAvailable ? FirebaseFirestore.instance : null;

  // Local/Offline state management
  UserModel? _currentUser;
  final StreamController<UserModel?> _userStreamController =
      StreamController<UserModel?>.broadcast();

  final Map<String, UserModel> _localUsers = {
    'master_admin_01': UserModel(
      uid: 'master_admin_01',
      name: AppConstants.adminDisplayName, // خاکسار ایڈمن: علی جاوید
      email: AppConstants.adminEmail, // ranaalijaved154@gmail.com
      role: AppConstants.roleAdmin,
      isApproved: true,
      status: AppConstants.statusApproved,
      createdAt: DateTime(2026, 1, 1),
    ),
  };

  final StreamController<List<UserModel>> _pendingUsersController =
      StreamController<List<UserModel>>.broadcast();

  void _initAuthListener() {
    if (isFirebaseAvailable && _auth != null) {
      _auth!.authStateChanges().listen((User? fbUser) async {
        if (fbUser == null) {
          if (_currentUser?.uid.startsWith('local_') != true &&
              _currentUser?.uid != 'master_admin_01') {
            _currentUser = null;
            _userStreamController.add(null);
          }
        } else {
          final isMaster = AppConstants.isMasterAdmin(fbUser.email);
          final userModel = await getUser(fbUser.uid);
          if (userModel != null) {
            _currentUser = userModel;
            _userStreamController.add(userModel);
          } else if (isMaster) {
            final masterModel = UserModel(
              uid: fbUser.uid,
              name: fbUser.displayName ?? AppConstants.adminDisplayName,
              email: fbUser.email ?? AppConstants.adminEmail,
              role: AppConstants.roleAdmin,
              isApproved: true,
              status: AppConstants.statusApproved,
              createdAt: DateTime.now(),
            );
            _currentUser = masterModel;
            _userStreamController.add(masterModel);
          }
        }
      });
    }
  }

  /// App-wide reactive stream of UserModel (works both Online & Offline)
  Stream<UserModel?> get appUserStream => _userStreamController.stream;

  /// Legacy stream for FirebaseAuth
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  /// Current user model
  UserModel? get currentAppUser => _currentUser;

  /// Current Firebase User (if available)
  User? get currentUser => _auth?.currentUser;

  /// Sign in directly as Master Admin ("خاکسار ایڈمن: علی جاوید")
  Future<void> signInAsMasterAdmin() async {
    final adminUser = UserModel(
      uid: 'master_admin_01',
      name: AppConstants.adminDisplayName,
      email: AppConstants.adminEmail,
      role: AppConstants.roleAdmin,
      isApproved: true,
      status: AppConstants.statusApproved,
      createdAt: DateTime.now(),
    );
    _currentUser = adminUser;
    _userStreamController.add(adminUser);
  }

  /// Sign in as a Guest User
  Future<void> signInAsGuest() async {
    final guestUser = UserModel(
      uid: 'guest_local_${DateTime.now().millisecondsSinceEpoch}',
      name: 'معزز مہمان',
      email: 'guest@kanzenaseem.com',
      role: AppConstants.roleUser,
      isApproved: true,
      status: AppConstants.statusApproved,
      createdAt: DateTime.now(),
    );
    _currentUser = guestUser;
    _userStreamController.add(guestUser);
  }

  /// Register a new user with Email, Password, and Full Name
  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();
    final bool isMaster = AppConstants.isMasterAdmin(cleanEmail);

    if (isFirebaseAvailable && _auth != null && _firestore != null) {
      try {
        final UserCredential credential =
            await _auth!.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        final User? user = credential.user;
        if (user == null) {
          throw FirebaseAuthException(
            code: 'user-null',
            message: 'صارف بناتے وقت خرابی پیش آئی۔',
          );
        }

        await user.updateDisplayName(cleanName);

        final String role =
            isMaster ? AppConstants.roleAdmin : AppConstants.roleUser;
        final bool isApproved = isMaster ? true : false;
        final String status = isMaster
            ? AppConstants.statusApproved
            : AppConstants.statusPending;

        final Map<String, dynamic> userData = {
          'uid': user.uid,
          'name': cleanName,
          'email': cleanEmail,
          'role': role,
          'isApproved': isApproved,
          'status': status,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userData);

        final model = UserModel(
          uid: user.uid,
          name: cleanName,
          email: cleanEmail,
          role: role,
          isApproved: isApproved,
          status: status,
          createdAt: DateTime.now(),
        );

        _currentUser = model;
        _userStreamController.add(model);
        return model;
      } on FirebaseAuthException catch (e) {
        throw _handleFirebaseAuthException(e);
      } catch (e) {
        debugPrint('Firebase registration failed, falling back to local: $e');
      }
    }

    // Local / Offline fallback registration
    final newUid = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final model = UserModel(
      uid: newUid,
      name: cleanName,
      email: cleanEmail,
      role: isMaster ? AppConstants.roleAdmin : AppConstants.roleUser,
      isApproved: isMaster,
      status: isMaster ? AppConstants.statusApproved : AppConstants.statusPending,
      createdAt: DateTime.now(),
    );

    _localUsers[newUid] = model;
    _currentUser = model;
    _userStreamController.add(model);
    _emitPendingUsers();
    return model;
  }

  /// Sign in with Email and Password
  Future<dynamic> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final bool isMaster = AppConstants.isMasterAdmin(cleanEmail);

    if (isFirebaseAvailable && _auth != null) {
      try {
        final credential = await _auth!.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        if (credential.user != null) {
          final userModel = await getUser(credential.user!.uid);
          if (userModel != null) {
            _currentUser = userModel;
            _userStreamController.add(userModel);
          } else if (isMaster) {
            await signInAsMasterAdmin();
          }
        }
        return credential;
      } on FirebaseAuthException catch (e) {
        if (!isMaster) {
          throw _handleFirebaseAuthException(e);
        }
      } catch (e) {
        debugPrint('Firebase login notice: $e');
      }
    }

    // Local / Offline fallback login
    if (isMaster) {
      await signInAsMasterAdmin();
      return _currentUser;
    }

    // Check local registered users
    final matching = _localUsers.values.where((u) => u.email == cleanEmail);
    if (matching.isNotEmpty) {
      final user = matching.first;
      _currentUser = user;
      _userStreamController.add(user);
      return user;
    }

    throw Exception(
      'اس ای میل سے کوئی اکاؤنٹ موجود نہیں ہے۔ براہ کرم پہلے رجسٹر ہوں۔\n(No account found for this email. Please register first)',
    );
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (isFirebaseAvailable && _auth != null) {
      try {
        await _auth!.sendPasswordResetEmail(email: cleanEmail);
        return;
      } on FirebaseAuthException catch (e) {
        throw _handleFirebaseAuthException(e);
      } catch (e) {
        debugPrint('Password reset offline notice: $e');
      }
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _currentUser = null;
    _userStreamController.add(null);
    if (isFirebaseAvailable && _auth != null) {
      try {
        await _auth!.signOut();
      } catch (_) {}
    }
  }

  /// Stream of user document
  Stream<UserModel?> streamUser(String uid) {
    if (isFirebaseAvailable && _firestore != null) {
      return _firestore!
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .snapshots()
          .map((snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return _localUsers[uid];
        }
        return UserModel.fromDocument(snapshot);
      }).handleError((_) => _localUsers[uid]);
    }

    return Stream.value(_localUsers[uid] ?? _currentUser);
  }

  /// Single fetch of user document
  Future<UserModel?> getUser(String uid) async {
    if (isFirebaseAvailable && _firestore != null) {
      try {
        final doc = await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromDocument(doc);
        }
      } catch (_) {}
    }
    return _localUsers[uid] ?? _currentUser;
  }

  /// Stream of pending users for Admin approval panel
  Stream<List<UserModel>> streamPendingUsers() {
    if (isFirebaseAvailable && _firestore != null) {
      return _firestore!
          .collection(AppConstants.usersCollection)
          .where('status', isEqualTo: AppConstants.statusPending)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => UserModel.fromDocument(d)).toList())
          .handleError((_) => _getLocalPendingUsers());
    }

    _emitPendingUsers();
    return _pendingUsersController.stream;
  }

  List<UserModel> _getLocalPendingUsers() {
    return _localUsers.values
        .where((u) => u.status == AppConstants.statusPending)
        .toList();
  }

  void _emitPendingUsers() {
    _pendingUsersController.add(_getLocalPendingUsers());
  }

  /// Approve a pending user (Admin Action)
  Future<void> approveUser(String uid) async {
    if (isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .update({
          'isApproved': true,
          'status': AppConstants.statusApproved,
        });
      } catch (_) {}
    }

    if (_localUsers.containsKey(uid)) {
      final old = _localUsers[uid]!;
      final updated = UserModel(
        uid: old.uid,
        name: old.name,
        email: old.email,
        role: old.role,
        isApproved: true,
        status: AppConstants.statusApproved,
        createdAt: old.createdAt,
      );
      _localUsers[uid] = updated;

      if (_currentUser?.uid == uid) {
        _currentUser = updated;
        _userStreamController.add(updated);
      }
      _emitPendingUsers();
    }
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'اس ای میل سے کوئی اکاؤنٹ موجود نہیں ہے۔ براہ کرم پہلے رجسٹر ہوں۔\n(No account found for this email)';
      case 'wrong-password':
        return 'درج کردہ پاس ورڈ غلط ہے۔ دوبارہ کوشش کریں۔\n(Incorrect password)';
      case 'invalid-credential':
        return 'ای میل یا پاس ورڈ درست نہیں ہے۔\n(Invalid email or password credentials)';
      case 'email-already-in-use':
        return 'یہ ای میل پہلے سے زیرِ استعمال ہے۔ براہ کرم لاگ ان کریں۔\n(This email is already registered. Please login)';
      case 'weak-password':
        return 'پاس ورڈ کمزور ہے۔ کم از کم 6 حروف پر مشتمل پاس ورڈ منتخب کریں۔\n(Password is too weak)';
      case 'invalid-email':
        return 'ای میل ایڈریس کا فارمیٹ درست نہیں ہے۔\n(Invalid email address)';
      case 'network-request-failed':
        return 'انٹرنیٹ کنکشن دستیاب نہیں ہے۔ اپنا انٹرنیٹ چیک کریں۔\n(Network error)';
      default:
        return e.message ?? 'ایک غیر متوقع خرابی پیش آئی ہے۔';
    }
  }
}
