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
    final errorMessages = errors.entries
        .map((e) => '${e.key}: ${e.value.join(', ')}')
        .join('\n');
    return ApiException(
      message: errorMessages,
      statusCode: 400,
      errorCode: 'VALIDATION_ERROR',
    );
  }

  factory ApiException.fromDioError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiException.timeoutError();
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;
          
          if (statusCode == 401) {
            return ApiException.unauthorized(
              data?['message'] ?? 'Unauthorized access. Please login again.',
            );
          } else if (statusCode == 400) {
            if (data is Map<String, dynamic>) {
              return ApiException.validationError(data);
            } else {
              return ApiException(
                message: data?.toString() ?? 'Bad request',
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
              data?['message'] ?? 'Server error occurred.',
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
}