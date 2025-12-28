import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/storage/shared_prefs.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences prefs;

  AuthInterceptor({required this.prefs});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token
    final token = SharedPrefs.getToken();
    
    // Always add token if we have it
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If we get 401, clear token and redirect to login
    if (err.response?.statusCode == 401) {
      await SharedPrefs.clearAuthData();
      
      // You can add navigation to login screen here if needed
      // Example: NavigationService.navigateTo('/login');
    }
    
    return handler.reject(err);
  }
}