// features/scan/presentation/provider/scan_provider.dart
import 'package:flutter/foundation.dart';
import 'package:trash2cash/features/home/data/model/recycling_data.dart';
import 'package:trash2cash/features/home/data/services/scan_service.dart';

class ScanProvider with ChangeNotifier {
  final ScanService scanService;
  
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _successMessage;
  RecyclingData? _lastScan;
  List<RecyclingData> _scanHistory = [];
  
  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  RecyclingData? get lastScan => _lastScan;
  List<RecyclingData> get scanHistory => _scanHistory;
  
  ScanProvider(this.scanService);
  
  /// Process QR code string
  Future<Map<String, dynamic>> processQRCode(String qrCode) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      // Parse QR code
      final recyclingData = RecyclingData.fromQRCode(qrCode);
      
      // Validate
      if (!recyclingData.isValidMaterial) {
        _errorMessage = 'Invalid material type: ${recyclingData.materialType}';
        _isProcessing = false;
        notifyListeners();
        return {
          'success': false,
          'message': _errorMessage,
        };
      }
      
      // Store last scan
      _lastScan = recyclingData;
      
      // Show confirmation dialog (UI will handle this)
      _isProcessing = false;
      notifyListeners();
      
      return {
        'success': true,
        'message': 'QR code scanned successfully',
        'recyclingData': recyclingData,
      };
    } catch (e) {
      _isProcessing = false;
      _errorMessage = 'Failed to parse QR code: $e';
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }
  
  /// Confirm and send scan to backend
  Future<Map<String, dynamic>> confirmAndSendScan(RecyclingData recyclingData) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      // Send to backend
      final result = await scanService.processQRScan(recyclingData);
      
      _isLoading = false;
      
      if (result['success'] == true) {
        _successMessage = result['message'];
        
        // Add to history
        _scanHistory.add(recyclingData);
        
        notifyListeners();
        return {
          'success': true,
          'message': _successMessage,
          'data': result['data'] ?? {},
          'pointsAdded': recyclingData.pointsToAdd,
        };
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return {
          'success': false,
          'message': _errorMessage,
        };
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Scan failed: ${e.toString()}';
      notifyListeners();
      return {
        'success': false,
        'message': _errorMessage,
      };
    }
  }
  
  /// Cancel current scan
  void cancelScan() {
    _isProcessing = false;
    _lastScan = null;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
  
  /// Clear all states
  void clearState() {
    _isLoading = false;
    _isProcessing = false;
    _errorMessage = null;
    _successMessage = null;
    _lastScan = null;
    notifyListeners();
  }
  
  /// Get total points scanned
  int get totalPointsScanned {
    return _scanHistory.fold(0, (sum, scan) => sum + scan.pointsToAdd);
  }
  
  /// Get scan count by material
  Map<String, int> get scanCountByMaterial {
    final counts = <String, int>{};
    
    for (final scan in _scanHistory) {
      counts[scan.materialType] = (counts[scan.materialType] ?? 0) + 1;
    }
    
    return counts;
  }
}