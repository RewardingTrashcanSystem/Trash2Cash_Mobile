import 'dart:convert';

/// Simple model for 3 waste types
class RecyclingData {
  final String materialType; // 'plastic', 'metal', or 'non-recycle'
  final int pointsToAdd;
  final DateTime date;
  
  RecyclingData({
    required this.materialType,
    required this.pointsToAdd,
    required this.date,
  });

  /// Parse from QR code JSON
  factory RecyclingData.fromQRCode(String qrCode) {
    final json = jsonDecode(qrCode) as Map<String, dynamic>;
    
    return RecyclingData(
      materialType: json['materialType'].toString().toLowerCase(),
      pointsToAdd: (json['pointsToAdd'] ?? 0).toInt(),
      date: DateTime.parse(json['date'].toString()),
    );
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
}