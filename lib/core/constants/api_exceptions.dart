import 'package:dio/dio.dart';
import 'dart:io';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => 'ApiException: $message';

  factory ApiException.networkError(String message) {
    return ApiException(
      message: message,
      errorCode: 'NETWORK_ERROR',
    );
  }

  factory ApiException.timeoutError() {
    return ApiException(
      message: 'Request timeout. Please check your internet connection.',
      errorCode: 'TIMEOUT_ERROR',
    );
  }

  factory ApiException.serverError(int statusCode, String message) {
    return ApiException(
      message: message,
      statusCode: statusCode,
      errorCode: 'SERVER_ERROR',
    );
  }

  factory ApiException.unauthorized(String message) {
    return ApiException(
      message: message,
      statusCode: 401,
      errorCode: 'UNAUTHORIZED',
    );
  }

  factory ApiException.validationError(Map<String, dynamic> errors) {
    // Safely extract error messages
    final errorMessages = errors.entries
        .map((e) {
          final key = e.key;
          final value = e.value;
          
          // Handle different types of values
          if (value is List) {
            // Join only if it's a list of strings
            final stringValues = value.whereType<String>().toList();
            if (stringValues.isNotEmpty) {
              return '${e.key}: ${stringValues.join(', ')}';
            } else {
              return '${e.key}: ${value.toString()}';
            }
          } else if (value is String) {
            return '${e.key}: $value';
          } else if (value is bool) {
            return '${e.key}: ${value ? 'true' : 'false'}';
          } else {
            return '${e.key}: ${value?.toString() ?? 'null'}';
          }
        })
        .join('\n');
    
    return ApiException(
      message: errorMessages,
      statusCode: 400,
      errorCode: 'VALIDATION_ERROR',
    );
  }

  factory ApiException.fromDioError(dynamic error) {
    if (error is DioException) {
      print('=== DIO ERROR DEBUG ===');
      print('Error type: ${error.type}');
      print('Error message: ${error.message}');
      print('Response status: ${error.response?.statusCode}');
      print('Response data: ${error.response?.data}');
      print('Response data type: ${error.response?.data?.runtimeType}');
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException.timeoutError();
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          print('Bad response with status: $statusCode');
          print('Response data: $data');
          
          if (statusCode == 401) {
            return ApiException.unauthorized(
              _extractMessage(data) ?? 'Unauthorized access. Please login again.',
            );
          } else if (statusCode == 400) {
            if (data is Map<String, dynamic>) {
              print('Calling validationError with: $data');
              return ApiException.validationError(data);
            } else {
              return ApiException(
                message: _extractMessage(data) ?? 'Bad request',
                statusCode: 400,
                errorCode: 'VALIDATION_ERROR',
              );
            }
          } else if (statusCode == 404) {
            return ApiException.serverError(404, 'Requested resource not found.');
          } else if (statusCode == 500) {
            return ApiException.serverError(500, 'Internal server error.');
          } else {
            return ApiException.serverError(
              statusCode ?? 500,
              _extractMessage(data) ?? 'Server error occurred.',
            );
          }
        
        case DioExceptionType.cancel:
          return ApiException(
            message: 'Request was cancelled',
            errorCode: 'REQUEST_CANCELLED',
          );
        
        case DioExceptionType.connectionError:
          return ApiException.networkError(
            'No internet connection. Please check your network.',
          );
        
        case DioExceptionType.badCertificate:
          return ApiException(
            message: 'SSL certificate error',
            errorCode: 'SSL_ERROR',
          );
        
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return ApiException.networkError('No internet connection.');
          }
          return ApiException(
            message: 'An unexpected error occurred: ${error.error}',
            errorCode: 'UNKNOWN_ERROR',
          );
      }
    }
    
    return ApiException(
      message: 'An unexpected error occurred',
      errorCode: 'UNKNOWN_ERROR',
    );
  }

  // Helper method to safely extract message from response data
  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? 
             data['error']?.toString() ?? 
             data['detail']?.toString();
    } else if (data is String) {
      return data;
    } else if (data != null) {
      return data.toString();
    }
    return null;
  }
}