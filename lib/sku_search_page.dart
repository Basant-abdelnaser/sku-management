import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SKUSearchPage extends StatefulWidget {
  @override
  _SKUSearchPageState createState() => _SKUSearchPageState();
}

class _SKUSearchPageState extends State<SKUSearchPage> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _skuResults = [];
  bool _isLoading = false;
  bool _notFound = false;
  String _searchType = 'all'; // 'all', 'sku', 'name', 'category'
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('skus');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchInventory() async {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _skuResults = [];
        _notFound = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _notFound = false;
    });

    try {
      final snapshot = await _dbRef.get();
      List<Map<String, dynamic>> matchedResults = [];

      for (var child in snapshot.children) {
        final data = Map<String, dynamic>.from(child.value as Map);

        bool matches = false;
        switch (_searchType) {
          case 'sku':
            matches = data['skuCode']?.toString().toLowerCase().contains(query) ?? false;
            break;
          case 'name':
            matches = data['itemName']?.toString().toLowerCase().contains(query) ?? false;
            break;
          case 'category':
            matches = data['category']?.toString().toLowerCase().contains(query) ?? false;
            break;
          default: // 'all'
            matches =
                (data['skuCode']?.toString().toLowerCase().contains(query) ?? false) ||
                    (data['itemName']?.toString().toLowerCase().contains(query) ?? false) ||
                    (data['category']?.toString().toLowerCase().contains(query) ?? false);
        }

        if (matches) {
          matchedResults.add(data);
        }
      }

      setState(() {
        _skuResults = matchedResults;
        _notFound = matchedResults.isEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _notFound = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching inventory: ${e.toString()}')),
      );
    }
  }

  Widget _buildSearchTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSearchTypeChip('All', 'all'),
          _buildSearchTypeChip('SKU', 'sku'),
          _buildSearchTypeChip('Name', 'name'),
          _buildSearchTypeChip('Category', 'category'),
        ],
      ),
    );
  }

  Widget _buildSearchTypeChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _searchType == value,
      onSelected: (selected) {
        setState(() {
          _searchType = value;
        });
        if (_searchController.text.isNotEmpty) {
          _searchInventory();
        }
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> sku) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      elevation: 2.0,
      child: ExpansionTile(
        title: Text(
          sku['itemName'] ?? 'Unnamed Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('SKU: ${sku['skuCode'] ?? 'N/A'}'),
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Category', sku['category']),
                _buildDetailRow('Subcategory', sku['subcategory']),
                _buildDetailRow('Brand', sku['brand']),
                _buildDetailRow('Status', sku['active'] ? 'Active' : 'Inactive'),
                if (sku['description'] != null)
                  _buildDetailRow('Description', sku['description']),
                if (sku['price'] != null)
                  _buildDetailRow('Price', '\$${sku['price'].toString()}'),
                if (sku['quantity'] != null)
                  _buildDetailRow('Quantity', sku['quantity'].toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Search'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search inventory',
                hintText: 'Enter SKU, name, or category',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchInventory,
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _searchInventory(),
            ),
            _buildSearchTypeSelector(),
            SizedBox(height: 8),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_notFound)
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No matching items found',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            else if (_skuResults.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    itemCount: _skuResults.length,
                    itemBuilder: (context, index) => _buildItemCard(_skuResults[index]),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}