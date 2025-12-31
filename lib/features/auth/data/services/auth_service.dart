import 'package:trash2cash/core/constants/api_constants.dart';
import 'package:trash2cash/core/constants/api_exceptions.dart';
import 'package:trash2cash/core/constants/dio_client.dart';
import 'package:trash2cash/core/network/network_info.dart';
import 'package:trash2cash/core/storage/shared_prefs.dart';

class AuthService {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  AuthService({
    required this.dioClient,
    required this.networkInfo,
  });

 Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ApiException.networkError('No internet connection');
    }

    final response = await dioClient.post(
      ApiConstants.login,
      data: {
        'email_or_phone': emailOrPhone.trim(),
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final tokens = response.data['tokens'];
      
      // Save both access and refresh tokens
      await SharedPrefs.saveToken(tokens['access']);
      
      // Save refresh token if available
      if (tokens['refresh'] != null) {
        await SharedPrefs.saveRefreshToken(tokens['refresh']);
      }
      
      await SharedPrefs.setLoggedIn(true);
      return;
    }

    throw ApiException.serverError(
      response.statusCode ?? 500,
      'Login failed',
    );
  }

  /// Register — TOKENS ONLY
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ApiException.networkError('No internet connection');
    }
    
    await SharedPrefs.clearAuthData();
    
    final response = await dioClient.post(
      ApiConstants.register,
      data: {
        'email': email.trim(),
        'password': password,
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone_number': phoneNumber.trim(),
      },
    );

    if (response.statusCode == 201) {
      final tokens = response.data['tokens'];
      
      // Save both access and refresh tokens
      await SharedPrefs.saveToken(tokens['access']);
      
      // Save refresh token if available
      if (tokens['refresh'] != null) {
        await SharedPrefs.saveRefreshToken(tokens['refresh']);
      }
      
      await SharedPrefs.setLoggedIn(true);
      return;
    }

    throw ApiException.serverError(
      response.statusCode ?? 500,
      'Registration failed',
    );
  }

  /// ✅ Check Registration Availability
  Future<Map<String, dynamic>> checkRegistration({
    required String email,
    required String phoneNumber,
  }) async {
    if (!await networkInfo.isConnected) {
      throw ApiException.networkError('No internet connection');
    }

    final response = await dioClient.post(
      ApiConstants.checkRegistration, // make sure this endpoint exists in your backend
      data: {
        'email': email.trim(),
        'phone_number': phoneNumber.trim(),
      },
    );

    if (response.statusCode == 200) {
      return response.data; // { success: true/false, suggestLogin: true/false, message: '...' }
    }

    return {'success': false, 'message': 'Failed to check registration'};
  }

  /// Logout
  Future<void> logout() async {
    await SharedPrefs.clearAuthData();
  }
}
