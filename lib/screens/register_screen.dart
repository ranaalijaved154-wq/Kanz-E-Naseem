import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.registerWithEmailAndPassword(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      // AuthWrapper will catch the new auth state and route to WaitingApprovalScreen (or Dashboard if admin)
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'رجسٹریشن (Registration)',
          style: GoogleFonts.amiri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryEmerald,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading
                    Text(
                      'نیا اکاؤنٹ بنائیں',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.amiri(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    Text(
                      'Create your Kanz-e-Naseem account',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Registration Form Card
                    Container(
                      padding: const EdgeInsets.all(22),
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
                          // Full Name
                          CustomTextField(
                            controller: _nameController,
                            label: 'پورا نام (Full Name)',
                            hint: 'Muhammad Ali',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'براہ کرم اپنا پورا نام درج کریں۔';
                              }
                              if (val.trim().length < 3) {
                                return 'نام کم از کم 3 حروف پر مشتمل ہو۔';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
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

                          // Password
                          CustomTextField(
                            controller: _passwordController,
                            label: 'پاس ورڈ (Password)',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscureText: _obscurePassword,
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
                                return 'پاس ورڈ کم از کم 6 حروف پر مشتمل ہو۔';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Confirm Password
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'پاس ورڈ کی تصدیق (Confirm Password)',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_reset_rounded,
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'براہ کرم پاس ورڈ دوبارہ درج کریں۔';
                              }
                              if (val != _passwordController.text) {
                                return 'دونوں پاس ورڈ آپس میں مماثل نہیں ہیں۔';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Note about approval
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.badgePendingBg.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppTheme.accentGold.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: AppTheme.badgePendingText,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'رجسٹریشن کے بعد ایڈمن کی منظوری ضروری ہوگی۔\n(Admin approval will be required after sign-up)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.badgePendingText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Submit Button
                          CustomButton(
                            text: 'رجسٹر کریں (Create Account)',
                            icon: Icons.person_add_alt_1_rounded,
                            isLoading: _isLoading,
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Back to Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'پہلے سے اکاؤنٹ موجود ہے؟ ',
                          style: GoogleFonts.outfit(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'لاگ ان کریں (Sign In)',
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
                    const SizedBox(height: 20),
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
