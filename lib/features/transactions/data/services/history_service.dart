// features/history/data/services/history_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:trash2cash/core/constants/api_constants.dart';
import 'package:trash2cash/core/constants/api_exceptions.dart';
import 'package:trash2cash/core/constants/dio_client.dart';
import 'package:trash2cash/core/network/network_info.dart';
import 'package:trash2cash/features/transactions/data/services/history_response.dart';


class HistoryService {
  final DioClient dioClient;
  final NetworkInfo networkInfo;

  HistoryService({
    required this.dioClient,
    required this.networkInfo,
  });

  Future<HistoryResponse> getHistory({
    int page = 1,
    int pageSize = 20,
    String ?action ,
    String? search,
    String? ordering,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        throw ApiException.networkError('No internet connection');
      }

      final params = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (action != 'all') 'action': action,
        if (search != null && search.isNotEmpty) 'search': search,
        if (ordering != null) 'ordering': ordering,
        if (startDate != null) 'start_date': startDate.toIso8601String().split('T')[0],
        if (endDate != null) 'end_date': endDate.toIso8601String().split('T')[0],
      };

      final response = await dioClient.get(
        ApiConstants.history,
        queryParameters: params,
      );

      return HistoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(
        message: 'Failed to load history: ${e.toString()}',
        errorCode: 'HISTORY_ERROR',
      );
    }
  }
}