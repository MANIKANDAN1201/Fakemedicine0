import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'scan_result_screen.dart'; // Import the result screen

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String _barcode = "";
  String _scanResult = "";
  String _expiryDate = "";
  bool? _isFake;
  String _medicineName = "";
  String _manufacturerName = ""; // Updated from _batchNumber

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
        _scanResult = 'Error: $e';
      });
    }
  }

  Future<void> _checkMedicine(String barcode) async {
    try {
      final url =
          'https://api.upcitemdb.com/prod/trial/lookup?upc=$barcode'; // API URL with the scanned barcode
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['items'] != null && data['items'].isNotEmpty) {
          final product = data['items'][0];
          setState(() {
            _medicineName = product['title'] ?? "Unknown"; // Product title
            _manufacturerName =
                product['brand'] ?? "Unknown"; // Brand or any relevant field
            _expiryDate =
                "Not Available"; // Expiry date might not be available in the API
            _isFake = false; // Assuming the product is genuine if found
            _scanResult = "This medicine is genuine.";

            _navigateToResultScreen();
          });
        } else {
          // If product not found in API, check the local JSON file
          await _checkMedicineInJson(barcode);
        }
      } else {
        setState(() {
          _scanResult = "Failed to check medicine. Please try again.";
          _navigateToResultScreen();
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Error connecting to API: $e';
        _navigateToResultScreen();
      });
    }
  }

  Future<void> _checkMedicineInJson(String barcode) async {
    try {
      // Load the JSON file
      final String jsonString =
          await rootBundle.loadString('assets/medicines.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);

      // Search for the barcode in the JSON data
      final product = jsonData.firstWhere(
        (item) => item['Barcode_No'] == barcode,
        orElse: () => null,
      );

      if (product != null) {
        setState(() {
          _medicineName = product['Name'] ?? "Unknown";
          _manufacturerName =
              product['Manufacturer'] ?? "Unknown"; // Updated to manufacturer
          _expiryDate = product['Expiry_Date'] ?? "Not Available";
          _isFake = false; // Assuming the product is genuine if found in JSON
          _scanResult = "This medicine is genuine.";
        });
      } else {
        setState(() {
          _scanResult = "Medicine not found. It might be fake.";
          _isFake = true;
        });
      }

      _navigateToResultScreen();
    } catch (e) {
      setState(() {
        _scanResult = 'Error reading JSON data: $e';
        _navigateToResultScreen();
      });
    }
  }

  void _navigateToResultScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanResultScreen(
          barcode: _barcode,
          scanResult: _scanResult,
          expiryDate: _expiryDate,
          isFake: _isFake!,
          medicineName: _medicineName,
          manufacturerName:
              _manufacturerName, // Updated to match the new naming
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _barcode.isEmpty ? 'Scan a barcode' : 'Scanned: $_barcode',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanBarcode,
              child: Text('Start Barcode Scan'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              _scanResult.isEmpty ? '' : 'Result: $_scanResult',
              style: TextStyle(
                  fontSize: 16,
                  color: _isFake == true ? Colors.red : Colors.green),
            ),
            SizedBox(height: 20),
            Text(
              _expiryDate,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
