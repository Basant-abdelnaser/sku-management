import 'package:barcode_widget/barcode_widget.dart' as bw;
import 'package:erp_assignment_v2/%20QR-Barcode/sku_repositry.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BarcodeGeneratorScreen extends StatelessWidget {
  final String skuCode;

  const BarcodeGeneratorScreen({Key? key, required this.skuCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barcode Generator')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('SKU: $skuCode', style: TextStyle(fontSize: 20)),
            SizedBox(height: 30),
            bw.BarcodeWidget(
              barcode: bw.Barcode.code128(),
              data: skuCode,
              width: 250,
              height: 100,
            ),
            SizedBox(height: 30),
            QrImageView(
              data: skuCode,
              version: QrVersions.auto,
              size: 200.0,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Scanner'),
            ),
          ],
        ),
      ),
    );
  }
}
