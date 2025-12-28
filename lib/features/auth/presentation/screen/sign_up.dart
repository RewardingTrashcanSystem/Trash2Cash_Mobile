import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/features/auth/presentation/screen/login_screen.dart';
import 'package:trash2cash/features/auth/presentation/widgets/Input_format.dart';
import 'package:trash2cash/features/onboarding/widget/app_button.dart';
import 'package:trash2cash/features/auth/presentation/provider/auth_provider.dart';
import 'package:trash2cash/features/home/presentation/screen/home_screen.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController(); // Added phone controller

  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  String? _availabilityMessage;
  bool _isAvailable = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkRegistrationAvailability() async {
    if (_emailController.text.isEmpty || _phoneController.text.isEmpty) {
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
      _availabilityMessage = null;
      _isAvailable = false;
    });

    final authProvider = context.read<AuthProvider>();
    
    final result = await authProvider.checkRegistration(
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    setState(() {
      _isCheckingAvailability = false;
    });

    if (result['success'] == true) {
      setState(() {
        _availabilityMessage = '✓ Email and phone are available';
        _isAvailable = true;
      });
      
      _showSnackBar('Available for registration', Colors.green);
    } else if (result['suggestLogin'] == true) {
      setState(() {
        _availabilityMessage = '✗ Account already exists. Please sign in instead.';
        _isAvailable = false;
      });
      
      _showAccountExistsDialog();
    } else {
      setState(() {
        _availabilityMessage = result['message'] ?? 'Registration check failed';
        _isAvailable = false;
      });
    }
  }

  Future<void> _onSignUp() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Validate all fields
    if (_firstNameController.text.isEmpty) {
      _showError('Please enter your first name');
      return;
    }

    if (_lastNameController.text.isEmpty) {
      _showError('Please enter your last name');
      return;
    }

    if (_emailController.text.isEmpty) {
      _showError('Please enter your email');
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showError('Please enter a valid email address');
      return;
    }

    if (_phoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }

    if (_passwordController.text.isEmpty) {
      _showError('Please enter a password');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters long');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    if (!_termsAccepted) {
      _showError('Please accept the Terms of Service and Privacy Policy');
      return;
    }

    // Optional: Check availability before registering
    if (!_isAvailable && _emailController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      final shouldCheck = await _showCheckAvailabilityDialog();
      if (shouldCheck == true) {
        await _checkRegistrationAvailability();
        if (!_isAvailable) return;
      } else if (shouldCheck == false) {
        return; // User chose not to check
      }
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    
    final result = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Show success message
      _showSnackBar('Account created successfully!', Colors.green);

      // Navigate to home screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Trash2CashHomeUI()),
        (route) => false,
      );
    } else {
      // Show error message
      _showError(result['message'] ?? 'Registration failed. Please try again.');
      
      // If it's a duplicate error, suggest login
      if (result['message']?.toLowerCase().contains('already exists') == true) {
        _showAccountExistsDialog();
      }
    }
  }

  Future<bool?> _showCheckAvailabilityDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check Availability'),
        content: const Text(
          'Would you like to check if this email and phone number are available before creating your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Check'),
          ),
        ],
      ),
    );
  }

  void _showAccountExistsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Already Exists'),
        content: const Text(
          'An account with this email or phone number already exists. '
          'Would you like to sign in instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
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
            stops: [0.25, 0.75],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header image
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

              const SizedBox(height: 20),

              // Title
              const Text(
                "Welcome!",
                style: TextStyle(
                  fontFamily: 'Afacad',
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create your account",
                style: TextStyle(
                  fontFamily: 'Afacad',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              // Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InputFormat.firstName(
                        controller: _firstNameController,
                      ),
                      const SizedBox(height: 18),

                      InputFormat.lastName(
                        controller: _lastNameController,
                      ),
                      const SizedBox(height: 18),

                      InputFormat.email(
                        controller: _emailController,
                        isRequired: true,
                      ),
                      const SizedBox(height: 18),

                      // Phone Number Field (Added)
                      _buildPhoneField(),
                      const SizedBox(height: 10),

                      // Availability Check
                      if (_isCheckingAvailability)
                        const Row(
                          children: [
                            SizedBox(width: 12),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Checking availability...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        )
                      else if (_availabilityMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 8),
                          child: Text(
                            _availabilityMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: _isAvailable ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      InputFormat.password(
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 18),

                      InputFormat.confirmPassword(
                        controller: _confirmPasswordController,
                        originalPassword: _passwordController.text,
                        label: 'Confirm Password',
                        isRequired: true,
                      ),

                      const SizedBox(height: 25),

                      // Terms checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _termsAccepted,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    setState(() {
                                      _termsAccepted = value ?? false;
                                    });
                                  },
                            activeColor: const Color(0xFF00357A),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'By creating an account, you agree to our Terms of Service and Privacy Policy',
                              style: TextStyle(
                                fontFamily: 'Afacad',
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      AppButton(
                        buttonText: _isLoading ? 'Creating Account...' : "Sign Up",
                        onPressed: (_isLoading || !_termsAccepted) ? null : _onSignUp,
                        color: const Color(0xFF00357A),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Color(0xFF00357A),
                        fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            'Phone Number *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            hintText: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone),
            suffixIcon: _emailController.text.isNotEmpty && _phoneController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.check_circle, size: 20),
                    onPressed: _isCheckingAvailability ? null : _checkRegistrationAvailability,
                    color: _isAvailable ? Colors.green : Colors.blue,
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            setState(() {
              _availabilityMessage = null;
              _isAvailable = false;
            });
          },
        ),
      ],
    );
  }
}