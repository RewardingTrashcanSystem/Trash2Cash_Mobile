import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:trash2cash/core/constants/api_exceptions.dart';
import 'package:trash2cash/core/storage/shared_prefs.dart';
import 'package:trash2cash/features/auth/data/model/user_model.dart';
import 'package:trash2cash/features/auth/data/services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService profileService;

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;

  ProfileProvider(this.profileService);

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => SharedPrefs.isLoggedIn();

// In profile_provider.dart - Update fetchProfile method
Future<void> fetchProfile({bool forceRefresh = false}) async {
  print('=== FETCH PROFILE ===');
  print('forceRefresh: $forceRefresh');
  print('isLoggedIn: ${SharedPrefs.isLoggedIn()}');
  
  // Check if we have a token
  final token = SharedPrefs.getToken();
  if (token == null || token.isEmpty) {
    print('No token found, clearing user data');
    _user = null;
    _hasLoaded = false;
    _error = 'Not authenticated';
    notifyListeners();
    return;
  }

  // Skip if already loading
  if (_isLoading) {
    print('Already loading, skipping');
    return;
  }

  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    print('Fetching profile from service...');
    _user = await profileService.getProfile();
    print('Profile fetched successfully');
    print('User email: ${_user?.email}');
    print('User points: ${_user?.totalPoints}');
    _error = null;
    _hasLoaded = true;
  } catch (e) {
    print('Error fetching profile: $e');
    _error = e.toString();
    
    // If it's a 401 error, clear auth data
    if (e is ApiException && e.statusCode == 401) {
      print('401 Unauthorized - Clearing auth data');
      await SharedPrefs.clearAuthData();
      _user = null;
    }
    
    // Reset loaded state on error so we can retry
    _hasLoaded = false;
  } finally {
    _isLoading = false;
    notifyListeners();
    print('Fetch complete - has user: ${_user != null}');
  }
}

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await profileService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        imageFile: imageFile,
      );
      _user = updatedUser;
      return updatedUser;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> ensureProfileLoaded() async {
    if (!_hasLoaded && !_isLoading) {
      await fetchProfile();
    }
  }

  void clearUserData() {
    _user = null;
    _hasLoaded = false;
    _error = null;
    notifyListeners();
  }

  void clearUser() {
    clearUserData(); // Call the same method
  }
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}