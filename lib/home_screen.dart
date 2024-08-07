import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'scan_result_screen.dart';
import 'notifications.dart';
import 'report_screen.dart';
import 'profile_screen.dart';
import 'barcode_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  String _barcode = "";
  String _scanResult = "";
  String _expiryDate = "";
  bool? _isFake;
  TextEditingController _serialNumberController = TextEditingController();

  Future<void> _scanBarcode() async {
    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      if (result != '-1') {
        setState(() {
          _barcode = result;
        });

        await FirebaseFirestore.instance.collection('barcodes').add({
          'barcode': _barcode,
          'scannedAt': Timestamp.now(),
        });

        await _checkMedicine(_barcode);
      }
    } catch (e) {
      setState(() {
        _barcode = 'Error: $e';
      });
    }
  }

  Future<void> _checkMedicine(String barcode) async {
    try {
      final url = 'https://your-api-endpoint.com/check-medicine';
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'barcode': barcode}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isFake = data['isFake'];
          _expiryDate = "Expiry Date: ${data['expiryDate']}";
          _scanResult =
              _isFake! ? "This medicine is fake." : "This medicine is genuine.";
        });

        // Navigate to the ScanResultScreen with the results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanResultScreen(
              barcode: _barcode,
              scanResult: _scanResult,
              expiryDate: _expiryDate,
              isFake: _isFake!,
            ),
          ),
        );
      } else {
        setState(() {
          _scanResult = "Failed to check medicine. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Error connecting to API: $e';
      });
    }
  }

  static List<Widget> _pages = <Widget>[
    BarcodeScannerScreen(),
    NotificationsScreen(),
    ReportScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF43A047),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services,
              size: 28,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'MEDTRUST',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              _onItemTapped(1);
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              _onItemTapped(3);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF43A047),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Account'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(3);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/auth');
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search for Medicine',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              SizedBox(height: 20),
              // Serial number input
              TextField(
                controller: _serialNumberController,
                decoration: InputDecoration(
                  labelText: 'Enter Serial Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Barcode scanner button
              ElevatedButton(
                onPressed: _scanBarcode,
                child: Text('Scan Barcode'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Display scanned barcode
              Text(
                _barcode.isEmpty
                    ? 'Awaiting scan or serial input...'
                    : 'Scanned: $_barcode',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 20),
              // Feature cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFeatureCard(
                    icon: Icons.health_and_safety,
                    label: 'Health Vitals',
                    color: Colors.green,
                  ),
                  _buildFeatureCard(
                    icon: Icons.featured_play_list,
                    label: 'Feature 2',
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.notifications, 'Notifications', 1),
              const SizedBox(width: 50), // Space for floating action button
              _buildNavItem(Icons.report, 'Report', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 60,
        height: 60,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              _onItemTapped(0); // Redirect to Barcode Scanner Page
            },
            child: Icon(Icons.qr_code_scanner_rounded, size: 30),
            backgroundColor: Color(0xFF43A047),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 8.0,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            color: isSelected ? Color(0xFF43A047) : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFF43A047) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      {required IconData icon, required String label, required Color color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15), // Rounded corners
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
