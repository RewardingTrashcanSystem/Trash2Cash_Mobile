// features/history/data/model/history_response.dart
import 'package:trash2cash/features/transactions/data/model/history_model.dart';
import 'dart:developer'; // Add for debugging

class HistoryResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<HistoryModel> results;
  final Map<String, dynamic>? summary;

  HistoryResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
    this.summary,
  });

  factory HistoryResponse.fromJson(Map<String, dynamic> json) {
    // Debug log to see actual API response
    log('HistoryResponse JSON keys: ${json.keys.toList()}');
    log('Has results key: ${json.containsKey('results')}');
    log('Has summary key: ${json.containsKey('summary')}');
    
    if (json.containsKey('results')) {
      // Standard paginated response with results array
      final resultsList = json['results'] as List<dynamic>?;
      log('Results list length: ${resultsList?.length ?? 0}');
      
      if (resultsList != null && resultsList.isNotEmpty) {
        // Log first item to see its structure
        log('First item keys: ${(resultsList.first as Map<String, dynamic>).keys.toList()}');
        log('First item: ${resultsList.first}');
      }
      
      return HistoryResponse(
        count: json['count'] ?? resultsList?.length ?? 0,
        next: json['next'],
        previous: json['previous'],
        results: resultsList
                ?.map((item) => HistoryModel.fromJson(item))
                .toList() ??
            [],
        summary: json['summary'] is Map<String, dynamic> ? json['summary'] : null,
      );
    } else {
      // Handle case where results might be directly in the response
      // (non-paginated or different structure)
      log('No results key found, checking for direct data...');
      
      // Try to find any list data in the response
      List<dynamic>? directResults;
      for (var key in json.keys) {
        if (json[key] is List<dynamic>) {
          directResults = json[key] as List<dynamic>;
          log('Found direct results in key: $key with ${directResults.length} items');
          break;
        }
      }
      
      return HistoryResponse(
        count: directResults?.length ?? 0,
        next: json['next'],
        previous: json['previous'],
        results: directResults
                ?.map((item) => HistoryModel.fromJson(item))
                .toList() ??
            [],
        summary: json['summary'] is Map<String, dynamic> ? json['summary'] : null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((item) => item.toJson()).toList(),
      'summary': summary,
    };
  }
  
  @override
  String toString() {
    return 'HistoryResponse(count: $count, hasNext: ${next != null}, results: ${results.length} items, summary: ${summary != null})';
  }
}