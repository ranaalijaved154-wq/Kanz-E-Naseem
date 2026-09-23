import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class WaitingApprovalScreen extends StatefulWidget {
  final UserModel? user;

  const WaitingApprovalScreen({super.key, this.user});

  @override
  State<WaitingApprovalScreen> createState() => _WaitingApprovalScreenState();
}

class _WaitingApprovalScreenState extends State<WaitingApprovalScreen> {
  final _authService = AuthService();
  bool _isChecking = false;
  bool _isLoggingOut = false;

  Future<void> _checkStatus() async {
    final currentUid = widget.user?.uid ?? _authService.currentUser?.uid;
    if (currentUid == null) return;

    setState(() => _isChecking = true);

    try {
      final updatedUser = await _authService.getUser(currentUid);
      if (!mounted) return;

      if (updatedUser != null && updatedUser.hasAccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'مبارک ہو! آپ کا اکاؤنٹ منظور کر لیا گیا ہے۔\n(Account has been approved! Redirecting...)',
            ),
            backgroundColor: AppTheme.primaryEmerald,
          ),
        );
        // The AuthWrapper Stream will automatically route to MainDashboardScreen!
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'آپ کی درخواست ابھی زیرِ التواء ہے۔ ایڈمن سے منظوری کا انتظار کریں۔\n(Your request is still pending admin review)',
            ),
            backgroundColor: AppTheme.accentGoldDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خرابی: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _authService.signOut();
      // AuthWrapper will automatically transition to LoginScreen
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لاگ آؤٹ میں خرابی: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final userName = user?.name.isNotEmpty == true
        ? user!.name
        : (_authService.currentUser?.displayName ?? 'معزز صارف');
    final userEmail = user?.email.isNotEmpty == true
        ? user!.email
        : (_authService.currentUser?.email ?? '—');
    final formattedDate = user?.createdAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(user!.createdAt!)
        : 'تازہ ترین (Just now)';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          AppConstants.appNameUrdu,
          style: GoogleFonts.amiri(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryEmerald,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'لاگ آؤٹ (Logout)',
            onPressed: _isLoggingOut ? null : _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Animated / Icon Indicator Badge
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.hourglass_top_rounded,
                            size: 40,
                            color: AppTheme.accentGoldDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.badgePendingBg,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppTheme.accentGoldDark.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.badgePendingText,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppConstants.pendingApprovalStatusUrdu,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.badgePendingText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Prominent Urdu Message as specified by User
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryEmerald.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryEmerald.withOpacity(0.15),
                            ),
                          ),
                          child: Text(
                            AppConstants.pendingApprovalMessageUrdu,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.amiri(
                              fontSize: 18,
                              height: 1.8,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Your registration has been received. Access to materials will be granted after administrator verification.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppTheme.textMuted,
                            height: 1.4,
                          ),
                        ),
                        const Divider(height: 36, thickness: 1),

                        // User Details Box
                        Text(
                          'رجسٹریشن کی تفصیلات (Registration Details)',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.amiri(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildInfoRow(
                          icon: Icons.person_outline,
                          title: 'نام (Name):',
                          value: userName,
                        ),
                        const SizedBox(height: 10),

                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          title: 'ای میل (Email):',
                          value: userEmail,
                        ),
                        const SizedBox(height: 10),

                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          title: 'تاریخ (Date):',
                          value: formattedDate,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Real-time live notice
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryEmerald.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.primaryEmerald.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.sync,
                          color: AppTheme.primaryEmerald,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'ایڈمن کی منظوری کے بعد یہ اسکرین خودکار طور پر کھل جائے گی۔\n(Screen updates automatically in real-time upon approval)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryEmerald.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buttons: Check Status / Refresh & Logout
                  CustomButton(
                    text: 'دوبارہ چیک کریں (Check Status / Refresh)',
                    icon: Icons.refresh_rounded,
                    isLoading: _isChecking,
                    onPressed: _checkStatus,
                  ),

                  const SizedBox(height: 12),

                  CustomButton(
                    text: 'لاگ آؤٹ کریں (Logout)',
                    icon: Icons.logout_rounded,
                    isOutlined: true,
                    isLoading: _isLoggingOut,
                    color: Colors.red.shade700,
                    textColor: Colors.red.shade700,
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
