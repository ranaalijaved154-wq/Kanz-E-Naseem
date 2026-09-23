import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/audio/mini_player_widget.dart';
import 'admin/admin_dashboard_screen.dart';
import 'tabs/kutub_tab.dart';
import 'tabs/sout_tab.dart';
import 'tabs/yadain_tab.dart';

class MainDashboardScreen extends StatefulWidget {
  final UserModel? user;
  final bool isAdmin;

  const MainDashboardScreen({
    super.key,
    this.user,
    this.isAdmin = false,
  });

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  final _authService = AuthService();
  int _currentIndex = 0;
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _authService.signOut();
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

  void _openAdminPanel() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminDashboardScreen(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Admin access is strictly restricted to master admin email
    final isMaster = AppConstants.isMasterAdmin(_authService.currentUser?.email) ||
        AppConstants.isMasterAdmin(widget.user?.email) ||
        (widget.isAdmin && widget.user?.email == AppConstants.adminEmail);

    final displayName = widget.user?.name.isNotEmpty == true
        ? widget.user!.name
        : (_authService.currentUser?.displayName ?? 'معزز صارف');

    // ONLY the 3 user-facing modules (Kutub, Sout o Bayan, Yadain o Sawaneh)
    final List<Widget> tabs = [
      KutubTab(isAdmin: isMaster),
      SoutTab(isAdmin: isMaster),
      YadainTab(isAdmin: isMaster),
    ];

    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_stories_rounded, color: AppTheme.accentGoldLight),
            const SizedBox(width: 8),
            Text(
              AppConstants.appNameUrdu,
              style: GoogleFonts.amiri(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryEmerald,
        actions: [
          // Discrete Admin Portal icon (visible ONLY to Master Admin)
          if (isMaster)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accentGoldLight),
              tooltip: 'ایڈمنسٹریٹر پینل (Admin Dashboard)',
              onPressed: _openAdminPanel,
            ),

          // Logout Action
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'لاگ آؤٹ (Logout)',
            onPressed: _isLoggingOut ? null : _handleLogout,
          ),
        ],
      ),

      // Main Tab Content
      body: SafeArea(
        child: Column(
          children: [
            // User Greeting strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.primaryDark.withOpacity(0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'خوش آمدید، $displayName',
                    style: GoogleFonts.amiri(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                  if (isMaster)
                    GestureDetector(
                      onTap: _openAdminPanel,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.accentGold, width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_rounded, size: 12, color: AppTheme.accentGoldDark),
                            const SizedBox(width: 4),
                            Text(
                              'ایڈمن پورٹل',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppTheme.accentGoldDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Active Tab (Kutub, Sout o Bayan, or Yadain o Sawaneh)
            Expanded(child: tabs[safeIndex]),
          ],
        ),
      ),

      // Persistent Sticky Bottom Mini-Player + Strict 3-Tab Navigation Bar
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Docked Mini-Player above BottomNavigationBar
          const MiniPlayerWidget(),

          // Bottom Navigation Bar with ONLY 3 public user-facing items
          BottomNavigationBar(
            currentIndex: safeIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryEmerald,
            unselectedItemColor: AppTheme.textMuted,
            selectedLabelStyle: GoogleFonts.amiri(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            unselectedLabelStyle: GoogleFonts.amiri(
              fontSize: 12,
            ),
            elevation: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded),
                activeIcon: Icon(Icons.menu_book_rounded, color: AppTheme.primaryEmerald),
                label: 'کتب',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.graphic_eq_rounded),
                activeIcon: Icon(Icons.graphic_eq_rounded, color: AppTheme.primaryEmerald),
                label: 'صوت و بیان',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_library_rounded),
                activeIcon: Icon(Icons.photo_library_rounded, color: AppTheme.primaryEmerald),
                label: 'یادیں و سوانح',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
