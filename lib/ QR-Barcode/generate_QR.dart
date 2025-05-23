import 'package:erp_assignment_v2/%20QR-Barcode/sku_repositry.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:qr_flutter/qr_flutter.dart';

import 'barcode_generator.dart';
import 'customer-scanner.dart';

class SKUScannerScreen extends StatefulWidget {
  const SKUScannerScreen({Key? key}) : super(key: key);

  @override
  State<SKUScannerScreen> createState() => _SKUScannerScreenState();
}

class _SKUScannerScreenState extends State<SKUScannerScreen> {
  ms.MobileScannerController cameraController = ms.MobileScannerController();
  String? scannedCode;
  bool isScanning = true;
  final SKURepository skuRepository = SKURepository();
  final TextEditingController manualCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan SKU'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case ms.TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case ms.TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case ms.CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case ms.CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: _showManualEntryDialog,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              if (scannedCode != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BarcodeGeneratorScreen(skuCode: scannedCode!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scan a code first!')),
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ms.MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<ms.Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && isScanning) {
                  setState(() {
                    scannedCode = barcode.rawValue;
                    isScanning = false;
                  });
                  _processScannedCode(barcode.rawValue!);
                }
              }
            },
          ),
          if (isScanning) CustomScannerOverlay(),
          if (scannedCode != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black54,
                child: Text(
                  'Scanned: $scannedCode',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !isScanning
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            scannedCode = null;
            isScanning = true;
          });
        },
        child: const Icon(Icons.qr_code_scanner),
      )
          : null,
    );
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter SKU Manually'),
        content: TextField(
          controller: manualCodeController,
          decoration: const InputDecoration(hintText: 'Enter SKU Code'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (manualCodeController.text.isNotEmpty) {
                _processScannedCode(manualCodeController.text.trim());
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> _processScannedCode(String code) async {
    if (code.isEmpty || !RegExp(r'^[A-Za-z0-9]+$').hasMatch(code)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid Code'),
          content:
          const Text('The entered/scanned code is not a valid SKU format.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => isScanning = true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final skuData = await skuRepository.getSKUData(code);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('SKU Found'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Code: $code'),
              const SizedBox(height: 10),
              Text('Name: ${skuData['itemName']}'),
              Text('Category: ${skuData['category']}'),
              const SizedBox(height: 20),
              Center(
                child: bw.BarcodeWidget(
                  barcode: bw.Barcode.code128(),
                  data: code,
                  width: 200,
                  height: 80,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => isScanning = true);
              },
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BarcodeGeneratorScreen(skuCode: code),
                  ),
                );
              },
              child: const Text('Generate QR'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('SKU not found: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => isScanning = true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    manualCodeController.dispose();
    super.dispose();
  }
}

class CustomScannerOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Align SKU barcode/QR code'
                    ' within the frame',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 250),
              Text(
                'Scanning will start automatically',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
