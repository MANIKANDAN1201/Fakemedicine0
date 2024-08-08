import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'myprofile.dart';

class ProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF17395E),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: _fetchUserProfile(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text('Error loading user data');
                    } else if (snapshot.hasData && snapshot.data!.exists) {
                      final Map<String, dynamic> userData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final String? profileImageUrl = userData['profileImage'];

                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage('assets/images/user.JPG')
                                    as ImageProvider,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            userData['name'] ??
                                user?.displayName ??
                                'User Name',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            userData['email'] ??
                                user?.email ??
                                'user@example.com',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      );
                    } else {
                      return const Text('No user data found');
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to MyProfileScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.person),
                  label: const Text('My profile'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/auth');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<DocumentSnapshot> _fetchUserProfile() async {
    final String? uid = user?.uid;
    if (uid != null) {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
    } else {
      throw Exception("User not logged in");
    }
  }
}
