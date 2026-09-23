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

    return StreamBuilder<UserModel?>(
      stream: authService.appUserStream,
      initialData: authService.currentAppUser,
      builder: (context, snapshot) {
        final UserModel? user = snapshot.data;

        // 1. User not logged in -> Show LoginScreen
        if (user == null) {
          return const LoginScreen();
        }

        final bool isMaster = AppConstants.isMasterAdmin(user.email);

        // 2. Master Admin or Admin Role -> Route to MainDashboardScreen with full Admin panel
        if (isMaster || user.isAdmin) {
          return MainDashboardScreen(
            user: user,
            isAdmin: true,
          );
        }

        // 3. Approved User -> Route to MainDashboardScreen
        if (user.isApproved == true ||
            user.status == AppConstants.statusApproved) {
          return MainDashboardScreen(
            user: user,
            isAdmin: false,
          );
        }

        // 4. Unapproved / Pending User -> Route to WaitingApprovalScreen
        return WaitingApprovalScreen(user: user);
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
