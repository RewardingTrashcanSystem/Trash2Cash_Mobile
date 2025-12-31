// features/scan/data/model/recycling_data.dart
import 'dart:convert';

class RecyclingData {
  final String materialType; // 'plastic', 'metal', or 'non-recycle'
  final int pointsToAdd;
  final DateTime scannedAt; // Device time when scanned
  
  RecyclingData({
    required this.materialType,
    required this.pointsToAdd,
    required this.scannedAt,
  });

  /// Parse from QR code JSON - Extract only material and points
  factory RecyclingData.fromQRCode(String qrCode) {
    try {
      final json = jsonDecode(qrCode) as Map<String, dynamic>;
      
      return RecyclingData(
        materialType: json['materialType'].toString().toLowerCase(),
        pointsToAdd: (json['pointsToAdd'] ?? 0).toInt(),
        scannedAt: DateTime.now(), // Use device time, NOT from QR code
      );
    } catch (e) {
      throw FormatException('Invalid QR code format: $e');
    }
  }

  /// Validate material type
  bool get isValidMaterial => 
      materialType == 'plastic' || 
      materialType == 'metal' || 
      materialType == 'non-recycle';

  /// Get formatted display name
  String get displayName {
    switch (materialType) {
      case 'plastic': return 'Plastic';
      case 'metal': return 'Metal';
      case 'non-recycle': return 'Non-Recyclable';
      default: return materialType;
    }
  }

  /// Get emoji
  String get emoji {
    switch (materialType) {
      case 'plastic': return '🥤';
      case 'metal': return '🥫';
      case 'non-recycle': return '🚫';
      default: return '📦';
    }
  }

  /// For API submission
  Map<String, dynamic> toApiJson() {
    return {
      'materialType': materialType,
      'pointsToAdd': pointsToAdd,
      'date': scannedAt.toUtc().toIso8601String(), // Send device time in UTC
    };
  }

  @override
  String toString() {
    return 'RecyclingData(materialType: $materialType, pointsToAdd: $pointsToAdd, scannedAt: $scannedAt)';
  }
}