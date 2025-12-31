import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/core/helper/image_helper.dart';
import 'package:trash2cash/features/auth/data/model/user_model.dart';
import 'package:trash2cash/features/auth/presentation/provider/profile_provider.dart';
import 'package:trash2cash/features/home/presentation/widget/qr_sacnner_page.dart';
import 'package:trash2cash/features/home/presentation/widget/side_bar.dart';
import 'package:trash2cash/features/transactions/data/model/history_model.dart';
import 'package:trash2cash/features/transactions/presentation/screen/history_screen.dart';
import 'package:trash2cash/features/transactions/presentation/screen/transfer_screen.dart';
import 'package:trash2cash/features/transactions/presentation/provider/histrory_provider.dart';

class Trash2CashHomeUI extends StatefulWidget {
  const Trash2CashHomeUI({super.key});

  @override
  State<Trash2CashHomeUI> createState() => _Trash2CashHomeUIState();
}

class _Trash2CashHomeUIState extends State<Trash2CashHomeUI> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProfile();
    });
  }

  Future<void> _initializeProfile() async {
    if (_isInitialized) return;
    
    final context = this.context;
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    
    print('HomeScreen: Initializing profile and recent activities...');
    await profileProvider.fetchProfile();
    
    // Fetch recent history for activities
    await historyProvider.fetchHistory();
    
    _isInitialized = true;
    
    if (profileProvider.user == null) {
      print('HomeScreen: Profile is null after initialization!');
    } else {
      print('HomeScreen: Profile loaded successfully');
      print('HomeScreen: Recent activities count: ${historyProvider.history.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(),
      body: Consumer2<ProfileProvider, HistoryProvider>(
        builder: (context, profileProvider, historyProvider, child) {
          // Show loading on initial load
          if (profileProvider.isLoading && profileProvider.user == null && !_isInitialized) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          final user = profileProvider.user;

          // If no user after loading, show error/retry
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Unable to load profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    profileProvider.error ?? 'Please try again',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      profileProvider.fetchProfile();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          final String userName = user.fullName;
          final String ecoLevel = user.ecoLevel;
          final int totalPoints = user.totalPoints;
          final String userEmail = user.email;

          // Get recent activities (last 3 transactions)
          final recentActivities = historyProvider.history.take(3).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await profileProvider.fetchProfile();
              await historyProvider.refreshHistory();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: Colors.green,
            backgroundColor: Colors.green.shade50,
            strokeWidth: 3.0,
            displacement: 40,
            edgeOffset: 0,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            child: SafeArea(
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 20),
                  // HEADER
                  Row(
                    children: [
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
                            return const Icon(Icons.recycling, color: Colors.white, size: 32);
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
                      Builder(
                        builder: (context) {
                          return IconButton(
                            icon: Icon(Icons.menu, size: 30, color: Colors.green.shade800),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // USER CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.green.shade50, Colors.blue.shade50]),
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
                            ClipOval(
                              child: Container(
                                width: 64,
                                height: 64,
                                color: Colors.green.shade600,
                                child: user.image != null && user.image!.isNotEmpty
                                    ? ImageHelper.profileImage(
                                        imagePath: user.image,
                                        size: 64,
                                        isCircle: true,
                                        backgroundColor: Colors.green.shade600,
                                        iconColor: Colors.white,
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                              ),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.eco, size: 16, color: Colors.green),
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

                        // POINTS CARD
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Colors.green.shade100, Colors.white]),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade300, width: 2),
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
                                    style: TextStyle(fontSize: 16, color: Colors.green.shade700),
                                  ),
                                ],
                              ),
                              const Icon(Icons.trending_up, size: 36, color: Colors.green),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),

                        /// REWARDS TITLE
                        Row(
                          children: [
                            Text(
                              "Available Rewards",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                            ),
                            const Spacer(),
                            Text(
                              "${(totalPoints / 100).floor()} available",
                              style: TextStyle(color: Colors.green.shade700),
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
                            _RewardCard(title: "Voucher", icon: Icons.card_giftcard, colors: [Color(0xFFFF9A00), Color(0xFFFF6B00)], points: 100),
                            _RewardCard(title: "Discount", icon: Icons.local_offer, colors: [Color(0xFF00B4DB), Color(0xFF0083B0)], points: 150),
                            _RewardCard(title: "Coupon", icon: Icons.confirmation_number, colors: [Color(0xFF9D50BB), Color(0xFF6E48AA)], points: 200),
                            _RewardCard(title: "Gift", icon: Icons.card_membership, colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)], points: 5),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // SCAN BUTTON
                        _buildScanButton(context),

                        const SizedBox(height: 30),

                        // RECENT ACTIVITY
                        if (recentActivities.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Recent Activity",
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
                                    },
                                    child: Text("View All", style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              ...recentActivities.map((activity) => _buildActivityItem(activity)).toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(HistoryModel activity) {
    // Get icon based on action type
    IconData icon = _getActivityIcon(activity.action);
    
    // Get description
    String description = activity.description;
    
    // Format date to show only time if today, otherwise show date
    String timeText = _formatActivityTime(activity.formattedTime, activity.formattedDate);
    
    // Get points prefix and color
    String pointsPrefix = _getPointsPrefix(activity.action);
    Color pointsColor = _getPointsColor(activity.action);
    
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
              color: _getIconBackgroundColor(activity.action),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _getIconColor(activity.action)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getActivityTitle(activity.action),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$pointsPrefix${activity.points}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: pointsColor,
                  fontSize: 16,
                ),
              ),
              Text(
                'points',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods for activity items
  IconData _getActivityIcon(String action) {
    switch (action) {
      case 'transfer_out':
        return Icons.send;
      case 'transfer_in':
        return Icons.download;
      case 'scan':
        return Icons.qr_code_scanner;
      default:
        return Icons.recycling;
    }
  }

  Color _getIconBackgroundColor(String action) {
    switch (action) {
      case 'transfer_out':
        return Colors.red.shade50;
      case 'transfer_in':
        return Colors.green.shade50;
      case 'scan':
        return Colors.blue.shade50;
      default:
        return Colors.green.shade50;
    }
  }

  Color _getIconColor(String action) {
    switch (action) {
      case 'transfer_out':
        return Colors.red;
      case 'transfer_in':
        return Colors.green;
      case 'scan':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _getActivityTitle(String action) {
    switch (action) {
      case 'transfer_out':
        return 'Points Sent';
      case 'transfer_in':
        return 'Points Received';
      case 'scan':
        return 'QR Scan';
      default:
        return 'Transaction';
    }
  }

  String _formatActivityTime(String time, String date) {
    // Check if date is today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activityDate = _parseDate(date);
    
    if (activityDate != null && activityDate.isAtSameMomentAs(today)) {
      return 'Today, $time';
    } else if (activityDate != null) {
      return date;
    }
    return time;
  }

  DateTime? _parseDate(String dateString) {
    try {
      // Try to parse date like "Dec 31, 2025"
      final parts = dateString.split(' ');
      if (parts.length >= 3) {
        final month = _getMonthNumber(parts[0]);
        final day = parts[1].replaceAll(',', '');
        final year = parts[2];
        return DateTime(int.parse(year), month, int.parse(day));
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return null;
  }

  int _getMonthNumber(String month) {
    switch (month.toLowerCase()) {
      case 'jan': return 1;
      case 'feb': return 2;
      case 'mar': return 3;
      case 'apr': return 4;
      case 'may': return 5;
      case 'jun': return 6;
      case 'jul': return 7;
      case 'aug': return 8;
      case 'sep': return 9;
      case 'oct': return 10;
      case 'nov': return 11;
      case 'dec': return 12;
      default: return 1;
    }
  }

  String _getPointsPrefix(String action) {
    switch (action) {
      case 'transfer_out':
        return '-';
      case 'transfer_in':
      case 'scan':
        return '+';
      default:
        return '';
    }
  }

  Color _getPointsColor(String action) {
    switch (action) {
      case 'transfer_out':
        return Colors.red;
      case 'transfer_in':
      case 'scan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScannerScreen())),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green.shade500, Colors.green.shade700]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.green.shade800.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text("Scan QR to Recycle", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// REWARD CARD
class _RewardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final int points;

  const _RewardCard({required this.title, required this.icon, required this.colors, required this.points});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redeem $title for $points points'), backgroundColor: Colors.green),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: colors[0].withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 5),
            Text("$points pts", style: const TextStyle(fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 5),
            const Text("Tap to Redeem", style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}