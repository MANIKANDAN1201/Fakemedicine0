import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicineDetailsPage extends StatelessWidget {
  final String medicineName;

  MedicineDetailsPage({required this.medicineName});

  Future<Map<String, dynamic>> fetchMedicineDetails() async {
    final response = await http.get(
      Uri.parse(
          'https://api.fda.gov/drug/label.json?search=openfda.brand_name:"$medicineName"&limit=1'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'].isNotEmpty) {
        return data['results'][0];
      } else {
        throw Exception('No data found');
      }
    } else {
      throw Exception('Failed to load medicine details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medicine Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMedicineDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found for $medicineName'));
          }

          final medicineData = snapshot.data!;
          final openfda = medicineData['openfda'] ?? {};
          final brandName = openfda['brand_name']?.isNotEmpty == true
              ? openfda['brand_name'][0]
              : 'N/A';
          final genericName = openfda['generic_name']?.isNotEmpty == true
              ? openfda['generic_name'][0]
              : 'N/A';
          final manufacturerName =
              openfda['manufacturer_name']?.isNotEmpty == true
                  ? openfda['manufacturer_name'][0]
                  : 'N/A';
          final activeIngredient =
              medicineData['active_ingredient']?.isNotEmpty == true
                  ? medicineData['active_ingredient'][0]
                  : 'N/A';
          final purpose = medicineData['purpose']?.isNotEmpty == true
              ? medicineData['purpose'][0]
              : 'N/A';
          final warnings = medicineData['warnings']?.isNotEmpty == true
              ? medicineData['warnings'][0]
              : 'N/A';
          final imageUrl = openfda['image_url']?.isNotEmpty == true
              ? openfda['image_url'][0]
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null)
                  Center(
                    child:
                        Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                  ),
                SizedBox(height: 20),
                Text(
                  'Medicine Information',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
                SizedBox(height: 20),
                _buildInfoCard(
                  icon: Icons.label,
                  label: 'Brand Name',
                  value: brandName,
                ),
                SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.science,
                  label: 'Generic Name',
                  value: genericName,
                ),
                SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.business,
                  label: 'Manufacturer',
                  value: manufacturerName,
                ),
                SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.local_pharmacy,
                  label: 'Active Ingredient',
                  value: activeIngredient,
                ),
                SizedBox(height: 10),
                _buildInfoCard(
                  icon: Icons.info,
                  label: 'Purpose',
                  value: purpose,
                ),
                SizedBox(height: 20),
                _buildWarningCard(
                  warnings: warnings,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 30),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningCard({required String warnings}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      color: Colors.redAccent[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.redAccent, size: 30),
                SizedBox(width: 10),
                Text(
                  'Important Warnings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              warnings,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
