import 'package:firebase_database/firebase_database.dart';

class SKURepository {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<Map<String, dynamic>> getSKUData(String skuCode) async {
    try {
      final snapshot = await _database
          .child('skus')
          .orderByChild('skuCode')
          .equalTo(skuCode)
          .limitToFirst(1)
          .get();

      if (!snapshot.exists || snapshot.children.isEmpty) {
        throw Exception('SKU not found');
      }

      final firstMatch = snapshot.children.first;
      return Map<String, dynamic>.from(firstMatch.value as Map);
    } catch (e) {
      throw Exception('Error fetching SKU data: $e');
    }
  }

  Future<void> storeGeneratedCode(String skuCode, String imageUrl) async {
    try {
      await _database.child('skus/$skuCode').update({
        'barcodeImageUrl': imageUrl,
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (e) {
      throw Exception('Error updating SKU data: $e');
    }
  }
}