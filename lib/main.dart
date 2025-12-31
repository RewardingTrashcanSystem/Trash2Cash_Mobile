// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/network/network_info.dart';
import 'core/constants/dio_client.dart';
import 'core/storage/shared_prefs.dart';

import 'features/auth/data/services/auth_service.dart';
import 'features/auth/data/services/profile_service.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/auth/presentation/provider/profile_provider.dart';
import 'features/auth/presentation/screen/splash_screen.dart';

import 'features/home/data/services/scan_service.dart';
import 'features/home/presentation/provider/scan_provider.dart';

import 'features/transactions/data/services/transfer_service.dart';
import 'features/transactions/data/services/history_service.dart';
import 'features/transactions/presentation/provider/transfer_provider.dart';
import 'features/transactions/presentation/provider/histrory_provider.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  await SharedPrefs.init();
  
  final prefs = await SharedPreferences.getInstance();
  final connectivity = Connectivity();

  runApp(
    MultiProvider(
      providers: [
        // Core dependencies
        Provider<SharedPreferences>(create: (_) => prefs),
        Provider<Connectivity>(create: (_) => connectivity),
        Provider<NetworkInfo>(
          create: (context) => NetworkInfo(context.read<Connectivity>()),
        ),
        Provider<DioClient>(
          create: (context) => DioClient(context.read<SharedPreferences>()),
        ),

        // Services
        Provider<AuthService>(
          create: (context) => AuthService(
            dioClient: context.read<DioClient>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),
        Provider<ProfileService>(
          create: (context) => ProfileService(
            dioClient: context.read<DioClient>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),
        Provider<TransferService>(
          create: (context) => TransferService(
            dioClient: context.read<DioClient>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),
        Provider<HistoryService>(
          create: (context) => HistoryService(
            dioClient: context.read<DioClient>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),
        Provider<ScanService>(
          create: (context) => ScanService(
            dioClient: context.read<DioClient>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),

        // Providers - Make sure they're created properly
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
          ),
          lazy: false, // Don't lazy load this
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (context) => ProfileProvider(
            context.read<ProfileService>(),
          ),
          lazy: false, // Don't lazy load this
        ),
        ChangeNotifierProvider<TransferProvider>(
          create: (context) => TransferProvider(
            context.read<TransferService>(),
          ),
        ),
        ChangeNotifierProvider<HistoryProvider>(
          create: (context) => HistoryProvider(
            context.read<HistoryService>(),
          ),
        ),
        ChangeNotifierProvider<ScanProvider>(
          create: (context) => ScanProvider(
            context.read<ScanService>(),
          ),
        ),
      ],
      child: MyApp(navigatorKey: navigatorKey),
    ),
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trash2Cash',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}