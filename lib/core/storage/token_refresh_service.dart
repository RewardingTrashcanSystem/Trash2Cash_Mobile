import 'package:dio/dio.dart';
import 'package:trash2cash/core/storage/shared_prefs.dart';

class TokenRefreshService {
  Dio? _dio;

  // Set Dio instance after it's created
  void setDio(Dio dio) {
    _dio = dio;
  }

  Future<bool> refreshToken() async {
    try {
      // Get refresh token
      final refreshToken = SharedPrefs.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        print('No refresh token available');
        return false;
      }

      // Check if Dio is initialized
      if (_dio == null) {
        print('Dio not initialized for token refresh');
        return false;
      }

      print('Attempting token refresh...');
      
      // Make refresh request WITHOUT Authorization header
      final response = await _dio!.post(
        '/api/auth/token/refresh/',
        data: {'refresh': refreshToken},
        // Important: Don't send Authorization header for refresh
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            // NO Authorization header here!
          },
        ),
      );
      
      print('Refresh token response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        print('Refresh token successful: $data');
        
        // Save new tokens
        if (data['access'] != null) {
          await SharedPrefs.saveToken(data['access']);
          print('New access token saved');
        }
        
        // If backend returns new refresh token, save it too
        if (data['refresh'] != null) {
          await SharedPrefs.saveRefreshToken(data['refresh']);
          print('New refresh token saved');
        }
        
        return true;
      } else {
        print('Token refresh failed with status: ${response.statusCode}');
        print('Response: ${response.data}');
      }
    } on DioException catch (e) {
      print('Token refresh Dio error: $e');
      print('Response data: ${e.response?.data}');
      print('Response status: ${e.response?.statusCode}');
    } catch (e) {
      print('Token refresh error: $e');
    }
    return false;
  }

  static bool shouldRefreshToken() {
    return SharedPrefs.getToken() != null && 
           SharedPrefs.getRefreshToken() != null;
  }
}