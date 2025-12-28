import 'package:flutter/material.dart';
import 'package:trash2cash/features/auth/presentation/screen/login_screen.dart';
import 'package:trash2cash/features/auth/presentation/screen/sign_up.dart';

class OnbordingPage extends StatelessWidget {
  const OnbordingPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient overlay
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/image.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top spacing - responsive
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                
                // Logo with shadow
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.contain,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 25),
                
                // App name with gradient
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: [
                        Color(0xFF75C7C7), // Your light blue
                        Color(0xFF00357A), // Your dark blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    "Trash2Cash",
                    style: TextStyle(
                      fontFamily: 'Afacad',
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                
                SizedBox(height: 8),
                
                // Tagline
                Text(
                  "Toss Trash, Earn Cash",
                  style: TextStyle(
                    fontFamily: 'Afacad',
                    fontSize: 22,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                SizedBox(height: 6),
                
                // Call to action
                Text(
                  "Start Your Green Journey Today",
                  style: TextStyle(
                    fontFamily: 'Afacad',
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                // Spacer to push buttons to bottom
                Spacer(),
                
                // Action buttons section
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Get Started",
                        style: TextStyle(
                          fontFamily: 'Afacad',
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      
                      SizedBox(height: 25),
                      
                      // Sign Up Button with icon
                      Container(
                        width: double.infinity,
                        child: Material(
                          color: Color(0xFF00357A),
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              print('Sign Up tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUp()),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_add_alt_1,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontFamily: 'Afacad',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Login Button with icon
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF75C7C7),
                            width: 2,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              print('Login tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.login,
                                    color: Color(0xFF75C7C7),
                                    size: 22,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Login to Account",
                                    style: TextStyle(
                                      fontFamily: 'Afacad',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF75C7C7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 25),
                      // Future Plan
                      
                      // // Or continue with text
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: Divider(
                      //         color: Colors.white.withOpacity(0.3),
                      //         thickness: 1,
                      //       ),
                      //     ),
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(horizontal: 15),
                      //       child: Text(
                      //         "or continue with",
                      //         style: TextStyle(
                      //           fontFamily: 'Afacad',
                      //           fontSize: 14,
                      //           color: Colors.white.withOpacity(0.7),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: Divider(
                      //         color: Colors.white.withOpacity(0.3),
                      //         thickness: 1,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      
                      // SizedBox(height: 20),
                      
                      
                    ],
                  ),
                ),
                
                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper widget for social buttons
  // Widget _buildSocialButton({
  //   required IconData icon,
  //   required Color color,
  //   required Color bgColor,
  //   required VoidCallback onTap,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 50,
  //       height: 50,
  //       decoration: BoxDecoration(
  //         color: bgColor,
  //         shape: BoxShape.circle,
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.2),
  //             blurRadius: 8,
  //             offset: Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Center(
  //         child: Icon(
  //           icon,
  //           color: color,
  //           size: 26,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}