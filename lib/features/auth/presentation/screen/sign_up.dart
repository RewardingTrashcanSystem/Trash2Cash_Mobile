import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/features/auth/presentation/provider/profile_provider.dart';
import 'package:trash2cash/features/auth/presentation/screen/login_screen.dart';
import 'package:trash2cash/features/onboarding/widget/app_button.dart';
import 'package:trash2cash/features/auth/presentation/provider/auth_provider.dart';
import 'package:trash2cash/features/home/presentation/screen/home_screen.dart';
import 'package:trash2cash/features/auth/presentation/widgets/Input_format.dart';

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
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  Future<void> _onSignUp() async {
    if (_isLoading) return;
    
    FocusScope.of(context).unfocus();

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_termsAccepted) {
      _showError('Please accept Terms and Privacy Policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final profileProvider = context.read<ProfileProvider>();

      print('=== SIGNUP PROCESS STARTED ===');
      print('1. Starting registration...');

      // 1. Register user
      await authProvider.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      print('2. Registration successful');
      
      if (!mounted) return;

      // Show success message
      _showSnackBar('Account created successfully!', Colors.green);

      // 2. Wait a moment for backend to process
      print('3. Waiting for backend processing...');
      await Future.delayed(const Duration(seconds: 1));

      // 3. Verify tokens were saved
      print('4. Verifying authentication state...');
      
      // Check if user is authenticated
      if (!authProvider.isAuthenticated) {
        print('ERROR: User not authenticated after registration');
        throw Exception('Authentication failed after registration');
      }

      // 4. Try to fetch profile with retry logic
      print('5. Attempting to fetch profile...');
      bool profileLoaded = false;
      int retryCount = 0;
      const maxRetries = 3;

      while (!profileLoaded && retryCount < maxRetries) {
        try {
          print('Profile fetch attempt ${retryCount + 1}...');
          await profileProvider.fetchProfile();
          
          if (profileProvider.user != null) {
            profileLoaded = true;
            print('SUCCESS: Profile loaded on attempt ${retryCount + 1}');
            print('User email: ${profileProvider.user?.email}');
            print('User points: ${profileProvider.user?.totalPoints}');
          } else {
            print('WARNING: Profile is null after fetch attempt ${retryCount + 1}');
            retryCount++;
            if (retryCount < maxRetries) {
              await Future.delayed(const Duration(seconds: 1));
            }
          }
        } catch (e) {
          print('Profile fetch error on attempt ${retryCount + 1}: $e');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }

      if (!mounted) return;

      // 5. Handle profile loading result
      if (!profileLoaded) {
        print('WARNING: Profile could not be loaded after $maxRetries attempts');
        print('Proceeding with navigation anyway...');
        
        // Show info dialog
        _showProfileDelayDialog();
        return;
      }

      // 6. Navigate to home screen
      print('6. Navigating to home screen...');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Trash2CashHomeUI()),
        (_) => false,
      );
      
      print('=== SIGNUP PROCESS COMPLETED ===');
      
    } catch (e) {
      print('=== SIGNUP ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Full error: $e');
      
      String errorMessage = e.toString();
      
      // Parse error message
      if (errorMessage.contains('already exists') || 
          errorMessage.contains('duplicate') ||
          errorMessage.contains('already registered')) {
        _showAccountExistsDialog();
      } else if (errorMessage.contains('400') || errorMessage.contains('Bad Request')) {
        if (errorMessage.contains('email') || errorMessage.contains('phone')) {
          _showError('Invalid email or phone format.');
        } else if (errorMessage.contains('password')) {
          _showError('Password requirements not met.');
        } else {
          _showError('Invalid registration data. Please check your information.');
        }
      } else if (errorMessage.contains('500') || errorMessage.contains('Server Error')) {
        _showError('Server error. Please try again later.');
      } else if (errorMessage.contains('network') || errorMessage.contains('Network')) {
        _showError('Network error. Please check your connection.');
      } else if (errorMessage.contains('422') || errorMessage.contains('Unprocessable')) {
        _showError('Unable to process registration. Please check all fields.');
      } else if (errorMessage.contains('Authentication failed')) {
        _showError('Registration successful but login failed. Please try logging in.');
      } else {
        _showError('Registration failed: ${errorMessage.split('\n').first}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAccountExistsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Account Already Exists'),
        content: const Text(
            'An account with this email or phone already exists. Would you like to sign in instead?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
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

  void _showProfileDelayDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Account Created Successfully'),
        content: const Text(
          'Your account has been created! '
          'Profile setup may take a moment. '
          'Please log in to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (_) => false,
              );
            },
            child: const Text('Go to Login'),
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
        duration: const Duration(seconds: 4),
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
              Container(
                width: double.infinity,
                height: 228,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/image1.png'), 
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40), 
                      bottomRight: Radius.circular(40)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome!",
                style: TextStyle(
                  fontFamily: 'Afacad', 
                  fontSize: 42, 
                  fontWeight: FontWeight.w700
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Create your account",
                style: TextStyle(
                  fontFamily: 'Afacad', 
                  fontSize: 28, 
                  fontWeight: FontWeight.w600, 
                  color: Colors.black54
                ),
              ),
              const SizedBox(height: 30),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InputFormat.firstName(
                          controller: _firstNameController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter first name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        InputFormat.lastName(
                          controller: _lastNameController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter last name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        InputFormat.email(
                          controller: _emailController, 
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        InputFormat.phone(
                          controller: _phoneController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter phone number';
                            }
                            // Optional: Add phone number validation
                            if (value.trim().length < 10) {
                              return 'Please enter a valid phone number (at least 10 digits)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),
                        InputFormat.password(
                          controller: _passwordController,
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            // Optional: Add stronger password validation
                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return 'Password must contain at least one uppercase letter';
                            }
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return 'Password must contain at least one number';
                            }
                            return null;
                          },
                          obscureText: _obscurePassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        InputFormat.confirmPassword(
                          controller: _confirmPasswordController,
                          originalPassword: _passwordController.text,
                          label: 'Confirm Password',
                          isRequired: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please confirm password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          obscureText: _obscureConfirmPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 25),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              onChanged: _isLoading
                                  ? null
                                  : (v) => setState(() => _termsAccepted = v ?? false),
                              activeColor: const Color(0xFF00357A),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () => setState(() => _termsAccepted = !_termsAccepted),
                                child: Text(
                                  'By creating an account, you agree to our Terms of Service and Privacy Policy',
                                  style: TextStyle(
                                    fontFamily: 'Afacad', 
                                    fontSize: 13, 
                                    color: Colors.grey[700]
                                  ),
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
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            ),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        color: Color(0xFF00357A), 
                        fontWeight: FontWeight.w600
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
}