import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class SKUCreationPage extends StatefulWidget {
  @override
  _SKUCreationPageState createState() => _SKUCreationPageState();
}

class _SKUCreationPageState extends State<SKUCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _skuCodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _brandController = TextEditingController();
  bool _autoGenerate = true;

  final DatabaseReference _skuRef = FirebaseDatabase.instance.ref().child('skus');

  String _generateAutoSKUCode() {
    // A simple auto-code: SKU + timestamp
    return 'SKU${DateTime.now().millisecondsSinceEpoch}';
  }

  void _addSKU() {
    if (_formKey.currentState!.validate()) {
      final skuCode = _autoGenerate ? _generateAutoSKUCode() : _skuCodeController.text;

      final newSKURef = _skuRef.push();
      newSKURef.set({
        'itemName': _itemNameController.text,
        'skuCode': skuCode,
        'category': _categoryController.text,
        'subcategory': _subcategoryController.text,
        'brand': _brandController.text,
        'active': true,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SKU added successfully')),
        );
        _formKey.currentState!.reset();
        _skuCodeController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add SKU: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create SKU')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Auto Generate SKU Code'),
                  value: _autoGenerate,
                  onChanged: (val) => setState(() => _autoGenerate = val),
                ),
                if (!_autoGenerate)
                  TextFormField(
                    controller: _skuCodeController,
                    decoration: InputDecoration(labelText: 'SKU Code'),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Enter SKU Code' : null,
                  ),
                TextFormField(
                  controller: _itemNameController,
                  decoration: InputDecoration(labelText: 'Item Name'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter item name' : null,
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter category' : null,
                ),
                TextFormField(
                  controller: _subcategoryController,
                  decoration: InputDecoration(labelText: 'Subcategory'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter subcategory' : null,
                ),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(labelText: 'Brand'),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter brand name' : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addSKU,
                  child: Text('Create SKU'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}