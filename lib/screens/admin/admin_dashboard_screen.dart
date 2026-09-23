import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'admin_upload_dialog.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserModel? user;

  const AdminDashboardScreen({super.key, this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _authService = AuthService();

  void _openUploadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AdminUploadDialog(),
    );
  }

  Future<void> _approveUser(String uid, String userName) async {
    try {
      await _authService.approveUser(uid);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$userName کا اکاؤنٹ منظور کر لیا گیا ہے۔ (User Approved)'),
          backgroundColor: AppTheme.primaryEmerald,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('منظوری میں خرابی: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.accentGoldLight),
            const SizedBox(width: 8),
            Text(
              'ایڈمنسٹریٹر پینل',
              style: GoogleFonts.amiri(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openUploadDialog,
        backgroundColor: AppTheme.primaryEmerald,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.accentGoldLight),
        label: Text(
          'مواد شامل کریں (Upload)',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Status Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryDark, AppTheme.primaryEmerald],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          color: AppTheme.accentGoldLight, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'ایڈمنسٹریٹر پینل (Admin Dashboard)',
                        style: GoogleFonts.amiri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${AppConstants.adminDisplayName} (${AppConstants.adminEmail})',
                    style: GoogleFonts.amiri(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGoldLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _openUploadDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.primaryDark,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text(
                      'مواد اپلوڈ مینیجر کھولیں (Open Upload Manager)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Content Upload Quick Actions
            Text(
              'مواد اپلوڈ مینیجر (Content Upload Actions)',
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildUploadShortcutCard(
                    title: 'کتاب اپلوڈ',
                    subtitle: 'PDF to /books/',
                    icon: Icons.menu_book_rounded,
                    onTap: _openUploadDialog,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildUploadShortcutCard(
                    title: 'تصویر / سوانح',
                    subtitle: 'Photo to /memories/',
                    icon: Icons.photo_library_rounded,
                    onTap: _openUploadDialog,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildUploadShortcutCard(
                    title: 'آڈیو بیان',
                    subtitle: 'MP3 to /audios/',
                    icon: Icons.audiotrack_rounded,
                    onTap: _openUploadDialog,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Approval Section
            Text(
              'منظوری کے منتظر صارفین (Pending User Approvals)',
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryEmerald,
              ),
            ),
            const SizedBox(height: 10),

            StreamBuilder<List<UserModel>>(
              stream: _authService.streamPendingUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final pendingUsers = snapshot.data ?? [];
                if (pendingUsers.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderGrey),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: AppTheme.primaryEmerald, size: 36),
                        const SizedBox(height: 8),
                        Text(
                          'کوئی نیا صارف منظوری کا منتظر نہیں ہے۔',
                          style: GoogleFonts.amiri(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        const Text(
                          'All registered users have been reviewed.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: pendingUsers.map((pendingUser) {
                    final name = pendingUser.name.isNotEmpty ? pendingUser.name : 'نامعلوم';
                    final email = pendingUser.email.isNotEmpty ? pendingUser.email : '—';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderGrey),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryEmerald.withOpacity(0.12),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppTheme.primaryEmerald,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _approveUser(pendingUser.uid, name),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryEmerald,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('منظور کریں', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadShortcutCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryEmerald, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
