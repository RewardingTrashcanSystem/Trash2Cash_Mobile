import 'package:shared_preferences/shared_preferences.dart';
import 'package:trash2cash/core/constants/api_constants.dart';


class SharedPrefs {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Management
  static Future<void> saveToken(String token) async {
    await _prefs.setString(ApiConstants.tokenKey, token);
  }

  static String? getToken() {
    return _prefs.getString(ApiConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await _prefs.remove(ApiConstants.tokenKey);
  }

  // User Data Management
  static Future<void> saveUserData(String userJson) async {
    await _prefs.setString(ApiConstants.userKey, userJson);
  }

  static String? getUserData() {
    return _prefs.getString(ApiConstants.userKey);
  }

  static Future<void> removeUserData() async {
    await _prefs.remove(ApiConstants.userKey);
  }

  // Login State
  static Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(ApiConstants.isLoggedInKey, value);
  }

  static bool isLoggedIn() {
    return _prefs.getBool(ApiConstants.isLoggedInKey) ?? false;
  }

  // Clear all auth data
  static Future<void> clearAuthData() async {
    await removeToken();
    await removeUserData();
    await setLoggedIn(false);
  }
}