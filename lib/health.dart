import 'package:fakemedicine/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HealthVitalsScreens(),
    );
  }
}

class HealthVitalsScreens extends StatefulWidget {
  @override
  _HealthVitalsScreenState createState() => _HealthVitalsScreenState();
}

class _HealthVitalsScreenState extends State<HealthVitalsScreens> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _allergyTitleController = TextEditingController();
  final TextEditingController _allergySymptomsController =
      TextEditingController();
  final TextEditingController _allergyDateController = TextEditingController();

  List<Map<String, String>> _allergies = [];
  String _outcome = "";
  Set<String> _enteredVitals = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _bloodPressureController.text = prefs.getString('bloodPressure') ?? '';
      _heartRateController.text = prefs.getString('heartRate') ?? '';
      _temperatureController.text = prefs.getString('temperature') ?? '';
      _outcome = prefs.getString('outcome') ?? '';
      _enteredVitals = (prefs.getStringList('enteredVitals') ?? []).toSet();
      _allergies = (prefs.getStringList('allergies') ?? [])
          .map((e) => Map<String, String>.from(json.decode(e)))
          .toList();
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('bloodPressure', _bloodPressureController.text);
    await prefs.setString('heartRate', _heartRateController.text);
    await prefs.setString('temperature', _temperatureController.text);
    await prefs.setString('outcome', _outcome);
    await prefs.setStringList('enteredVitals', _enteredVitals.toList());
    await prefs.setStringList(
      'allergies',
      _allergies.map((e) => json.encode(e)).toList(),
    );
  }

  void _calculateOutcome(String vital) {
    if (_formKey.currentState?.validate() ?? false) {
      final bloodPressure = _bloodPressureController.text.split('/');
      final heartRate = int.tryParse(_heartRateController.text) ?? 0;
      final temperature = double.tryParse(_temperatureController.text) ?? 0.0;

      String outcome = "";

      if (vital == 'Blood Pressure' && bloodPressure.length == 2) {
        final systolic = int.tryParse(bloodPressure[0]) ?? 0;
        final diastolic = int.tryParse(bloodPressure[1]) ?? 0;

        if (systolic < 120 && diastolic < 80) {
          outcome += "Blood pressure is normal.\n";
        } else if (systolic <= 129 && diastolic < 80) {
          outcome += "Elevated blood pressure.\n";
        } else if (systolic >= 130 || diastolic >= 80) {
          outcome += "High blood pressure.\n";
        } else {
          outcome += "Blood pressure is out of range.\n";
        }
      } else if (vital == 'Heart Rate') {
        if (heartRate < 60) {
          outcome += "Heart rate is low.\n";
        } else if (heartRate <= 100) {
          outcome += "Heart rate is normal.\n";
        } else {
          outcome += "Heart rate is high.\n";
        }
      } else if (vital == 'Temperature') {
        if (temperature < 36.1) {
          outcome += "Temperature is low.\n";
        } else if (temperature <= 37.2) {
          outcome += "Temperature is normal.\n";
        } else {
          outcome += "Temperature is high.\n";
        }
      }

      setState(() {
        _outcome = outcome;
        _enteredVitals.add(vital);
      });

      _saveData();
    }
  }

  void _addAllergy() {
    if (_allergyTitleController.text.isNotEmpty &&
        _allergySymptomsController.text.isNotEmpty &&
        _allergyDateController.text.isNotEmpty) {
      setState(() {
        _allergies.add({
          'title': _allergyTitleController.text,
          'symptoms': _allergySymptomsController.text,
          'date': _allergyDateController.text,
        });
        _allergyTitleController.clear();
        _allergySymptomsController.clear();
        _allergyDateController.clear();
      });

      _saveData();
    }
  }

  void _deleteAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });

    _saveData();
  }

  void _showVitalInputDialog(String vital) {
    TextEditingController controller;
    String label;
    String hint;

    switch (vital) {
      case 'Blood Pressure':
        controller = _bloodPressureController;
        label = 'Blood Pressure (mm Hg)';
        hint = 'e.g., 120/80';
        break;
      case 'Heart Rate':
        controller = _heartRateController;
        label = 'Heart Rate (bpm)';
        hint = 'e.g., 70';
        break;
      case 'Temperature':
        controller = _temperatureController;
        label = 'Temperature (°C)';
        hint = 'e.g., 36.6';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Your $vital'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: controller,
                    label: label,
                    hint: hint,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _calculateOutcome(vital);
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showAllergyInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Allergy'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: _allergyTitleController,
                  label: 'Allergy Name',
                  hint: 'e.g., Pollen',
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _allergySymptomsController,
                  label: 'Symptoms',
                  hint: 'e.g., Sneezing, runny nose',
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 20),
                _buildTextField(
                  controller: _allergyDateController,
                  label: 'Date',
                  hint: 'e.g., 20 October 2022',
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _addAllergy();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAllergyDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Allergy'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Aligns the content to the left
              children: _allergies.map((allergy) {
                return ListTile(
                  title: Text(allergy['title']!),
                  subtitle: Text(allergy['symptoms']!),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      int index = _allergies.indexOf(allergy);
                      _deleteAllergy(index);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vitals'),
        backgroundColor: Colors.blue[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Vital Signs'),
            _buildCardItem(
              title: 'Blood Pressure',
              icon: Icons.favorite_border,
              onTap: () => _showVitalInputDialog('Blood Pressure'),
            ),
            _buildCardItem(
              title: 'Heart Rate',
              icon: Icons.pause,
              onTap: () => _showVitalInputDialog('Heart Rate'),
            ),
            _buildCardItem(
              title: 'Temperature',
              icon: Icons.thermostat,
              onTap: () => _showVitalInputDialog('Temperature'),
            ),
            if (_outcome.isNotEmpty) ...[
              _buildSectionTitle('Outcome'),
              Card(
                color: Colors.blue[100],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _outcome,
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),
            _buildSectionTitle('Allergies'),
            _buildCardItem(
              title: 'Add Allergy',
              icon: Icons.add,
              onTap: _showAllergyInputDialog,
            ),
            _buildCardItem(
              title: 'View Allergies',
              icon: Icons.list,
              onTap: _showAllergyDeleteDialog,
            ),
            ..._allergies.map((allergy) {
              return Card(
                child: ListTile(
                  title: Text(allergy['title']!),
                  subtitle: Text(allergy['symptoms']!),
                  trailing: Text(allergy['date']!),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Vitals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 1, // Highlight Vitals as the current screen
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
          // Handle other index taps if needed
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.blue[900],
        ),
      ),
    );
  }

  Widget _buildCardItem(
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        title: Text(title),
        leading: Icon(icon, color: Colors.blue[900]),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }
}
