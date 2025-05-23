import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SKUDeactivatePage extends StatefulWidget {
  @override
  _SKUDeactivatePageState createState() => _SKUDeactivatePageState();
}

class _SKUDeactivatePageState extends State<SKUDeactivatePage> {
  final TextEditingController _skuCodeController = TextEditingController();
  String _statusMessage = '';

  Future<void> _deactivateSKU() async {
    final skuCode = _skuCodeController.text.trim();
    if (skuCode.isEmpty) return;

    final dbRef = FirebaseDatabase.instance.ref().child('skus');
    final snapshot = await dbRef.get();

    bool found = false;
    for (var child in snapshot.children) {
      final data = Map<String, dynamic>.from(child.value as Map);
      if (data['skuCode'] == skuCode) {
        await dbRef.child(child.key!).update({'active': false});
        setState(() {
          _statusMessage = '✅ SKU "$skuCode" deactivated successfully.';
        });
        found = true;
        break;
      }
    }

    if (!found) {
      setState(() {
        _statusMessage = '❌ SKU "$skuCode" not found.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _skuCodeController,
              decoration: InputDecoration(
                labelText: 'Enter SKU Code to deactivate',
                suffixIcon: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: _deactivateSKU,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(_statusMessage, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
