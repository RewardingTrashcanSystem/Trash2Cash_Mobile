// features/transfer/data/services/transfer_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:trash2cash/core/constants/api_constants.dart';
import 'package:trash2cash/core/constants/api_exceptions.dart';
import 'package:trash2cash/core/constants/dio_client.dart';
import 'package:trash2cash/core/network/network_info.dart';

class TransferService {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  TransferService({
    required this.dioClient,
    required this.networkInfo,
  });

  // Check if receiver exists
  Future<Map<String, dynamic>> checkReceiver({
    required String emailOrPhone,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw ApiException.networkError('No internet connection');
      }

      print('Checking receiver: $emailOrPhone');
      
      final response = await dioClient.post(
        ApiConstants.checkReceiver,
        data: {
          'email_or_phone': emailOrPhone.trim(),
        },
      );

      print('Check receiver response: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      // Handle Django response
      if (response.statusCode == 200 || response.statusCode == 400) {
        final data = response.data;
        
        // Ensure we return a proper Map
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          // If it's not a Map, wrap it
          return {
            'success': false,
            'message': 'Invalid response format from server',
            'exists': false,
          };
        }
      } else {
        throw ApiException.serverError(
          response.statusCode ?? 500,
          'Failed to check receiver',
        );
      }
    } on DioException catch (e) {
      print('Dio error in checkReceiver: $e');
      if (e.response != null) {
        print('Dio error response: ${e.response!.data}');
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      print('Error in checkReceiver: $e');
      throw ApiException(
        message: 'Failed to check receiver: ${e.toString()}',
        errorCode: 'CHECK_RECEIVER_ERROR',
      );
    }
  }

  // Transfer points
  Future<Map<String, dynamic>> transferPoints({
    required String receiverEmailOrPhone,
    required int points,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw ApiException.networkError('No internet connection');
      }

      print('Transferring $points points to $receiverEmailOrPhone');
      
      final response = await dioClient.post(
        ApiConstants.transferPoints,
        data: {
          'receiver_email_or_phone': receiverEmailOrPhone.trim(),
          'points': points,
        },
      );

      print('Transfer response: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      // Handle Django response
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {
            'success': false,
            'message': 'Invalid response format',
          };
        }
      } else if (response.statusCode == 400) {
        // Handle validation errors
        final data = response.data;
        String message = 'Transfer failed';
        
        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            message = data['message'].toString();
          } else if (data['errors'] != null) {
            // Handle Django serializer errors
            if (data['errors'] is Map) {
              final errors = Map<String, dynamic>.from(data['errors']);
              message = errors.entries.map((e) => '${e.key}: ${e.value}').join(', ');
            } else {
              message = data['errors'].toString();
            }
          }
        }
        
        return {
          'success': false,
          'message': message,
        };
      } else {
        throw ApiException.serverError(
          response.statusCode ?? 500,
          'Transfer failed',
        );
      }
    } on DioException catch (e) {
      print('Dio error in transferPoints: $e');
      if (e.response != null) {
        print('Dio error response: ${e.response!.data}');
        
        // Handle Django error responses
        if (e.response!.statusCode == 400) {
          final data = e.response!.data;
          String message = 'Transfer failed';
          
          if (data is Map<String, dynamic>) {
            if (data['message'] != null) {
              message = data['message'].toString();
            } else if (data['errors'] != null) {
              message = data['errors'].toString();
            }
          }
          
          return {
            'success': false,
            'message': message,
          };
        }
      }
      throw ApiException.fromDioError(e);
    } catch (e) {
      print('Error in transferPoints: $e');
      throw ApiException(
        message: 'Transfer failed: ${e.toString()}',
        errorCode: 'TRANSFER_ERROR',
      );
    }
  }
}