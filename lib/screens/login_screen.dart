import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.loginWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Navigation is automatically handled by AuthWrapper stream!
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSecretAdminGesture() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.security_rounded, color: AppTheme.accentGold),
            const SizedBox(width: 8),
            Text(
              'خفیہ ایڈمن پورٹل',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'یہ رسائی صرف مجاز ماسٹر ایڈمن کے لیے مخصوص ہے۔',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryEmerald.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                AppConstants.adminEmail,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryEmerald,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);
                await _authService.signInAsMasterAdmin();
                if (mounted) setState(() => _isLoading = false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.verified_user_rounded, color: AppTheme.accentGoldLight),
              label: const Text('بطور ایڈمن داخل ہوں'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryEmerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final dialogFormKey = GlobalKey<FormState>();
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.lock_reset, color: AppTheme.accentGold),
                  const SizedBox(width: 8),
                  Text(
                    'پاس ورڈ ری سیٹ (Reset Password)',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              content: Form(
                key: dialogFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'اپنا رجسٹرڈ ای میل درج کریں۔ ہم آپ کو پاس ورڈ تبدیل کرنے کا لنک ارسال کریں گے۔',
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: resetEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.email_outlined,
                            color: AppTheme.primaryEmerald),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'ای میل درج کریں';
                        }
                        if (!val.contains('@') || !val.contains('.')) {
                          return 'درست ای میل درج کریں';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isResetting ? null : () => Navigator.pop(context),
                  child: const Text('منسوخ (Cancel)'),
                ),
                ElevatedButton(
                  onPressed: isResetting
                      ? null
                      : () async {
                          if (!dialogFormKey.currentState!.validate()) return;
                          setDialogState(() => isResetting = true);
                          try {
                            await _authService.sendPasswordResetEmail(
                              resetEmailController.text.trim(),
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              _showSuccessSnackBar(
                                'پاس ورڈ ری سیٹ ای میل روانہ کر دی گئی ہے۔ اپنا ان باکس چیک کریں۔\n(Password reset email sent)',
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isResetting = false);
                            _showErrorSnackBar(
                              e.toString().replaceAll('Exception: ', ''),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryEmerald,
                  ),
                  child: isResetting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('ارسال کریں (Send)'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Islamic Brand Header (with secret admin long-press gesture)
                    Center(
                      child: GestureDetector(
                        onLongPress: _handleSecretAdminGesture,
                        child: Container(
                          padding: const EdgeInsets.all(18),
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
                            size: 46,
                            color: AppTheme.primaryEmerald,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // App Title
                    Center(
                      child: Text(
                        AppConstants.appNameUrdu,
                        style: GoogleFonts.amiri(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        AppConstants.appNameEnglish,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: AppTheme.accentGoldDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        AppConstants.appSubTitleUrdu,
                        style: GoogleFonts.amiri(
                          fontSize: 15,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Card Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'خوش آمدید! لاگ ان کریں',
                            style: GoogleFonts.amiri(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryEmerald,
                            ),
                          ),
                          Text(
                            'Login to your account',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          CustomTextField(
                            controller: _emailController,
                            label: 'ای میل ایڈریس (Email Address)',
                            hint: 'your.email@domain.com',
                            prefixIcon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'براہ کرم ای میل درج کریں۔';
                              }
                              if (!val.contains('@') || !val.contains('.')) {
                                return 'درست ای میل درج کریں۔';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          CustomTextField(
                            controller: _passwordController,
                            label: 'پاس ورڈ (Password)',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'براہ کرم پاس ورڈ درج کریں۔';
                              }
                              if (val.length < 6) {
                                return 'پاس ورڈ کم از کم 6 حروف پر مشتمل ہونا چاہیے۔';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'پاس ورڈ بھول گئے؟ (Forgot Password)',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentGoldDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Login Button
                          CustomButton(
                            text: 'لاگ ان کریں (Sign In)',
                            icon: Icons.login_rounded,
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: 16),

                          // Guest Access
                          Center(
                            child: TextButton.icon(
                              onPressed: () async {
                                await _authService.signInAsGuest();
                              },
                              icon: const Icon(Icons.explore_outlined,
                                  color: AppTheme.primaryEmerald, size: 18),
                              label: Text(
                                'بطور مہمان کتب و بیانات دیکھیں (Guest)',
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryEmerald,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Navigation to Register Screen
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'نیا اکاؤنٹ بنانا چاہتے ہیں؟ ',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'رجسٹر ہوں (Register)',
                            style: GoogleFonts.outfit(
                              color: AppTheme.primaryEmerald,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
