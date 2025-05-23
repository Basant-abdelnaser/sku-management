import 'package:erp_assignment_v2/sku_creation_lib.dart';
import 'package:erp_assignment_v2/sku_deactivate_page.dart';
import 'package:erp_assignment_v2/sku_search_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import ' QR-Barcode/generate_QR.dart';
import 'add_branch_page.dart';
import 'barcode_qr_page.dart';
import 'package:erp_assignment_v2/barcode_qr_page.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'sku_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(InventoryApp());
}

class InventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          elevation: 2,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      home: MainScreen(), // Changed to a separate screen widget
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AddBranchPage(),
    SKUCreationPage(),
    SKUSearchPage(),
    SKUDeactivatePage(),

  ];

  Future<bool> _checkCameraPermissions() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SKU MANAGEMENT'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Branches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: 'SKUs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_circle_outline),
            label: 'Deactivate',
          ),

        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final hasPermission = await _checkCameraPermissions();
          if (hasPermission) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SKUScannerScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Camera permission required')),
            );
          }
        },
        child: Icon(Icons.qr_code_scanner),
        tooltip: 'Scan SKU',
      ),
    );
  }
}