import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/features/auth/presentation/provider/auth_provider.dart';
import 'package:trash2cash/features/home/presentation/screen/home_screen.dart';
import 'package:trash2cash/features/onboarding/presentation/Screen/onboarding_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Check if user is authenticated
    if (authProvider.isAuthenticated) {
      // Navigate to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Trash2CashHomeUI()),
      );
    } else {
      // Navigate to onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnbordingPage()),
      );
    }
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo - Using your logo.png
              Image.asset(
                'assets/images/logo.png',
                height: 150,
                width: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              
              // App Name
              Text(
                'Trash2Cash',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00357A),
                  fontFamily: 'Afacad',
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Loading Indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00357A)),
                strokeWidth: 2,
              ),
              
              const SizedBox(height: 20),
              
              // Loading Text
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Afacad',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}