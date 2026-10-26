import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null) {
        _isScanned = true;

        // UPI QR parsing (upi://pay?pa=...&pn=...)
        String upiId = 'merchant@upi';
        String name = 'Merchant Store';

        if (rawValue.startsWith('upi://pay')) {
          final uri = Uri.parse(rawValue);
          upiId = uri.queryParameters['pa'] ?? upiId;
          name = uri.queryParameters['pn'] ?? name;
        } else if (rawValue.contains('@')) {
          upiId = rawValue;
          name = rawValue.split('@')[0];
        }

        Navigator.of(context).pop({'name': name, 'upiId': upiId});
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan any UPI QR'),
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          // Scanner Overlay Box
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Positioned(
            bottom: 40,
            child: Text(
              'Align QR code inside the frame to scan',
              style: TextStyle(color: Colors.white, fontSize: 14, backgroundColor: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
