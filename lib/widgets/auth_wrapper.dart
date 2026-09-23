import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../screens/login_screen.dart';
import '../screens/main_dashboard_screen.dart';
import '../screens/waiting_approval_screen.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, authSnapshot) {
        // 1. Loading state while checking authentication
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingSplash();
        }

        // 2. User is not logged in -> show LoginScreen
        if (!authSnapshot.hasData || authSnapshot.data == null) {
          return const LoginScreen();
        }

        final User firebaseUser = authSnapshot.data!;

        // 3. User is logged in -> Listen to Firestore 'users' collection in real-time
        return StreamBuilder<UserModel?>(
          stream: authService.streamUser(firebaseUser.uid),
          builder: (context, userSnapshot) {
            // Check if Master Admin email
            final bool isMasterAdmin =
                AppConstants.isMasterAdmin(firebaseUser.email);

            // While waiting for initial Firestore document load
            if (userSnapshot.connectionState == ConnectionState.waiting &&
                !userSnapshot.hasData) {
              // Master admin bypasses initial delay to guarantee immediate access
              if (isMasterAdmin) {
                return MainDashboardScreen(
                  user: UserModel(
                    uid: firebaseUser.uid,
                    name: firebaseUser.displayName ?? AppConstants.adminDisplayName,
                    email: firebaseUser.email ?? AppConstants.adminEmail,
                    role: AppConstants.roleAdmin,
                    isApproved: true,
                    status: AppConstants.statusApproved,
                  ),
                  isAdmin: true,
                );
              }
              return const _LoadingSplash();
            }

            final UserModel? userModel = userSnapshot.data;

            // Transient state: User just registered but doc is still being committed
            if (userModel == null) {
              if (isMasterAdmin) {
                return MainDashboardScreen(
                  user: UserModel(
                    uid: firebaseUser.uid,
                    name: firebaseUser.displayName ?? AppConstants.adminDisplayName,
                    email: firebaseUser.email ?? AppConstants.adminEmail,
                    role: AppConstants.roleAdmin,
                    isApproved: true,
                    status: AppConstants.statusApproved,
                  ),
                  isAdmin: true,
                );
              }
              // Temporarily show waiting screen while document synchronizes
              return const WaitingApprovalScreen();
            }

            // A) Master Admin or Admin Role -> Route directly to MainDashboardScreen with Admin panel
            if (isMasterAdmin || userModel.isAdmin) {
              return MainDashboardScreen(
                user: userModel,
                isAdmin: true,
              );
            }

            // B) Approved User -> Route to MainDashboardScreen
            if (userModel.isApproved == true ||
                userModel.status == AppConstants.statusApproved) {
              return MainDashboardScreen(
                user: userModel,
                isAdmin: false,
              );
            }

            // C) Unapproved / Pending User -> Route to WaitingApprovalScreen
            return WaitingApprovalScreen(user: userModel);
          },
        );
      },
    );
  }
}

class _LoadingSplash extends StatelessWidget {
  const _LoadingSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.accentGold.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 52,
                color: AppTheme.primaryEmerald,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppConstants.appNameUrdu,
              style: GoogleFonts.amiri(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            Text(
              AppConstants.appNameEnglish,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: AppTheme.accentGoldDark,
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
