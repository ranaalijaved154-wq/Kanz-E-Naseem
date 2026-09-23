import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Stream of current Firebase Auth state (logged in / logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Current Firebase User
  User? get currentUser => _auth.currentUser;

  /// Register a new user with Email, Password, and Full Name
  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanName = name.trim();

    try {
      // 1. Create user in Firebase Authentication
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-null',
          message: 'صارف بناتے وقت خرابی پیش آئی۔ User could not be created.',
        );
      }

      // 2. Set Firebase Auth display name
      await user.updateDisplayName(cleanName);

      // 3. Determine role & approval status
      // Master admin is automatically approved and given admin role
      final bool isMaster = AppConstants.isMasterAdmin(cleanEmail);
      final String role =
          isMaster ? AppConstants.roleAdmin : AppConstants.roleUser;
      final bool isApproved = isMaster ? true : false;
      final String status = isMaster
          ? AppConstants.statusApproved
          : AppConstants.statusPending;

      // 4. Create document in Cloud Firestore under 'users' collection
      final Map<String, dynamic> userData = {
        'uid': user.uid,
        'name': cleanName,
        'email': cleanEmail,
        'role': role,
        'isApproved': isApproved,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userData);

      return UserModel(
        uid: user.uid,
        name: cleanName,
        email: cleanEmail,
        role: role,
        isApproved: isApproved,
        status: status,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('رجسٹریشن کے عمل میں رکاوٹ: $e');
    }
  }

  /// Sign in with Email and Password
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      // If user logs in with the master admin email, ensure their Firestore doc has role: admin
      if (credential.user != null && AppConstants.isMasterAdmin(cleanEmail)) {
        await _ensureMasterAdminRole(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('لاگ ان کے دوران خرابی: $e');
    }
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      await _auth.sendPasswordResetEmail(email: cleanEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception('پاس ورڈ ری سیٹ ای میل بھیجنے میں خرابی: $e');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('لاگ آؤٹ میں خرابی: $e');
    }
  }

  /// Stream of user document from Firestore (real-time approval updates)
  Stream<UserModel?> streamUser(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserModel.fromDocument(snapshot);
    });
  }

  /// Single fetch of user document (for manual refresh / checks)
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return UserModel.fromDocument(doc);
    } catch (e) {
      return null;
    }
  }

  /// Helper to guarantee master admin always has Firestore admin doc
  Future<void> _ensureMasterAdminRole(User user) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        await docRef.set({
          'uid': user.uid,
          'name': user.displayName ?? AppConstants.adminDisplayName,
          'email': user.email ?? AppConstants.adminEmail,
          'role': AppConstants.roleAdmin,
          'isApproved': true,
          'status': AppConstants.statusApproved,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = doc.data() ?? {};
        if (data['role'] != AppConstants.roleAdmin ||
            data['isApproved'] != true ||
            data['status'] != AppConstants.statusApproved) {
          await docRef.update({
            'role': AppConstants.roleAdmin,
            'isApproved': true,
            'status': AppConstants.statusApproved,
          });
        }
      }
    } catch (_) {
      // Non-fatal, UserModel will still treat master email as admin locally
    }
  }

  /// User-friendly Urdu and English Firebase error translation
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
        return 'پاس ورڈ کمزور ہے۔ کم از کم 6 حروف پر مشتمل پاس ورڈ منتخب کریں۔\n(Password is too weak. Must be at least 6 characters)';
      case 'invalid-email':
        return 'ای میل ایڈریس کا فارمیٹ درست نہیں ہے۔\n(Invalid email address format)';
      case 'user-disabled':
        return 'یہ صارف اکاؤنٹ غیر فعال کر دیا گیا ہے۔ ایڈمن سے رابطہ کریں۔\n(This account has been disabled)';
      case 'too-many-requests':
        return 'بہت زیادہ ناکام کوششیں کی گئی ہیں۔ کچھ دیر بعد دوبارہ کوشش کریں۔\n(Too many attempts. Please try again later)';
      case 'network-request-failed':
        return 'انٹرنیٹ کنکشن دستیاب نہیں ہے۔ اپنا انٹرنیٹ چیک کریں۔\n(Network error. Please check your internet connection)';
      default:
        return e.message ?? 'ایک غیر متوقع خرابی پیش آئی ہے۔ (An error occurred)';
    }
  }
}
