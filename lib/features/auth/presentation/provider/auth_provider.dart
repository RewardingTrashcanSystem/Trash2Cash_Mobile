import 'package:flutter/foundation.dart';
import 'package:trash2cash/core/storage/shared_prefs.dart';
import 'package:trash2cash/features/auth/data/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  AuthProvider(this.authService) {
    _isAuthenticated = SharedPrefs.isLoggedIn();
  }

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  Future<void> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await authService.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );
      _isAuthenticated = true;
      await SharedPrefs.setLoggedIn(true);
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// In auth_provider.dart
Future<void> register({
  required String email,
  required String password,
  required String firstName,
  required String lastName,
  required String phoneNumber,
}) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    await authService.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
    );
    
    // CRITICAL: Set authenticated state BEFORE notifyListeners()
    _isAuthenticated = true;
    await SharedPrefs.setLoggedIn(true);
    
    print('AuthProvider: User registered and authenticated');
    
  } catch (e) {
    _error = e.toString();
    _isAuthenticated = false;
    rethrow;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<Map<String, dynamic>> checkRegistration({
    required String email,
    required String phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic> result;

    try {
      result = await authService.checkRegistration(
        email: email,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      result = {
        'success': false,
        'message': e.toString(),
        'suggestLogin': false,
      };
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // auth_provider.dart
Future<void> logout() async {
  _isLoading = true;
  notifyListeners();

  try {
    await authService.logout();
    _isAuthenticated = false;
    await SharedPrefs.clearAuthData();
    
    // Clear profile provider data
    // You need access to ProfileProvider
    // Option 1: Pass ProfileProvider as dependency
    // Option 2: Use a service locator
    // Option 3: Add a method to clear profile
    
    // Since you can't directly access ProfileProvider from AuthProvider,
    // update the logout flow in your UI
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  void clearError() {
    _error = null;
    notifyListeners();
  }
}