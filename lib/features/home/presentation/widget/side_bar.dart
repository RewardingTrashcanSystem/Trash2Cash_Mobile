import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/core/helper/image_helper.dart';
import 'package:trash2cash/features/auth/data/model/user_model.dart';
import 'package:trash2cash/features/auth/presentation/provider/auth_provider.dart';

import 'package:trash2cash/features/auth/presentation/screen/login_screen.dart';
import 'package:trash2cash/features/home/presentation/screen/about_page.dart';
import 'package:trash2cash/features/home/presentation/screen/edit_profile_screen.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 60,),
            // Header with user info - Matching green theme
            _buildUserHeader(user, context),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Home
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Home',
                    color: Colors.green.shade800,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  
                  // Edit Profile
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    color: Colors.green.shade800,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen() ),
                      );
                    },
                  ),
                  
                  // History
                  _buildDrawerItem(
                    icon: Icons.history,
                    title: 'History',
                    color: Colors.green.shade800,
                    onTap: () {
                      // Navigator.pop(context);
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => const HistoryScreen()),
                      // );
                    },
                  ),
                  
                  // Settings
                  // _buildDrawerItem(
                  //   icon: Icons.settings,
                  //   title: 'Settings',
                  //   color: Colors.green.shade800,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     // TODO: Add settings screen
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Settings coming soon!')),
                  //     );
                  //   },
                  // ),
                  
                  // Help & Support
                  // _buildDrawerItem(
                  //   icon: Icons.help,
                  //   title: 'Help & Support',
                  //   color: Colors.green.shade800,
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     // TODO: Add help screen
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       const SnackBar(content: Text('Help center coming soon!')),
                  //     );
                  //   },
                  // ),
                  
                  // About
                  _buildDrawerItem(
                    icon: Icons.info,
                    title: 'About',
                    color: Colors.green.shade800,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                  
                  const Divider(color: Colors.green),
                  
                  // Logout
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildUserHeader(UserModel? user, BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.green.shade400, Colors.green.shade700],
      ),
    ),
    child: Row(
      children: [
        // User Avatar using ImageHelper
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipOval(
            child: ImageHelper.profileImage(
              imagePath: user?.image,
              size: 56, // Slightly smaller to account for border
              isCircle: true,
              backgroundColor: Colors.green,
              iconColor: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(width: 15),
        
        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.fullName ?? 'Guest User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? 'No email',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${user?.totalPoints ?? 0} Points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.eco,
                    color: Colors.lightGreenAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user?.ecoLevel ?? 'Beginner',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Close dialog immediately
            Navigator.pop(dialogContext);
            
            // Perform logout and navigation in a separate microtask
            Future.microtask(() async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final result = await authProvider.logout();
              
              if (result['success'] == true) {
                // Navigate to login
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            });
          },
          child: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
}