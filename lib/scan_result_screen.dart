import 'package:flutter/material.dart';

class ScanResultScreen extends StatelessWidget {
  final String barcode;
  final String scanResult;
  final String expiryDate;
  final bool isFake;
  final String medicineName;
  final String manufacturerName; // Renamed from batchNumber

  const ScanResultScreen({
    Key? key,
    required this.barcode,
    required this.scanResult,
    required this.expiryDate,
    required this.isFake,
    required this.medicineName,
    required this.manufacturerName, // Updated to match the new naming
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Result'),
        backgroundColor:
            isFake ? Colors.red : Colors.green, // Conditional color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Barcode: $barcode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Medicine Name: $medicineName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Manufacturer Name: $manufacturerName', // Updated text
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Expiry Date: $expiryDate',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              scanResult,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isFake ? Colors.red : Colors.green,
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Scan Another'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isFake ? Colors.red : Colors.green, // Correct parameter
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
