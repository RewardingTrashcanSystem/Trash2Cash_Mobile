import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/features/auth/presentation/provider/profile_provider.dart';
import 'package:trash2cash/features/auth/presentation/screen/sign_up.dart';
import 'package:trash2cash/features/onboarding/widget/app_button.dart';
import 'package:trash2cash/features/auth/presentation/provider/auth_provider.dart';
import 'package:trash2cash/features/home/presentation/screen/home_screen.dart';
// import 'package:trash2cash/features/profile/presentation/provider/profile_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.isEmpty) {
      _showError('Please enter email or phone number');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter password');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final profileProvider = context.read<ProfileProvider>();
       profileProvider.clearUser();
      // 🔐 Login (tokens only)
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      // 👤 Fetch profile (ONLY source of user data)
      await profileProvider.fetchProfile();

      if (!mounted) return;

      if (profileProvider.user == null) {
        throw Exception('Failed to load user profile');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Trash2CashHomeUI()),
        (_) => false,
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFBBC888), Colors.white],
            stops: [0.3, 0.7],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 228,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/image1.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Login to your account",
                style: TextStyle(
                  fontFamily: 'Afacad',
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email / Phone',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _login(),
                      ),

                      const SizedBox(height: 30),

                      AppButton(
                        buttonText:
                            _isLoading ? 'Logging in...' : 'Login',
                        onPressed: _isLoading ? null : _login,
                        color: const Color(0xFF00357A),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUp(),
                                      ),
                                    );
                                  },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xFF00357A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
