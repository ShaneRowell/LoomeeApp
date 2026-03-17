import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/legal_sheet.dart';
import '../../widgets/common/loomee_logo.dart';

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
  bool _obscurePassword = true;
  bool _consentAccepted = false;

  // Gesture recognisers for tappable links inside the consent text
  late final TapGestureRecognizer _tosRecognizer;
  late final TapGestureRecognizer _ppRecognizer;

  @override
  void initState() {
    super.initState();
    _tosRecognizer = TapGestureRecognizer()
      ..onTap = () => _showLegal(
            'Terms of Service',
            LegalContent.termsOfService,
          );
    _ppRecognizer = TapGestureRecognizer()
      ..onTap = () => _showLegal(
            'Privacy Policy',
            LegalContent.privacyPolicy,
          );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _tosRecognizer.dispose();
    _ppRecognizer.dispose();
    super.dispose();
  }

  void _showLegal(String title, List<LegalSection> sections) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LegalSheet(title: title, sections: sections),
    );
  }

  Future<void> _register() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }
    // Require consent
    if (!_consentAccepted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please accept the Terms of Service and Privacy Policy to continue.',
            style: GoogleFonts.playfairDisplay(),
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );
    if (success && mounted) {
      HapticFeedback.mediumImpact();
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else if (mounted && authProvider.error != null) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error!,
              style: GoogleFonts.playfairDisplay()),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accentLink = scheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo / Brand
                const LomeeLogo(size: 72),
                const SizedBox(height: 12),
                Text(
                  'Loomeé',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 48),

                // Name field
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 20,
                        color: scheme.onSurface.withValues(alpha: 0.4),
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  decoration:
                      const InputDecoration(hintText: 'Confirm Password'),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ── Consent checkbox ──────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _consentAccepted,
                        onChanged: (v) {
                          HapticFeedback.lightImpact();
                          setState(() => _consentAccepted = v ?? false);
                        },
                        activeColor: AppTheme.accentColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        side: BorderSide(
                          color: scheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 13,
                              color: scheme.onSurface.withValues(alpha: 0.7),
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms of Service',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 13,
                                  color: accentLink,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: accentLink,
                                ),
                                recognizer: _tosRecognizer,
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 13,
                                  color: accentLink,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: accentLink,
                                ),
                                recognizer: _ppRecognizer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Create Account button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final enabled = !auth.isLoading && _consentAccepted;
                      return ElevatedButton(
                        onPressed: enabled ? _register : null,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Create Account',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        color: scheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                      child: Text(
                        'Sign in',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
