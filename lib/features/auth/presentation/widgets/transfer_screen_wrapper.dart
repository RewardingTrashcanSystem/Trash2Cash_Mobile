// transfer_screen_wrapper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/features/auth/presentation/provider/profile_provider.dart';
import 'package:trash2cash/features/transactions/presentation/provider/transfer_provider.dart';
import 'package:trash2cash/features/transactions/presentation/screen/transfer_screen.dart';

class TransferScreenWrapper extends StatelessWidget {
  const TransferScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the providers from the parent context
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final transferProvider = Provider.of<TransferProvider>(context, listen: false);

    return MultiProvider(
      providers: [
        // Re-provide the ProfileProvider with the existing instance
        ChangeNotifierProvider<ProfileProvider>.value(
          value: profileProvider,
        ),
        // Re-provide the TransferProvider with the existing instance
        ChangeNotifierProvider<TransferProvider>.value(
          value: transferProvider,
        ),
      ],
      child: const TransferScreen(),
    );
  }
}