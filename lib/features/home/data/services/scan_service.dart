// features/scan/data/services/scan_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:trash2cash/core/constants/api_constants.dart';
import 'package:trash2cash/core/constants/api_exceptions.dart';
import 'package:trash2cash/core/constants/dio_client.dart';
import 'package:trash2cash/core/network/network_info.dart';
import 'package:trash2cash/features/home/data/model/recycling_data.dart';


class ScanService {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  ScanService({
    required this.dioClient,
    required this.networkInfo,
  });

  /// Process QR scan and send to backend
  Future<Map<String, dynamic>> processQRScan(RecyclingData recyclingData) async {
    try {
      if (!await networkInfo.isConnected) {
        throw ApiException.networkError('No internet connection');
      }

      // Validate material
      if (!recyclingData.isValidMaterial) {
        return {
          'success': false,
          'message': 'Invalid material type: ${recyclingData.materialType}',
        };
      }

      // Send to backend
      final response = await dioClient.post(
        ApiConstants.qrScan,
        data: recyclingData.toApiJson(),
      );

      // Debug
      print('QR Scan API Response: ${response.data}');

      return {
        'success': true,
        'message': response.data['message'] ?? 'Points added successfully',
        'data': response.data['data'] ?? {},
        'pointsAdded': recyclingData.pointsToAdd,
        'material': recyclingData.displayName,
      };
    } on DioException catch (e) {
      print('Dio Error in QR Scan: $e');
      
      // Try to get error message from response
      String errorMessage = 'QR scan failed';
      if (e.response != null) {
        final errorData = e.response!.data;
        errorMessage = errorData['message'] ?? errorData.toString();
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('Error in QR Scan: $e');
      return {
        'success': false,
        'message': 'QR scan failed: ${e.toString()}',
      };
    }
  }

  /// Simulate QR scan (for testing without backend)
  Future<Map<String, dynamic>> simulateQRScan(RecyclingData recyclingData) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'message': '${recyclingData.pointsToAdd} points added for ${recyclingData.displayName}',
      'pointsAdded': recyclingData.pointsToAdd,
      'material': recyclingData.displayName,
      'simulated': true,
    };
  }
}