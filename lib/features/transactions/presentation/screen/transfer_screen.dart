// transfer_screen.dart - COMPLETE FIXED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/features/auth/presentation/provider/profile_provider.dart';
import 'package:trash2cash/features/transactions/presentation/provider/transfer_provider.dart';
import 'package:trash2cash/features/transactions/presentation/screen/history_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _receiverController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Points'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Builder(
      builder: (context) {
        // Use Builder to get the correct context
        return Consumer2<ProfileProvider, TransferProvider>(
          builder: (context, profileProvider, transferProvider, child) {
            final user = profileProvider.user;
            final totalPoints = user?.totalPoints ?? 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPointsCard(totalPoints),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReceiverInput(transferProvider),
                        const SizedBox(height: 12),
                        if (transferProvider.receiverInfo != null)
                          _buildReceiverInfoCard(transferProvider.receiverInfo!),
                        const SizedBox(height: 20),
                        _buildPointsInput(totalPoints),
                        const SizedBox(height: 30),
                        if (transferProvider.errorMessage != null)
                          _buildErrorMessage(transferProvider.errorMessage!),
                        if (transferProvider.successMessage != null)
                          _buildSuccessMessage(transferProvider.successMessage!),
                        const SizedBox(height: 20),
                        _buildTransferButton(transferProvider, profileProvider),
                        const SizedBox(height: 20),
                        _buildInfoCard(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPointsCard(int totalPoints) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Points',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$totalPoints Pts',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          Icon(
            Icons.account_balance_wallet,
            size: 40,
            color: Colors.green.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverInput(TransferProvider transferProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receiver\'s Email or Phone Number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _receiverController,
          decoration: InputDecoration(
            hintText: 'Enter email or phone number',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green.shade600),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: transferProvider.isCheckingReceiver
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _receiverController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _checkReceiver(transferProvider),
                      )
                    : null,
          ),
          onChanged: (value) {
            if (value.isNotEmpty && transferProvider.receiverInfo != null) {
              transferProvider.clearState();
            }
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter email or phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildReceiverInfoCard(Map<String, dynamic> receiverInfo) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receiverInfo['full_name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    receiverInfo['email'] ??
                        receiverInfo['phone_number'] ??
                        '',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.verified, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsInput(int totalPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Points to Transfer',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pointsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Minimum 5 points',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.green.shade600),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter points to transfer';
            }
            final points = int.tryParse(value);
            if (points == null) return 'Please enter a valid number';
            if (points < 5) return 'Minimum transfer is 5 points';
            if (points > totalPoints) {
              return 'You do not have enough points';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferButton(
      TransferProvider transferProvider, ProfileProvider profileProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: transferProvider.isLoading
            ? null
            : () => _transferPoints(transferProvider, profileProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: transferProvider.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Transfer Points',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.blue.shade700,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Transfer Guidelines',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '• Minimum transfer: 5 points\n'
            '• Receiver must be a registered user\n'
            '• Points cannot be transferred back\n'
            '• No transaction fees\n'
            '• Transfer is instant',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkReceiver(TransferProvider transferProvider) async {
  final receiverInfo = _receiverController.text.trim();
  if (receiverInfo.isEmpty) return;

  print('=== CHECKING RECEIVER START ===');
  print('Receiver info: $receiverInfo');

  try {
    final result = await transferProvider.checkReceiver(
        emailOrPhone: receiverInfo);

    print('=== CHECK RECEIVER RESULT ===');
    print('Result type: ${result.runtimeType}');
    print('Result: $result');
    
    // Check what keys are in the result
    if (result is Map) {
      print('Result keys: ${result.keys.toList()}');
      print('Success value: ${result['success']} (type: ${result['success']?.runtimeType})');
      print('Message value: ${result['message']} (type: ${result['message']?.runtimeType})');
    }

    if (result['success'] == false) {
      print('Receiver check failed');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Receiver not found'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      print('Receiver check successful');
    }
  } catch (e, stackTrace) {
    print('=== ERROR IN CHECK RECEIVER ===');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error checking receiver: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
  
  print('=== CHECKING RECEIVER END ===');
}

  Future<void> _transferPoints(
      TransferProvider transferProvider, ProfileProvider profileProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final receiverInfo = _receiverController.text.trim();
    final points = int.parse(_pointsController.text);

    final result = await transferProvider.transferPoints(
      receiverEmailOrPhone: receiverInfo,
      points: points,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      _receiverController.clear();
      _pointsController.clear();

      await profileProvider.fetchProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View History',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}