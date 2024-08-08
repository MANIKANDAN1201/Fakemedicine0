import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<MyProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile =
          await _firestore.collection('users').doc(user.uid).get();
      if (userProfile.exists) {
        Map<String, dynamic>? data =
            userProfile.data() as Map<String, dynamic>?;
        setState(() {
          _nameController.text = data?['name'] ?? '';
          _phoneController.text = data?['phone'] ?? '';
          _addressController.text = data?['address'] ?? '';
          _emailController.text = data?['email'] ?? user.email ?? '';
          _profileImageUrl = data?['profileImage'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'email': _emailController.text,
        'profileImage': _profileImageUrl ?? '', // Save the image URL
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _isLoading = true; // Show loading indicator while uploading
      });

      try {
        User? user = _auth.currentUser;
        if (user != null) {
          // Upload the image to Firebase Storage with the specified path
          final storageRef = _storage
              .refFromURL('gs://fakemedicine-3aca1.appspot.com')
              .child('profile_pictures/${user.uid}.jpg');
          await storageRef.putFile(File(image.path));

          // Get the download URL
          final downloadUrl = await storageRef.getDownloadURL();

          // Save the URL in Firestore
          await _firestore
              .collection('users')
              .doc(user.uid)
              .update({'profileImage': downloadUrl});

          setState(() {
            _profileImageUrl = downloadUrl;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Name', _nameController),
              _buildTextField('Phone', _phoneController),
              _buildTextField('Address', _addressController),
              _buildTextField('Email', _emailController),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _saveUserProfile();
                Navigator.of(context).pop();
                setState(() {}); // To refresh the screen with updated values
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : const AssetImage('assets/images/user.JPG')
                              as ImageProvider,
                    ),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Upload Profile Picture'),
                    ),
                    const SizedBox(height: 20),
                    itemProfile(
                        'Name', _nameController.text, CupertinoIcons.person),
                    const SizedBox(height: 10),
                    itemProfile(
                        'Phone', _phoneController.text, CupertinoIcons.phone),
                    const SizedBox(height: 10),
                    itemProfile('Address', _addressController.text,
                        CupertinoIcons.location),
                    const SizedBox(height: 10),
                    itemProfile(
                        'Email', _emailController.text, CupertinoIcons.mail),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _editProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                        ),
                        child: const Text('Edit Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Container itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.deepOrange.withOpacity(.2),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey.shade400),
        tileColor: Colors.white,
      ),
    );
  }
}
