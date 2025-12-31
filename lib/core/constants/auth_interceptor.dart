import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trash2cash/core/storage/shared_prefs.dart';
import 'package:trash2cash/core/storage/token_refresh_service.dart';

class AuthInterceptor extends Interceptor {
  final SharedPreferences prefs;
  final TokenRefreshService refreshService;
  bool _isRefreshing = false;

  AuthInterceptor({required this.prefs, required this.refreshService});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if this is a refresh request - DO NOT add Authorization header
    final isRefreshRequest = options.path.contains('/token/refresh/');
    
    // Also check if it's a login or register request
    final isAuthRequest = options.path.contains('/login/') || 
                         options.path.contains('/register/') ||
                         options.path.contains('/check-registration/');
    
    // Only add token for non-auth requests
    if (!isRefreshRequest && !isAuthRequest) {
      final token = SharedPrefs.getToken();
      
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if this error is from a refresh request
    final isRefreshRequest = err.requestOptions.path.contains('/token/refresh/');
    
    // If it's a refresh request that failed, clear auth and reject
    if (isRefreshRequest && err.response?.statusCode == 401) {
      print('AuthInterceptor: Refresh token failed - logging out');
      await SharedPrefs.clearAuthData();
      
      // Navigate to login screen if needed
      // You might want to add navigation logic here
      return handler.reject(err);
    }
    
    // Handle 401 for non-refresh requests
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      
      print('AuthInterceptor: 401 Unauthorized - Attempting token refresh');
      _isRefreshing = true;
      
      try {
        // Try to refresh token
        final refreshed = await refreshService.refreshToken();
        
        if (refreshed) {
          print('AuthInterceptor: Token refreshed successfully');
          
          // Get new token
          final token = SharedPrefs.getToken();
          
          if (token != null && token.isNotEmpty) {
            // Update the original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            
            // Clone the request options to avoid modification issues
            final requestOptions = Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
              sendTimeout: err.requestOptions.sendTimeout,
              receiveTimeout: err.requestOptions.receiveTimeout,
              extra: err.requestOptions.extra,
              contentType: err.requestOptions.contentType,
              responseType: err.requestOptions.responseType,
              validateStatus: err.requestOptions.validateStatus,
              receiveDataWhenStatusError: err.requestOptions.receiveDataWhenStatusError,
              followRedirects: err.requestOptions.followRedirects,
              maxRedirects: err.requestOptions.maxRedirects,
              requestEncoder: err.requestOptions.requestEncoder,
              responseDecoder: err.requestOptions.responseDecoder,
              listFormat: err.requestOptions.listFormat,
            );
            
            // Create a new Dio instance without interceptors for the retry
            final dio = Dio(BaseOptions(
              baseUrl: err.requestOptions.baseUrl,
              headers: err.requestOptions.headers,
            ));
            
            // Retry the original request with the new token
            final response = await dio.request(
              err.requestOptions.path,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
              options: requestOptions,
            );
            
            _isRefreshing = false;
            return handler.resolve(response);
          }
        }
      } catch (e) {
        print('AuthInterceptor: Token refresh failed: $e');
      } finally {
        _isRefreshing = false;
      }
      
      // If refresh failed, clear auth data
      print('AuthInterceptor: Clearing auth data due to 401');
      await SharedPrefs.clearAuthData();
      
      // You might want to navigate to login here
    }
    
    return handler.reject(err);
  }
}