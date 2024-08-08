import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _purchaseDetailsController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pharmacyNameController = TextEditingController();
  final _dateOfPurchaseController = TextEditingController();
  File? _photo;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photo = File(image.path);
      });
    }
  }

  void _submitReport() {
    if (_formKey.currentState?.validate() ?? false) {
      // Process the report
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Counterfeit Medicine'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please provide the following details to report counterfeit medicine:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildTextField(
                  label: 'Medicine Name',
                  controller: _medicineNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the medicine name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Batch Number',
                  controller: _batchNumberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the batch number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Purchase Details',
                  controller: _purchaseDetailsController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter where the medicine was bought';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Pharmacy Name',
                  controller: _pharmacyNameController,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Date of Purchase',
                  controller: _dateOfPurchaseController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the date of purchase';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'Description (Optional)',
                  controller: _descriptionController,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    _photo == null
                        ? Text('Please submit an image as proof',
                            style: TextStyle(fontSize: 16, color: Colors.grey))
                        : Image.file(_photo!,
                            height: 100, width: 100, fit: BoxFit.cover),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white, // Text color
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      icon: Icon(Icons.add_a_photo),
                      label: Text('Add Photo'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white, // Text color
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Submit Report'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: validator,
      maxLines: label == 'Description (Optional)' ? 3 : 1,
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ReportScreen(),
    theme: ThemeData(
      primarySwatch: Colors.deepPurple,
    ),
  ));
}
