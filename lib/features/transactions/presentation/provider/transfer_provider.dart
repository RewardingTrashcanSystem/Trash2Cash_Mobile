// features/transfer/presentation/provider/transfer_provider.dart
import 'package:flutter/foundation.dart';
import 'package:trash2cash/features/transactions/data/services/transfer_service.dart';

class TransferProvider with ChangeNotifier {
  final TransferService transferService;
  
  bool _isLoading = false;
  bool _isCheckingReceiver = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _receiverInfo;
  
  bool get isLoading => _isLoading;
  bool get isCheckingReceiver => _isCheckingReceiver;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Map<String, dynamic>? get receiverInfo => _receiverInfo;
  
  TransferProvider(this.transferService);
  
  // Clear all states
  void clearState() {
    _errorMessage = null;
    _successMessage = null;
    _receiverInfo = null;
    notifyListeners();
  }
  
  // Check if receiver exists - FIXED VERSION
  Future<Map<String, dynamic>> checkReceiver({
    required String emailOrPhone,
  }) async {
    if (emailOrPhone.isEmpty) {
      _receiverInfo = null;
      notifyListeners();
      return {'success': false, 'message': 'Please enter email or phone'};
    }
    
    _isCheckingReceiver = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = await transferService.checkReceiver(
        emailOrPhone: emailOrPhone,
      );
      
      _isCheckingReceiver = false;
      
      print('Check receiver result: $result');
      
      // Safely check the 'success' field
      final success = result['success'] == true;
      
      // Safely check the 'exists' field - it's a boolean from Django
      final exists = result['exists'] == true;
      
      if (success && exists) {
        // Make sure user data exists and is a Map
        if (result['user'] is Map<String, dynamic>) {
          _receiverInfo = Map<String, dynamic>.from(result['user']);
        } else {
          _receiverInfo = null;
          return {
            'success': false,
            'message': 'Invalid user data format',
          };
        }
        notifyListeners();
        return {
          'success': true,
          'message': result['message']?.toString() ?? 'Receiver found',
          'user': _receiverInfo,
        };
      } else {
        _receiverInfo = null;
        notifyListeners();
        return {
          'success': false,
          'message': result['message']?.toString() ?? 'Receiver not found',
        };
      }
    } catch (e) {
      _isCheckingReceiver = false;
      _receiverInfo = null;
      _errorMessage = e.toString();
      notifyListeners();
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Transfer points
  Future<Map<String, dynamic>> transferPoints({
    required String receiverEmailOrPhone,
    required int points,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      final result = await transferService.transferPoints(
        receiverEmailOrPhone: receiverEmailOrPhone,
        points: points,
      );
      
      _isLoading = false;
      
      print('Transfer result: $result');
      
      // Safely parse the response
      final success = result['success'] == true;
      
      if (success) {
        _successMessage = result['message']?.toString() ?? 'Transfer successful';
        _receiverInfo = null;
        _errorMessage = null;
        notifyListeners();
        return {
          'success': true,
          'message': _successMessage,
          'data': result['data'],
        };
      } else {
        _errorMessage = result['message']?.toString() ?? 'Transfer failed';
        _successMessage = null;
        notifyListeners();
        return {
          'success': false,
          'message': _errorMessage,
        };
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Transfer failed: ${e.toString()}';
      _successMessage = null;
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }
}