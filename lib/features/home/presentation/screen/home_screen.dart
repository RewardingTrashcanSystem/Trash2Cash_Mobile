import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/core/helper/image_helper.dart';
import 'package:trash2cash/core/helper/qr_scanner_service.dart';
import 'package:trash2cash/features/auth/data/model/user_model.dart';
import 'package:trash2cash/features/auth/presentation/provider/auth_provider.dart';
import 'package:trash2cash/features/home/data/model/recycling_data.dart';
import 'package:trash2cash/features/home/presentation/widget/side_bar.dart';


class Trash2CashHomeUI extends StatelessWidget {
  const Trash2CashHomeUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final user = authProvider.user;
          
          // Use real user data or fallback to dummy
          final String userName = user?.fullName ?? "Guest User";
          final String ecoLevel = user?.ecoLevel ?? "Newbie";
          final int totalPoints = user?.totalPoints ?? 10;
          final String userEmail = user?.email ?? "guest@example.com";

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),

                /// HEADER with Menu
                Row(
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade700],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        height: 40,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.recycling,
                            color: Colors.white,
                            size: 32,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Trash2Cash',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900,
                      ),
                    ),
                    const Spacer(),
                    // Menu button that opens drawer
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: Icon(
                            Icons.menu,
                            size: 30,
                            color: Colors.green.shade800,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// USER CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.blue.shade50],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                      children: [
                        // User Avatar with better fallback handling
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.green.shade600,
                          backgroundImage: _getUserProfileImage(user),
                          child: _getUserAvatarChild(user),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.eco,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      ecoLevel,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                      const SizedBox(height: 30),

                      /// POINTS CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade100, Colors.white],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green.shade300,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$totalPoints Pts",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                Text(
                                  "Total Points",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.trending_up,
                              size: 36,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      /// REWARDS TITLE
                      Row(
                        children: [
                          Text(
                            "Available Rewards",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "${(totalPoints / 100).floor()} available",
                            style: TextStyle(
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// REWARDS GRID
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 0.85,
                        children: const [
                          _RewardCard(
                            title: "Voucher",
                            icon: Icons.card_giftcard,
                            colors: [Color(0xFFFF9A00), Color(0xFFFF6B00)],
                            points: 100,
                          ),
                          _RewardCard(
                            title: "Discount",
                            icon: Icons.local_offer,
                            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                            points: 150,
                          ),
                          _RewardCard(
                            title: "Coupon",
                            icon: Icons.confirmation_number,
                            colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)],
                            points: 200,
                          ),
                          _RewardCard(
                            title: "Gift",
                            icon: Icons.card_membership,
                            colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                            points: 250,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// SCAN BUTTON - UPDATED WITH QR SCANNER
                      GestureDetector(
                        onTap: () async {
                          final qrService = QRScannerService();
                          
                          await qrService.openQRScanner(
                            context: context,
                            onScanSuccess: (recyclingData) {
                              // Show confirmation dialog
                              qrService.showRecyclingConfirmation(
                                context: context,
                                recyclingData: recyclingData,
                                onConfirm: () {
                                  // Add points to user
                                  // _addRecyclingPoints(context, recyclingData);
                                },
                                onCancel: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Recycling cancelled')),
                                  );
                                },
                              );
                            },
                            onScanCancel: () {
                              // User cancelled from QR scanner
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('QR scanning cancelled')),
                              );
                            },
                            onError: (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          );
                      },
                      child: Container(
                        height: 65,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade500, Colors.green.shade700],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.shade800.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
                            SizedBox(width: 12),
                            Text(
                              "Scan QR to Recycle",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                      const SizedBox(height: 30),

                      /// RECENT ACTIVITY
                      if (totalPoints > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Recent Activity",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildActivityItem("Plastic Bottles", 50, Icons.recycling),
                            _buildActivityItem("Glass", 30, Icons.recycling),
                            _buildActivityItem("Paper", 20, Icons.recycling),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(String item, int points, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Text(
                  "Recycled today",
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "+$points pts",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  ImageProvider? _getUserProfileImage(UserModel? user) {
    if (user?.image != null && user!.image!.isNotEmpty) {
      final fullUrl = ImageHelper.getFullImageUrl(user.image!);
      if (fullUrl.isNotEmpty) {
        return NetworkImage(fullUrl);
      }
    }
    return null;
  }

  Widget? _getUserAvatarChild(UserModel? user) {
    if (user?.image == null || user!.image!.isEmpty) {
      return const Icon(
        Icons.person,
        size: 32,
        color: Colors.white,
      );
    }
    return null;
  }

  // QR Scanner Methods
  void _showQRScannerDialog(BuildContext context, AuthProvider authProvider) {
    // Since we don't have the QR scanner screen yet, show a dialog to test
    showDialog(
      context: context,
      builder: (context) => _buildTestQRScannerDialog(context, authProvider),
    );
  }

  AlertDialog _buildTestQRScannerDialog(BuildContext context, AuthProvider authProvider) {
    return AlertDialog(
      title: const Text('Test QR Scanner'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select a test QR code to simulate scanning:'),
          const SizedBox(height: 20),
          _buildTestQRButton(
            context,
            authProvider,
            'Plastic',
            '{"materialType": "plastic", "pointsToAdd": 50, "date": "${DateTime.now().toIso8601String()}"}',
          ),
          _buildTestQRButton(
            context,
            authProvider,
            'Metal',
            '{"materialType": "metal", "pointsToAdd": 75, "date": "${DateTime.now().toIso8601String()}"}',
          ),
          _buildTestQRButton(
            context,
            authProvider,
            'Non-Recyclable',
            '{"materialType": "non-recycle", "pointsToAdd": 20, "date": "${DateTime.now().toIso8601String()}"}',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildTestQRButton(BuildContext context, AuthProvider authProvider, String label, String qrCode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context); // Close test dialog
          _processQRCode(context, qrCode, authProvider);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _getColorForMaterial(label),
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(label),
      ),
    );
  }

  Color _getColorForMaterial(String material) {
    switch (material.toLowerCase()) {
      case 'plastic':
        return Colors.blue;
      case 'metal':
        return Colors.grey;
      case 'non-recyclable':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  void _processQRCode(BuildContext context, String qrCode, AuthProvider authProvider) {
    try {
      // Parse QR code
      final recyclingData = RecyclingData.fromQRCode(qrCode);
      
      // Validate material type
      if (!recyclingData.isValidMaterial) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid material type: ${recyclingData.materialType}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => _buildConfirmationDialog(context, recyclingData, authProvider),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error parsing QR code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  AlertDialog _buildConfirmationDialog(BuildContext context, RecyclingData data, AuthProvider authProvider) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.qr_code_scanner, color: Colors.green),
          const SizedBox(width: 10),
          Text('${data.displayName} Detected'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material info
          _buildDialogRow('Material:', '${data.emoji} ${data.displayName}'),
          const SizedBox(height: 10),
          _buildDialogRow('Points to Add:', '${data.pointsToAdd} points'),
          const SizedBox(height: 10),
          _buildDialogRow('Date:', data.date.toLocal().toString().split('.')[0]),
          const SizedBox(height: 20),
          
          // Current points
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Current Points: ${authProvider.user?.totalPoints ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          
          // New total
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_up, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'New Total: ${(authProvider.user?.totalPoints ?? 0) + data.pointsToAdd} points',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // _addPointsToUser(context, data, authProvider);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Add Points'),
        ),
      ],
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

//   void _addPointsToUser(BuildContext context, RecyclingData data, AuthProvider authProvider) {
//     // Show success message
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           '✅ ${data.pointsToAdd} points added for ${data.displayName}!',
//           style: const TextStyle(fontSize: 16),
//         ),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 3),
//       ),
//     );
    
//     // TODO: Call AuthProvider to update points
//     // You need to add this method to your AuthProvider:
//     // authProvider.addPoints(data.pointsToAdd);
    
//     print('Added ${data.pointsToAdd} points for ${data.displayName}');
    
//     // Update UI by refreshing profile
//     authProvider.getProfile();
//   }
}

/// REWARD CARD WIDGET
class _RewardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final int points;

  const _RewardCard({
    required this.title,
    required this.icon,
    required this.colors,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Redeem $title for $points points'),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "$points pts",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Tap to Redeem",
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}