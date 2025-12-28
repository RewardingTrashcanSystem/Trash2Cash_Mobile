import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:trash2cash/core/constants/dio_client.dart';
import 'package:trash2cash/features/auth/data/services/auth_service.dart';
import 'package:trash2cash/features/auth/presentation/provider/auth_provider.dart';
import 'package:trash2cash/features/auth/presentation/screen/splash_screen.dart';
import 'core/network/network_info.dart';
import 'core/storage/shared_prefs.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize shared preferences
  await SharedPrefs.init();
  
  // Get shared preferences instance
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize connectivity
  final connectivity = Connectivity();
  
  runApp(
    MultiProvider(
      providers: [
        // Network Info
        Provider<NetworkInfo>(
          create: (_) => NetworkInfo(connectivity),
        ),
        
        // Dio Client
        Provider<DioClient>(
          create: (_) => DioClient(prefs),
        ),
        
        // Auth Service
        Provider<AuthService>(
          create: (context) => AuthService(
            dioClient: context.read<DioClient>(),
            networkInfo: context.read<NetworkInfo>(),
          ),
        ),
        
        // Auth Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
          ),
          lazy: false,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trash2Cash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}