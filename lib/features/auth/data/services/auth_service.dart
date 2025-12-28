import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:trash2cash/core/constants/api_constants.dart';
import 'package:trash2cash/core/constants/api_exceptions.dart';
import 'package:trash2cash/core/constants/dio_client.dart';
import 'package:trash2cash/core/network/network_info.dart';
import 'package:trash2cash/core/storage/shared_prefs.dart';
import 'package:trash2cash/features/auth/data/model/user_model.dart';


class AuthService {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  AuthService({
    required this.dioClient,
    required this.networkInfo,
  });

  /// Check Registration
  Future<Map<String, dynamic>> checkRegistration({
    required String email,
    required String phoneNumber,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw ApiException.networkError('No internet connection');
      }

      final response = await dioClient.post(
        ApiConstants.checkRegistration,
        data: {
          'email': email.trim(),
          'phone_number': phoneNumber.trim(),
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
          'message': 'Available for registration',
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': response.data['message'] ?? 'User already exists',
          'suggestLogin': response.data['suggest_login'] ?? false,
        };
      } else {
        throw ApiException.serverError(
          response.statusCode ?? 500,
          response.data['message'] ?? 'Registration check failed',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Failed to check registration: ${e.toString()}',
        errorCode: 'CHECK_REGISTRATION_ERROR',
      );
    }
  }

  /// Register User
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw ApiException.networkError('No internet connection');
      }

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
        final userJson = response.data['user'];
        
        await SharedPrefs.saveToken(tokens['access']);
        
        final user = UserModel.fromJson(userJson);
        await SharedPrefs.saveUserData(json.encode(user.toJson()));
        await SharedPrefs.setLoggedIn(true);

        return {
          'success': true,
          'message': 'Registration successful',
          'user': user,
        };
      } else if (response.statusCode == 400) {
        throw ApiException.validationError(
          response.data is Map<String, dynamic> 
            ? response.data 
            : {'error': [response.data.toString()]},
        );
      } else {
        throw ApiException.serverError(
          response.statusCode ?? 500,
          response.data['message'] ?? 'Registration failed',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Registration failed: ${e.toString()}',
        errorCode: 'REGISTRATION_ERROR',
      );
    }
  }

  /// Login User
  Future<Map<String, dynamic>> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
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
        final userJson = response.data['user'];
        
        await SharedPrefs.saveToken(tokens['access']);
        
        final user = UserModel.fromJson(userJson);
        await SharedPrefs.saveUserData(json.encode(user.toJson()));
        await SharedPrefs.setLoggedIn(true);

        return {
          'success': true,
          'message': 'Login successful',
          'user': user,
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Invalid credentials',
        };
      } else {
        throw ApiException.serverError(
          response.statusCode ?? 500,
          response.data['message'] ?? 'Login failed',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Login failed: ${e.toString()}',
        errorCode: 'LOGIN_ERROR',
      );
    }
  }

  /// Get User Profile
  Future<UserModel> getProfile() async {
    try {
      if (!await networkInfo.isConnected) {
        throw ApiException.networkError('No internet connection');
      }

      final response = await dioClient.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        await SharedPrefs.saveUserData(json.encode(user.toJson()));
        return user;
      } else {
        throw ApiException.serverError(
          response.statusCode ?? 500,
          response.data['message'] ?? 'Failed to load profile',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Failed to load profile: ${e.toString()}',
        errorCode: 'GET_PROFILE_ERROR',
      );
    }
  }

  /// Update Profile (Only first name, last name, and image)
Future<UserModel> updateProfile({
  String? firstName,
  String? lastName,
  File? imageFile,
}) async {
  try {
    if (!await networkInfo.isConnected) {
      throw ApiException.networkError('No internet connection');
    }

    // Create form data for multipart request
    final formData = FormData();

    // Add only editable fields
    if (firstName != null) {
      formData.fields.add(MapEntry('first_name', firstName.trim()));
    }
    if (lastName != null) {
      formData.fields.add(MapEntry('last_name', lastName.trim()));
    }

    // Add image if provided
    if (imageFile != null) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      ));
    }

    // Send multipart request
    final response = await dioClient.dio.put(
      ApiConstants.profile,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode == 200) {
      final user = UserModel.fromJson(response.data['user']);
      await SharedPrefs.saveUserData(json.encode(user.toJson()));
      return user;
    } else if (response.statusCode == 400) {
      throw ApiException.validationError(
        response.data is Map<String, dynamic> 
          ? response.data 
          : {'error': [response.data.toString()]},
      );
    } else {
      throw ApiException.serverError(
        response.statusCode ?? 500,
        response.data['message'] ?? 'Failed to update profile',
      );
    }
  } on DioException catch (e) {
    throw ApiException.fromDioError(e);
  } catch (e) {
    throw ApiException(
      message: 'Failed to update profile: ${e.toString()}',
      errorCode: 'UPDATE_PROFILE_ERROR',
    );
  }
}

  /// Logout
  Future<void> logout() async {
    try {
      if (await networkInfo.isConnected) {
        // Try to call logout API
        await dioClient.post(ApiConstants.logout).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            return Response(
              requestOptions: RequestOptions(path: ApiConstants.logout),
              statusCode: 200,
            );
          },
        );
      }
    } catch (e) {
      // Ignore API errors, always clear local data
      print('Logout API error (ignored): $e');
    } finally {
      // Always clear local auth data
      await SharedPrefs.clearAuthData();
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    final hasToken = SharedPrefs.getToken() != null;
    final hasUserData = SharedPrefs.getUserData() != null;
    final isLoggedIn = SharedPrefs.isLoggedIn();
    
    return hasToken && hasUserData && isLoggedIn;
  }
}