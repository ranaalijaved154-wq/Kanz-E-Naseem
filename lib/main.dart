import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'constants/app_constants.dart';
import 'theme/app_theme.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    // If you have run `flutterfire configure`, replace with:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
    // If google-services.json / GoogleService-Info.plist has not been configured yet,
    // we catch this gracefully and allow the app to show a setup guidance screen.
  }

  runApp(KanzENaseemApp(isFirebaseReady: firebaseInitialized));
}

class KanzENaseemApp extends StatelessWidget {
  final bool isFirebaseReady;

  const KanzENaseemApp({super.key, this.isFirebaseReady = true});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${AppConstants.appNameUrdu} - ${AppConstants.appNameEnglish}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isFirebaseReady
          ? const AuthWrapper()
          : const _FirebaseSetupPendingScreen(),
    );
  }
}

/// Helpful fallback screen displayed if Firebase configuration files are pending
class _FirebaseSetupPendingScreen extends StatelessWidget {
  const _FirebaseSetupPendingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.settings_suggest_rounded,
                        size: 54,
                        color: AppTheme.accentGoldDark,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'کنزِ نسیم (Kanz-e-Naseem)',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryEmerald,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Firebase Configuration Pending',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Please configure Firebase for your Flutter app using the FlutterFire CLI or by adding:\n\n'
                        '• Android: android/app/google-services.json\n'
                        '• iOS: ios/Runner/GoogleService-Info.plist\n\n'
                        'Once added, rerun the app to activate Firebase Auth & Firestore.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Try reinitializing
                          main();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryEmerald,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('دوبارہ کوشش کریں (Retry)'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
