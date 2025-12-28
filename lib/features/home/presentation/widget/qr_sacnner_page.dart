import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String)? onQRCodeScanned;
  
  const QRScannerScreen({super.key, this.onQRCodeScanned});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isFlashOn = false;
  bool _isScanning = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.green.shade700,
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
              if (_isScanning) return;
              
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null && widget.onQRCodeScanned != null) {
                  setState(() => _isScanning = true);
                  widget.onQRCodeScanned!(code);
                  
                  // Wait a moment before allowing next scan
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() => _isScanning = false);
                    }
                  });
                }
              }
            },
          ),
          
          // Scanner overlay
          _buildScannerOverlay(),
          
          // Scanning indicator
          if (_isScanning) _buildScanningIndicator(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    final size = MediaQuery.of(context).size;
    final cutoutSize = size.width * 0.7;
    
    return Column(
      children: [
        // Top overlay
        Expanded(
          child: Container(color: Colors.black.withOpacity(0.5)),
        ),
        
        // Middle section with cutout
        SizedBox(
          height: cutoutSize,
          child: Row(
            children: [
              // Left overlay
              Expanded(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
              
              // Scanner frame
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
              
              // Right overlay
              Expanded(
                child: Container(color: Colors.black.withOpacity(0.5)),
              ),
            ],
          ),
        ),
        
        // Bottom overlay with instructions
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

  Widget _buildScanningIndicator() {
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