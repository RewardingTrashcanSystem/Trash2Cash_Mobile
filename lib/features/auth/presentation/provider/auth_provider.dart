import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:trash2cash/core/constants/api_exceptions.dart';
import 'package:trash2cash/core/storage/shared_prefs.dart';
import 'package:trash2cash/features/auth/data/model/user_model.dart';
import 'package:trash2cash/features/auth/data/services/auth_service.dart';


class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  final AuthService authService;

  AuthProvider(this.authService) {
    _loadUserFromStorage();
  }

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && !_user!.isEmpty;

  // Load user from storage
  Future<void> _loadUserFromStorage() async {
    try {
      final userData = SharedPrefs.getUserData();
      if (userData != null) {
        final Map<String, dynamic> json = jsonDecode(userData);
        _user = UserModel.fromJson(json);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user from storage: $e');
    }
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Check Registration
  Future<Map<String, dynamic>> checkRegistration({
    required String email,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await authService.checkRegistration(
        email: email,
        phoneNumber: phoneNumber,
      );
      _setLoading(false);
      return result;
    } on ApiException catch (e) {
      _setLoading(false);
      _setError(e.message);
      return {
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      };
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred');
      return {
        'success': false,
        'message': 'An unexpected error occurred',
      };
    }
  }

  /// Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (result['success'] == true) {
        _user = result['user'];
        notifyListeners();
      }

      _setLoading(false);
      return result;
    } on ApiException catch (e) {
      _setLoading(false);
      _setError(e.message);
      return {
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      };
    } catch (e) {
      _setLoading(false);
      _setError('Registration failed');
      return {
        'success': false,
        'message': 'Registration failed',
      };
    }
  }

  /// Login
  Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await authService.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );

      if (result['success'] == true) {
        _user = result['user'];
        notifyListeners();
      }

      _setLoading(false);
      return result;
    } on ApiException catch (e) {
      _setLoading(false);
      _setError(e.message);
      return {
        'success': false,
        'message': e.message,
        'errorCode': e.errorCode,
      };
    } catch (e) {
      _setLoading(false);
      _setError('Login failed');
      return {
        'success': false,
        'message': 'Login failed',
      };
    }
  }

  /// Get Profile
  Future<Map<String, dynamic>> getProfile() async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await authService.getProfile();
      _user = user;
      notifyListeners();
      
      _setLoading(false);
      return {
        'success': true,
        'user': user,
      };
    } on ApiException catch (e) {
      _setLoading(false);
      _setError(e.message);
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      _setLoading(false);
      _setError('Failed to load profile');
      return {
        'success': false,
        'message': 'Failed to load profile',
      };
    }
  }

  /// Update Profile
  Future<Map<String, dynamic>> updateProfile({
    String? firstName,
    String? lastName,
    File? imageFile,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = await authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        imageFile: imageFile,
      );

      _user = user;
      notifyListeners();
      
      _setLoading(false);
      return {
        'success': true,
        'message': 'Profile updated successfully',
        'user': user,
      };
    } on ApiException catch (e) {
      _setLoading(false);
      _setError(e.message);
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update profile');
      return {
        'success': false,
        'message': 'Failed to update profile',
      };
    }
  }

  /// Update Profile Image Only
  Future<Map<String, dynamic>> updateProfileImage(File imageFile) async {
    return await updateProfile(imageFile: imageFile);
  }

  /// Logout
  Future<Map<String, dynamic>> logout() async {
    _setLoading(true);
    _setError(null);

    try {
      await authService.logout();
      _user = null;
      notifyListeners();
      
      _setLoading(false);
      return {
        'success': true,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      _setLoading(false);
      // Even if API fails, clear local data
      _user = null;
      await SharedPrefs.clearAuthData();
      notifyListeners();
      return {
        'success': true,
        'message': 'Logged out',
      };
    }
  }
}