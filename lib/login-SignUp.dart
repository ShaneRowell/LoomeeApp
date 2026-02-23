import 'package:flutter/material.dart';
import 'forgot password.dart';
import 'home page.dart';

// This acts as our "Fake Database" for this session
Map<String, String> _mockUserDb = {};

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  double _strength = 0;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _isLoading = false);

      String email = _emailController.text.trim();
      String password = _passwordController.text;

      if (isLogin) {
        // --- LOGIN LOGIC ---
        if (_mockUserDb.containsKey(email) && _mockUserDb[email] == password) {
          _navigateToHome();
        } else {
          _showError('Invalid email or password. Please sign up first.');
        }
      } else {
        // --- SIGN UP LOGIC ---
        _mockUserDb[email] = password; // Save user to our "database"
        _showSuccess('Account created! Please log in.');
        setState(() => isLogin = true); // Switch back to login mode automatically
        _confirmPasswordController.clear();
      }
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // Password strength logic
  void _updatePasswordStrength(String value) {
    double strength = 0;
    if (value.isNotEmpty) {
      if (value.length >= 8) strength += 0.25;
      if (value.contains(RegExp(r'[A-Z]'))) strength += 0.25;
      if (value.contains(RegExp(r'[0-9]'))) strength += 0.25;
      if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    }
    setState(() => _strength = strength);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenSize.height - 50),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text('Loomeé', style: TextStyle(fontSize: 48, color: Color(0xFF1C2B39))),
                    const Text('Where technology meets haute couture', style: TextStyle(fontStyle: FontStyle.italic, color:Color(0xFF1C2B39))),
                    const SizedBox(height: 40),

                    _buildToggleSwitch(),
                    const SizedBox(height: 30),

                    _buildTextFormField(
                      controller: _emailController,
                      hint: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Email is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    _buildTextFormField(
                      controller: _passwordController,
                      hint: 'Password',
                      isObscure: _obscurePassword,
                      onChanged: _updatePasswordStrength,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (!isLogin && value.length < 8) return 'Min 8 characters required';
                        return null;
                      },
                    ),

                    if (!isLogin) ...[
                      const SizedBox(height: 15),
                      _buildTextFormField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm Password',
                        isObscure: _obscureConfirm,
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 20),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],

                    if (!isLogin || _strength > 0) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: _strength,
                          backgroundColor: Colors.black12,
                          color: _strength <= 0.25 ? Colors.red : (_strength <= 0.75 ? Colors.orange : Colors.green),
                          minHeight: 5,
                        ),
                      ),
                    ],

                    if (isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage())),
                          child: const Text('Forgot password?', style: TextStyle(color: Colors.grey)),
                        ),
                      ),

                    const SizedBox(height: 20),
                    _buildActionButton(),
                    const SizedBox(height: 30),

                    _buildSocialButton('Continue with Google', 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png'),
                    const SizedBox(height: 15),
                    _buildSocialButton('Continue with Apple', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildToggleSwitch() {
    return Container(
      height: 45,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.black12)),
      child: Row(
        children: [
          Expanded(child: _toggleItem('Login', isLogin)),
          Expanded(child: _toggleItem('Sign Up', !isLogin)),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() {
        isLogin = (label == 'Login');
        _strength = 0;
        _passwordController.clear();
        _confirmPasswordController.clear();
      }),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: active ? const Color(0xFF333333) : Colors.transparent, borderRadius: BorderRadius.circular(25)),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    bool isObscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
  }) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(8),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAuth,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF333333), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(isLogin ? 'Login' : 'Create Account', style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _buildSocialButton(String text, String logoUrl) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(logoUrl, height: 20),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}