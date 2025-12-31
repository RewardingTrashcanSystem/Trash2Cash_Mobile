// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
// import 'package:trash2cash/features/home/data/model/recycling_data.dart';
// import 'package:trash2cash/features/home/presentation/provider/scan_provider.dart';
// import 'package:trash2cash/features/home/presentation/widget/qr_sacnner_page.dart';


// class QRScannerService {
//   // Singleton pattern
//   static final QRScannerService _instance = QRScannerService._internal();
//   factory QRScannerService() => _instance;
//   QRScannerService._internal();

//   // Open QR scanner with new provider system
//   Future<void> openQRScanner({
//     required BuildContext context,
//     required Function(RecyclingData) onScanSuccess,
//     Function()? onScanCancel,
//     Function(String)? onError,
//   }) async {
//     try {
//       // Check camera permission
//       final bool hasPermission = await _checkCameraPermission(context);
      
//       if (!hasPermission) {
//         onError?.call('Camera permission denied');
//         return;
//       }
      
//       // Navigate to QR scanner
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => QRScannerScreen(),
//         ),
//       );
      
//       // Check if scan was successful by checking the provider
//       final scanProvider = Provider.of<ScanProvider>(context, listen: false);
//       final lastScan = scanProvider.lastScan;
      
//       if (lastScan != null) {
//         onScanSuccess(lastScan);
//         // Clear the scan from provider
//         scanProvider.clearState();
//       } else if (onScanCancel != null) {
//         onScanCancel();
//       }
      
//     } catch (e) {
//       onError?.call('Failed to open QR scanner: $e');
//     }
//   }

//   // Parse QR code into RecyclingData - UPDATED to use device time
//   RecyclingData? parseQRCode(String qrCode) {
//     try {
//       final Map<String, dynamic> jsonData = jsonDecode(qrCode);
      
//       // Validate required fields
//       if (!jsonData.containsKey('materialType') ||
//           !jsonData.containsKey('pointsToAdd')) {
//         return null;
//       }
      
//       // Validate material type
//       final materialType = jsonData['materialType'].toString().toLowerCase();
//       if (materialType != 'plastic' && 
//           materialType != 'metal' && 
//           materialType != 'non-recycle') {
//         return null;
//       }
      
//       // Parse points
//       int parsedPoints;
//       if (jsonData['pointsToAdd'] is String) {
//         parsedPoints = int.tryParse(jsonData['pointsToAdd']) ?? 0;
//       } else {
//         parsedPoints = (jsonData['pointsToAdd'] as num).toInt();
//       }
      
//       // Validate points
//       if (parsedPoints <= 0) {
//         return null;
//       }
      
//       return RecyclingData(
//         materialType: materialType,
//         pointsToAdd: parsedPoints,
//         scannedAt: DateTime.now(), // Use device time instead of QR code date
//       );
      
//     } catch (e) {
//       print('Error parsing QR code: $e');
//       return null;
//     }
//   }

//   // Check camera permission
//   Future<bool> _checkCameraPermission(BuildContext context) async {
//     final status = await Permission.camera.status;
    
//     if (status.isGranted) return true;
    
//     if (status.isDenied) {
//       final result = await Permission.camera.request();
//       return result.isGranted;
//     }
    
//     if (status.isPermanentlyDenied) {
//       final bool shouldOpenSettings = await _showPermissionDialog(context);
//       if (shouldOpenSettings) {
//         await openAppSettings();
//       }
//       return false;
//     }
    
//     return false;
//   }

//   // Show permission dialog
//   Future<bool> _showPermissionDialog(BuildContext context) async {
//     return await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Camera Permission Required'),
//         content: const Text('To scan QR codes, camera access is required.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//             ),
//             child: const Text('Open Settings'),
//           ),
//         ],
//       ),
//     ) ?? false;
//   }

//   // Show recycling confirmation dialog - UPDATED for provider system
//   Future<void> showRecyclingConfirmation({
//     required BuildContext context,
//     required RecyclingData recyclingData,
//     required Function() onConfirm,
//     Function()? onCancel,
//   }) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Confirm Recycling'),
//         content: _buildConfirmationContent(recyclingData),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context, false);
//             },
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context, true);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//             ),
//             child: const Text('Confirm Recycling'),
//           ),
//         ],
//       ),
//     );
    
//     if (result == true) {
//       onConfirm();
//     } else {
//       onCancel?.call();
//     }
//   }

//   Widget _buildConfirmationContent(RecyclingData data) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildInfoRow('Material Type:', '${data.emoji} ${data.displayName}'),
//         _buildInfoRow('Points to Add:', '${data.pointsToAdd} points'),
//         _buildInfoRow('Time:', '${DateTime.now().toLocal().toString().split('.')[0]}'),
//         const SizedBox(height: 16),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.green.shade50,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.eco, color: Colors.green),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   'Confirm to add ${data.pointsToAdd} points to your account',
//                   style: const TextStyle(color: Colors.green),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.grey),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // New method to process QR code with provider
//   Future<Map<String, dynamic>> processQRCodeWithProvider({
//     required BuildContext context,
//     required String qrCode,
//   }) async {
//     final scanProvider = Provider.of<ScanProvider>(context, listen: false);
//     return await scanProvider.processQRCode(qrCode);
//   }

//   // New method to confirm and send scan with provider
//   Future<Map<String, dynamic>> confirmScanWithProvider({
//     required BuildContext context,
//     required RecyclingData recyclingData,
//   }) async {
//     final scanProvider = Provider.of<ScanProvider>(context, listen: false);
//     return await scanProvider.confirmAndSendScan(recyclingData);
//   }

//   // Validate QR code format
//   bool isValidQRFormat(String qrCode) {
//     try {
//       final json = jsonDecode(qrCode);
//       return json is Map<String, dynamic> &&
//           json.containsKey('materialType') &&
//           json.containsKey('pointsToAdd');
//     } catch (e) {
//       return false;
//     }
//   }

//   // Get QR code format hint
//   String get qrFormatHint {
//     return 'QR code should contain:\n'
//         '- materialType: "plastic", "metal", or "non-recycle"\n'
//         '- pointsToAdd: number (e.g., 50)\n'
//         'Example:\n'
//         '{\n'
//         '  "materialType": "plastic",\n'
//         '  "pointsToAdd": 50\n'
//         '}';
//   }

//   // Show QR format error dialog
//   void showQRFormatError(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Invalid QR Code Format'),
//         content: Text(qrFormatHint),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }
// }