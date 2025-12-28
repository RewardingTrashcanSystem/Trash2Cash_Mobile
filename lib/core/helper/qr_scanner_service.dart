import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trash2cash/features/home/data/model/recycling_data.dart';
import 'package:trash2cash/features/home/presentation/widget/qr_sacnner_page.dart';


class QRScannerService {
  // Singleton pattern
  static final QRScannerService _instance = QRScannerService._internal();
  factory QRScannerService() => _instance;
  QRScannerService._internal();

  // Open QR scanner
  Future<void> openQRScanner({
    required BuildContext context,
    required Function(RecyclingData) onScanSuccess,
    Function()? onScanCancel,
    Function(String)? onError,
  }) async {
    try {
      // Check camera permission
      final bool hasPermission = await _checkCameraPermission(context);
      
      if (!hasPermission) {
        onError?.call('Camera permission denied');
        return;
      }
      
      // Navigate to QR scanner
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(
            onQRCodeScanned: (qrCode) {
              final recyclingData = _parseQRCode(qrCode);
              if (recyclingData != null) {
                onScanSuccess(recyclingData);
              } else {
                onError?.call('Invalid QR code format. Expected JSON with materialType, pointsToAdd, date');
              }
            },
          ),
        ),
      );
      
      // Handle cancellation
      if (result == null && onScanCancel != null) {
        onScanCancel();
      }
      
    } catch (e) {
      onError?.call('Failed to open QR scanner: $e');
    }
  }

  // Parse QR code into RecyclingData
  RecyclingData? _parseQRCode(String qrCode) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(qrCode);
      
      // Validate required fields
      if (!jsonData.containsKey('materialType') ||
          !jsonData.containsKey('pointsToAdd') ||
          !jsonData.containsKey('date')) {
        return null;
      }
      
      // Validate material type
      final materialType = jsonData['materialType'].toString().toLowerCase();
      if (materialType != 'plastic' && 
          materialType != 'metal' && 
          materialType != 'non-recycle') {
        return null;
      }
      
      // Parse date
      DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(jsonData['date'].toString());
      } catch (e) {
        parsedDate = DateTime.now();
      }
      
      // Parse points
      int parsedPoints;
      if (jsonData['pointsToAdd'] is String) {
        parsedPoints = int.tryParse(jsonData['pointsToAdd']) ?? 0;
      } else {
        parsedPoints = (jsonData['pointsToAdd'] as num).toInt();
      }
      
      return RecyclingData(
        materialType: materialType,
        pointsToAdd: parsedPoints,
        date: parsedDate,
      );
      
    } catch (e) {
      print('Error parsing QR code: $e');
      return null;
    }
  }

  // Check camera permission
  Future<bool> _checkCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) return true;
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      final bool shouldOpenSettings = await _showPermissionDialog(context);
      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }
    
    return false;
  }

  // Show permission dialog
  Future<bool> _showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text('To scan QR codes, camera access is required.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    ) ?? false;
  }

  // Show recycling confirmation dialog
  Future<void> showRecyclingConfirmation({
    required BuildContext context,
    required RecyclingData recyclingData,
    required Function() onConfirm,
    Function()? onCancel,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Recycling'),
        content: _buildConfirmationContent(recyclingData),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirm Recycling'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationContent(RecyclingData data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Material Type:', '${data.emoji} ${data.displayName}'),
        _buildInfoRow('Points to Add:', '${data.pointsToAdd} points'),
        _buildInfoRow('Date:', data.date.toLocal().toString().split('.')[0]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.eco, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Confirm to add ${data.pointsToAdd} points to your account',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}