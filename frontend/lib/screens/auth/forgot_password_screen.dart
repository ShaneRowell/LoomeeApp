import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: wire up to AuthService.forgotPassword once backend endpoint exists
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _emailSent ? _buildConfirmation() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            'Forgot\nPassword?',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppTheme.fontColor,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Enter the email address linked to your account and we'll send you a reset link.",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.fontColor.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendResetLink(),
            decoration: const InputDecoration(hintText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetLink,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Send Reset Link',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.widgetColor.withValues(alpha: 0.08),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 48,
            color: AppTheme.widgetColor,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Check your email',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppTheme.fontColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'We sent a password reset link to\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.fontColor.withValues(alpha: 0.6),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back to Login',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _sendResetLink,
          child: Text(
            "Didn't receive it? Resend",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.fontColor.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
