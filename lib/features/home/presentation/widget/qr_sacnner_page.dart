import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:trash2cash/features/home/data/model/recycling_data.dart';
import 'package:trash2cash/features/home/presentation/provider/scan_provider.dart';


class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = Provider.of<ScanProvider>(context);
    
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          scanProvider.clearState();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          backgroundColor: Colors.green.shade700,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              scanProvider.clearState();
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isFlashOn = !_isFlashOn;
                });
                cameraController.toggleTorch();
              },
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            // QR Scanner
            MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                _handleQRDetection(capture, scanProvider);
              },
            ),
            
            // Scanner overlay
            _buildScannerOverlay(),
            
            // Processing indicator
            if (scanProvider.isProcessing) _buildProcessingIndicator(),
          ],
        ),
      ),
    );
  }

  void _handleQRDetection(BarcodeCapture capture, ScanProvider scanProvider) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final code = barcodes.first.rawValue;
    if (code == null) return;
    
    // Prevent duplicate scans within 3 seconds
    final now = DateTime.now();
    if (_lastScannedCode == code && 
        _lastScanTime != null && 
        now.difference(_lastScanTime!).inSeconds < 3) {
      return;
    }
    
    // Update last scan info
    _lastScannedCode = code;
    _lastScanTime = now;
    
    // Process QR code
    scanProvider.processQRCode(code).then((result) {
      if (result['success'] == true && result['recyclingData'] != null) {
        // Show confirmation dialog
        _showConfirmationDialog(context, result['recyclingData'], scanProvider);
      }
    });
  }

  void _showConfirmationDialog(BuildContext context, RecyclingData recyclingData, ScanProvider scanProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: Colors.green),
            const SizedBox(width: 10),
            Text('${recyclingData.displayName} Detected'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Material: ${recyclingData.emoji} ${recyclingData.displayName}'),
            const SizedBox(height: 10),
            Text('Points: ${recyclingData.pointsToAdd}'),
            const SizedBox(height: 10),
            Text('Time: ${DateTime.now().toLocal().toString().split('.')[0]}'),
            const SizedBox(height: 20),
            const Text(
              'Do you want to add these points?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              scanProvider.cancelScan();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final result = await scanProvider.confirmAndSendScan(recyclingData);
              
              if (result['success'] == true) {
                // Show success and go back
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Delay and go back
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    scanProvider.clearState();
                    Navigator.pop(context);
                  }
                });
              } else {
                // Show error
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message']),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Add Points'),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    final size = MediaQuery.of(context).size;
    final cutoutSize = size.width * 0.7;
    
    return Column(
      children: [
        Expanded(
          child: Container(color: Colors.black.withOpacity(0.5)),
        ),
        
        SizedBox(
          height: cutoutSize,
          child: Row(
            children: [
              Expanded(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
              
              Container(
                width: cutoutSize,
                height: cutoutSize,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 50,
                      color: Colors.green.shade300,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Align QR code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: Container(
            color: Colors.black.withOpacity(0.8),
            padding: const EdgeInsets.all(20),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'How to scan:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '1. Point camera at QR code\n'
                  '2. Keep it steady within frame\n'
                  '3. Wait for automatic scan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Processing QR Code...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}