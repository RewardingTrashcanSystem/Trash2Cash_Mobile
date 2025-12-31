// features/history/presentation/provider/history_provider.dart
import 'package:flutter/foundation.dart';
import 'package:trash2cash/features/transactions/data/model/history_model.dart';
import 'package:trash2cash/features/transactions/data/services/history_service.dart';
import 'package:trash2cash/features/transactions/data/services/history_response.dart';

class HistoryProvider with ChangeNotifier {
  final HistoryService historyService;
  
  List<HistoryModel> _history = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _hasMore = true;
  int _currentPage = 1;
  Map<String, dynamic>? _summary;
  String? _error;
  
  List<HistoryModel> get history => _history;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasMore => _hasMore;
  Map<String, dynamic>? get summary => _summary;
  String? get error => _error;
  
  HistoryProvider(this.historyService);
  
  Future<void> fetchHistory({String action = 'all', bool refresh = false}) async {
    if (refresh) {
      _isRefreshing = true;
      _currentPage = 1;
      _hasMore = true;
    } else {
      _isLoading = true;
    }
    
    _error = null;
    notifyListeners();
    
    try {
      // Get HistoryResponse object
      final HistoryResponse response = await historyService.getHistory(
        page: _currentPage,
        action: action != 'all' ? action : null,
      );
      
      print('History response count: ${response.count}');
      print('History results: ${response.results.length}');
      
      // Use the HistoryResponse properties directly
      if (refresh) {
        _history = response.results;
        _isRefreshing = false;
      } else {
        _history = response.results;
      }
      
      _summary = response.summary;
      _hasMore = response.next != null;
      
      if (!refresh && _currentPage == 1) {
        _currentPage = 2;
      }
      
    } catch (e) {
      _error = 'Failed to load history: $e';
      print('History fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final HistoryResponse response = await historyService.getHistory(
        page: _currentPage,
      );
      
      _history.addAll(response.results);
      _hasMore = response.next != null;
      _currentPage++;
    } catch (e) {
      _error = 'Failed to load more: $e';
      print('Load more error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> refreshHistory() async {
    await fetchHistory(refresh: true);
  }
  
  void clearHistory() {
    _history = [];
    _summary = null;
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}