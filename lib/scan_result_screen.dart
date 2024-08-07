import 'package:flutter/material.dart';

class ScanResultScreen extends StatelessWidget {
  final String barcode;
  final String scanResult;
  final String expiryDate;
  final bool isFake;

  const ScanResultScreen({
    Key? key,
    required this.barcode,
    required this.scanResult,
    required this.expiryDate,
    required this.isFake,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Result'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Scanned Barcode: $barcode',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              scanResult,
              style: TextStyle(
                fontSize: 20,
                color: isFake ? Colors.red : Colors.green,
              ),
            ),
            SizedBox(height: 20),
            if (expiryDate.isNotEmpty)
              Text(
                expiryDate,
                style: TextStyle(fontSize: 18),
              ),
          ],
        ),
      ),
    );
  }
}
