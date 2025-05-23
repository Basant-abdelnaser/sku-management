import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQRScreen extends StatefulWidget {
  final Function(String) onScan;

  const ScanQRScreen({Key? key, required this.onScan}) : super(key: key);

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan SKU QR/Barcode")),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
        ),
        onDetect: (BarcodeCapture capture) {
          if (isScanned) return; // prevent multiple scans
          final List<Barcode> barcodes = capture.barcodes;

          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            final String code = barcodes.first.rawValue!;
            setState(() => isScanned = true);
            Navigator.pop(context);
            widget.onScan(code);
          }
        },
      ),
    );
  }
}
