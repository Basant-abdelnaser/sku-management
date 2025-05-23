// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:qr_flutter/qr_flutter.dart';
//
// class BarcodeQRPage extends StatefulWidget {
//   @override
//   _BarcodeQRPageState createState() => _BarcodeQRPageState();
// }
//
// class _BarcodeQRPageState extends State<BarcodeQRPage> {
//   final TextEditingController _skuCodeController = TextEditingController();
//   Map<String, dynamic>? _skuData;
//   String _scanResult = '';
//
//   Future<void> _generateQR() {
//     setState(() {}); // مجرد لإعادة بناء الـ QR widget
//     return Future.value();
//   }
//
//   Future<void> _scanQR() async {
//     final result = await FlutterBarcodeScanner.scanBarcode(
//         '#ff6666', 'Cancel', true, ScanMode.QR);
//
//     if (result != '-1') {
//       setState(() {
//         _scanResult = result;
//         _skuCodeController.text = result;
//       });
//       await _fetchSKUData(result);
//     }
//   }
//
//   Future<void> _fetchSKUData(String skuCode) async {
//     final dbRef = FirebaseDatabase.instance.ref().child('skus');
//     final snapshot = await dbRef.get();
//
//     for (var child in snapshot.children) {
//       final data = Map<String, dynamic>.from(child.value as Map);
//       if (data['skuCode'] == skuCode) {
//         setState(() {
//           _skuData = data;
//         });
//         return;
//       }
//     }
//
//     setState(() {
//       _skuData = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               TextField(
//                 controller: _skuCodeController,
//                 decoration: InputDecoration(
//                   labelText: 'Enter SKU Code to generate QR',
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: _generateQR,
//                 child: Text("Generate QR"),
//               ),
//               if (_skuCodeController.text.isNotEmpty)
//                 QrImageView(
//                   data: _skuCodeController.text,
//                   size: 200,
//                 ),
//               SizedBox(height: 20),
//               ElevatedButton.icon(
//                 icon: Icon(Icons.qr_code_scanner),
//                 label: Text("Scan QR"),
//                 onPressed: _scanQR,
//               ),
//               if (_skuData != null) ...[
//                 Divider(),
//                 Text("SKU Found:", style: TextStyle(fontWeight: FontWeight.bold)),
//                 ListTile(
//                   title: Text(_skuData!['itemName']),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text("Category: ${_skuData!['category']}"),
//                       Text("Brand: ${_skuData!['brand']}"),
//                       Text("SKU: ${_skuData!['skuCode']}"),
//                       Text("Status: ${_skuData!['active'] ? 'Active' : 'Inactive'}"),
//                     ],
//                   ),
//                 )
//               ] else if (_scanResult.isNotEmpty) ...[
//                 Text("❌ SKU not found for scanned code."),
//               ]
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
